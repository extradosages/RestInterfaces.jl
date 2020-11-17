module Util

using HTTP: Request, payload, queryparams
using HTTP.URIs: URI, splitpath
using JSON3

export json_payload, query_parameters, uri_parameter

# json_payload

"""
    json_payload(req::Request)::JSON3.Object

Retrieve the json payload from a request.
"""
json_payload(req::Request) = req |> payload |> IOBuffer |> JSON3.read

# query_parameters

"""
    query_parameters(req::Request)::Dict{String, String}

Retrieve the parameters encoded in the querystring from the request.
"""
query_parameters(req::Request) = req.target |> URI |> queryparams

# uri_parameter

"""
    uri_parameter(req::Request, segment_idx::Int)::String

Retrieve a uri parameter from a request.
"""
uri_parameter(req::Request, segment_idx::Int) = splitpath(req.target) |> x -> x[segment_idx]

end
