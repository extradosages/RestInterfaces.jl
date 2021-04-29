"""
  RestInterfaces

Library for building REST APIs.
"""
module RestInterfaces

include("./HttpErrors.jl")
include("./HttpMethods.jl")
include("./Resources.jl")
include("./Middleware.jl")
include("./Utils.jl")

end # module Rest
