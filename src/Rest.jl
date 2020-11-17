"""
  Rest

Library for building REST APIs.
"""
module Rest

include("./http-errors.jl")
include("./http-methods.jl")
include("./resources.jl")
include("./middleware.jl")
include("./util.jl")

end # module Rest
