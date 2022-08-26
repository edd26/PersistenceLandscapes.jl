#=
Main module that contains constructors of PersistenceLandsacpe structure.

ATM also contains basic operations on lnadscapes: +, -, *, /, ==
=#
using Plots

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
    if !isfile(filename)
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

# class vectorSpaceOfPersistenceLandscapes

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
# functionzone:
# this is a general algorithm to perform linear operations on persisntece lapscapes. It perform it by doing operations on landscape points.

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Basic operations on PersistenceLandscape >>>
# function operationOnPairOfLandscapes(land1, land2 , oper);

# TODO Add depreciation for this function
function addTwoLandscapes(land1::PersistenceLandscape, land2::PersistenceLandscape)::PersistenceLandscape
    return operationOnPairOfLandscapes(land1, land2, +)
end

# TODO Add depreciation for this function
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
    ##

    # Append only the elements that are beyond the end of the vector
    # if land1 is longer
    start_val = min(size(land1.land, 1), size(land2.land, 1)) + 1
    stop_val = max(size(land1.land, 1), size(land2.land, 1))
    is_land1_longer() = size(land1.land, 1) > min(size(land1.land, 1), size(land2.land, 1))
    is_land2_longer() = size(land2.land, 1) > min(size(land1.land, 1), size(land2.land, 1))

    if is_land1_longer()
        @debug "first if modifier"
        local_dbg && println("size(land1.land,1) > $(min( size(land1.land,1), size(land2.land,1) ))")

        result = append_nonoverlapping_elements(result, land1, stop_val, start_val, oper; zero_tailing=true, zero_start=false)
    elseif is_land2_longer()
        @debug "second if modifier"
        local_dbg && println("( size(land2.land,1) > $(min( size(land1.land,1) , size(land2.land,1))) ")

        result = append_nonoverlapping_elements(result, land2, stop_val, start_val, oper; zero_tailing=false, zero_start=true)
    else
        @debug "Both have the same number of layers, so there is no need to append anything."
    end

    local_dbg && println("operationOnPairOfLandscapes")

    # return result
    return PersistenceLandscape(result, dims)
end# operationOnPairOfLandscapes


function append_nonoverlapping_elements(result, args...; kwargs...)
    new_result = deepcopy(result)

    append_nonoverlapping_elements!(new_result, args...; kwargs...)
    return new_result
end

function append_nonoverlapping_elements!(result, selected_land::PersistenceLandscape, stop_val, start_val, oper; zero_tailing=false, zero_start=false)
    # append results with all layers that are in selected_land and are between stop val and start val

    # TODO check if the new method does the same as the old one -> it didnt
    for lambda_n = selected_land.land[start_val:stop_val]

        for nr = 1:size(lambda_n, 1)
            if zero_tailing && !zero_start
                oper_result = oper(lambda_n[nr].second, 0)
            elseif !zero_tailing && zero_start
                oper_result = oper(0, lambda_n[nr].second)
            end

            new_pair = MyPair(lambda_n[nr].first, oper_result)
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


"""
Compute the integral of the landscape for p=1.
"""
function computeIntegralOfLandscape(in_land::PersistenceLandscape)
    # TODO this should be expressed as the same funciton called with param p=0 (or whichever is equivalent)
    # it suffices to compute every planar integral and then sum them ap for each lambda_n
    return 0.5 * [
        [
            (latter.first - former.first) * (latter.second + former.second) for
            (former, latter) in zip(layer[1:(end - 1)], layer[2:end])
        ] |> sum for layer in in_land.land
    ] |> sum

    # Same but more readable version:
    # for layer = in_land.land
    #     for (former, latter) = zip(layer[1:end-1], layer[2:end])
    #         # it suffices to compute every planar integral and then sum them ap for each lambda_n
    #         val1 = (latter.first - former.first)
    #         val2 = (latter.second + former.second)
    #         result += 0.5 * val1 * val2
    #     end
    # end
end

"""
Compute the integral of the landscape for p.

In this interval, the landscape has a form f(x) = ax+b. We want to compute
integral of (ax+b)^p, which is [(ax+b)^(p+1)]/(ap+a)
"""
function computeIntegralOfLandscape(in_land::PersistenceLandscape, p::Real; local_dbg=false)
    result = 0
    for land_layer = in_land.land
        for (former_point, latter_point) = zip(land_layer[1:end-1], land_layer[2:end])

            # In this interval, the landscape has a form f(x) = ax+b. We want to compute integral of (ax+b)^p, which is [(ax+b)^(p+1)]/(ap+a)
            coef = computeParametersOfALine(latter_point, former_point)
            a = coef.first
            b = coef.second

            # Points have same 1st coordinate, so their integral is equal to 0
            latter_point.first == former_point.first && continue

            # Not in original code: if landscapes are spaced, don't count the space in between them
            0 == latter_point.second == former_point.second && continue

            if a != 0
                val1 = a * latter_point.first + b
                val2 = a * former_point.first + b
                denominator = a * (p + 1)
                result += ((val1^(p + 1)) - (val2^(p + 1))) / denominator
            else
                # here, a==0, so it is constant, then integral is fragment_length* (constant^power)
                val1 = latter_point.first - former_point.first
                val2 = latter_point.second
                result += val1 * (val2^p)
            end
        end
    end
    return result
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

# Operations on landscapes <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Other functions  >>>

function computeParametersOfALine(p1::MyPair, p2::MyPair)
    a = (p2.second - p1.second) / (p2.first - p1.first)
    b = p1.second - a * p1.first
    return MyPair(a, b)
end

# Other functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-


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
