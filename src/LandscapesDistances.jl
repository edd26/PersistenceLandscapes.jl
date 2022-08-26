#=
Module with all functions that compute distances of landscapes
=#
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

