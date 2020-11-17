"""
  HttpErrors

Http-themed errors. Very sexy.

At present this module doesn't implement all the errors indicated in
https://tools.ietf.org/html/rfc7231. That's because I haven't needed
them yet. You're encouraged to submit a pull request.
"""
module HttpErrors

export Content,
  HttpError,
  bad_request!,
  unauthorized!,
  forbidden!,
  not_found!,
  method_not_allowed!,
  conflict!,
  im_a_teapot!,
  unprocessable_entity!,
  internal_server_error!,
  not_implemented!

# HTTPError

"""
    Content

`HttpError` content-type. Alias for `Union{String, Exception, Nothing`.
"""
const Content = Union{String, Exception, Nothing}

"""
    HttpError

Http-themed error.

While nothing's stopping you from building one of these yourself, the value proposition of
this module comes from using the constructors (e.g. `bad_request!`, `not_found!`, &c.).

Instances come with fields `status::Int`, `name::String`, and `content::Content`.
"""
struct HttpError <: Exception
  status::Int
  name::String
  content::String
end

"""
    HttpError(status::Int, name::String, ::Nothing)

Produce an `HttpError` with no content.
"""
HttpError(status::Int, name::String, ::Nothing) = HttpError(status, name, "")

"""
    HttpError(status::Int, name::String, err::Exception)

Produce an `HttpError` with a serialized `err` as its content.
"""
HttpError(status::Int, name::String, err::Exception) =
  HttpError(status, name, sprint(showerror, err))


Base.showerror(io::IO, e::HttpError) = string(
  "$(e.status) $(e.name)",
  isempty(e.content) ? "" : " - $(e.content)"
) |> x -> write(io, x)

# bad_request!

"""
    bad_request!(content=nothing::Content)

400

The server cannot or will not process the request due to something that is perceived to
be a client error (e.g., malformed request syntax, invalid request content framing, or 
deceptive request routing).
"""
bad_request!(content=nothing::Content) =
  HttpError(400, "Bad Request", content) |> throw

# unauthorized!

"""
  unauthorized!(content=nothing::Content)

401

The request has not been applied because it lacks valid authentication credentials 
for the target resource.
"""
unauthorized!(content=nothing::Content) =
  HttpError(401, "Unauthorized", content) |> throw

# forbidden!

"""
  forbidden!(content=nothing::Content)

403

The server understood the request but refuses to authorize it.
"""
forbidden!(content=nothing::Content) =
  HttpError(403, "Forbidden", content) |> throw

# not_found!

"""
  not_found!(content=nothing::Content)

404

The origin server did not find a current representation for the target resource or is
not willing to disclose that one exists.
"""
not_found!(content=nothing::Content) =
  HttpError(404, "Not Found", content) |> throw

# method_not_allowed!

"""
  method_not_allowed!(content=nothing::Content)

405

The method received in the request-line is known by the origin server but not supported
by the target resource.
"""
method_not_allowed!(content=nothing::Content) =
  HttpError(405, "Method Not Allowed", content) |> throw

# conflict!

"""
  conflict!(content=nothing::Content)

409

The request could not be completed due to a conflict with the current state of the target
resource. This code is used in situations where the user might be able to resolve the
conflict and resubmit the request.
"""
conflict!(content=nothing::Content) =
  HttpError(409, "Conflict", content) |> throw

# im_a_teapot!

"""
  im_a_teapot!(content=nothing::Content)

418

Any attempt to brew coffee with a teapot should result in the error code "418 I'm a
teapot". The resulting entity body MAY be short and stout.
"""
im_a_teapot!(content=nothing::Content) =
  HttpError(418, "I'm A Teapot", content) |> throw

# unprocessable_entity!

"""
  unprocessable_entity!(content=nothing::Content)

422

The server understands the content type of the request entity (hence a 415
Unsupported Media Type status code is inappropriate), and the syntax of the request
entity is correct (thus a 400 Bad Request status code is inappropriate) but was
unable to process the contained instructions.
"""
unprocessable_entity!(content=nothing::Content) =
  HttpError(422, "Unprocessable Entity", content) |> throw

# internal_server_error!

"""
  internal_server_error!(content=nothing::Content)

500

The server encountered an unexpected condition that prevented it from fulfilling the
request.
"""
internal_server_error!(content=nothing::Content) =
  HttpError(500, "Internal Server Error", content) |> throw

# not_implemented!

"""
  not_implemented!(content=nothing::Content)

501

The server does not support the functionality required to fulfill the request.
"""
not_implemented!(content=nothing::Content) =
  HttpError(501, "Not Implemented", content) |> throw

end
