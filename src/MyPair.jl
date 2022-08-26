#=
Module with MyPair, which is a parir of floating point numbers.
=#
import Base.:<, Base.:>, Base.==, Base.isless

# tested
struct MyPair
    first::Float64
    second::Float64
end

# based on compareMyPairs function
function isless(p1::MyPair, p2::MyPair)
    return <(p1, p2)
end

function <(p1::MyPair, p2::MyPair)
    if p1.first < p2.first
        return true
    elseif p1.first == p2.first
        if p1.second < p2.second
            return true
        end
    else
        return false
    end
end

function >(p1::MyPair, p2::MyPair)
    if p1.first > p2.first
        return true
    elseif p1.first == p2.first
        if p1.second > p2.second
            return true
        end
    else
        return false
    end
end


function ==(p1::MyPair, p2::MyPair)
    return p1.first == p2.first && p1.second == p2.second
end

# tested
function make_MyPair(val1, val2)
    return MyPair(val1, val2)
end

function birth(a::MyPair)
    return a.first - a.second
end

function death(a::MyPair)
    return a.first + a.second
end

# function used in computeValueAtAGivenPoint
# We assume here, that x \in \[ p1.first, p2.first \] and p1 and p2 are points
# between which we will put the line segment.
"""
Assuming that `p1` and `p2` are points of a line, compute the value of the
function that crosses both points at the position `x`.

"""
function functionValue(p1::MyPair, p2::MyPair, x::Float64)
    if p2.first == p1.first && p2.second == p1.second
        ArgumentError(
            "Points can not be equal (can not deifne function with 2 points that are equal).",
        ) |> throw
    elseif p2.first == p1.first
        ArgumentError("Ponints should have different x values.") |> throw
    end
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first

    return (a * x + b)
end

# TODO rename to getLineZeroCrossing
function findZeroOfALineSegmentBetweenThoseTwoPoints(p1::MyPair, p2::MyPair)
    # TODO Investigate: This function returns Nan if both of the y values in p1 and p2 are 0
    if p1.first == p2.first
        return p1.first
    end
    if p1.second * p2.second > 0
        error(
            "In function findZeroOfALineSegmentBetweenThoseTwoPoints the agguments are: ($(p1.first)),$(p1.second)) and ($(p2.first), $(p2.second)). There is no zero in line between those two points. Program terminated.",
        )
    end

    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    # println("Line crossing points : ($(p1.first << ",$(p1.second)) oraz (" << p2.first) $(p2.second)) :")")
    # println("a : $(a) $(b) , x : $(x)")
    return -b / a
end

function computeParametersOfALine(p1::MyPair, p2::MyPair)
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    return MyPair(a, b)
end
