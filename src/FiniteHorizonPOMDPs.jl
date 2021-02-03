module FiniteHorizonPOMDPs

using POMDPs
using POMDPModelTools
using Random: Random, AbstractRNG
using NamedTupleTools: merge

import POMDPs: Policy, action
import Base.Iterators

export
    stage_states,
    stage_stateindex,
    HorizonLength,
    FiniteHorizon,
    InfiniteHorizon,
    horizon

include("interface.jl")

export
    fixhorizon

include("fixhorizon.jl")

export 
    FiniteHorizonPolicy,
    solve,
    action

include("valueiteration.jl")
include("solver.jl")

end
