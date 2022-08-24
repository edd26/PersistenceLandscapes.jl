#=     Copyright 2013-2014 University of Pennsylvania
#     Copyright 2020-2022 University of Hertfordshire
#     C version created by Pawel Dlotko; Julia version created by Emil Dmitruk
#
#     This file is part of Persistence Landscape Toolbox (PLT).
#
#     PLT is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     PLT is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with PLT.  If not, see <http:# www.gnu.org/licenses/>.
=#
# TODO Add MyPair module

#include "Configure.h"
# include("PersistenceBarcode.jl")

using Plots
using Eirene

import Base.:+, Base.:-, Base.:*, Base.:/, Base.==

struct PersistenceLandscape
    land::Vector{Vector{MyPair}} # for empty one use a = Vector{Vector{MyPair}}()
    # land is a sorted list L_k of the points (x, lambda_k(x))
    dimension::UInt

    # ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
    # Constructors >>>
    function PersistenceLandscape(landscapePointsWithoutInfinities::Vector{Vector{MyPair}})
        land = get_landscape_form_vectors(landscapePointsWithoutInfinities)
        new(land, 0)
    end

    function PersistenceLandscape(landscapePointsWithoutInfinities::Vector{Vector{MyPair}}, dim::Number)
        land = get_landscape_form_vectors(landscapePointsWithoutInfinities)
        new(land, dim)
    end

    # function PersistenceLandscape(p::PersistenceBarcodes; dbg = false)
    function PersistenceLandscape(p::PersistenceBarcodes; dbg=false)
        land = create_PersistenceLandscape(p; dbg=dbg)
        new(land, p.dimensionOfBarcode)
    end

    function PersistenceLandscape(p::PersistenceBarcodes, dim::Number; dbg=false)
        land = create_PersistenceLandscape(p; dbg=dbg)
        new(land, dim)
    end
end

function get_landscape_form_vectors(landscapePointsWithoutInfinities::Vector{Vector{MyPair}})
    land = Vector{Vector{MyPair}}()
    for level = 1:size(landscapePointsWithoutInfinities, 1)
        v = landscapePointsWithoutInfinities[level]
        if allow_inf_intervals
            if !(make_MyPair(-Inf, 0) in v)
                v = vcat(make_MyPair(-Inf, 0), v)
            end
            if !(make_MyPair(Inf, 0) in v)
                v = vcat(v, make_MyPair(Inf, 0))
            end
        end
        push!(land, v)
    end
    return land
end

function create_PersistenceLandscape(p::PersistenceBarcodes; dbg=false)
    dbg && println("PersistenceLandscape(PersistenceBarcodes& p )")

    # land = Any[]
    land = Vector{Vector{MyPair}}()
    if !useGridInComputations
        dbg && println("PL version")
        # this is a general algorithm to construct persistence landscapes.
        sorted_bars = sort(p.barcodes)
        bars = sorted_bars

        # bars.insert( bars.begin() , p.barcodes.begin() , p.barcodes.end() )
        # sort( bars.begin() , bars.end() , comparePoints2 )

        if (dbg)
            println("Bars :")
            for i = 0:size(bars, 1)
                println("$(bars[i])")
            end
        end

        characteristicPoints = MyPair[]
        for i = 1:size(bars, 1)
            p_beg = (bars[i].first + bars[i].second) / 2
            p_end = (bars[i].second - bars[i].first) / 2
            new_pair = MyPair(p_beg, p_end)

            push!(characteristicPoints, new_pair)
        end

        persistenceLandscape = MyPair[]
        while (!isempty(characteristicPoints))
            # for (index, points_pair) in enumerate(characteristicPoints)
            if (dbg)
                for i = 1:size(characteristicPoints, 1)
                    println("($(characteristicPoints[i]))")
                end
            end
            lambda_n = MyPair[]
            if allow_inf_intervals
                push!(lambda_n, make_MyPair(-Inf, 0))
            end

            # TODO this has to be here for creation of PL not to crash on firt iteration
            push!(lambda_n, make_MyPair(birth(characteristicPoints[1]), 0))
            push!(lambda_n, characteristicPoints[1])

            dbg && println("1 Adding to lambda_n : ($(make_MyPair( INT_MIN , 0 ))) , ($(std::make_MyPair(birth(characteristicPoints[1]),0)) $(characteristicPoints[1])))")

            i = 2
            @debug "New char points"
            newCharacteristicPoints = MyPair[]
            while (i <= size(characteristicPoints, 1))
                @debug "running for i: $(i) and size of char points $(size(characteristicPoints, 1)+1)"
                p = 1
                last_lambda_n = size(lambda_n, 1)
                if (birth(characteristicPoints[i]) >= birth(lambda_n[last_lambda_n])) &&
                   (death(characteristicPoints[i]) > death(lambda_n[last_lambda_n]))

                    if birth(characteristicPoints[i]) < death(lambda_n[last_lambda_n])
                        p_start = (birth(characteristicPoints[i]) + death(lambda_n[last_lambda_n])) / 2
                        p_stop = (death(lambda_n[last_lambda_n]) - birth(characteristicPoints[i])) / 2

                        point = MyPair(p_start, p_stop)
                        push!(lambda_n, point)

                        dbg && println("2 Adding to lambda_n : ($(point))")
                        if dbg
                            println("comparePoints(point,characteristicPoints[i+p]) : $(comparePoints(point,characteristicPoints[i+p]))")
                            println("characteristicPoints[i+p] : $(characteristicPoints[i+p])")
                            println("point : $(point)")
                        end

                        while (
                            (i + p < size(characteristicPoints, 1)) &&
                            (almostEqual(birth(point), birth(characteristicPoints[i+p]))) &&
                            (death(point) <= death(characteristicPoints[i+p]))
                        )
                            push!(newCharacteristicPoints, characteristicPoints[i+p])
                            dbg && println("3.5 Adding to newCharacteristicPoints : ($(characteristicPoints[i+p]))")
                            p += 1
                        end
                        push!(newCharacteristicPoints, point)

                        dbg && println("4 Adding to newCharacteristicPoints : ($(point))")
                        while (
                            (i + p < size(characteristicPoints, 1)) &&
                            (birth(point) <= birth(characteristicPoints[i+p])) &&
                            (death(point) >= death(characteristicPoints[i+p]))
                        )
                            push!(newCharacteristicPoints, characteristicPoints[i+p])
                            if (dbg)
                                println("characteristicPoints[i+p] : $(characteristicPoints[i+p])")
                                println("point : $(point)")
                                println("comparePoints(point,characteristicPoints[i+p]) : $(comparePoints(point,characteristicPoints[i+p]))")
                                println("characteristicPoints[i+p] birth and death : $(birth(characteristicPoints[i+p])) $(death(characteristicPoints[i+p]))")
                                println("point birth and death : $(birth(point)) $(death(point))")
                                println("3 Adding to newCharacteristicPoints : ($(characteristicPoints[i+p]))")
                                # getchar()
                            end
                            p += 1
                        end
                    else
                        pair1 = make_MyPair(death(lambda_n[size(lambda_n, 1)]), 0)
                        pair2 = make_MyPair(birth(characteristicPoints[i]), 0)
                        push!(lambda_n, pair1)
                        push!(lambda_n, pair2)
                        if (dbg)
                            println("5 Adding to lambda_n:size(($(pair1)))")
                            println("5 Adding to lambda_n : ($(pair2))")
                        end
                    end
                    push!(lambda_n, characteristicPoints[i])
                    dbg && println("6 Adding to lambda_n : ($(characteristicPoints[i]))")
                else
                    push!(newCharacteristicPoints, characteristicPoints[i])
                    dbg && println("7 Adding to newCharacteristicPoints : ($(characteristicPoints[i]))")
                end
                i = i + p
            end
            # This is necessary for this structure of code to work, especially, when inf intervals are disabled
            push!(lambda_n, make_MyPair(death(lambda_n[size(lambda_n, 1)]), 0))
            if allow_inf_intervals
                push!(lambda_n, make_MyPair(Inf, 0))
            end
            # CHANGE
            characteristicPoints = newCharacteristicPoints

            # is this supposed to erase unique elements, or leave only unique elements?
            # # This leaves only unique element in a
            # a = unique(lambda_n.begin(), lambda_n.end())
            # # Erase removes elements given in the brackets
            # lambda_n.erase(a, lambda_n.end())

            # leave only the non-unique elements (???)
            # lambda_n = filter(unique(lambda_n.begin(), lambda_n.end()), lambda_n.end())
            lambda_n = unique(lambda_n)
            push!(land, lambda_n)
        end
    else
        dbg && println("Constructing persistence landscape based on a grid")# getchar())

        # in this case useGridInComputations is true, therefore we will build a landscape on a grid.
        externgridDiameter
        minMax_val = minMax(p)
        numberOfBins = 2 * ((minMax_val.second - minMax_val.first) / gridDiameter) + 1

        # first element of a pa::MyPairir<, vector<double> > is a x-value. Second element is a vector of values of landscapes.

        # vector< pair<, std::vector<double> > > criticalValuesOnPointsOfGrid(numberOfBins)
        criticalValuesOnPointsOfGrid = Any[]

        # filling up the bins:
        # Now, the idea is to iterate on land.land[lambda-1] and use only points over there. The problem is at the very beginning, when there is nothing
        # in land.land. That is why over here, we make a fate this->land[0]. It will be later deteted before moving on.

        aa = MyPair[]
        if allow_inf_intervals
            push!(aa, make_MyPair(-Inf, 0))
        end

        x = minMax_val.first
        for i = 0:numberOfBins
            v = Float64[]
            # pair<, vector<double> > p = std::make_MyPair( x , v )
            p = (x, v)
            push!(aa, make_MyPair(x, 0))
            push!(criticalValuesOnPointsOfGrid[i], p)
            dbg && println("x : $(x)")
            x += 0.5 * gridDiameter
        end

        if allow_inf_intervals
            push!(aa, make_MyPair(Inf, 0))
        end
        dbg && println("Grid has been created. Now, begin to add intervals")
        # for every peristent interval
        for ervalNo = 0:size(p, 1)
            beginn = ()(2 * (p.barcodes[intervalNo].first - minMax_val.first) / (gridDiameter)) + 1
            dbg && println("We are considering interval : [$(p.barcodes[intervalNo].first),$(p.barcodes[intervalNo].second) $(beginn) in the grid")
            while (criticalValuesOnPointsOfGrid[beginn].first < p.barcodes[intervalNo].second)
                dbg && println("Adding a value : ($(criticalValuesOnPointsOfGrid[beginn].first) $(min( abs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,abs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ))) ")
                criticalValuesOnPointsOfGrid[beginn].second.push_back(min(abs(criticalValuesOnPointsOfGrid[beginn].first - p.barcodes[intervalNo].first), abs(criticalValuesOnPointsOfGrid[beginn].first - p.barcodes[intervalNo].second)))
                beginn += 1
            end
        end
        # now, the basic structure is created. We need to translate it to a persistence landscape data structure.
        # To do so, first we need to sort all the vectors in criticalValuesOnPointsOfGrid[i].second
        maxNonzeroLambda = 0
        for i = 0:size(criticalValuesOnPointsOfGrid, 1)
            sort(criticalValuesOnPointsOfGrid[i].second.begin(), criticalValuesOnPointsOfGrid[i].second.end(), greater < int > ())
            if criticalValuesOnPointsOfGrid[i].second.size() > maxNonzeroLambda
                maxNonzeroLambda = criticalValuesOnPointsOfGrid[i].second.size()
            end
        end
        if dbg
            println("After sorting")
            for i = 0:size(criticalValuesOnPointsOfGrid, 1)
                println("x : $(criticalValuesOnPointsOfGrid[i].first << " : ")")
                for j = 0:size(criticalValuesOnPointsOfGrid[i].second, 1)
                    println(criticalValuesOnPointsOfGrid[i].second[j] << " ")
                end
                println("\n")
            end
        end
        push!(land, aa)
        for lambda = 0:maxNonzeroLambda
            dbg && println("Constructing lambda_$(lambda)")
            nextLambbda = MyPair[]

            push!(nextLambbda, make_MyPair(INT_MIN, 0))

            # for every element in the domain for which the previous landscape is nonzero.
            wasPrevoiusStepZero = true
            nr = 1
            while nr < size(land.land[size(land, 1)-1]) - 1
                dbg && println("nr : $(nr)")
                address = ()(2 * (land.land[size(land, 1)-1][nr].first - minMax_val.first) / (gridDiameter))
                dbg && println("We are considering the element x : $(land.land[ size(land,1)-1 ][nr].first). Its position in the structure is : $(address)")
                if criticalValuesOnPointsOfGrid[address].second.size() <= lambda
                    if (!wasPrevoiusStepZero)
                        wasPrevoiusStepZero = true
                        dbg && println("AAAdding : ($(criticalValuesOnPointsOfGrid[address].first) $(0)) to lambda_$(lambda)")# getchar())")
                        push!(nextLambbda, make_MyPair(criticalValuesOnPointsOfGrid[address].first, 0))
                    end
                else
                    if wasPrevoiusStepZero
                        dbg && println("Adding : ($(criticalValuesOnPointsOfGrid[address-1].first) $(0)) to lambda_$(lambda)")# getchar())")
                        push!(nextLambbda, make_MyPair(criticalValuesOnPointsOfGrid[address-1].first, 0))
                        wasPrevoiusStepZero = false
                    end
                    dbg && println("AAdding : ($(criticalValuesOnPointsOfGrid[address].first) $(criticalValuesOnPointsOfGrid[address].second[lambda])) to lambda_$(lambda)")
                    push!(nextLambbda, make_MyPair(criticalValuesOnPointsOfGrid[address].first, criticalValuesOnPointsOfGrid[address].second[lambda]))
                end
                nr += 1
            end

            dbg && println("Done with : lambda_$(lambda)")

            if lambda == 0
                # removing the first, fake, landscape
                land.land.clear()
            end
            push!(nextLambbda, make_MyPair(INT_MAX, 0))
            nextLambbda.erase(unique(nextLambbda.begin(), nextLambbda.end()), nextLambbda.end())
            push!(land, nextLambbda)
        end
    end

    return land
end

# Constructor form file
function create_PersistenceLandscape(land::PersistenceLandscape, filename::String; dbg=false)
    land_vecto = copy(land.land)
    if dbg
        println("Using constructor : PersistenceLandscape $(filename)")
    end
    if !check_if_file_exist(filename)
        println("The file : $(filename) do not exist. The program will now terminate")
        throw(SystemError("File not exist, please consult output of the program for further details."))
    end
    # this constructor reads persistence landscape form a file. This file have to be created by this software beforehead

    dimension = 0
    open(filename, "r") do io
        # read till end of file
        s = readline(f)
        dimension = UInt(s)

        isThisAFirsLine = true
        line = ""
        landscapeAtThisLevel = MyPair[]

        while !eof(io)
            s = readline(io)
            if !(line.length() == 0 || line[0] == '#')
                lineSS = line
                splitted = split(lineSS, " ")
                beginning = splitted[1]
                ending = splitted[2]


                push!(landscapeAtThisLevel, make_MyPair(beginning, ending))
                if (dbg)
                    println("Reading a pont : $(beginning), $(ending)")
                else
                    if (dbg)
                        println("IGNORE LINE")
                        # getchar()
                    end
                    if !isThisAFirsLine
                        if allow_inf_intervals
                            push!(landscapeAtThisLevel, make_MyPair(Inf, 0))
                        end
                        push!(land_vecto, landscapeAtThisLevel)
                        landscapeAtThisLevel = MyPair[]
                    end
                    if allow_inf_intervals
                        push!(landscapeAtThisLevel, make_MyPair(-Inf, 0))
                    end
                    isThisAFirsLine = false
                end
            end
        end
    end
    if size(landscapeAtThisLevel, 1) > 1
        # seems that the last line of the file is not finished with the newline sign. We need to put what we have in landscapeAtThisLevel to the constructed landscape.
        if allow_inf_intervals
            push!(landscapeAtThisLevel, make_MyPair(Inf, 0))
        end
        push!(land_vecto, landscapeAtThisLevel)
    end
    return PersistenceLandscape(land_vecto, dimension)
end

# Constructors <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

function almostEqual(a::Float64, b::Float64)
    if abs(a - b) < eps()
        return true
    end
    return false
end

function birth(a::MyPair)
    return a.first - a.second
end

function death(a::MyPair)
    return a.first + a.second
end

# functions used in PersistenceLandscape( PersistenceBarcodes& p ) constructor:
# comparePointsDBG::Bool = false
function comparePoints(f::MyPair, s::MyPair; local_debug::Bool=false)
    differenceBirth = birth(f) - birth(s)

    if differenceBirth < 0
        differenceBirth *= -1
    end

    differenceDeath = death(f) - death(s)
    if differenceDeath < 0
        differenceDeath *= -1
    end

    if (differenceBirth < epsi) && (differenceDeath < epsi)
        local_debug && println("CP1")
        return false
    end
    if differenceBirth < epsi
        # consider birth points the same. If we are here, we know that death points are NOT the same
        if death(f) < death(s)
            local_debug && println("CP2")
            return true
        end
        local_debug && println("CP3")

        return false
    end
    if differenceDeath < epsi
        # we consider death points the same and since we are here, the birth points are not the same!
        if birth(f) < birth(s)
            local_debug && println("CP4")

            return false
        end
        local_debug && println("CP5")

        return true
    end
    if birth(f) > birth(s)
        local_debug && println("CP6")

        return false
    end
    if birth(f) < birth(s)
        local_debug && println("CP7")

        return true
    end
    # if this is true, we assume that death(f)<=death(s) -- othervise I have had a lot of roundoff problems here!
    if death(f) <= death(s)
        local_debug && println("CP8")

        return false
    end
    local_debug && println("CP9")

    return true
end

# this function assumes birth-death coords
function comparePoints2(f::MyPair, s::MyPair)
    if f.first < s.first
        return true
    else
        if f.first > s.first
            return false
        else
            # f.first == s.first
            if f.second > s.second
                return true
            else
                return false
            end
        end
    end
end

# class vectorSpaceOfPersistenceLandscapes
# functions used to add and subtract landscapes

function add(x::Float64, y::Float64)
    return x + y
end

function sub(x::Float64, y::Float64)
    return x - y
end

# function used in computeValueAtAGivenPoint
function functionValue(p1::MyPair, p2::MyPair, x::Float64)
    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    # println("Line crossing points : ($(p1.first << ",$(p1.second)) oraz (" << p2.first) $(p2.second)) :")")
    # println("a : $(a) $(b) , x : $(x)")
    return (a * x + b)
end

# class PersistenceLandscape

function lDimBegin(land::PersistenceLandscape, dim::UInt)
    if dim > size(land, 1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][1]
end

function lDimEnd(land::PersistenceLandscape, dim::UInt)
    if dim > size(land, 1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][size(land[dim], 1)]
end

# functionzone:
# this is a general algorithm to perform linear operations on persisntece lapscapes. It perform it by doing operations on landscape points.

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Basic operations on PersistenceLandscape >>>
# function operationOnPairOfLandscapes(land1, land2 , oper);

function addTwoLandscapes(land1::PersistenceLandscape, land2::PersistenceLandscape)::PersistenceLandscape
    return operationOnPairOfLandscapes(land1, land2, +)
end

function subtractTwoLandscapes(land1::PersistenceLandscape, land2::PersistenceLandscape)::PersistenceLandscape
    return operationOnPairOfLandscapes(land1, land2, -)
end

function +(first::PersistenceLandscape, second::PersistenceLandscape)
    return addTwoLandscapes(first, second)
end

function -(first::PersistenceLandscape, second::PersistenceLandscape)
    return subtractTwoLandscapes(first, second)
end

function *(first::PersistenceLandscape, con::Real)
    return multiplyLanscapeByRealNumberNotOverwrite(first, con)
end

function *(con::Real, first::PersistenceLandscape)
    return multiplyLanscapeByRealNumberNotOverwrite(first, con)
end

function /(this::PersistenceLandscape, x::Real)
    x == 0 && throw(DomainError("In Base./=, division by 0. Program terminated."))
    return this / x
end

function ==(lhs::PersistenceLandscape, rhs::PersistenceLandscape; operatorEqualDbg=false)
    if size(lhs.land, 1) != size(rhs.land, 1)
        operatorEqualDbg && println("1")
        return false
    end

    # check if every elements are the same
    for level = 1:size(lhs.land, 1)
        if size(lhs.land[level]) != size(rhs.land[level])
            if (operatorEqualDbg)
                println("size(lhs.land[level]) : $(size(lhs.land[level]))")
                println("size(rhs.land[level]) : $(size(rhs.land[level]))")
                println("2")
            end
            return false
        end
        for i = 1:size(lhs.land[level], 1)
            if lhs.land[level][i] != rhs.land[level][i]
                if (operatorEqualDbg)
                    println("lhs.land[level][i] : $(lhs.land[level][i])")
                    println("rhs.land[level][i] : $(rhs.land[level][i])")
                    println("3")
                end
                return false
            end
        end
    end
    return true
end

# function operator=(land::PersistenceLandscape, oryginal::PersistenceLandscape)
# remved, vbecause unnecesssary
# end

function Base.size(land::PersistenceLandscape)
    return size(land.land, 1)
end

# ===-===-===-
# This function is realised by constructors, most probably not needed once consstructors are fixed.
function check_for_infs(landscape::PersistenceLandscape)
    landscape_set = Array{Array{MyPair,1},1}()
    negative_inf = MyPair(-Inf, 0)
    positive_inf = MyPair(Inf, 0)

    for land in landscape.land
        new_landscape = land
        if !(negative_inf in new_landscape)
            new_landscape = vcat(negative_inf, new_landscape)
        end

        if !(positive_inf in new_landscape)
            new_landscape = vcat(new_landscape, positive_inf)
        end
        push!(landscape_set, new_landscape)
    end

    return PersistenceLandscape(landscape_set, landscape.dimension)
end

function operationOnPairOfLandscapes(in_land1::PersistenceLandscape, in_land2::PersistenceLandscape, oper; local_dbg=false)
    land1 = deepcopy(in_land1)
    land2 = deepcopy(in_land2)

    local_dbg && println("operationOnPairOfLandscapes")

    #check for (-Inf,0) and (0, Inf) pairs
    # land1 = check_for_infs(land1)
    # land2 = check_for_infs(land2)

    # PersistenceLandscape result
    # result = Dict(:land => Any[], :dims => land1.dimension)

    land = Vector{Vector{MyPair}}()
    result = Vector{Vector{MyPair}}()
    dims = land1.dimension
    # result.land = land

    # iterate for elements that are in both pers landscapes
    for i = 1:min(size(land1.land, 1), size(land2.land, 1))#-1)
        @debug "for loop, i: $(i)"
        lambda_n = MyPair[]
        p = 1
        q = 1

        # this while covers cases when there are vectors left in both land1 and land2
        # while  (p+1 < size(land1.land[i],1)) && (q+1 < size(land2.land[i],1))
        while (p <= size(land1.land[i], 1)) && (q <= size(land2.land[i], 1))
            # this while has to have forward check
            @debug "first while loop, p: $(p), q: $(q)"
            if local_dbg
                println("p : $(p)")
                println("q : $(q)")
                println("land1.land[i][p].first : $(land1.land[i][p].first)")
                println("land2.land[i][q].first : $(land2.land[i][q].first)")
                println()
            end

            # This if may be true for p=1 and thus will always fail for the first iteration
            # because it was assumed, that the first pair is (-Inf, 0), because for that
            # this condition would not be satisfied, neiter for second if, only the third one
            # will be met and thus p and q will be increased, so that for second iteration this will
            # be ok. That might be the reason why (0, Inf) is added at the last iteration
            if land1.land[i][p].first < land2.land[i][q].first
                @debug "First if, land1.first < land2.first"
                local_dbg && println("first if, first values are equal")

                if q == 1
                    element_before = MyPair(land1.land[i][p].first, 0)
                    # new_pair = MyPair(
                    #                   min(land1.land[i][p].first,
                    #                       land2.land[i][q].first),
                    #                   max( land1.land[i][p].second,
                    #                       land2.land[i][q].second)
                    #                  )
                else
                    element_before = land2.land[i][q-1]
                end
                end_value = functionValue(element_before,
                    land2.land[i][q],
                    land1.land[i][p].first
                )
                operation_result = oper(land1.land[i][p].second, end_value)
                new_pair = MyPair(land1.land[i][p].first, operation_result)

                local_dbg && println("end_value = $(end_value)")
                local_dbg && println("operation_result = $(operation_result)")
                local_dbg && println("new_pair  = $(new_pair  )")

                push!(lambda_n, new_pair)
                p += 1
                continue
            end

            if land1.land[i][p].first > land2.land[i][q].first
                @debug "Second if, land1.first > land2.first"
                local_dbg && println("Second if, first values are equal")

                if p == 1
                    element_before = MyPair(land2.land[i][q].first, 0)
                    # new_pair = MyPair(
                    #                   min( land1.land[i][p].first,
                    #                       land2.land[i][q].first),
                    #                   max( land1.land[i][p].second,
                    #                       land2.land[i][q].second)
                    #                  )
                else
                    element_before = land1.land[i][p-1]
                end
                end_value = functionValue(land1.land[i][p],
                    element_before,
                    land2.land[i][q].first
                )
                operation_result = oper(end_value, land2.land[i][q].second)
                new_pair = MyPair(land2.land[i][q].first, operation_result)

                local_dbg && println("end_value = $(end_value)")
                local_dbg && println("operation_result = $(operation_result)")
                local_dbg && println("new_pair  = $(new_pair  )")

                push!(lambda_n, new_pair)
                q += 1
                continue
            end

            # this the only if statement in while loop that can be executed in frist loop
            # other loops try to access q-1 or p-1 elements
            if land1.land[i][p].first == land2.land[i][q].first
                @debug "Last if, land1 == land2"
                # local_dbg && println("Third")
                # division by a factor of 2 was added in julia version
                operation_result = oper(land1.land[i][p].second, land2.land[i][q].second)

                new_pair = MyPair(land2.land[i][q].first, operation_result)

                push!(lambda_n, new_pair)
                p += 1
                q += 1
            end
            local_dbg && println("Next iteration")
            # getchar())
        end

        # this while covers case when there are no vectors left in land2 and there some left in land1
        # original +1 was changed to -1
        while (p <= size(land1.land[i], 1)) && (q >= size(land2.land[i], 1))
            @debug "second while loop, p: $(p), q: $(q)"

            oper_result = oper(land1.land[i][p].second, 0)
            local_dbg && println("New point : $(land1.land[i][p].first)  oper(land1.land[i][p].second,0) : $(oper_result)")

            new_pair = MyPair(land1.land[i][p].first, oper_result)

            push!(lambda_n, new_pair)
            p += 1
        end

        # this while covers case when there are no vectors left in land1 and there some left in land2
        # original +1 was changed to -1
        while (p >= size(land1.land[i], 1)) && (q <= size(land2.land[i], 1))
            @debug "third while loop, p: $(p), q: $(q)"

            oper_result = oper(0, land2.land[i][q].second)
            local_dbg && println("New point : $(land2.land[i][q].first) oper(0,land2.land[i][q].second) : $(oper_result)")

            new_pair = MyPair(land2.land[i][q].first, oper_result)

            push!(lambda_n, new_pair)
            q += 1
        end

        # if both of while loops fail, then there is nothing added to lambda_n
        # why add this infinite loop if there was none in the original data?
        # push!(lambda_n,  make_MyPair( Inf, 0 ) )
        # CHANGE
        # result.land[i] = lambda_n
        push!(result, lambda_n)
    end

    # if land1 is longer
    start_val = min(1, size(land1.land, 1), size(land2.land, 1))
    stop_val = max(size(land1.land, 1), size(land2.land, 1))
    is_land1_shorter() = size(land1.land, 1) > min(size(land1.land, 1), size(land2.land, 1))
    is_land2_shorter() = size(land2.land, 1) > min(size(land1.land, 1), size(land2.land, 1))

    if is_land1_shorter()
        @debug "first if modifier"
        local_dbg && println("size(land1.land,1) > $(min( size(land1.land,1), size(land2.land,1) ))")

        append_nonoverlapping_elements!(result, land1, stop_val, start_val, oper; zero_tailing=true, zero_start=false)
    elseif is_land2_shorter()
        @debug "second if modifier"
        local_dbg && println("( size(land2.land,1) > $(min( size(land1.land,1) , size(land2.land,1))) ")

        append_nonoverlapping_elements!(result, land2, stop_val, start_val, oper; zero_tailing=false, zero_start=true)
    end

    local_dbg && println("operationOnPairOfLandscapes")

    # return result
    return PersistenceLandscape(result, dims)
end# operationOnPairOfLandscapes


function append_nonoverlapping_elements!(result, selected_land::PersistenceLandscape, stop_val, start_val, oper; zero_tailing=false, zero_start=false)
    # append all elements form land1 that are above length of land2

    # TODO check if the new method does the same as the old one
    for lambda_n = selected_land.land
        for nr = 1:size(lambda_n, 1)
            if zero_tailing && !zero_start
                oper_result = oper(lambda_n[nr].second, 0)
            elseif !zero_tailing && zero_start
                oper_result = oper(0, lambda_n[nr].second)
            end

            new_pair = make_MyPair(lambda_n[nr].first, oper_result)
            lambda_n[nr] = new_pair
        end
        # CHANGE
        push!(result, lambda_n)
    end
    # Original version:
    # for i = start_val:stop_val
    #     # lambda_n = MyPair[]
    #     # take the tailing parirs and modify them with oper function -> why oper function?
    #     lambda_n = selected_land.land[i]
    #     for nr = 1 : size(selected_land.land[i],1)
    #         if zero_tailing && !zero_start
    #             oper_result  = oper(selected_land.land[i][nr].second, 0)
    #         elseif !zero_tailing && zero_start
    #             oper_result = oper(0 , selected_land.land[i][nr].second)
    #         end
    #
    #         new_pair = make_MyPair(selected_land.land[i][nr].first, oper_result)
    #         lambda_n[nr] = new_pair
    #     end
    #     # CHANGE
    #     push!(result, lambda_n)
    # end
end

# Basic operations on PersistenceLandscape <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

function computeMaximum(land::PersistenceLandscape)
    maxValue = 0
    if size(land, 1) != 0
        maxValue = -Inf
        for i = 1:size(land[0], 1)
            if land[1][i].second > maxValue
                maxValue = land[1][i].second
            end
        end
    end
    return maxValue
end

function computeNormOfLandscape(land::PersistenceLandscape, i::Int)
    l = PersistenceLandscape()
    if i != -1
        return computeDiscanceOfLandscapes(land, l, i)
    else
        return computeMaxNormDiscanceOfLandscapes(land, l)
    end
end

# Empty constructor?

function dim(land::PersistenceLandscape)
    return land.dimension
end

function minimalNonzeroPoint(land::PersistenceLandscape, l::UInt)
    if size(land, 1) < l
        return Inf
    end
    return land[l][1].first
end

function maximalNonzeroPoint(land::PersistenceLandscape, l::UInt)
    if size(land, 1) < l
        return -Inf
    end
    return land[l][size(land[l], 1)-2].first
end


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# visualization part...
# To be created in Julia





# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CAUTION, this procedure do not work yet. Please do not use it until this warning is removed.
# PersistenceBarcodes PersistenceLandscape::convertToBarcode()
# function body removed
#
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-




# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Operations on landscapes
# this function find maximum of lambda_n
function gimmeProperLandscapePoints(land::PersistenceLandscape)::Vector{MyPair}
    result = MyPair[]
    for level = 1:size(land, 1)
        v = MyPair(land[level].begin() + 1, land[level].end() - 1)
        push!(result, v)
    end
    return result
end

function check_if_file_exist(name::String)
    return isfile(name)
end

function findMax(land::PersistenceLandscape, lambda::UInt)
    if (size(land, 1) < lambda)
        return 0
    end
    maximum = -Inf
    for i = 0:size(land.land[lambda], 1)
        if land.land[lambda][i].second > maximum
            maximum = land.land[lambda][i].second
        end
    end
    return maximum
end

# this function compute n-th moment of lambda_level
function computeNthMoment(land::PersistenceLandscape, n::UInt, center, level::UInt; local_debug=false)
    if n < 1
        println("Cannot compute n-th moment for  n = $(n << ". The program will now terminate")")
        throw("Cannot compute n-th moment. The program will now terminate")
    end
    result = 0
    if size(land, 1) > level
        for i = 2:size(land.land[level], 1)-1
            if land.land[level][i].first - land.land[level][i-1].first == 0
                continue
            end
            # between land.land[level][i] and land.land[level][i-1] the lambda_level is of the form ax+b. First we need to find a and b.
            a = (land.land[level][i].second - land.land[level][i-1].second) / (land.land[level][i].first - land.land[level][i-1].first)
            b = land.land[level][i-1].second - a * land.land[level][i-1].first
            x1 = land.land[level][i-1].first
            x2 = land.land[level][i].first
            #first = b*(pow((x2-center),(double)(n+1))/(n+1)-pow((x1-center),(double)(n+1))/(n+1))
            #second = a/(n+1)*((x2*pow((x2-center),(double)(n+1))) - (x1*pow((x1-center),(double)(n+1))) )
            #               +
            #               a/(n+1)*( pow((x2-center),(double)(n+2))/(n+2) - pow((x1-center),(double)(n+2))/(n+2) )
            # result += first
            # result += second
            first = a / (n + 2) * (((x2 - center)^(n + 2)) - ((x1 - center)^(n + 2)))
            second = center / (n + 1) * (((x2 - center)^(n + 1)) - ((x1 - center)^(n + 1)))
            third = b / (n + 1) * (((x2 - center)^(n + 1)) - ((x1 - center)^(n + 1)))
            if local_debug
                println("x1 : $(x1)")
                println("x2 : $(x2)")
                println("a : $(a)")
                println("b : $(b)")
                println("first : $(first)")
                println("second : $(second)")
                println("third : $(third)")
                # getchar()
            end
            result += first + second + third
        end
    end
    return result
end# computeNthMoment

function testLandscape(land::PersistenceLandscape, b::PersistenceBarcodes)
    for level = 1:size(land, 1)
        for i = 1:size(land.land[level], 1)-1
            if land.land[level][i].second < epsi
                continue
            end
            # check if over land.land[level][i].first-land.land[level][i].second , land.land[level][i].first+land.land[level][i].second] there are level barcodes.
            nrOfOverlapping = 0
            for nr = 1:size(b.barcodes, 1)
                if (b.barcodes[nr].first - epsi <= land.land[level][i].first - land.land[level][i].second
                    &&
                    (b.barcodes[nr].second + epsi >= land.land[level][i].first + land.land[level][i].second)
                )
                    nrOfOverlapping += 1
                end
            end
            if nrOfOverlapping != level + 1
                println("We have a problem :")
                println("land.land[level][i].first : $(land.land[level][i].first)")
                println("land.land[level][i].second : $(land.land[level][i].second)")
                println("[$(land.land[level][i].first-land.land[level][i].second) $(land.land[level][i].first+land.land[level][i].second)]")
                println("level : $(level) , nrOfOverlapping: $(nrOfOverlapping)")
                # getchar()
                for nr = 1:size(b.barcodes, 1)
                    if (b.barcodes[nr].first <= land.land[level][i].first - land.land[level][i].second
                        &&
                        (b.barcodes[nr].second >= land.land[level][i].first + land.land[level][i].second)
                    )
                        println("($(b.barcodes[nr].first) $(b.barcodes[nr].second))")
                    end
                    # land.printToFiles("out")
                    # land.generateGnuplotCommandToPlot("out")
                    # # getchar();getchar();getchar()
                end
            end
        end
    end
    return true
end


function computeLandscapeOnDiscreteSetOfPoints(land::PersistenceLandscape, b::PersistenceBarcodes, dx; local_dbg=false)
    miMa = minMax(b)
    bmin = miMa.first
    bmax = miMa.second
    local_dbg && println("bmin: $(bmin) $(bmax)")
    # if(local_dbg)end
    # vector< pair<double,std::vector<double> > > result( (bmax-bmin)/(dx/2) + 2 )
    result = Vector{Vector{MyPair}}()
    x = bmin
    i = 0
    while (x <= bmax)
        v = Float64[]
        result[i] = make_MyPair(x, v)
        x += dx / 2.0
        i += 1
    end

    local_dbg && println("Vector initally filled in")

    for i = 0:size(b.barcodes, 1)
        # adding barcode b.barcodes[i] to out mesh:
        beginBar = b.barcodes[i].first
        endBar = b.barcodes[i].second
        index = ceil((beginBar - bmin) / (dx / 2))
        while result[index].first < beginBar
            index += 1
        end
        while result[index].first < beginBar
            index -= 1
        end
        height = 0
        # I know this is silly to add dx/100000 but this is neccesarry to make it work. Othervise, because of roundoff error, the program gave wrong results. It took me a while to track this.
        while (height <= ((endBar - beginBar) / 2.0))
            # go up
            result[index].second.push_back(height)
            height += dx / 2
            index += 1
        end
        height -= dx
        while ((height >= 0))
            # go down
            result[index].second.push_back(height)
            height -= dx / 2
            index += 1
        end
    end
    # println("All barcodes has been added to the mesh")
    indexOfLastNonzeroLandscape = 0
    i = 0
    for x = bmin:bmax
        sort(result[i].second.begin(), result[i].second.end(), greater < double > ())
        if (result[i].second.size() > indexOfLastNonzeroLandscape)
            indexOfLastNonzeroLandscape = result[i].second.size()
        end
        i += 1
    end
    if (local_dbg)println("Now we fill in the suitable vecors in this landscape")
    end
    land = Vector{Vector{MyPair}}()
    for dim = 0:indexOfLastNonzeroLandscape
        land[dim].push_back(make_MyPair(-Inf, 0))
    end
    i = 0
    for x = bmin:bmax
        for nr = 0:size(result[i].second, 1)
            land[nr].push_back(make_MyPair(result[i].first, result[i].second[nr]))
        end
        i += 1
    end
    for dim = 0:indexOfLastNonzeroLandscape
        land[dim].push_back(make_MyPair(Inf, 0))
    end
    land.land.clear()
    land.land.swap(land)
    land.reduceAlignedPoints()
end

function multiplyByIndicatorFunction(land::PersistenceLandscape, indicator::Vector{MyPair}; local_dbg::Bool=false)
    result = Vector{Vector{MyPair}}
    for dim = 0:size(land, 1)
        if (local_dbg)println("dim : $(dim)")
        end
        lambda_n = MyPair[]
        push!(lambda_n, make_MyPair(0, INT_MIN))
        if indicator.size() > dim
            if (local_dbg)
                println("There is nonzero indicator in this dimension")
                println("[ $(indicator[dim].first) $(indicator[dim].second)]")
            end
            for nr = 0:size(land.land[dim], 1)
                if (local_dbg)
                    println("land.land[dim][nr] : $(land.land[dim][nr].first) $(land.land[dim][nr].second)")
                end
                if land.land[dim][nr].first < indicator[dim].first
                    if (local_dbg)
                        println("Below treshold")
                    end
                    continue
                end
                if land.land[dim][nr].first > indicator[dim].second
                    if (local_dbg)println("Just pass above treshold")
                    end
                    push!(lambda_n,
                        make_MyPair(
                            indicator[dim].second,
                            functionValue(land.land[dim][nr-1],
                                land.land[dim][nr],
                                indicator[dim].second
                            )
                        )
                    )
                    push!(lambda_n, make_MyPair(
                        indicator[dim].second,
                        0
                    )
                    )
                    break
                end
                if (land.land[dim][nr].first >= indicator[dim].first) && (land.land[dim][nr-1].first <= indicator[dim].first)
                    if (local_dbg)
                        println("Entering the indicator")
                    end
                    push!(lambda_n, make_MyPair(indicator[dim].first, 0))
                    push!(lambda_n, make_MyPair(indicator[dim].first, functionValue(land.land[dim][nr-1], land.land[dim][nr], indicator[dim].first)))
                end
                if (local_dbg)
                    println("We are here")
                end
                push!(lambda_n, make_MyPair(land.land[dim][nr].first, land.land[dim][nr].second))
            end
        end
        push!(lambda_n, make_MyPair(0, -Inf))
        if size(lambda_n, 1) > 2
            result.land.push_back(lambda_n)
        end
    end
    return result
end


# TODO -- removewhen the problem is respved
function check(i::UInt, v::Vector{MyPair})
    if i < 0 || i >= size(v, 1)
        println("you want to get to index:size($(i) $(v)) indices")
        # cin.ignore()
        return true
    end
    return false
end

"""
Compute the integral of the landscape for p=0.
"""
function computeIntegralOfLandscape(land::PersistenceLandscape; local_dbg=false)
    # TODO this should be expressed as the same funciton called with param p=0 (or whichever is equivalent)
    result = 0
    for i = 1:size(land) # for every layer
        for nr = 2:size(land.land[i], 1)-1 # for every point in layer
            # it suffices to compute every planar integral and then sum them ap for each lambda_n
            val1 = land.land[i][nr].first - land.land[i][nr-1].first
            val2 = land.land[i][nr].second + land.land[i][nr-1].second
            result += 0.5 * val1 * val2
        end
    end
    return result
end

"""
Compute the integral of the landscape for p.

In this interval, the landscape has a form f(x) = ax+b. We want to compute
integral of (ax+b)^p = 1/a * (ax+b)^(p+1)/(p+1)
"""
function computeIntegralOfLandscape(land::PersistenceLandscape, p::Real; local_dbg=false)
    result = 0
    for i = 1:size(land)
        # total_points_in_layer = size(land.land[i],1)-1 # -1 because of the (0,0) point
        # for nr = 2:total_points_in_layer
        for nr = 2:size(land.land[i], 1)-1
            local_dbg && println("nr : $(nr)")
            # In this interval, the landscape has a form f(x) = ax+b. We want to compute integral of (ax+b)^p = 1/a * (ax+b)^p+1end/(p+1)
            coef = computeParametersOfALine(land.land[i][nr], land.land[i][nr-1])
            a = coef.first
            b = coef.second
            local_dbg && println("current: ($(land.land[i][nr].first),$(land.land[i][nr].second)) ,\n previous: ($(land.land[i][nr-1].first) $(land.land[i][nr-1].second))")

            if land.land[i][nr].first == land.land[i][nr-1].first
                continue
            end

            if a != 0
                val1 = a * land.land[i][nr].first + b
                val2 = a * land.land[i][nr-1].first + b
                denominator = a * (p + 1)
                result += ((val1^(p + 1)) - (val2^(p + 1))) / denominator
            else
                val1 = land.land[i][nr].first - land.land[i][nr-1].first
                val2 = land.land[i][nr].second
                result += val1 * (val2^p)
            end

            if local_dbg
                println("a : $(a), b : $(b)")
                println("result : $(result)")
            end
        end
    end
    return result
end

function computeIntegralOfLandscapeMultipliedByIndicatorFunction(land::PersistenceLandscape, indicator::Vector{MyPair})
    l = multiplyByIndicatorFunction(land, indicator)
    return l.computeIntegralOfLandscape()
end

function computeIntegralOfLandscapeMultipliedByIndicatorFunction(land::PersistenceLandscape, indicator::Vector{MyPair}, p::Float64) # this function compute integral of p-th power of landscape.
    l = multiplyByIndicatorFunction(land, indicator)
    return computeIntegralOfLandscape(l, p)
end

# This is a standard function which pairs maxima and minima which are not more than epsilon apart.
# This algorithm do not reduce all of them, just make one passage through data. In order to reduce all of them
# use the function reduceAllPairsOfLowPersistenceMaximaMinima(epsilon )
# WARNING! THIS PROCEDURE MODIFIES THE LANDSCAPE!!!
function removePairsOfLocalMaximumMinimumOfEpsPersistence(land::PersistenceLandscape, epsilon::Float64)
    numberOfReducedPairs = 0
    for dim = 0:size(land, 1)
        (2 > land.land[dim].size() - 3) && continue #  to make sure that the loop in below is not infinite.
        for nr = 2:size(land.land[dim], 1)-3
            if (abs_pl(land.land[dim][nr].second - land.land[dim][nr+1].second) < epsilon) &&
               (land.land[dim][nr].second != land.land[dim][nr+1].second)
                # right now we modify only the lalues of a points. That means that angles of lines in the landscape changes a bit. This is the easiest computational
                # way of doing this. But I am not sure if this is the best way of doing such a reduction of nonessential critical points. Think about this!
                if land.land[dim][nr].second < land.land[dim][nr+1].second
                    land.land[dim][nr].second = land.land[dim][nr+1].second
                else
                    land.land[dim][nr+1].second = land.land[dim][nr].second
                end
                numberOfReducedPairs += 1
            end
        end
    end
    return numberOfReducedPairs
end

# this procedure redue all critical points of low persistence.
function reduceAllPairsOfLowPersistenceMaximaMinima(land::PersistenceLandscape, epsilon)
    numberOfReducedPoints = 1
    while (numberOfReducedPoints)
        numberOfReducedPoints = removePairsOfLocalMaximumMinimumOfEpsPersistence(land, epsilon)
    end
end

# It may happened that some landscape points obtained as a aresult of an algorithm lies in a line. In this case, the following procedure allows to
# remove unnecesary points.
function reduceAlignedPoints(land::PersistenceLandscape, tollerance; local_debug=false)# this parapeter says how much the coeficients a and b in a formula y=ax+b may be different to consider points aligned.
    for dim = 0:size(land, 1)
        nr = 1
        lambda_n = MyPair[]
        push!(lambda_n, land.land[dim][0])
        while (nr != land.land[dim].size() - 2)
            # first, compute a and b in formula y=ax+b of a line crossing land.land[dim][nr] and land.land[dim][nr+1].
            res = computeParametersOfALine(land.land[dim][nr], land.land[dim][nr+1])
            if local_debug
                println("Considering points : $(land.land[dim][nr]) and $(land.land[dim][nr+1])")
                println("Adding : $(land.land[dim][nr] << " to lambda_n.")")
            end
            push!(lambda_n, land.land[dim][nr])
            a = res.first
            b = res.second
            i = 1
            while (nr + i != land.land[dim].size() - 2)
                local_debug && println("Checking if : $(land.land[dim][nr+i+1]) is aligned with them )")

                res1 = computeParametersOfALine(land.land[dim][nr], land.land[dim][nr+i+1])
                if (abs(res1.first - a) < tollerance) && (abs(res1.second - b) < tollerance)
                    local_debug && println("It is aligned ")
                    i += 1
                else
                    local_debug && println("It is NOT aligned ")
                    break
                end
            end
            local_debug && println("We are out of the while loop. The number of aligned points is : $(i)") # std::cin.ignore())")
            nr += i
        end
        if local_debug
            println("Out  of main while loop, done with this dimension ")
            println("Adding:size($(land.land[dim][size(land.land[dim],1)-2 ]) to lamnda_n ")
            println("Adding:size($(land.land[dim][size(land.land[dim],1)-1 ]) to lamnda_n ")
        end

        @error "Some code needs to be fixed in here"
        push!(lambda_n, land.land[dim][land.land[dim].size()-2])
        push!(lambda_n, land.land[dim][land.land[dim].size()-1])
        # if something was reduced, then replace land.land[dim] with the new lambda_n.

        if size(lambda_n, 1) < size(land.land[dim])
            if size(lambda_n, 1) > 4
                land.land[dim] = lambda_n
            end
        end
    end
end

# Yet another function to smooth up the data. The idea of this one is as follows. Let us take a landscape point A which is not (+infty,0), (-infty,0) of (a,0), (b,0), where a and b denotes the
# points which support of the function begins and ends. Let B and C will be the landscape points after A. Suppose B and C are also no one as above.
# The question we are asking here is -- can we remove the point B and draw a line from A to C such that the difference in a landscape will be not greater than epsilon?
# To measure the penalty of removing B, the funcion penalty. In below, the simplese example is given:
function penalty(A::MyPair, B::MyPair, C::MyPair)
    return abs(functionValue(A, C, B.first) - B.second)
end# penalty

function reducePoints(land::PersistenceLandscape, tollerance, penalty; local_debug=false)::PersistenceLandscape

    numberOfPointsReduced = 0
    for dim = 0:size(land, 1)
        nr = 1
        lambda_n = MyPair[]
        local_debug && println("Adding point to lambda_n : $(land.land[dim][0])")
        push!(lambda_n, land.land[dim][0])
        while (nr <= land.land[dim].size() - 2)
            local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")
            push!(lambda_n, land.land[dim][nr])
            if penalty(land.land[dim][nr], this -> land[dim][nr+1], this -> land[dim][nr+2]) < tollerance
                nr += 1
                numberOfPointsReduced += 1
            end
            nr += 1
        end
        local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")
        local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")

        push!(lambda_n, land.land[dim][this->land[dim].size() - 2])
        push!(lambda_n, land.land[dim][this->land[dim].size() - 1])

        # if something was reduced, then replace land.land[dim] with the new lambda_n.
        if size(lambda_n, 1) < size(land.land[dim], 1)
            if size(lambda_n) > 4
                # CHANGE
                # land.land[dim] = lambda_n
                land.land[dim].swap(lambda_n)
            end
        else
            land.land[dim].clear()
        end
    end
    return numberOfPointsReduced
end

# Untested
function findZeroOfALineSegmentBetweenThoseTwoPoints(p1::MyPair, p2::MyPair)
    # TODO Investigate: This function returns Nan if both of the y values in p1 and p2 are 0
    if p1.first == p2.first
        return p1.first
    end
    if p1.second * p2.second > 0
        error("In function findZeroOfALineSegmentBetweenThoseTwoPoints the agguments are: ($(p1.first)),$(p1.second)) and ($(p2.first), $(p2.second)). There is no zero in line between those two points. Program terminated.")
    end

    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    # println("Line crossing points : ($(p1.first << ",$(p1.second)) oraz (" << p2.first) $(p2.second)) :")")
    # println("a : $(a) $(b) , x : $(x)")
    return -b / a
end

# this is O(log(n)) algorithm, where n is number of points in land.land.
function computeValueAtAGivenPoint(land::PersistenceLandscape, level::UInt, x::Float64; local_dbg=false)
    # in such a case lambda_level = 0.
    if level > size(land, 1)
        return 0
    end
    # we know that the points in land.land[level] are ordered according to x coordinate. Therefore, we can find the point by using bisection:
    coordBegin = 1
    coordEnd = land.land[level].size() - 2
    if local_dbg
        println("Tutaj")
        println("x : $(x)")
        println("land.land[level][coordBegin].first : $(land.land[level][coordBegin].first)")
        println("land.land[level][coordEnd].first : $(land.land[level][coordEnd].first)")
    end
    # in this case x is outside the support of the landscape, therefore the value of the landscape is 0.
    if x <= land.land[level][coordBegin].first
        return 0
    end
    if x >= land.land[level][coordEnd].first
        return 0
    end
    local_dbg && println("Entering to the while loop")
    while (coordBegin + 1 != coordEnd)
        if (local_dbg)
            println("coordBegin : $(coordBegin)")
            println("coordEnd : $(coordEnd)")
            println("land.land[level][coordBegin].first : $(land.land[level][coordBegin].first)")
            println("land.land[level][coordEnd].first : $(land.land[level][coordEnd].first)")
        end
        newCord = (unsigned)floor((coordEnd + coordBegin) / 2.0)
        if (local_dbg)
            println("newCord : $(newCord)")
            println("land.land[level][newCord].first : $(land.land[level][newCord].first)")
        end
        if land.land[level][newCord].first <= x
            coordBegin = newCord
            if (land.land[level][newCord].first == x)
                return land.land[level][newCord].second
            end
        else
            coordEnd = newCord
        end
    end
    if (local_dbg)
        println("x : $(x) is between : $(land.land[level][coordBegin].first) $(land.land[level][coordEnd].first))")
        println("the y coords are : $(land.land[level][coordBegin].second) $(land.land[level][coordEnd].second)")
        println("coordBegin : $(coordBegin)")
        println("coordEnd : $(coordEnd)")
    end
    return functionValue(land.land[level][coordBegin], land.land[level][coordEnd], x)
end
# Operations on landscapes <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Plotting functions >>>
function get_peaks_and_positions(lambdas)
    # TODO lowest leve, below unity and separate peaks are not found corrrectly
    filtered_pl = filter(x -> x.first != Inf, lambdas)
    filtered_pl = filter(x -> x.first != -Inf, filtered_pl)
    # filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)

    if isempty(filtered_pl)
        @warn "lambdas has only infinite intervals. Interrupting"
        return [], []
    end
    new_peaks_position = [x.first for x in filtered_pl]
    new_peaks = [x.second for x in filtered_pl]
    # peaks_position = [x.first for x in filtered_pl]
    # peaks = [x.second for x in filtered_pl]
    #
    # # find an index of pair for which first peak was found
    # index_peak1 = findall(x->x.first == peaks_position[1], lambdas)
    #
    # # find an index of pair for which last peak was found
    # index_peak_last = findall(x->x.first == peaks_position[end], lambdas)
    #
    #
    # # add starting point for the plot
    # peaks_position = vcat(peaks_position[1]-lambdas[index_peak1][1].second, peaks_position) # add starting poin
    # peaks = vcat(0, peaks) # add starting poin
    #
    # # add ending point for the plot
    # peaks_position = vcat(peaks_position, peaks_position[end]+lambdas[index_peak_last ][1].second) # add starting poin
    # peaks = vcat(peaks, 0) # add starting poin
    #
    # new_peaks = Real[]
    # new_peaks_position = Real[]
    # push!(new_peaks, peaks[1])
    # push!(new_peaks, peaks[2])
    # push!(new_peaks_position, peaks_position[1])
    # push!(new_peaks_position, peaks_position[2])
    #
    # # for every point, check if next peak position is within rach of range. if not, add zero poin
    # for k in 2:length(peaks_position)-1
    #     # this is peak position
    #     right_limit = peaks_position[k] + peaks[k]
    #     if right_limit < peaks_position[k+1]
    #
    #         push!(new_peaks, peaks[k])
    #         push!(new_peaks_position, peaks_position[k])
    #
    #         # add closing zero
    #         push!(new_peaks, 0)
    #         push!(new_peaks_position, right_limit)
    #
    #         # add opening zero
    #         left_limit = peaks_position[k+1] - peaks[k+1]
    #         push!(new_peaks, 0)
    #         push!(new_peaks_position, left_limit)
    #     else
    #         push!(new_peaks, peaks[k])
    #         push!(new_peaks_position, peaks_position[k])
    #     end
    # end
    #
    # push!(new_peaks, peaks[end])
    # push!(new_peaks_position, peaks_position[end])


    return new_peaks_position, new_peaks
end

function plot_persistence_landscape(pl1::PersistenceLandscape; max_layers=size(pl1.land, 1), plot_kwargs...)
    colors = cgrad(:cmyk, max(2, max_layers), categorical=true, rev=true)

    try
        colors = cgrad(plot_kwargs[:palette], max_layers, categorical=true, rev=true)
    catch
        @debug "Catched no palette"
    end

    canvas1 = plot()
    for k in 1:max_layers
        peaks_position, peaks = get_peaks_and_positions(pl1.land[k])

        plot!(canvas1, peaks_position, peaks; c=colors[k], plot_kwargs...)
    end

    return canvas1
end

# Plotting functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Other functions  >>>

function computeParametersOfALine(p1::MyPair, p2::MyPair)
    # p1.second = a*p1.first + b => b = p1.second - a*p1.first
    # p2.second = a*p2.first + b = a*p2.first + p1.second - a*p1.first = p1.second + a*( p2.first - p1.first )
    # =>
    # (p2.second-p1.second)/( p2.first - p1.first )  = a
    # b = p1.second - a*p1.first.
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    return make_MyPair(a, b)
end

# Other functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-


function multiplyLanscapeByRealNumberOverwrite(land::PersistenceLandscape, x::Float64)
    for dim = 0:size(land, 1)
        for i = 0:size(land.land[dim], 1)
            land.land[dim][i].second *= x
        end
    end
end


function abs_pl(in_landscape::PersistenceLandscape; local_debug=false)
    # PersistenceLandscape result;
    result = Vector{Vector{MyPair}}()

    # level = 1
    # land_layer = in_landscape.land[level]
    for (level, land_layer) in in_landscape.land |> enumerate
        # for level = 1:total_levels
        local_debug && println("level: $(level)")

        lambda_n = MyPair[]
        total_points = size(land_layer, 1)

        for x_index = 1:total_points
            if x_index == 1
                current_point = land_layer[x_index]
                push!(lambda_n, MyPair(current_point.first, current_point.second))
                continue
            end

            local_debug && println("in_landscape.land[$(level)][$(x_index)] : $(land_layer[x_index])")

            # if a line segment between land.land[level][i-1] and this->land[level][i] crosses the x-axis, then we have to add one landscape point to result
            previous_point = land_layer[x_index-1]
            y_previous_step = previous_point.second
            current_point = land_layer[x_index]
            y_current_step = current_point.second
            if (y_previous_step * y_current_step) < 0
                # function below is not yet julia valid
                zero = findZeroOfALineSegmentBetweenThoseTwoPoints(previous_point, current_point)
                first = current_point.first
                second = abs(current_point.second)

                push!(lambda_n, MyPair(zero, 0))
                push!(lambda_n, MyPair(first, second))

                if local_debug
                    println("Adding pair : ($(zero),0)")
                    println("In the same step adding pair : ($(first) $(second)) ")
                end
            else
                first = current_point.first
                second = abs(current_point.second)

                push!(lambda_n, MyPair(first, second))

                local_debug && println("Adding pair : ($(first) $(second))")
            end
        end
        push!(result, lambda_n)
    end
    return PersistenceLandscape(result, in_landscape.dimension)
end

function multiplyLanscapeByRealNumberNotOverwrite(land::PersistenceLandscape, x::Real)
    result = Vector{Vector{MyPair}}()
    for dim = 1:size(land)
        lambda_dim = MyPair[]
        for i = 1:size(land.land[dim], 1)
            push!(lambda_dim, make_MyPair(land.land[dim][i].first, x * land.land[dim][i].second))
        end

        push!(result, lambda_dim)
    end
    # CHANGE
    # res.land = result
    return PersistenceLandscape(result, land.dimension)
end# multiplyLanscapeByRealNumberOverwrite


# Edit1: original function took arguments which were m,odified in the function. Now it returns values required
# function computeMaximalDistanceNonSymmetric( pl1::PersistenceLandscape, pl2::PersistenceLandscape , nrOfLand::UInt , x::Float64, y1::Float64, y2::Float64)::PersistenceLandscape
# Edit2: This function was modified, because it was modyfying arguments and returning new results; To make it
# working again for landscapes distances, an intermidiate function had to be added.
function computeMaximalDistanceNonSymmetric(pl1::PersistenceLandscape, pl2::PersistenceLandscape)# , nrOfLand::UInt , x::Float64, y1::Float64, y2::Float64)
    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    maxDist = 0
    minimalNumberOfLevels = min(size(pl1.land, 1), pl2.land.size())[1]
    for level = 1:minimalNumberOfLevels
        p2Count = 0
        for i = 1:size(l1.land[level], 1)-1  # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while (true)
                if (
                    (pl1.land[level][i].first >= pl2.land[level][p2Count].first)
                    &&
                    (pl1.land[level][i].first <= pl2.land[level][p2Count+1].first)
                )
                    break
                end
                p2Count += 1
            end
            val = abs(
                functionValue(pl2.land[level][p2Count],
                    pl2.land[level][p2Count+1],
                    pl1.land[level][i].first
                ) - pl1.land[level][i].second
            )
            # println("functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) : $(functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ))")
            # println("pl1.land[level][i].second : $(pl1.land[level][i].second)")
            # println("pl1.land[level][i].first :$(pl1.land[level][i].first)")
            # cin.ignore()
            if maxDist <= val
                maxDist = val
                nrOfLand = level
                x = pl1.land[level][i].first
                y1 = pl1.land[level][i].second
                y2 = functionValue(pl2.land[level][p2Count], pl2.land[level][p2Count+1], pl1.land[level][i].first)
            end
        end
    end
    if minimalNumberOfLevels < size(pl1.land, 1)
        for level = minimalNumberOfLevels:size(pl1.land, 1)
            for i = 1:psize(l1.land[level])
                if maxDist < pl1.land[level][i].second
                    maxDist = pl1.land[level][i].second
                    nrOfLand = level
                    x = pl1.land[level][i].first
                    y1 = pl1.land[level][i].second
                    y2 = 0
                end
            end
        end
    end
    return maxDist, nrOfLand, x, y1, y2
end

function computeMaxNormDiscanceOfLandscapes(first, second)#, nrOfLand , x::Float64, y1::Float64, y2::Float64)::PersistenceLandscape

    dFirst, nrOfLandFirst, xFirst, y1First, y2First = computeMaximalDistanceNonSymmetric(first, second)
    #,nrOfLandFirst,xFirst, y1First, y2First)

    dSecond, nrOfLandSecond, xSecond, y1Second, y2Second = computeMaximalDistanceNonSymmetric(second, first)
    #,nrOfLandSecond,xSecond, y1Second, y2Second)

    if dFirst > dSecond
        nrOfLand = nrOfLandFirst
        x = xFirst
        y1 = y1First
        y2 = y2First
    else
        nrOfLand = nrOfLandSecond
        x = xSecond
        # this twist in below is neccesary!
        y2 = y1Second
        y1 = y2Second
        # y1 = y1Second
        # y2 = y2Second
    end
    return max(dFirst, dSecond)[1], nrOfLand, x, y1, y2
end

function computeMaximalDistanceNonSymmetric2(pl1::PersistenceLandscape, pl2::PersistenceLandscape; dbg=false)
    dbg && println(" computeMaximalDistanceNonSymmetric")
    @warn "name of function modified due to conflicting names"

    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    maxDist = 0
    minimalNumberOfLevels = min(size(pl1.land), size(pl2.land))[1] # why indexing here?
    for level = 1:minimalNumberOfLevels
        if (dbg)
            println("Level : $(level)")
            println("PL1 :")
            for i = 0:psize(l1.land[level])
                println("($(pl1.land[level][i].first),$(pl1.land[level][i].second))")
            end
            println("PL2 :")
            for i = 0:psize(l2.land[level])
                println("($(pl2.land[level][i].first),$(pl2.land[level][i].second))")
            end
            # cin.ignore()
        end

        p2Count = 1
        for i = 1:size(l1.land[level], 1)-1  # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while true
                if (pl1.land[level][i].first >= pl2.land[level][p2Count].first) &&
                   (pl1.land[level][i].first <= pl2.land[level][p2Count+1].first)
                    break
                end
                p2Count += 1
            end
            point_approximation = functionValue(pl2.land[level][p2Count],
                pl2.land[level][p2Count+1],
                pl1.land[level][i].first
            )
            val = abs(point_approximation - pl1.land[level][i].second)

            if maxDist <= val
                maxDist = val
            end

            if (dbg)
                println("pl1.land[level][i].first [$(pl2.land[level][p2Count].first),$(pl2.land[level][p2Count+1].first)])")
                println("pl1[level][i].second : $(pl1.land[level][i].second)")
                println("functionValue( pl2[level][p2Count] , pl2[level][p2Count+1] , pl1[level][i].first ) : $(functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ))")
                println("val : $(val)")
                # cin.ignore()
            end
        end
    end

    dbg && println("minimalNumberOfLevels : $(minimalNumberOfLevels)")

    if minimalNumberOfLevels < size(pl1.land, 1)
        for level = minimalNumberOfLevels:size(pl1.land, 1)
            for i = 1:size(l1.land[level], 1)
                dbg && println("pl1[level][i].second  : $(pl1.land[level][i].second)")
                if maxDist < pl1.land[level][i].second
                    maxDist = pl1.land[level][i].second
                end
            end
        end
    end
    return maxDist
end

function computeDiscanceOfLandscapes(first::PersistenceLandscape, second::PersistenceLandscape, p::Real)
    # This is what we want to compute: (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p). We will do it one step at a time:
    # first-second :
    lan = subtractTwoLandscapes(first, second)

    # | first-second |:
    lan = abs_pl(lan)

    # \int_- \inftyend^+\inftyend| first-second |^p
    if p != 1
        result = computeIntegralOfLandscape(lan, p)
    else
        result = computeIntegralOfLandscape(lan)
    end

    # (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p)
    return result^(1 / p)
end

function computeMaxNormDiscanceOfLandscapes(first::PersistenceLandscape, second::PersistenceLandscape)::PersistenceLandscape
    # this is being solved now: @warn "This function may not work, as max is not defined for PersistenceLandscape structure"

    distance1 = computeMaximalDistanceNonSymmetric(first, second)
    distance2 = computeMaximalDistanceNonSymmetric(second, first)

    return max(distance1, distance2)
end

function comparePairsForMerging(first::MyPair, second::MyPair)
    return (first.first < second.first)
end

function generateBettiNumbersHistogram(land::PersistenceLandscape; dbg=false)::PersistenceLandscape
    resultRaw = MyPair[]

    for dim = 0:size(land, 1)
        rangeOfLandscapeInThisDimension = MyPair[]
        if dim > 0
            for i = 1:size(land.land[dim], 1)-1
                if land.land[dim][i].second == 0
                    push!(rangeOfLandscapeInThisDimension, make_MyPair(land.land[dim][i].first, dim + 1))
                end
            end
        else
            # dim == 0.
            first = true
            for i = 1:size(land.land[dim], 1)-1
                if land.land[dim][i].second == 0
                    if first
                        push!(rangeOfLandscapeInThisDimension, make_MyPair(
                            land.land[dim][i].first,
                            0)
                        )
                    end
                    push!(rangeOfLandscapeInThisDimension, make_MyPair(
                        land.land[dim][i].first,
                        dim + 1)
                    )
                    if (!first)
                        push!(rangeOfLandscapeInThisDimension, make_MyPair(
                            land.land[dim][i].first,
                            0)
                        )
                    end
                    first = !first
                end
            end
        end
        # vector< std::pair<, unsigned > > resultRawNew( resultRaw.size() + rangeOfLandscapeInThisDimension.size() )
        resultRawNew = MyPair[]

        resultRaw = sort(
            vcat(resultRaw.begin(),
                resultRaw.end(),
                rangeOfLandscapeInThisDimension.begin(),
                rangeOfLandscapeInThisDimension.end(),
                resultRawNew.begin()
            ),
            comparePairsForMerging)

        resultRawNew = copy(resultRaw)
        if dbg
            println("Raw result : for dim : $(dim)")
            for i = 0:size(resultRaw)
                println("($(resultRaw[i].first) $(resultRaw[i].second))")
            end
            # getchar()
        end
    end
    if dbg
        println("Raw result : ")
        for i = 0:size(resultRaw)
            println("($(resultRaw[i].first) $(resultRaw[i].second))")
        end
        # getchar()
    end

    # now we should make it into a step function by adding a points in the jumps:
    result = MyPair[]

    size(resultRaw) == 0 && return result

    for i = 1:size(resultRaw)
        push!(result, resultRaw[i-1])
        if resultRaw[i-1].second <= resultRaw[i].second
            push!(result, make_MyPair(resultRaw[i].first, resultRaw[i-1].second))
        else
            push!(result, make_MyPair(resultRaw[i-1].first, resultRaw[i].second))
        end
    end
    # result.erase( unique( result.begin(), result.end() ), result.end() )
    result = unique(result)

    resultNew = MyPair[]
    i = 1
    while (i != size(result))
        x = result[i].first
        maxBetti = result[i].second
        minBetti = result[i].second
        while ((i != size(result)) && (abs(result[i].first - x) < 0.000001))
            if maxBetti < result[i].second
                maxBetti = result[i].second
            end
            if minBetti > result[i].second
                minBetti = result[i].second
            end
            i += 1
        end
        if minBetti != maxBetti
            if (size(resultNew) == 0) || (size(resultNew[resultNew-1].second) <= minBetti)
                # going up
                push!(resultNew, make_MyPair(x, minBetti))
                push!(resultNew, make_MyPair(x, maxBetti))
            else
                # going down
                push!(resultNew, make_MyPair(x, maxBetti))
                push!(resultNew, make_MyPair(x, minBetti))
            end
        else
            push!(resultNew, make_MyPair(x, minBetti))
        end
    end

    result = resultNew
    if dbg
        println("Final result : ")
        for i = 0:size(result)
            println("($(result[i].first) $(result[i].second))")
        end
        # getchar()
    end
    return result
end# generateBettiNumbersHistogram


function computeInnerProduct(l1::PersistenceLandscape, l2::PersistenceLandscape; dbg=true)
    result = 0
    for level = 1:min(size(l1), size(l2))[1]
        dbg && println("Computing inner product for a level : $(level)")

        if (size(l1.land[level], 1) * size(l2.land[level], 1) == 0)
            continue
        end
        # endpoints of the interval on which we will compute the inner product of two locally linear functions:
        x1 = -Inf
        x2 = 0
        if l1.land[level][1].first < l2.land[level][1].first
            x2 = l1.land[level][1].first
        else
            x2 = l2.land[level][1].first
        end
        # iterators for the landscapes l1 and l2

        l1It = 0
        l2It = 0
        while ((l1It < size(l1.land[level]) - 1, 1) && (l2It < size(l2.land[level]) - 1, 1))
            # compute the value of a inner product on a interval [x1,x2]
            a = (l1.land[level][l1It+1].second - l1.land[level][l1It].second) / (l1.land[level][l1It+1].first - l1.land[level][l1It].first)

            b = l1.land[level][l1It].second - a * l1.land[level][l1It].first

            c = (l2.land[level][l2It+1].second - l2.land[level][l2It].second) / (l2.land[level][l2It+1].first - l2.land[level][l2It].first)

            d = l2.land[level][l2It].second - c * l2.land[level][l2It].first

            contributionFromThisPart = (a * c * x2 * x2 * x2 / 3 + (a * d + b * c) * x2 * x2 / 2 + b * d * x2) - (a * c * x1 * x1 * x1 / 3 + (a * d + b * c) * x1 * x1 / 2 + b * d * x1)

            result += contributionFromThisPart
            if dbg
                println("[l1.land[level][l1It].first,l1.land[level][l1It+1].first] : $(l1.land[level][l1It].first), $(l1.land[level][l1It+1].first)")
                println("[l2.land[level][l2It].first,l2.land[level][l2It+1].first] : $(l2.land[level][l2It].first), $(l2.land[level][l2It+1].first)")
                println("a : $(a), b : $(b), c: $(c), d : $(d)")
                println("x1 : $(x1) , x2 : $(x2)")
                println("contributionFromThisPart : $(contributionFromThisPart)")
                println("result : $(result)")
                # getchar()
            end
            # we have two intervals in which functions are constant:
            # [l1.land[level][l1It].first , l1.land[level][l1It+1].first]
            # and
            # [l2.land[level][l2It].first , l2.land[level][l2It+1].first]
            # We also have an interval [x1,x2]. Since the intervals in the landscapes cover the whole R, then it is clear that x2
            # is either l1.land[level][l1It+1].first of l2.land[level][l2It+1].first or both. Lets test it.

            if x2 == l1.land[level][l1It+1].first
                if x2 == l2.land[level][l2It+1].first
                    # in this case, we increment both:
                    l2It += 1
                    dbg && println("Incrementing both")
                else
                    dbg && println("Incrementing first")
                end
                l1It += 1
            else
                # in this case we increment l2It
                l2It += 1
                dbg && println("Incrementing second")
            end
            # Now, we shift x1 and x2:
            x1 = x2
            if l1.land[level][l1It+1].first < l2.land[level][l2It+1].first
                x2 = l1.land[level][l1It+1].first
            else
                x2 = l2.land[level][l2It+1].first
            end
        end
    end
    return result
end