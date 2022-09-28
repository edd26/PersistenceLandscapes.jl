#=
Main module that contains constructors of PersistenceLandsacpe structure.

ATM also contains basic operations on lnadscapes: +, -, *, /, ==
=#
import Base.:+, Base.:-, Base.:*, Base.:/, Base.==

struct PersistenceLandscape
    land::Vector{Vector{MyPair}} # for empty one use a = Vector{Vector{MyPair}}()
    # land is a sorted list L_k of the points (x, lambda_k(x))
    dimension::Int

    # ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
    # Constructors >>>
    function PersistenceLandscape(landscapePointsWithoutInfinities::Vector{Vector{MyPair}})
        land = get_landscape_form_vectors(landscapePointsWithoutInfinities)
        new(land, 0)
    end

    function PersistenceLandscape(
        landscapePointsWithoutInfinities::Vector{Vector{MyPair}},
        dim::Number,
    )
        land = get_landscape_form_vectors(landscapePointsWithoutInfinities)
        new(land, dim)
    end

    function PersistenceLandscape(p::PersistenceBarcodes)
        land = create_PersistenceLandscape(p)
        new(land, p.dimensionOfBarcode)
    end

    function PersistenceLandscape(p::PersistenceBarcodes, dim::Number)
        land = create_PersistenceLandscape(p)
        new(land, dim)
    end
end

function get_landscape_form_vectors(
    landscapePointsWithoutInfinities::Vector{Vector{MyPair}};
    allow_inf_intervals=false
)
    land = Vector{Vector{MyPair}}()
    for level = 1:size(landscapePointsWithoutInfinities, 1)
        v = landscapePointsWithoutInfinities[level]
        if allow_inf_intervals
            if !(MyPair(-Inf, 0) in v)
                v = vcat(MyPair(-Inf, 0), v)
            end
            if !(MyPair(Inf, 0) in v)
                v = vcat(v, MyPair(Inf, 0))
            end
        end
        push!(land, v)
    end
    return land
end

function create_PersistenceLandscape(p::PersistenceBarcodes; useGridInComputations=false)
    # @debug "PersistenceLandscape(PersistenceBarcodes& p )"

    land = Vector{Vector{MyPair}}()
    if useGridInComputations
        land = constructLandscapeWithGrids(p)
    else
        land = noGridsLandscapesConstructor(p)
    end

    return land
end

function getCharacterisitcPoints(bars)
    characteristicPoints = MyPair[]
    # for i = 1:size(bars, 1)
    for bar in bars
        p_beg = (bar.first + bar.second) / 2
        p_end = (bar.second - bar.first) / 2
        new_pair = MyPair(p_beg, p_end)

        push!(characteristicPoints, new_pair)
    end
    return characteristicPoints
end

function subSelectCharacteristicPoints(point, subset_characteristicPoints, birth_oper, death_oper)
    barcodes = vcat([[x |> birth x |> death] for x in subset_characteristicPoints]...)
    point_barcode = [point |> birth point |> death]
    b_cond = birth_oper.(barcodes[:, 1], point_barcode[1, 1])
    d_cond = death_oper.(barcodes[:, 2], point_barcode[1, 2],)
    final_condition = b_cond .&& d_cond

    # birth_condition = birth_oper.(birth(point), birth.(subset_characteristicPoints))
    # # death_condition = death_oper.(death.(subset_characteristicPoints), death(point),)
    # death_condition = death_oper.(death(point), death.(subset_characteristicPoints),)

    # final_condition = birth_condition .&& death_condition
    # final_condition = birth_condition .|| death_condition

    if any(i -> i, final_condition)
        selected_points = subset_characteristicPoints[final_condition]
    else
        selected_points = Vector{MyPair}[]
    end
    return selected_points
end

# This is code smell
# function getPointsBeforeCharacteristic(point, subset_characteristicPoints)
#     subSelectCharacteristicPoints(point, subset_characteristicPoints, almostEqual, <=)
# end

# This is code smell
# function getPointsAfterCharacteristic(point, subset_characteristicPoints)
#     subSelectCharacteristicPoints(point, subset_characteristicPoints, <=, >=)
# end

function appendEndOfSection!(lambda_n, lambda_death, cp_birth)
    push!(lambda_n, MyPair(lambda_death, 0))
    push!(lambda_n, MyPair(cp_birth, 0))
    # return vcat(lambda_n,
    #             [MyPair(lambda_death , 0),
    #              MyPair(cp_birth, 0)]
    #            )
end

function getLambdaFromCharacteristicPoints(characteristicPoints)
end

function beginNewLambda(first_point)

    return [#MyPair(min_birth, 0),
        MyPair(first_point |> birth, 0),
        first_point]
end

function appendLastPoint!(lambda_n)
    last_death = lambda_n[end] |> death
    push!(lambda_n, MyPair(last_death, 0))
end

function appendInfIntervals(labmda::Vector{MyPair})
    return [MyPair(-Inf, 0), lambda_n, MyPair(Inf, 0)]
end

function get_landscape_dip(cp_birth, lambda_death)
    p_start = (cp_birth + lambda_death) / 2
    p_stop = (lambda_death - cp_birth) / 2
    point = MyPair(p_start, p_stop)
    return point
end

function drop_form_stack!(stack_of_points, point)::Vector{MyPair}
    point_position = findfirst(x -> x == point, stack_of_points)
    deleteat!(stack_of_points, point_position)
end

"""
Appending last point is necessary for this structure of code to work,
especially, when inf intervals are disabled.
"""
function getNthLambda(characteristicPoints; allow_inf_intervals::Bool=false)

    stack_of_points = copy(characteristicPoints)
    # ===-===-
    lambda_n = beginNewLambda(characteristicPoints[1])
    drop_form_stack!(stack_of_points, lambda_n[2])

    newCharacteristicPoints = MyPair[]

    # this while loop should be removing points from structure and iterate while there are points left
    # while (i <= total_characteristic_points)
    #     # @debug "running for i: $(i) and size of char points $(size(characteristicPoints, 1)+1)"
    #     iter = 1 # last_lambda_n = size(lambda_n, 1)
    #     cp_birth = birth(characteristicPoints[i])
    #     cp_death = death(characteristicPoints[i])
    while !(stack_of_points |> isempty)

        cp_birth = birth(stack_of_points[1])
        cp_death = death(stack_of_points[1])
        lambda_birth = birth(lambda_n[end])
        lambda_death = death(lambda_n[end])
        does_it_belong_to_lambda_n = (cp_birth >= lambda_birth) && (cp_death > lambda_death)

        if does_it_belong_to_lambda_n
            # does it happen within this hill?
            # what needs to be done when its true?
            # get indentation
            # push indentation to the lambda
            # add indentation to characteristic points
            # push point to the lambda
            if cp_birth < lambda_death
                point = get_landscape_dip(cp_birth, lambda_death)

                push!(lambda_n, point)
                # add point to characteristic points at position of i

                # push those poitns which have almost equal birth and that have death larger than point
                # get anything that starts at the same point and is smaller in length
                selected_points = subSelectCharacteristicPoints(point, stack_of_points, almostEqual, <=)
                newCharacteristicPoints = vcat(newCharacteristicPoints, selected_points)

                for point in selected_points
                    drop_form_stack!(stack_of_points, point)
                end

                push!(newCharacteristicPoints, point)

                selected_points = subSelectCharacteristicPoints(point, stack_of_points, <, >=)

                newCharacteristicPoints = vcat(newCharacteristicPoints, selected_points)
                for point in selected_points
                    drop_form_stack!(stack_of_points, point)
                end
            else # cp_birth >= lambda_death
                appendEndOfSection!(lambda_n, lambda_death, cp_birth)
            end

            if !(stack_of_points |> isempty)
                push!(lambda_n, stack_of_points[1])
                drop_form_stack!(stack_of_points, stack_of_points[1])
            end
            # @debug "6 Adding to lambda_n : ($(characteristicPoints[i]))"
        else # it does not belong to lambda n
            # push!(newCharacteristicPoints, characteristicPoints[i])
            push!(newCharacteristicPoints, stack_of_points[1])
            drop_form_stack!(stack_of_points, stack_of_points[1])
            # @debug "7 Adding to newCharacteristicPoints : ($(characteristicPoints[i]))"
        end
        # i = i + iter
    end

    appendLastPoint!(lambda_n)

    if allow_inf_intervals
        lambda_n = appendInfIntervals(labmda_n)
    end

    lambda_n = lambda_n |> unique # This function slows down computation signifficantly
    newCharacteristicPoints = newCharacteristicPoints |> unique # This function slows down computation signifficantly
    return lambda_n, newCharacteristicPoints
end

### ==-===-
"""
Generate layers of landscape from barcodes.

This is a general algorithm to construct persistence landscapes.
"""
function noGridsLandscapesConstructor(p::PersistenceBarcodes;)
    # min_birth = min([k.first for k in p.barcodes |> sort]...)


    # Apply sorting so that: first is increasing with index; if equal, then larger second are first
    characteristicPoints = p.barcodes |>
                           sort |>
                           getCharacterisitcPoints

    land = Vector{Vector{MyPair}}()
    while (!isempty(characteristicPoints))
        lambda_n, characteristicPoints = getNthLambda(characteristicPoints)
        push!(land, lambda_n)
    end
    return land
end

function constructLandscapeWithGrids(p::PersistenceBarcodes; allow_inf_intervals=false)

    land = Vector{Vector{MyPair}}()
    # # @debug "Constructing persistence landscape based on a grid"# getchar())

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
        push!(aa, MyPair(-Inf, 0))
    end

    x = minMax_val.first
    for i = 0:numberOfBins
        v = Float64[]
        # pair<, vector<double> > p = std::MyPair( x , v )
        p = (x, v)
        push!(aa, MyPair(x, 0))
        push!(criticalValuesOnPointsOfGrid[i], p)
        # @debug "x : $(x)"
        x += 0.5 * gridDiameter
    end

    if allow_inf_intervals
        push!(aa, MyPair(Inf, 0))
    end
    # @debug "Grid has been created. Now, begin to add intervals"
    # for every peristent interval
    for ervalNo = 0:size(p, 1)
        beginn =
            ()(2 * (p.barcodes[intervalNo].first - minMax_val.first) / (gridDiameter)) + 1
        # @debug "We are considering interval : [$(p.barcodes[intervalNo].first),$(p.barcodes[intervalNo].second) $(beginn) in the grid",
        while (criticalValuesOnPointsOfGrid[beginn].first < p.barcodes[intervalNo].second)
            # @debug "Adding a value : ($(criticalValuesOnPointsOfGrid[beginn].first) $(min( abs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,abs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ))) ",
            criticalValuesOnPointsOfGrid[beginn].second.push_back(
                min(
                    abs(
                        criticalValuesOnPointsOfGrid[beginn].first -
                        p.barcodes[intervalNo].first,
                    ),
                    abs(
                        criticalValuesOnPointsOfGrid[beginn].first -
                        p.barcodes[intervalNo].second,
                    ),
                ),
            )
            beginn += 1
        end
    end
    # now, the basic structure is created. We need to translate it to a persistence landscape data structure.
    # To do so, first we need to sort all the vectors in criticalValuesOnPointsOfGrid[i].second
    maxNonzeroLambda = 0
    for i = 0:size(criticalValuesOnPointsOfGrid, 1)
        sort(
            criticalValuesOnPointsOfGrid[i].second.begin(),
            criticalValuesOnPointsOfGrid[i].second.end(),
            greater < int > (),
        )
        if criticalValuesOnPointsOfGrid[i].second.size() > maxNonzeroLambda
            maxNonzeroLambda = criticalValuesOnPointsOfGrid[i].second.size()
        end
    end
    if false
        # @debug "After sorting"
        for i = 0:size(criticalValuesOnPointsOfGrid, 1)
            # @debug "x : $(criticalValuesOnPointsOfGrid[i].first): "
            for j = 0:size(criticalValuesOnPointsOfGrid[i].second, 1)
                # @debug "$(criticalValuesOnPointsOfGrid[i].second[j])"
            end
        end
    end
    push!(land, aa)
    for lambda = 0:maxNonzeroLambda
        # @debug "Constructing lambda_$(lambda)"
        nextLambbda = MyPair[]

        push!(nextLambbda, MyPair(INT_MIN, 0))

        # for every element in the domain for which the previous landscape is nonzero.
        wasPrevoiusStepZero = true
        nr = 1
        while nr < size(land.land[size(land, 1)-1]) - 1
            # @debug "nr : $(nr)"
            address = ()(
                2 * (land.land[size(land, 1)-1][nr].first - minMax_val.first) /
                (gridDiameter),
            )
            # @debug "We are considering the element x : $(land.land[ size(land,1)-1 ][nr].first). Its position in the structure is : $(address)",
            if criticalValuesOnPointsOfGrid[address].second.size() <= lambda
                if (!wasPrevoiusStepZero)
                    wasPrevoiusStepZero = true
                    # @debug "AAAdding : ($(criticalValuesOnPointsOfGrid[address].first) $(0)) to lambda_$(lambda)",
                    push!(
                        nextLambbda,
                        MyPair(criticalValuesOnPointsOfGrid[address].first, 0),
                    )
                end
            else
                if wasPrevoiusStepZero
                    # @debug "Adding : ($(criticalValuesOnPointsOfGrid[address-1].first) $(0)) to lambda_$(lambda)",
                    push!(
                        nextLambbda,
                        MyPair(criticalValuesOnPointsOfGrid[address-1].first, 0),
                    )
                    wasPrevoiusStepZero = false
                end
                # @debug "AAdding : ($(criticalValuesOnPointsOfGrid[address].first) $(criticalValuesOnPointsOfGrid[address].second[lambda])) to lambda_$(lambda)",
                push!(
                    nextLambbda,
                    MyPair(
                        criticalValuesOnPointsOfGrid[address].first,
                        criticalValuesOnPointsOfGrid[address].second[lambda],
                    ),
                )
            end
            nr += 1
        end

        # @debug "Done with : lambda_$(lambda)"

        if lambda == 0
            # removing the first, fake, landscape
            land.land.clear()
        end
        push!(nextLambbda, MyPair(INT_MAX, 0))
        nextLambbda.erase(unique(nextLambbda.begin(), nextLambbda.end()), nextLambbda.end())
        push!(land, nextLambbda)
    end
    return land
end
# Constructor form file
function create_PersistenceLandscape(
    land::PersistenceLandscape,
    filename::String;
    allow_inf_intervals::Bool=false
)
    land_vecto = copy(land.land)
    # @debug "Using constructor : PersistenceLandscape $(filename)"

    if !isfile(filename)
        println("The file : $(filename) do not exist. The program will now terminate")
        throw(
            SystemError(
                "File not exist, please consult output of the program for further details.",
            ),
        )
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


                push!(landscapeAtThisLevel, MyPair(beginning, ending))
                # @debug "Reading a pont : $(beginning), $(ending)"
                if false
                    # @debug "IGNORE LINE"
                    if !isThisAFirsLine
                        if allow_inf_intervals
                            push!(landscapeAtThisLevel, MyPair(Inf, 0))
                        end
                        push!(land_vecto, landscapeAtThisLevel)
                        landscapeAtThisLevel = MyPair[]
                    end
                    if allow_inf_intervals
                        push!(landscapeAtThisLevel, MyPair(-Inf, 0))
                    end
                    isThisAFirsLine = false
                end
            end
        end
    end
    if size(landscapeAtThisLevel, 1) > 1
        # seems that the last line of the file is not finished with the newline sign. We need to put what we have in landscapeAtThisLevel to the constructed landscape.
        if allow_inf_intervals
            push!(landscapeAtThisLevel, MyPair(Inf, 0))
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

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CAUTION, this procedure do not work yet. Please do not use it until this warning is removed.
# PersistenceBarcodes PersistenceLandscape::convertToBarcode()
# function body removed

function computeLandscapeOnDiscreteSetOfPoints(
    land::PersistenceLandscape,
    b::PersistenceBarcodes,
    dx,
)
    miMa = minMax(b)
    bmin = miMa.first
    bmax = miMa.second
    # @debug "bmin: $(bmin) $(bmax)"
    result = Vector{Vector{MyPair}}()
    x = bmin
    i = 0
    while (x <= bmax)
        v = Float64[]
        result[i] = MyPair(x, v)
        x += dx / 2.0
        i += 1
    end

    # @debug "Vector initally filled in"

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
    # @debug "Now we fill in the suitable vecors in this landscape"
    land = Vector{Vector{MyPair}}()
    for dim = 0:indexOfLastNonzeroLandscape
        land[dim].push_back(MyPair(-Inf, 0))
    end
    i = 0
    for x = bmin:bmax
        for nr = 0:size(result[i].second, 1)
            land[nr].push_back(MyPair(result[i].first, result[i].second[nr]))
        end
        i += 1
    end
    for dim = 0:indexOfLastNonzeroLandscape
        land[dim].push_back(MyPair(Inf, 0))
    end
    land.land.clear()
    land.land.swap(land)
    land.reduceAlignedPoints()
end

