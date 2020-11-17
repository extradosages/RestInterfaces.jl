# Rest.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

## Overview
This is a Julia library for implementing basic REST APIs. It was created to provide a style of programming these APIs that felt idiomatic to Julia.

This library sits on-top of the venerable [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl).

## A Minimal Example
The following is an example of a minimal Hello, World server.

```julia
using HTTP
using Rest.HttpMethods: Get
using Rest.Middleware.Routers: Router, route
using Rest.Resources
using Rest.Resources: Resource
using Rest.Util: json_payload, query_parameters

# Implement the `Resource` interface by subtyping `Resource` and implementing specialized
# methods for `path`, `deserialize`, `process`, and `serialize`.
# = Hello

struct Hello <: Resource end

# Mutable state
default_name = "World"

# Post

Resources.deserialize(::Post, ::Hello, req) = json_payload(req) |>
  x -> x[:name]

function Resources.process(::Post, ::Hello, name::String)
  global default_name
  default_name = name
  return nothing
end

Resources.serialize(::Post, ::Hello, ::Nothing) = HTTP.Response(201);

# Get

function Resources.deserialize(::Get, ::Hello, req)
      global default_name
      return query_parameters(req) |>
        x -> get(x, "name", default_name)
end

Resources.process(::Get, ::Hello, name::String) = "Hello, $(name)!"

Resources.serialize(::Get, ::Hello, greeting::String) = HTTP.Response(200, greeting)

# =
# Extend this method so that the router can match requests to this resource
Resources.path(::Hello) = "/hello"

# Build a router which register routes and will convert Requests into the app domain
router = Router(
  "/",
  [
    Hello() => Post(), 
    Hello() => Get()
  ]
)

# Serve on localhost:8081
router |> route |> HTTP.serve
```

Then you'll see, in another thread, by the majesty of science...
```bash
bash-3.2$ curl "localhost:8081/hello"
Hello, World!
bash-3.2$ curl "localhost:8081/hello?name=Boston"
Hello, Boston!
bash-3.2$
```
## Alternatives

- [Mux.jl](https://github.com/JuliaWeb/Mux.jl) is a lightweight layer on top of HTTP.jl that can be used to accomplish the same things that Rest can accomplish. It is more general and more mature than Rest is, but I am personally not a fan of the API.
