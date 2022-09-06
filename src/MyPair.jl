#=
Module with MyPair, which is a parir of floating point numbers.
=#
import Base.:<, Base.:>, Base.==, Base.isless, Base.show

struct MyPair
    first::Float64
    second::Float64
end

# Basic operators >>>
#
function ==(p1::MyPair, p2::MyPair)
    return p1.first == p2.first && p1.second == p2.second
end

# based on compareMyPairs function
function isless(p1::MyPair, p2::MyPair)
    return <(p1, p2)
end

function <(p1::MyPair, p2::MyPair)
    if p1.first < p2.first
        return true
    end

    if p1.first > p2.first
        return false
    end

    if p1.second > p2.second
        return true
    end

    return false
end

function >(p1::MyPair, p2::MyPair)
    if !(p1 == p2) && !(p1 < p2)
        return true
    else
        return false
    end
end

Base.show(io::IO, p::MyPair) = print(io, "(x=$(p.first),y=$(p.second))")

# Basic operators <<<

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

"""
Compare two structures MyPair with the following logic:
- return true if 's' was born before 'f'
- return false if 'f' was born before 's'
- return true if 's' died before 'f' (this applies when both are born at the same time)
- return false if none of above applies
"""
# TODO add function depreciation; use isless instead
function compareMyPairs(f::MyPair, s::MyPair)::Bool

    if f.first < s.first
        return true
    end

    if f.first > s.first
        return false
    end

    if f.second < s.second
        return true
    end
    return false
end

# ===-===-===-===-
## Untested functions imported form barcodes module
"""
Compute Euclidean distance for a pair of values.

TODO This should be extracted to Point2D related script.
"""
function computeDistanceOfPointsInPlane(p1::MyPair, p2::MyPair)::Float64
    # cerr << "Computing distance of points :(" << p1.first << "," << p1.second << ") and (" << p2.first << "," << p2.second << ")\n";
    # cerr << "Distance :" << sqrt( (p1.first-p2.first)*(p1.first-p2.first) + (p1.second-p2.second)*(p1.second-p2.second) ) << "\n";
    return sqrt((p1.first - p2.first)^2 + (p1.second - p2.second)^2)
end # computeDistanceOfPointsInPlane


"""
Projects point to the diagonal of a cube.

NOTE! This is not verified description.

Creates a new Point2D  which coordinates are average value of input coordinates.
TODO This should be extracted to Point2D related script.
"""
function projectionToDiagonal(p::MyPair)::MyPair
    return MyPair(0.5 * (p.first + p.second), 0.5 * (p.first + p.second))
end

# tested
"""
Check if the barcode 'f' is longer than barcode 's'.

TODO An alternative could be added with just f>s
TODO This should be extracted to Point2D related script.
"""
function compareAccordingToLength(f::MyPair, s::MyPair)::Bool
    l1 = abs(f.second - f.first) #::Float64
    l2 = abs(s.second - s.first) #::Float64
    return (l1 > l2)
end

"""
Boolean check if birth times of 'f' is smaller than birth time of 's'.
"""
function compareForHistograms(f::MyPair, s::MyPair)::Bool
    return f.first < s.first
end

# MyPair <<<
# ===-===-===-

# ===-===-===-
# Import from Landscapes Operations
## Untested functions imported form barcodes module
function comparePairsForMerging(first::MyPair, second::MyPair)
    return (first.first < second.first)
end

# Yet another function to smooth up the data. The idea of this one is as follows. Let us take a landscape point A which is not (+infty,0), (-infty,0) of (a,0), (b,0), where a and b denotes the
# points which support of the function begins and ends. Let B and C will be the landscape points after A. Suppose B and C are also no one as above.
# The question we are asking here is -- can we remove the point B and draw a line from A to C such that the difference in a landscape will be not greater than epsilon?
# To measure the penalty of removing B, the funcion penalty. In below, the simplese example is given:
function penalty(A::MyPair, B::MyPair, C::MyPair)
    return abs(functionValue(A, C, B.first) - B.second)
end# penalty


# ===-===-===-
# Import from Landscapes Construction
function comparePoints2(f::MyPair, s::MyPair)
    if (f.first < s.first)
        return true
    else
        # {//f.first >= s.first
        if (f.first > s.first)
            return false
        else
            # {//f.first == s.first
            if (f.second > s.second)
                return true
            else
                return false
            end # 3rd if
        end # 2nd if
    end #1st if
end # function
