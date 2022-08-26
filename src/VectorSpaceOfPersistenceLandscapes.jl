#=
This script contains a structure that is used to craete average lansdcape
fro a vector of landscapes

=#

import Base.size

# ===-===-
struct VectorSpaceOfPersistenceLandscapes
    vectOfLand::Vector{PersistenceLandscape}
end

function Base.size(vec_space::VectorSpaceOfPersistenceLandscapes;dim=1)
    return length(vec_space.vectOfLand)
end

# ===-===-
function averageLandscpceInDiscreteSetOfPoints(v_space_pland::VectorSpaceOfPersistenceLandscapes, dim::UInt, numberOfPoints::UInt, from_num::Float64, to::Float64; local_dbg=false)  # vector<pair<double,double> >

    if numberOfPoints <= 1
        errMessage = "Error in function averageLandscpceInDiscreteSetOfPoints. You want to compute average using : $(numberOfPoints) points. This variable cannot be less than 2 \n"
        throw( errMessage )
    end
    if to <= from

        errMessage << "Error in function averageLandscpceInDiscreteSetOfPoints. You want to compute average inrval [$(from),$(to)]. Please correct the vinterval in a way that it is in a form [from,to], where from <to"
        throw( errMessage )
    end

    result = MyPair[]

    for i = 1 : numberOfPoints-1
        result[i] = make_pair( from+(to-from)*i/(numberOfPoints-1) , 0 )
    end
    result[numberOfPoints-1] = make_pair( to , 0 )

    if local_dbg
        println("Initial values:")
        for i = 1 : numberOfPoints

            print("( $(result[i]) ) , ")
        end
        println()
    end

    for i = 1 : size(v_space_pland.vectOfLand,1)
        local_dbg &&  println("i : $(2)")
        if dim(v_space_pland.vectOfLand[i]) >= dim

             nr = 0
             it = 1
             while ( ( nr != numberOfPoints ) && ( it != size(v_space_pland.vectOfLand[i].land[dim],1) )  )

                if local_dbg
                    println("nr : $(nr) , it : $(it) , numberOfPoints : $(numberOfPoints) , v_space_pland.vectOfLand[i].land[dim].size() : $(2)")
                     println( "v_space_pland.vectOfLand[i].land[dim][it-1].first : $(2)")
                     println( "v_space_pland.vectOfLand[i].land[dim][it].first : $(2)")
                     println("result[nr].first : $(2)")
                end
                if (v_space_pland.vectOfLand[i].land[dim][it-1].first <= result[nr].first) && (v_space_pland.vectOfLand[i].land[dim][it].first >= result[nr].first)

                    result[nr].second += functionValue( v_space_pland.vectOfLand[i].land[dim][it-1] , v_space_pland.vectOfLand[i].land[dim][it] , result[nr].first )
                    nr += 1
                    continue
                 end
                 if result[nr].first > v_space_pland.vectOfLand[i].land[dim][it].first
                     it += 1
                     continue
                 end
            end
        end
    end

    if local_dbg
        println("Before averaging \n")
        for i = 1 : numberOfPoints
            println("( $(result[i]) ) , ")
        end
    end

    for i = 1 : numberOfPoints
        result[i].second /= size(v_space_pland.vectOfLand,1)
    end

    if local_dbg
        println("After averaging \n")
        for i = 1 : numberOfPoints
            println("( $(result[i]) ) , ")
        end
    end

    return result
end


function average(x::PersistenceLandscape...; dbg = false)::PersistenceLandscape
    v_space_pland = VectorSpaceOfPersistenceLandscapes([x1 for x1 in x])
    return average(v_space_pland, dbg=dbg)
end

function two_element_average(x, y)
   (x+y)/2
end

function average(v_space_pland::VectorSpaceOfPersistenceLandscapes; dbg = false)::PersistenceLandscape
    # size(v_space_pland.vectOfLand,1) == 0 && return PersistenceLandscape()
    size(v_space_pland.vectOfLand,1) == 0 && return []

    result = Any[]

    if useGridInComputations
        #finding maxN such that lambda_n exist
        maxN = 0
        for i = 1 : size(v_space_pland.vectOfLand,1)
            if maxN < size(v_space_pland.vectOfLand[i],1)
                maxN = size(v_space_pland.vectOfLand[i],1)
            end
        end
        dbg && println("Maximal nonzero lambda : $(maxN)")

        #for every lambda:
        for lambda = 0 : maxN
            dbg && println("Considering lambda : $(lambda)")
            #initialize and set up the counter:
            counter= VectorSpaceOfPersistenceLandscapes[]
            for i = 1 : size(v_space_pland.vectOfLand,1)
                push!(counter) = 1
            end

            thisLambda = MyPair[]
            push!(thisLambda,  make_pair( -Inf , 0 ) )
            while ( true )
                #now we need to iterate through the counter.
                whichIndicesShouldBeIncremented = Any[]
                valueInThisPoint = 0
                min_x = Inf

                for i = 1 : size(counter,1)
                    lambda >= size(v_space_pland.vectOfLand[i].land,1) && continue
                    counter[i] >= size(v_space_pland.vectOfLand[i].land[lambda],1) && continue

                    if v_space_pland.vectOfLand[i].land[lambda][counter[i]].first < min_x
                        #we found new point with smaller x coordinate. Whatever we had before that have the be zeored.
                        whichIndicesShouldBeIncremented = Any[]
                        valueInThisPoint = 0
                        push!(whichIndicesShouldBeIncremented, i)
                        min_x = v_space_pland.vectOfLand[i].land[lambda][counter[i]].first
                        valueInThisPoint += v_space_pland.vectOfLand[i].land[lambda][counter[i]].second
                    else
                        if v_space_pland.vectOfLand[i].land[lambda][counter[i]].first == min_x
                            valueInThisPoint += v_space_pland.vectOfLand[i].land[lambda][counter[i]].second
                            push!(whichIndicesShouldBeIncremented, i)
                        end
                    end
                end

                #if we cannot find any new point, that means that we are done.
                (min_x == Inf) && break
                push!(thisLambda,  make_pair( min_x , valueInThisPoint/size(v_space_pland.vectOfLand,1) ) )

                dbg && println("Adding to lambda : $(min_x) , $(valueInThisPoint/size(v_space_pland.vectOfLand,1))")

                for i = 1 : size(whichIndicesShouldBeIncremented, 1)
                    counter[ whichIndicesShouldBeIncremented[i] ] += 1
                end
            end
            push!(thisLambda,  make_pair( Inf , 0 ) )
            result.push!(land,  thisLambda )
        end
    else
        #compute average as a linear combination of PL functions
        nextLevelMerge = copy(v_space_pland.vectOfLand)

        # for i = 1 : size(v_space_pland.vectOfLand,1)
        #     nextLevelMerge[i] = v_space_pland.vectOfLand[i]
        # end

        # While there are no new levels to merge (so for single loop we process whole level to be merged)
        while ( size(nextLevelMerge, 1) != 1 )
            dbg && println("size(nextLevelMerge, 1) : $(size(nextLevelMerge, 1))")

            # a placeholder for new layer (merged with all previous layers?)
            nextNextLevelMerge = PersistenceLandscape[]
            # for every second layer- but why every second layer? because they are pairwise merged? yes
            # a pair of vector is merged and then pushed to the vector, in next while iteration it will be merged wit
            # another merge of 2 layers
            for i = 1:2:size(nextLevelMerge, 1)
                dbg && println("i : $(i)\nsize(nextLevelMerge, 1) : $(size(nextLevelMerge, 1))")

                # l = PersistenceLandscape[]
                if i+1 != size(nextLevelMerge, 1) +1
                    l = operationOnPairOfLandscapes(nextLevelMerge[i],nextLevelMerge[i+1], two_element_average)
                else
                    l = nextLevelMerge[i]
                end
                # l_divided = divide_layer(l)
                # push!(nextNextLevelMerge, l_divided )
                push!(nextNextLevelMerge, l)
            end
            dbg && println("After this iteration \n")

            nextLevelMerge = nextNextLevelMerge
        end
        result = nextLevelMerge[1]
    end
    return result
end

function divide_layer(l::PersistenceLandscape)
    final_layers_collection = Vector{Vector{MyPair}}()
    for layer in l.land
        layer_vector = MyPair[]
        for element in layer
            second= element.second/2
            push!(layer_vector, MyPair(element.first, second))
        end
        push!(final_layers_collection, layer_vector)
    end
    return PersistenceLandscape(final_layers_collection, l.dimension)
end



function standardDeviation(v_space_pland::VectorSpaceOfPersistenceLandscapes; whichDistance::String="regular")
    av = average(v_space_pland)
    distanceToAverage = 0

    for i = 1 : size(v_space_pland.vectOfLand,1)
        if whichDistance == "regular"
            #L^whichDistance distance
            distance = computeDiscanceOfLandscapes(av, v_space_pland.vectOfLand[i], 1)
        elseif whichDistance == "maxNorm"
            #L^infty distance
            distance = computeMaxNormDiscanceOfLandscapes(av, v_space_pland.vectOfLand[i], 0)
        end
        # distanceToAverage += distance*distance
        distanceToAverage += distance^2
    end
    deviation = sqrt(distanceToAverage/size(v_space_pland.vectOfLand,1))
    return deviation
end#standardDeviation

