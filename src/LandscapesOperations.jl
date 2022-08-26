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
    return land[l][size(land[l], 1)-2].first
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

# TODO -- removewhen the problem is respved
function check(i::UInt, v::Vector{MyPair})
    if i < 0 || i >= size(v, 1)
        println("you want to get to index:size($(i) $(v)) indices")
        # cin.ignore()
        return true
    end
    return false
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

# TODO is this function needed?
function multiplyLanscapeByRealNumberOverwrite(land::PersistenceLandscape, x::Float64)
    for dim = 0:size(land, 1)
        for i = 0:size(land.land[dim], 1)
            land.land[dim][i].second *= x
        end
    end
end
