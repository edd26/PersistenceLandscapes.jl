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
