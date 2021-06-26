module Indicomb

# Write your package code here.

"""
indicomb.py - combs through indico and builds a listing of your meetings for display as a webpage or importing to iCal
"""


using JSON3, HTTP, Dates, SHA
import DataStructures: OrderedDict
import HTTP: escapeuri

# performe a one-time update and then return digest
function sha1_hmac(key, data)
    h = HMAC_CTX(SHA1_CTX(), Vector{UInt8}(key))
    update!(h, Vector{UInt8}(data))
    digest!(h)
end

"""
    indico_request(path; params...)

Build a path?params url object (without the base domain). The key feature is to construct `signature=` query
based on the SHA1 HMAC algo. The construction of `signature` only cares about path, not base-site domain.
"""
function indico_request(path; params...)
    d = OrderedDict{Symbol, Any}(params) # don't care about performance
    if :secret_key ∈ keys(d)
        # key is `secret_key` and data is entire url except signature=
        _now = Dates.value(now(UTC)) - Dates.UNIXEPOCH
        d[:timestamp] = _now ÷ 1000# ms -> s
        sort!(d)
        temp_url = "$path?$(escapeuri(d))"
        sig = bytes2hex(sha1_hmac(d[:secret_key], temp_url))
        d[:signature] = sig
    end
    "$path?$(escapeuri(d))"
end

function get_indico_page(baseurl, path; params...)
    _u = "$baseurl$(indico_request(path; params...))"
    HTTP.get(_u)
end


end
