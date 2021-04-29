"""
  Resources

Server resource abstractions.
"""
module Resources

using HTTP
using HTTP: Response, Request, Router

using ..HttpErrors: HttpError, bad_request, internal_server_error, method_not_allowed
using ..HttpMethods: HttpMethod
using ..HttpMethods

export DeserializeError, Resource, deserialize, process, serialize, handle, handler

"""
    Resource Interface

Abstract type respresenting a resource.

# Implementation
Given `S <: HttpMethod`, an abstract type `T <: Resource` which implements this
interface *must* implement the following methods:
- `deserialize(::S, ::T, req::Request)::U`
- `process(::S, ::T, data::U)::V`
- `serialize(::S, ::T, data::V)::Response`
(mathematically, `U`, `V` are intended to represent type varables bound consistently
across all three methods, although this is informal notation here, and there are no 
formal enforcements of this principle).

Implementing the first three methods will enable users to use the function
`handle(::S, ::T, req::Request)` which serially invokes `deserialize`, `process`,
and then `serialize`, wrapping each in a small layer of extra logic.

The function given by `handler(::S, ::T)` serially invokes `deserialize`, `process`,
and then `serialize`.

Note that Julia will not throw a compile-time error if the `Resource` interface is
only partially implemented; it is up to the programmer to ensure that resources are
completely written if they want to make use of `handler`.

This issue may be solved in the future by an resource interface DSL, i.e. macro.

If one wants to register a resource and method with a `Rest.Middleware.Routers.Router`
instance, then one needs to additionally implement `path(::T)`, which specifies the
path at which a resource resides.
"""
abstract type Resource end

# DeserializeError

"""
    DeserializeError

Error to throw during deserialization.
"""
struct DeserializeError <: Exception end

# path

"""
    path(::Resource)

Specifiy the path at which a resource resides.
"""
function path end

# deserialize

"""
    deserialize(method::HttpMethod, resource::Resource, req::Request)

Deserialize an API request.

The result will be piped into `x -> API.process(method, resource, x)` for processing and
then subsequently into `x -> API.serialize(method, resource, x)` for serialization into a
response which will be returned to the client.

Throwing `API.DeserializeError` inside of `deserialize` will interrupt request handling
and send a 400-code response to the client. Any other error will send a 500-code
response to the client.
"""
function deserialize end

# process

"""
    process(method::HttpMethod, resource::Resource, data)

Process data in the handling an API request.

The result will be piped into `x -> API.serialize(method, resource, x)` for serialization into a
response which will be returned to the client.

Any error thrown in `process` will interrupt request handling and send a 500-code
response to the client.
"""
function process end

# serialize

"""
    serialize(method::HttpMethod, resource::Resource, data)::HTTP.Response

Serialize an object into an HTTP response.

Any error thrown in `serialize` will interrupt request handling and send a 500-code
response to the client.
"""
function serialize end

# handler

"""
    handle(method::HttpMethod, resource::Resource, req::Request)

Handle an `HTTP.Request` for `resource` using `method`.
"""
function handle(method::HttpMethod, resource::Resource, req::Request)
  req_data = try
    deserialize(method, resource, req)
  catch err
    # TODO: Determine if DeserializeError is useful
    """
    if isa(err, DeserializeError)
      bad_request(err.msg)
    elseif isa(err, HttpError) 
      rethrow(err)
    else
      sprint(showerror, err) |> internal_server_error
    end
    """
    if isa(err, HttpError)
      rethrow(err)
    else
      sprint(showerror, err) |> bad_request
    end
  end
  
  proc_result = try
    process(method, resource, req_data)
  catch err
    if isa(err, HttpError)
      rethrow(err)
    else
      sprint(showerror, err) |> internal_server_error
    end
  end

  try
    response = serialize(method, resource, proc_result)

    if !isa(response, Response)
      internal_server_error(
        "Serialization did not produce an `HTTP.Response`; check method implementation"
      )
    end

    return response
  catch err
    if isa(err, HttpError)
      rethrow(err)
    else
      sprint(showerror, err) |> internal_server_error
    end
  end
end

"""
    handler(::HttpMethod, ::Resource)

Produce a function which handles an `HTTP.Request` for a resource, given a method.
"""
handler(method::HttpMethod, resource::Resource) = (req -> handle(method, resource, req))

end # module Api
