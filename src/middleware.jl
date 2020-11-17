"""
  Middleware

Http request-handling middleware.
"""
module Middleware

using HTTP: Response, Request

using ..Resources
using ..HttpErrors
using ..HttpErrors: HttpError
using ..HttpMethods

export affix_newline, authorize, handle_errors, log_access

# affix_newline

function _affix_newline(handler, req::Request)
  res = handler(req)
  body = String(res.body)
  if !(endswith(body, "\n"))
    res.body = codeunits(body)
    return res
  end
  return res
end

"""
  affix_newline(handler)

Middleware to affix a newline to the end of a response if it doesn't already have one.
"""
affix_newline(handler) = req -> _affix_newline(handler, req)

# handle_errors

function _handle_errors(handler, req::Request)::Response
  try
    return handler(req)
  catch err
    @error exception=(err, catch_backtrace())
    if isa(err, HttpError)
      msg = sprint(showerror, err)
      return Response(err.status, msg)
    else
      return Response(500, "500 Internal Server Error")
    end
  end
end

"""
  handle_errors(handler)

Wraps an api handler with functionality to automatically handle and translate 
application-layer errors into HTTP responses with the appropriate status code.

Returns an api handler, i.e. intended with type
`(Request -> Response) -> (Request -> Response)`.
"""
handle_errors(handler) = req -> _handle_errors(handler, req)

# authorize

function _authorize(handler, req::Request)::Response
  @warn "`authorize` not implemented yet"
  return handler(req)
end

"""
  authorize(handler)

Wraps an api handler with functionality to restrict access to a resource.

Returns an api handler, i.e. intended with type
`(Request -> Response) -> (Request -> Response)`.
"""
authorize(handler) = req -> _authorize(handler, req)

# log_access

function _log_access(handler, req::Request)::Response
  @warn "`log_access` not implemented yet"
  return handler(req)
end

"""
  log_access(handler)

Wraps an api handler with access-logging functionality.

Returns an api handler, i.e. intended with type
`(Request -> Response) -> (Request -> Response)`.
"""
log_access(handler) = req -> _log_access(handler, req)

"""
  Routers

Router middleware.
"""
module Routers

using HTTP: Request
using HTTP.URIs: URI, splitpath

using ..Resources
using ..Resources: Resource, path
using ..HttpErrors: method_not_allowed!, not_found!
using ..HttpMethods: HttpMethod, http_method

# Router
# Because HTTP.@register sucks

const RoutePair = Pair{Resource, HttpMethod}

struct Router
  base_path::AbstractString
  routes::Vector{RoutePair}
end

# route

function _match(template::AbstractString, path::AbstractString) 
  vtemplate = splitpath(template)
  vpath = splitpath(path)
  if length(vtemplate) != length(vpath)
    return false
  end
  return all(
    x -> first(x) == "*" ? true : first(x) == last(x),
    zip(vtemplate, vpath)
  )
end

"""
    route(router::Router, request::HTTP.Request)

Route a `request` through a `router`.
"""
function route(router::Router, req::Request) 
  method = http_method(req.method)
  req_path = req.target |> URI |> x -> x.path

  potential_routes = filter(y -> _match(y |> first |> path, req_path), router.routes)
  if isempty(potential_routes)
    not_found!()
  end

  idx = findfirst(x -> x |> last == method, potential_routes)
  if isnothing(idx)
    method_not_allowed!("$method not allowed for $path")
  end

  @inbounds resource = potential_routes[idx] |> first

  return Resources.handle(method, resource, req)
end

"""
  route(router::Router)

Route requests through a `router`. Throws 404s and 405s when necessary.
"""
route(router::Router) = req -> route(router, req)

end # module Routers

end # module Middleware
