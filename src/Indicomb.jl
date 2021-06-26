module Indicomb

export get_events_catnum_name

# Write your package code here.

"""
indicomb.py - combs through indico and builds a listing of your meetings for display as a webpage or importing to iCal
"""

using JSON3, HTTP, Dates, SHA
import DataStructures: OrderedDict
import HTTP: escapeuri
import Base.Threads: @threads

_format_dt(dt) = Dates.format(dt, dateformat"y-m-d")

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

Build a path?params url object (without the base domain). The key feature is to construct `signature=` query
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
function sha1_hmac(key, data)
    h = HMAC_CTX(SHA1_CTX(), Vector{UInt8}(key))
    update!(h, Vector{UInt8}(data))
    return digest!(h)
end

end
