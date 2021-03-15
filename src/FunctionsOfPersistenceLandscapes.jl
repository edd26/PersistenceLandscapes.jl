include("PersistenceLandscape.jl")

#functions of landscape:
#integral
#maximum
#moments
#number of nonzero landscapes


function computeIntegral(l::PersistenceLandscape)

    return computeIntegralOfLandscape(l,);
end#computeIntegral

function maximum(l::PersistenceLandscape)

    return computeMaximum(l,);
end#maximum

function firstMomentOfFirstLandscapeCenteredAtZero(l::PersistenceLandscape)

    return computeNthMoment(l, 1 , 0 , 0 );
end#firstMomentCenteredAtZero

function secondMomentOfFirstLandscapeCenteredAtZero(l::PersistenceLandscape)

    return computeNthMoment(l, 2 , 0 , 0 );
end#firstMomentCenteredAtZero

function thirdMomentOfFirstLandscapeCenteredAtZero(l::PersistenceLandscape)

    return computeNthMoment(l, 3 , 0 , 0 );
end#firstMomentCenteredAtZero

function fourthMomentOfFirstLandscapeCenteredAtZero(l::PersistenceLandscape)

    return computeNthMoment(l, 4 , 0 , 0 );
end#firstMomentCenteredAtZero

function numberOfNonzeroLandscapes(l::PersistenceLandscape)

    return size(l);
end#numberOfNonzeroLandscapes

function userFunction(l::PersistenceLandscape)

    #Please implement your function here:
    return pi
end#numberOfNonzeroLandscapes


function averageBarcodeLength( b::PersistenceBarcodes)
    av = 0;
    for  i in b
        av += abs(i.second - i.first);
    end
    av = av / size(b)
    return av;
end

function maxLengthBarcode( b::PersistenceBarcodes)
    maxL = 0;
    for i in b
        if maxL < abs(i.second - i.first)
            maxL = abs(i.second - i.first)
        end
    end
    return maxL;
end


# TODO -- after adding any function to the above collection, please add it to the string and a function below that allows to choose suitable function by the user:
listOfAvailableFunctions = """
The available functions are:
1 - computeIntegral
2 - maximum
3 - firstMomentOfFirstLandscapeCenteredAtZero
4 - secondMomentOfFirstLandscapeCenteredAtZero
5 - thirdMomentOfFirstLandscapeCenteredAtZero
6 - fourthMomentOfFirstLandscapeCenteredAtZero
7 - numberOfNonzeroLandscapes
8 - user defined function, please go to the file functionsOfPersistenceLandscapes.h to define it\n
"""

# typedef double (*fptr)( PersistenceLandscape&);

function numberOfFunctions()
    return 8
end

function gimmeFunctionOfANumnber(numberOfFunction::Int )

    if ( (numberOfFunction <= 0) || (numberOfFunction > 7) )
        println("Wrong number of function : " << numberOfFunction << ".The program will now terminate.")
        throw("Wrong number of function, the program will now terminate.\n");
    end
    if numberOfFunction == 1
        println("Using function computeIntegral.")
        return computeIntegral;

    elseif numberOfFunction == 2
        println("Using function maximum.")
        return  maximum;

    elseif numberOfFunction == 3
        println("Using function firstMomentCenteredAtZero.")
        return firstMomentOfFirstLandscapeCenteredAtZero;

    elseif numberOfFunction == 4
        println("Using function secondMomentOfFirstLandscapeCenteredAtZero.")
        return secondMomentOfFirstLandscapeCenteredAtZero;

    elseif numberOfFunction == 5
        println("Using function thirdMomentthirdMomentCenteredAtZero.")
        return thirdMomentOfFirstLandscapeCenteredAtZero;

    elseif numberOfFunction == 6
        println("Using function fourthMomentthirdMomentCenteredAtZero.")
        return fourthMomentOfFirstLandscapeCenteredAtZero;

    elseif numberOfFunction == 7
        println("Using function numberOfNonzeroLandscapes.")
        return numberOfNonzeroLandscapes;

    elseif numberOfFunction == 8
        println("Using the function defined by the used in a file functionsOfPersistenceLandscapes.h.")
        return userFunction;

    else
        println("Unknown function, the program will now terminate.")
        throw("Unknown function, the program will now terminate.\n");
        return 0;
    end
end

