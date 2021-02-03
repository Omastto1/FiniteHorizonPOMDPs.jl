# Finite Horizon algorithm evaluating problem with use of other POMDP algorithms
# User has to define (PO)MDP instance with use of POMDPs interface methods isterminal, reward, actions, states, stateindex, actions, actionindex, discount, transition

# For example see problems defined in POMDPModels package or FiniteHorizonPOMDP/test/instances/1DFiniteHorizonGridWorld.jl
#
# Currently supporting: ValueIterationSolver
#
# Possible future improvements: Change arrays from row oriented to column oriented
#                               Create fixhorizon(m::Union{MDP,POMDP}, T::Int) utility


# Policy struct created according to one used in DiscreteValueIteration
mutable struct FiniteHorizonValuePolicy{Q<:AbstractArray, U<:AbstractMatrix, P<:AbstractMatrix, A, M<:MDP} <: Policy
    qmat::Q
    util::U 
    policy::P 
    action_map::Vector{A}
    include_Q::Bool 
    mdp::M
end

# Policy constructor
function FiniteHorizonValuePolicy(mdp::MDP)
    return FiniteHorizonValuePolicy(zeros(mdp.horizon, mdp.no_states, length(mdp.actions)), zeros(mdp.horizon, mdp.no_states), ones(Int64, mdp.horizon, mdp.no_states), ordered_actions(mdp), true, mdp)
end

function action(policy::FiniteHorizonValuePolicy, s::S) where S
    sidx = stateindex(policy.w, s)
    aidx = policy.policy'[sidx]
    return policy.action_map[aidx]
end

"""
    addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)

Store record for given stage results to `FiniteHorizonPolicy` and return updated version.
"""
function addstagerecord(fhpolicy::FiniteHorizonValuePolicy, qmat, util, policy, stage)    
    fhpolicy.qmat[stage, :, :] = qmat
    fhpolicy.util[stage, :] = util
    fhpolicy.policy[stage, :] = policy
    return fhpolicy
end

# In order to run Infinite Horizon MDPs one has to implement these functions
# User has to implement these fuctions in such a way that the function returns current epoch and the following one (the one that has already been evaluated)
function stage_states(mdp::MDP, epoch::Int64) end

function stage_stateindex(mdp::MDP, s, epoch::Int64) end

# Global variable for storing number of epoch in order to pass it to functions from outer solvers
# Is there a better way to achieve this?
fhepoch = -1


# Is it possible to change name of this function to solve?
# The problem is that I am not able to use for example DiscreteValueIteration.solve() as I do not know the Solver in advance

# MDP given horizon 5 assumes that agent can move 4 times
function solve(mdp::MDP; verbose::Bool=false, new_VI::Bool=true)
    fhpolicy = FiniteHorizonValuePolicy(mdp)
    util = fill(0., mdp.no_states)

    for stage=w.horizon:-1:1
        if verbose
            println("Stage: $stage")
        end

        stage_q, util, pol = valueiterationsolver(mdp, epoch, util)

        fhpolicy = addstagerecord(fhpolicy, stage_q, util, pol, stage)

        if verbose
            println("POLICY\n")
            println("QMAT")
            println(stage_q)
            println("util")
            println(util)
            println("policy")
            println(policy)
            # println("action_map")
            # println(policy.action_map)
            # println("include_Q")
            # println(policy.include_Q)
            # println("mdp")
            # println(policy.mdp)
            println("\n\n\n")
        end
    end

    return fhpolicy
end