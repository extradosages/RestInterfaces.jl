"""
  HttpMethods

Http method types.
"""
module HttpMethods

export HttpMethod,
  Get,
  Post,
  Put,
  Patch,
  Delete

const _get = "GET"
const _post = "POST"
const _put = "PUT"
const _patch = "PATCH"
const _delete = "DELETE"

"""
  HttpMethod

Abstract type representing HTTP methods.
"""
abstract type HttpMethod end

Base.show(io::IO, x::HttpMethod) = write(io, string(x))

# http_method

"""
  http_method(::String)

Return type corresponding to string.
"""

function http_method(str::String)::HttpMethod
  cleaned = str |> strip |> uppercase
  if cleaned == _get
    return Get()
  elseif cleaned == _post
    return Post()
  elseif cleaned == _put
    return Put()
  elseif cleaned == _patch
    return Patch()
  elseif cleaned == _delete
    return Delete()
  end
end

# Get

struct Get <: HttpMethod end

Base.string(::Get) = "GET"

# Post

struct Post <: HttpMethod end

Base.string(::Post) = "POST"

# Put

struct Put <: HttpMethod end

Base.string(::Put) = "PUT"

# Patch

struct Patch <: HttpMethod end

Base.string(::Patch) = "PATCH"

# Delete

struct Delete <: HttpMethod end

Base.string(::Delete) = "DELETE"

end # module HttpMethods
