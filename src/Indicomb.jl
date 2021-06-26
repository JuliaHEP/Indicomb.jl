module Indicomb

export get_events_catnum_name

using JSON3, HTTP, Dates, SHA
import DataStructures: OrderedDict
import HTTP: escapeuri
import Base.Threads: @threads

_format_dt(dt) = Dates.format(dt, dateformat"y-m-d")

"""
    get_events_catnum_name(baseurl, cat_num, evt_name; params...)

Main API for basic users, given base url (Indico server domain), category number and event title filter,
return a list of (`detail=subcontributions`) events JSON object.

# Example
```
julia> get_events_catnum_name("https://indico.cern.ch", 1X3X, "XXXXX"; from="2021-06-10", to="2021-06-30", apikey=".....", secretkey="....");
JSON3.Object{Vector{UInt8}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}} with 29 entries:
  :_type            => "Conference"
  :id               => "10521XX"
  :title            => "XXXXX group meeting"
  :description      => ""
  :startDate        => {…
  :timezone         => "Europe/Zurich"
  :endDate          => {…
  :room             => ""
  :location         => ""
  :address          => ""
  ...
```

"""
function get_events_catnum_name(
    baseurl,
    cat_num,
    evt_name;
    params...,
)

    # get category JSON which has events in simplr form
    cat = get_indico_page(baseurl, "/export/categ/$cat_num.json"; params...)
    simple_evts = filter_events(evt_name, cat)
    res = Vector{JSON3.Object}(undef, length(simple_evts))

    # add event specific headers to into original `params` to get full info
    detail_params = (pretty="yes", detail="subcontributions", params...)
    @threads for idx in eachindex(simple_evts)
        id = simple_evts[idx][:id]
        evt = get_indico_page(baseurl, "/export/event/$id.json"; detail_params...)
        # stupid Indico always return bloated/nested JSON, unpact here!
        res[idx] = only(evt[:results]) #`only` because we're quering a single event
    end
    return res
end
"""
    indico_request(path; params...)

Build a `path?params` url object (without the base domain). The key feature is to construct `signature=` query
based on the SHA1 HMAC algo. The construction of `signature` only cares about path, not base-site domain.
"""
function indico_request(path; params...)
    d = OrderedDict{Symbol,Any}(params) # don't care about performance
    if :secretkey ∈ keys(d)
        # key is `secret_key` and data is entire url except signature=
        _now = Dates.value(now(UTC)) - Dates.UNIXEPOCH
        d[:timestamp] = _now ÷ 1000# ms -> s
        sort!(d)
        temp_url = "$path?$(escapeuri(d))"
        sig = bytes2hex(sha1_hmac(d[:secretkey], temp_url))
        d[:signature] = sig
    end
    return "$path?$(escapeuri(d))"
end

function get_indico_page(baseurl, path; params...)
    _u = "$baseurl$(indico_request(path; params...))"
    return JSON3.read(HTTP.get(_u).body)
end

function filter_events(f::Function, category)
    return filter(f, category[:results])
end

function filter_events(title_name::Union{AbstractString,Regex}, category)
    return filter_events(x -> contains(x[:title], title_name), category)
end

# performe a one-time update and then return digest
"""
    sha1_hmac(key, data)
Return a 1-cycle daupted `digest` given key and data.

# Example
```
julia> bytes2hex(Indicomb.sha1_hmac("123", "Julia"))
"eca18118a715a32ab5f340f57d917c1e2eec96f5"
```
!!! note
    Indico uses *sorted*, query parameters as data. i.e.:

    Given: `"https://cern.ch/export/categ/1135.json?from=2020&apikey=8"`, `data` into this function will be
    `"apikey=8&from=2020"` (string from comes from `HTTP.escapeuri`).
"""
function sha1_hmac(key, data)
    h = HMAC_CTX(SHA1_CTX(), Vector{UInt8}(key))
    update!(h, Vector{UInt8}(data))
    return digest!(h)
end

end
