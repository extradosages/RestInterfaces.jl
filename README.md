# Rest.jl

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

## Overview
This is a lightweight Julia library for implementing basic REST APIs. It was created to provide a means of programming these APIs that felt Julia-idiomatic.

This library sits on-top of the venerable [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl).

## An Example
The following is an example of a small Hello, World! server.

```julia
using HTTP
# HTTP Error-themed exceptions can be found here; these acheive a special synergy
# with the error-handling middleware we're using below
using Rest.HttpErrors: unprocessable_entity!
# As one might have guessed, abstractions over HTTP Methods
using Rest.HttpMethods: Get, Post
# Several pre-made middleware functions can be found here
# This one converts HttpErrors into Http.Responses
using Rest.Middleware: handle_errors
# Composable routers with minimal pattern-matching facilities
using Rest.Middleware.Routers: Router, route
# Resource abstractions
using Rest.Resources
# THE Resource abstraction
using Rest.Resources: Resource
# Utilities for extracting information from HTTP.Requests
using Rest.Util: json_payload, query_parameters

# Mutable state-- a fake backend
default_name = "World"

## `Hello` resource

# Implement the `Resource` interface by subtyping `Resource` and extending
# `deserialize`, `process`, and `serialize` for the and HttpMethod and
# the specialized resource type
struct Hello <: Resource end

# Post

Resources.deserialize(::Post, ::Hello, req) = json_payload(req) |> x -> x[:name]

function Resources.process(::Post, ::Hello, name::String)
  global default_name
  default_name = name
  return nothing
end

Resources.serialize(::Post, ::Hello, ::Nothing) = HTTP.Response(201);

# Get

function Resources.deserialize(::Get, ::Hello, req)
  global default_name
  return query_parameters(req) |> x -> get(x, "name", default_name)
end

function Resources.process(::Get, ::Hello, name::String)
  if name === "Tokyo"
    unprocessable_entity!("Cannot greet Tokyo; ignorant of Japanese\n")
  end
  if name === "Tbilisi"
    return "გამარჯობა, თბილისი!"
  end
  return "Hello, $(name)!\n"
end

Resources.serialize(::Get, ::Hello, greeting::String) = HTTP.Response(200, greeting)

## Server

# Extend this method so that the router can match requests to this resource
Resources.path(::Hello) = "/hello"

# Register routes to a router
router = Router(
  "",
  [
    Hello() => Post(), 
    Hello() => Get(),
  ]
)

# Stack middleware and serve on localhost:8081
route(router) |> handle_errors |> HTTP.serve
```

A client might then see something like...
```bash
$ curl -i -X GET "localhost:8081/hello"
HTTP/1.1 200 OK
Transfer-Encoding: chunked

Hello, World!
$ curl -i -X POST --data '{"name":"Boston"}' "localhost:8081/hello"
HTTP/1.1 201 Created
Transfer-Encoding: chunked

$ curl "localhost:8081/hello"
Hello, Boston!
$ curl "localhost:8081/hello?name=Lagos"
Hello, Lagos!
$ curl "localhost:8081/hello?name=Tbilisi"
გამარჯობა, თბილისი!
$ curl -i "localhost:8081/hello?name=Tokyo"
HTTP/1.1 422 Unprocessable Entity
Transfer-Encoding: chunked

422 Unprocessable Entity - Cannot greet Tokyo; ignorant of Japanese
$ curl -i -X DELETE "localhost:8081/hello"
HTTP/1.1 405 Method Not Allowed
Transfer-Encoding: chunked

405 Method Not Allowed - DELETE not allowed for path
```
## Alternatives

- [Mux.jl](https://github.com/JuliaWeb/Mux.jl) is a lightweight layer on top of HTTP.jl that can be used to accomplish the same things that Rest.jl can accomplish. It is more general and more mature than Rest.jl is, but I am personally not a fan of the API.
