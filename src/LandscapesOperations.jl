#=
Module with functions that operate on PersistenceLandscapes
=#

## ===-===-===-
# Basic operations >>>
# TODO Add depreciation for this function
function addTwoLandscapes(
    land1::PersistenceLandscape,
    land2::PersistenceLandscape,
)::PersistenceLandscape
    return operationOnPairOfLandscapes(land1, land2, +)
end

# TODO Add depreciation for this function
function subtractTwoLandscapes(
    land1::PersistenceLandscape,
    land2::PersistenceLandscape,
)::PersistenceLandscape
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

function ==(lhs::PersistenceLandscape, rhs::PersistenceLandscape; operatorEqualDbg = false)
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

function Base.size(land::PersistenceLandscape)
    return size(land.land, 1)
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
function computeIntegralOfLandscape(
    in_land::PersistenceLandscape,
    p::Real;
    local_dbg = false,
)
    result = 0
    for land_layer in in_land.land
        for (former_point, latter_point) in zip(land_layer[1:(end - 1)], land_layer[2:end])

            # In this interval, the landscape has a form f(x) = ax+b. We want to compute integral of (ax+b)^p, which is [(ax+b)^(p+1)]/(ap+a)
            coef = computeParametersOfALine(latter_point, former_point)
            a = coef.first
            b = coef.second

            # Points have same 1st coordinate, so their integral is equal to 0
            latter_point.first == former_point.first && continue

            # Not in original code: if landscapes are spaced, don't count the space in between them
            # 0 == latter_point.second == former_point.second && continue

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


function abs_pl(in_landscape::PersistenceLandscape; local_debug = false)
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

            local_debug &&
                println("in_landscape.land[$(level)][$(x_index)] : $(land_layer[x_index])")

            # if a line segment between land.land[level][i-1] and this->land[level][i] crosses the x-axis, then we have to add one landscape point to result
            previous_point = land_layer[x_index - 1]
            y_previous_step = previous_point.second
            current_point = land_layer[x_index]
            y_current_step = current_point.second
            if (y_previous_step * y_current_step) < 0
                # function below is not yet julia valid
                zero = findZeroOfALineSegmentBetweenThoseTwoPoints(
                    previous_point,
                    current_point,
                )
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

function operationOnPairOfLandscapes(
    in_land1::PersistenceLandscape,
    in_land2::PersistenceLandscape,
    oper;
    local_dbg = false,
)
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
                    element_before = land2.land[i][q - 1]
                end
                end_value =
                    functionValue(element_before, land2.land[i][q], land1.land[i][p].first)
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
                    element_before = land1.land[i][p - 1]
                end
                end_value =
                    functionValue(land1.land[i][p], element_before, land2.land[i][q].first)
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
            local_dbg && println(
                "New point : $(land1.land[i][p].first)  oper(land1.land[i][p].second,0) : $(oper_result)",
            )

            new_pair = MyPair(land1.land[i][p].first, oper_result)

            push!(lambda_n, new_pair)
            p += 1
        end

        # this while covers case when there are no vectors left in land1 and there some left in land2
        # original +1 was changed to -1
        while (p >= size(land1.land[i], 1)) && (q <= size(land2.land[i], 1))
            @debug "third while loop, p: $(p), q: $(q)"

            oper_result = oper(0, land2.land[i][q].second)
            local_dbg && println(
                "New point : $(land2.land[i][q].first) oper(0,land2.land[i][q].second) : $(oper_result)",
            )

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
        local_dbg &&
            println("size(land1.land,1) > $(min( size(land1.land,1), size(land2.land,1) ))")

        result = append_nonoverlapping_elements(
            result,
            land1,
            stop_val,
            start_val,
            oper;
            zero_tailing = true,
            zero_start = false,
        )
    elseif is_land2_longer()
        @debug "second if modifier"
        local_dbg && println(
            "( size(land2.land,1) > $(min( size(land1.land,1) , size(land2.land,1))) ",
        )

        result = append_nonoverlapping_elements(
            result,
            land2,
            stop_val,
            start_val,
            oper;
            zero_tailing = false,
            zero_start = true,
        )
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

function append_nonoverlapping_elements!(
    result,
    selected_land::PersistenceLandscape,
    stop_val,
    start_val,
    oper;
    zero_tailing = false,
    zero_start = false,
)
    # append results with all layers that are in selected_land and are between stop val and start val

    # TODO check if the new method does the same as the old one -> it didnt
    for lambda_n in selected_land.land[start_val:stop_val]

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

# Basic operations <<<
## ===-===-===-
function multiplyByIndicatorFunction(
    land::PersistenceLandscape,
    indicator::Vector{MyPair};
    local_dbg::Bool = false,
)
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
                    println(
                        "land.land[dim][nr] : $(land.land[dim][nr].first) $(land.land[dim][nr].second)",
                    )
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
                    push!(
                        lambda_n,
                        make_MyPair(
                            indicator[dim].second,
                            functionValue(
                                land.land[dim][nr - 1],
                                land.land[dim][nr],
                                indicator[dim].second,
                            ),
                        ),
                    )
                    push!(lambda_n, make_MyPair(indicator[dim].second, 0))
                    break
                end
                if (land.land[dim][nr].first >= indicator[dim].first) &&
                   (land.land[dim][nr - 1].first <= indicator[dim].first)
                    if (local_dbg)
                        println("Entering the indicator")
                    end
                    push!(lambda_n, make_MyPair(indicator[dim].first, 0))
                    push!(
                        lambda_n,
                        make_MyPair(
                            indicator[dim].first,
                            functionValue(
                                land.land[dim][nr - 1],
                                land.land[dim][nr],
                                indicator[dim].first,
                            ),
                        ),
                    )
                end
                if (local_dbg)
                    println("We are here")
                end
                push!(
                    lambda_n,
                    make_MyPair(land.land[dim][nr].first, land.land[dim][nr].second),
                )
            end
        end
        push!(lambda_n, make_MyPair(0, -Inf))
        if size(lambda_n, 1) > 2
            result.land.push_back(lambda_n)
        end
    end
    return result
end

function gimmeProperLandscapePoints(land::PersistenceLandscape)::Vector{MyPair}
    result = MyPair[]
    for level = 1:size(land, 1)
        v = MyPair(land[level].begin() + 1, land[level].end() - 1)
        push!(result, v)
    end
    return result
end

function comparePairsForMerging(first::MyPair, second::MyPair)
    return (first.first < second.first)
end

function generateBettiNumbersHistogram(
    land::PersistenceLandscape;
    dbg = false,
)::PersistenceLandscape
    resultRaw = MyPair[]

    for dim = 0:size(land, 1)
        rangeOfLandscapeInThisDimension = MyPair[]
        if dim > 0
            for i = 1:(size(land.land[dim], 1) - 1)
                if land.land[dim][i].second == 0
                    push!(
                        rangeOfLandscapeInThisDimension,
                        make_MyPair(land.land[dim][i].first, dim + 1),
                    )
                end
            end
        else
            # dim == 0.
            first = true
            for i = 1:(size(land.land[dim], 1) - 1)
                if land.land[dim][i].second == 0
                    if first
                        push!(
                            rangeOfLandscapeInThisDimension,
                            make_MyPair(land.land[dim][i].first, 0),
                        )
                    end
                    push!(
                        rangeOfLandscapeInThisDimension,
                        make_MyPair(land.land[dim][i].first, dim + 1),
                    )
                    if (!first)
                        push!(
                            rangeOfLandscapeInThisDimension,
                            make_MyPair(land.land[dim][i].first, 0),
                        )
                    end
                    first = !first
                end
            end
        end
        # vector< std::pair<, unsigned > > resultRawNew( resultRaw.size() + rangeOfLandscapeInThisDimension.size() )
        resultRawNew = MyPair[]

        resultRaw = sort(
            vcat(
                resultRaw.begin(),
                resultRaw.end(),
                rangeOfLandscapeInThisDimension.begin(),
                rangeOfLandscapeInThisDimension.end(),
                resultRawNew.begin(),
            ),
            comparePairsForMerging,
        )

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
        push!(result, resultRaw[i - 1])
        if resultRaw[i - 1].second <= resultRaw[i].second
            push!(result, make_MyPair(resultRaw[i].first, resultRaw[i - 1].second))
        else
            push!(result, make_MyPair(resultRaw[i - 1].first, resultRaw[i].second))
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
            if (size(resultNew) == 0) || (size(resultNew[resultNew - 1].second) <= minBetti)
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

function computeInnerProduct(l1::PersistenceLandscape, l2::PersistenceLandscape; dbg = true)
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
            a =
                (l1.land[level][l1It + 1].second - l1.land[level][l1It].second) /
                (l1.land[level][l1It + 1].first - l1.land[level][l1It].first)

            b = l1.land[level][l1It].second - a * l1.land[level][l1It].first

            c =
                (l2.land[level][l2It + 1].second - l2.land[level][l2It].second) /
                (l2.land[level][l2It + 1].first - l2.land[level][l2It].first)

            d = l2.land[level][l2It].second - c * l2.land[level][l2It].first

            contributionFromThisPart =
                (a * c * x2 * x2 * x2 / 3 + (a * d + b * c) * x2 * x2 / 2 + b * d * x2) -
                (a * c * x1 * x1 * x1 / 3 + (a * d + b * c) * x1 * x1 / 2 + b * d * x1)

            result += contributionFromThisPart
            if dbg
                println(
                    "[l1.land[level][l1It].first,l1.land[level][l1It+1].first] : $(l1.land[level][l1It].first), $(l1.land[level][l1It+1].first)",
                )
                println(
                    "[l2.land[level][l2It].first,l2.land[level][l2It+1].first] : $(l2.land[level][l2It].first), $(l2.land[level][l2It+1].first)",
                )
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

            if x2 == l1.land[level][l1It + 1].first
                if x2 == l2.land[level][l2It + 1].first
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
            if l1.land[level][l1It + 1].first < l2.land[level][l2It + 1].first
                x2 = l1.land[level][l1It + 1].first
            else
                x2 = l2.land[level][l2It + 1].first
            end
        end
    end
    return result
end


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
    return land[l][size(land[l], 1) - 2].first
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
function computeNthMoment(
    land::PersistenceLandscape,
    n::UInt,
    center,
    level::UInt;
    local_debug = false,
)
    if n < 1
        println(
            "Cannot compute n-th moment for  n = $(n << ". The program will now terminate")",
        )
        throw("Cannot compute n-th moment. The program will now terminate")
    end
    result = 0
    if size(land, 1) > level
        for i = 2:(size(land.land[level], 1) - 1)
            if land.land[level][i].first - land.land[level][i - 1].first == 0
                continue
            end
            # between land.land[level][i] and land.land[level][i-1] the lambda_level is of the form ax+b. First we need to find a and b.
            a =
                (land.land[level][i].second - land.land[level][i - 1].second) /
                (land.land[level][i].first - land.land[level][i - 1].first)
            b = land.land[level][i - 1].second - a * land.land[level][i - 1].first
            x1 = land.land[level][i - 1].first
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
        for i = 1:(size(land.land[level], 1) - 1)
            if land.land[level][i].second < epsi
                continue
            end
            # check if over land.land[level][i].first-land.land[level][i].second , land.land[level][i].first+land.land[level][i].second] there are level barcodes.
            nrOfOverlapping = 0
            for nr = 1:size(b.barcodes, 1)
                if (
                    b.barcodes[nr].first - epsi <=
                    land.land[level][i].first - land.land[level][i].second && (
                        b.barcodes[nr].second + epsi >=
                        land.land[level][i].first + land.land[level][i].second
                    )
                )
                    nrOfOverlapping += 1
                end
            end
            if nrOfOverlapping != level + 1
                println("We have a problem :")
                println("land.land[level][i].first : $(land.land[level][i].first)")
                println("land.land[level][i].second : $(land.land[level][i].second)")
                println(
                    "[$(land.land[level][i].first-land.land[level][i].second) $(land.land[level][i].first+land.land[level][i].second)]",
                )
                println("level : $(level) , nrOfOverlapping: $(nrOfOverlapping)")
                # getchar()
                for nr = 1:size(b.barcodes, 1)
                    if (
                        b.barcodes[nr].first <=
                        land.land[level][i].first - land.land[level][i].second && (
                            b.barcodes[nr].second >=
                            land.land[level][i].first + land.land[level][i].second
                        )
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

# TODO -- removewhen the problem is respved
function check(i::UInt, v::Vector{MyPair})
    if i < 0 || i >= size(v, 1)
        println("you want to get to index:size($(i) $(v)) indices")
        # cin.ignore()
        return true
    end
    return false
end

function computeIntegralOfLandscapeMultipliedByIndicatorFunction(
    land::PersistenceLandscape,
    indicator::Vector{MyPair},
)
    l = multiplyByIndicatorFunction(land, indicator)
    return l.computeIntegralOfLandscape()
end

function computeIntegralOfLandscapeMultipliedByIndicatorFunction(
    land::PersistenceLandscape,
    indicator::Vector{MyPair},
    p::Float64,
) # this function compute integral of p-th power of landscape.
    l = multiplyByIndicatorFunction(land, indicator)
    return computeIntegralOfLandscape(l, p)
end

# This is a standard function which pairs maxima and minima which are not more than epsilon apart.
# This algorithm do not reduce all of them, just make one passage through data. In order to reduce all of them
# use the function reduceAllPairsOfLowPersistenceMaximaMinima(epsilon )
# WARNING! THIS PROCEDURE MODIFIES THE LANDSCAPE!!!
function removePairsOfLocalMaximumMinimumOfEpsPersistence(
    land::PersistenceLandscape,
    epsilon::Float64,
)
    numberOfReducedPairs = 0
    for dim = 0:size(land, 1)
        (2 > land.land[dim].size() - 3) && continue #  to make sure that the loop in below is not infinite.
        for nr = 2:(size(land.land[dim], 1) - 3)
            if (
                abs_pl(land.land[dim][nr].second - land.land[dim][nr + 1].second) < epsilon
            ) && (land.land[dim][nr].second != land.land[dim][nr + 1].second)
                # right now we modify only the lalues of a points. That means that angles of lines in the landscape changes a bit. This is the easiest computational
                # way of doing this. But I am not sure if this is the best way of doing such a reduction of nonessential critical points. Think about this!
                if land.land[dim][nr].second < land.land[dim][nr + 1].second
                    land.land[dim][nr].second = land.land[dim][nr + 1].second
                else
                    land.land[dim][nr + 1].second = land.land[dim][nr].second
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
        numberOfReducedPoints =
            removePairsOfLocalMaximumMinimumOfEpsPersistence(land, epsilon)
    end
end


# Yet another function to smooth up the data. The idea of this one is as follows. Let us take a landscape point A which is not (+infty,0), (-infty,0) of (a,0), (b,0), where a and b denotes the
# points which support of the function begins and ends. Let B and C will be the landscape points after A. Suppose B and C are also no one as above.
# The question we are asking here is -- can we remove the point B and draw a line from A to C such that the difference in a landscape will be not greater than epsilon?
# To measure the penalty of removing B, the funcion penalty. In below, the simplese example is given:
function penalty(A::MyPair, B::MyPair, C::MyPair)
    return abs(functionValue(A, C, B.first) - B.second)
end# penalty

function reducePoints(
    land::PersistenceLandscape,
    tollerance,
    penalty;
    local_debug = false,
)::PersistenceLandscape

    numberOfPointsReduced = 0
    for dim = 0:size(land, 1)
        nr = 1
        lambda_n = MyPair[]
        local_debug && println("Adding point to lambda_n : $(land.land[dim][0])")
        push!(lambda_n, land.land[dim][0])
        while (nr <= land.land[dim].size() - 2)
            local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")
            push!(lambda_n, land.land[dim][nr])
            if penalty(
                land.land[dim][nr],
                this -> land[dim][nr + 1],
                this -> land[dim][nr + 2],
            ) < tollerance
                nr += 1
                numberOfPointsReduced += 1
            end
            nr += 1
        end
        local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")
        local_debug && println("Adding point to lambda_n : $(land.land[dim][nr])")

        push!(lambda_n, land.land[dim][this -> land[dim].size() - 2])
        push!(lambda_n, land.land[dim][this -> land[dim].size() - 1])

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

# this is O(log(n)) algorithm, where n is number of points in land.land.
function computeValueAtAGivenPoint(
    land::PersistenceLandscape,
    level::UInt,
    x::Float64;
    local_dbg = false,
)
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
        println(
            "land.land[level][coordBegin].first : $(land.land[level][coordBegin].first)",
        )
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
            println(
                "land.land[level][coordBegin].first : $(land.land[level][coordBegin].first)",
            )
            println(
                "land.land[level][coordEnd].first : $(land.land[level][coordEnd].first)",
            )
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
        println(
            "x : $(x) is between : $(land.land[level][coordBegin].first) $(land.land[level][coordEnd].first))",
        )
        println(
            "the y coords are : $(land.land[level][coordBegin].second) $(land.land[level][coordEnd].second)",
        )
        println("coordBegin : $(coordBegin)")
        println("coordEnd : $(coordEnd)")
    end
    return functionValue(land.land[level][coordBegin], land.land[level][coordEnd], x)
end

# TODO is this function needed?
function multiplyLanscapeByRealNumberOverwrite(land::PersistenceLandscape, x::Float64)
    for dim = 0:size(land, 1)
        for i = 0:size(land.land[dim], 1)
            land.land[dim][i].second *= x
        end
    end
end

# It may happened that some landscape points obtained as a aresult of an algorithm lies in a line. In this case, the following procedure allows to
# remove unnecesary points.
function reduceAlignedPoints(land::PersistenceLandscape, tollerance; local_debug = false)# this parapeter says how much the coeficients a and b in a formula y=ax+b may be different to consider points aligned.
    for dim = 0:size(land, 1)
        nr = 1
        lambda_n = MyPair[]
        push!(lambda_n, land.land[dim][0])
        while (nr != land.land[dim].size() - 2)
            # first, compute a and b in formula y=ax+b of a line crossing land.land[dim][nr] and land.land[dim][nr+1].
            res = computeParametersOfALine(land.land[dim][nr], land.land[dim][nr + 1])
            if local_debug
                println(
                    "Considering points : $(land.land[dim][nr]) and $(land.land[dim][nr+1])",
                )
                println("Adding : $(land.land[dim][nr] << " to lambda_n.")")
            end
            push!(lambda_n, land.land[dim][nr])
            a = res.first
            b = res.second
            i = 1
            while (nr + i != land.land[dim].size() - 2)
                local_debug && println(
                    "Checking if : $(land.land[dim][nr+i+1]) is aligned with them )",
                )

                res1 =
                    computeParametersOfALine(land.land[dim][nr], land.land[dim][nr + i + 1])
                if (abs(res1.first - a) < tollerance) && (abs(res1.second - b) < tollerance)
                    local_debug && println("It is aligned ")
                    i += 1
                else
                    local_debug && println("It is NOT aligned ")
                    break
                end
            end
            local_debug && println(
                "We are out of the while loop. The number of aligned points is : $(i)",
            ) # std::cin.ignore())")
            nr += i
        end
        if local_debug
            println("Out  of main while loop, done with this dimension ")
            println("Adding:size($(land.land[dim][size(land.land[dim],1)-2 ]) to lamnda_n ")
            println("Adding:size($(land.land[dim][size(land.land[dim],1)-1 ]) to lamnda_n ")
        end

        @error "Some code needs to be fixed in here"
        push!(lambda_n, land.land[dim][land.land[dim].size() - 2])
        push!(lambda_n, land.land[dim][land.land[dim].size() - 1])
        # if something was reduced, then replace land.land[dim] with the new lambda_n.

        if size(lambda_n, 1) < size(land.land[dim])
            if size(lambda_n, 1) > 4
                land.land[dim] = lambda_n
            end
        end
    end
end


# Operations on landscapes <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-



function multiplyLanscapeByRealNumberNotOverwrite(land::PersistenceLandscape, x::Real)
    result = Vector{Vector{MyPair}}()
    for dim = 1:size(land)
        lambda_dim = MyPair[]
        for i = 1:size(land.land[dim], 1)
            push!(
                lambda_dim,
                make_MyPair(land.land[dim][i].first, x * land.land[dim][i].second),
            )
        end

        push!(result, lambda_dim)
    end
    # CHANGE
    # res.land = result
    return PersistenceLandscape(result, land.dimension)
end# multiplyLanscapeByRealNumberOverwrite
