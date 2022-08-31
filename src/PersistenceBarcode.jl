#=
Module with PersistentBarcode structure and all related functions
=#
# TODO remove all functions that operate on MyPair only, as they should be placed in MyPair module

import Base.size, Base.isempty, Base.copy, Base.sort

"""
Structure to hold information about persistence barcodes:
- barcodes- vector where elements are barcodes. Each barcodes is a pair of
    numbers, where first one is the birth time, second one is the death time
- dimensionOfBarcode - is the dimension for which all of the barcodes were generated

TODO rename MyPair to Point2D
TODO create a structure Barcode from Point2D (a level of abstraction)
"""
struct PersistenceBarcodes
    barcodes::Vector{MyPair}
    dimensionOfBarcode::Int

    function PersistenceBarcodes(bars::Vector{MyPair}, number::Real)
        new(PersistenceBarcodes(bars).barcodes, Int(number))
    end

    # This hould be transformed into constructor from matrix nx2
    # function PersistenceBarcodes(pers_barcode::PersistenceBarcodes,  vect::Vector, dimensionOfBarcode::UInt )
    #     1+1
    #     # *this = PersistenceBarcodes(vect);
    #     # pers_barcode.dimensionOfBarcode = dimensionOfBarcode;
    # end

    # This is constructor function and should be put in the struct
    function PersistenceBarcodes(pers_barcode::PersistenceBarcodes)
        # @info typeof(pers_barcodes.barcodes)
        # @info typeof(pers_barcodes.dimensionOfBarcode)
        new(pers_barcode.barcodes, Int(pers_barcode.dimensionOfBarcode))
    end

    function PersistenceBarcodes(bars::Vector{MyPair})
        total_pairs = size(bars, 1)
        infty = Inf
        dimensionOfBarcode = 0
        # sizeOfBarcode = 0 # ::UInt


        for i = 1:total_pairs
            # if ( bars[i].second != infty )
            #     sizeOfBarcode += 1
            # end
            if (bars[i].second < bars[i].first)
                bars[i] = MyPair(bars[i].second, bars[i].first)
            end
        end

        barcodes = MyPair[] #  ( sizeOfBarcode );
        nr = 1 # ::Unt
        for i = 1:total_pairs
            if (bars[i].second != infty)
                # this is a finite interval
                push!(barcodes, MyPair(bars[i].first, bars[i].second))
                nr += 1
            end
            # to keep it all compact for now I am removing infinite intervals from consideration.
            #=else
                # this is infinite interval:
                barcodes[i] =  MyPair( bars[i].first, INT_MAX );
            }=#
        end
        barcodes = sort(barcodes)

        # CHANGE
        new(barcodes, Int(dimensionOfBarcode))
    end

    function PersistenceBarcodes(filename::String, startin_point::Float64, step::Float64)
        barcodes = MyPair[]
        infty = Inf
        dimensionOfBarcode = 0
        open(filename, "r") do io
            # read till end of file
            while !eof(io)
                s = readline(io)
                splitted = split(s, " ")
                beginning = splitted[1]
                ending = splitted[2]
                if ending != infty
                    if ending < beginning
                        z = ending
                        ending = beginning
                        beginning = z
                    end
                    if (beginning != ending)
                        push!(
                            barcodes,
                            MyPair(
                                startin_point + beginning * step,
                                startin_point + ending * step,
                            ),
                        )
                    end
                end
            end
        end

        new(barcodes, Int(dimensionOfBarcode))
    end

    function PersistenceBarcodes(filename::String, dimensionOfBarcode::Int)
        my_pairs = MyPair[]
        open(filename, "r") do io
            # read till end of file
            while !eof(io)
                s = readline(f)
                splitted = split(s, " ")
                push!(my_pairs, MyPair(splitted[1], splitted[2]))
            end
        end

        new(barcodes, Int(dimensionOfBarcode))
    end
end

# to write individual bar
# function ostream& operator<<(ostream& out, MyPairp )
#     out << p.first << " " << p.second;
#     return out;
# end


# this class represent a barcodes in a given dimension.
# class PersistenceBarcodes


# ===-===-===-
# public:

# friend MyPair< , vector< pair< pair,pair> > > computeBottleneckDistance( first, PersistenceBarcodes& second::Float64, unsigned p ::PersistenceBarcodes);

# function ostream& operator<<(ostream& out, bar ::PersistenceBarcodes)
# function operator_to_std(out::ostream, bar::PersistenceBarcodes) # operator<<
"""
Prints the PersistenceBarcodes structure to the output.
"""
function operator_to_std(out, bar::PersistenceBarcodes) # operator<<

    for i = 0:size(bar.barcodes, 1)
        println("$(bar.barcodes[i].first) $(bar.barcodes[i].second)")
    end
    # return out;
end

# tested
"""
Return how many barcodes are there in the structure.
"""
function Base.size(pers_barcode::PersistenceBarcodes)
    return length(pers_barcode.barcodes)
end

# tested
"""
Returns a PersistenceBarcodes structure which is a copy of an input structure.
"""
function Base.copy(pers_barcode::PersistenceBarcodes)
    return PersistenceBarcodes(pers_barcode.barcodes, pers_barcode.dimensionOfBarcode)
end


# function Base.isempty(pers_barcode::PersistenceBarcodes)::Bool
#     return length(pers_barcode.barcodes) == 0
# end

# tested
"""
Returns the dimension of PersistenceBarcodes structure.
"""
function dim(pers_barcode::PersistenceBarcodes)::Int
    return pers_barcode.dimensionOfBarcode
end

# iterators
# typedef vector< MyPair>::iterator bIterator;
# function  bBegin(pers_barcode) # ::bIterator
#     return pers_barcode.barcodes.begin()
# end

# function bEnd(pers_barcode) # ::bIterator
#     return pers_barcode.barcodes.end()
# end

# ===-===-===-

# function plot(pers_barcode::PersistenceBarcodes,  filename::String )

# # this program create a gnuplot script file that allows to plot persistence diagram.
# ofstream out;
#
# ostringstream nameSS;
# nameSS << filename << "_GnuplotScript";
# string nameStr = nameSS.str();
#
# out.open( (char*)nameStr.c_str() );
# MyPairminMaxValues = pers_barcode.minMax();
# out << "set xrange [" << minMaxValues.first - 0.1*(minMaxValues.second-minMaxValues.first) << " :" << minMaxValues.second + 0.1*(minMaxValues.second-minMaxValues.first) << " ]" << endl;
# out << "set yrange [" << minMaxValues.first - 0.1*(minMaxValues.second-minMaxValues.first) << " :" << minMaxValues.second + 0.1*(minMaxValues.second-minMaxValues.first) << " ]" << endl;
#
# # out << "set xrange [0:40]" << endl;
# # out << "set yrange [0:40]" << endl;
#
# out << "plot '-' using 1:2 title \"" << filename << "\", \\" << endl;
# out << "     '-' using 1:2 notitle with lp" << endl;
# for i = 0:size(pers_barcode.barcodes,1)
#
#     out << pers_barcode.barcodes[i].first << " " << pers_barcode.barcodes[i].second << endl;
# end
# out << "EOF" << endl;
# out << minMaxValues.first - 0.1*(minMaxValues.second-minMaxValues.first) << " " << minMaxValues.first - 0.1*(minMaxValues.second-minMaxValues.first) << endl;
# out << minMaxValues.second + 0.1*(minMaxValues.second-minMaxValues.first) << " " << minMaxValues.second + 0.1*(minMaxValues.second-minMaxValues.first) << endl;
# # out << "0 0" << endl << "40 40" << endl;
# out.close();
#
# cout << "Gnuplot script to visualize persistence diagram written to the file:" << nameStr << ". Type load '" << nameStr << "' in gnuplot to visualize." << endl;
# end


# tested
"""
Remove barcodes from 'pers_barcode' which begin before 'number'
"""
function removeBarcodesThatBeginsBeforeGivenNumber(
    pers_barcode::PersistenceBarcodes,
    number::Int,
)
    newBarcodes = MyPair[]

    for i = 1:length(pers_barcode.barcodes)
        if pers_barcode.barcodes[i].first > number
            push!(newBarcodes, pers_barcode.barcodes[i])
        else
            # pers_barcode.barcodes[i].first <= number
            if (pers_barcode.barcodes[i].second > number)
                push!(newBarcodes, MyPair(number, pers_barcode.barcodes[i].second))
            end
            # in the opposite case pers_barcode.barcodes[i].second <= in which case, we totally ignore this point.
        end
    end
    # pers_barcode.barcodes.swap(newBarcodes);
    return PersistenceBarcodes(newBarcodes, pers_barcode.dimensionOfBarcode)
end


# tested
"""
Split the lifespan of barcodes into 'numberOfBins' bins and refactor bars such that
their birth and death is one of the bins.

This works as follows:
- create barcode with earliest birth and latests death in 'pers_barcode'
- split the range into 'numberOfBins' bins
- get unit barcode length, that is (latest death - earliest birth)/numberOfBins
- for each barcode from 'pers_barcode':
    - get index of the bin where is the barcode born
    - get index of the bin where the barcode dies
    - create a new barcode with birth equal to (unit length) * (birth index) and
        death equal to (unit length) * (death index)
"""
function putToBins(pers_barcode::PersistenceBarcodes, numberOfBins; dbg::Bool=false)
    myPair_minMax = minMax(pers_barcode)
    binnedData = MyPair[]
    dx = (myPair_minMax.second - myPair_minMax.first) / numberOfBins #::Float64

    if dbg
        println("Min : $(myPair_minMax.first)")
        println("Max : $(myPair_minMax.second)")
        println("dx :$(dx)")
    end

    for i = 1:size(pers_barcode.barcodes, 1)
        leftBinNumber = floor((pers_barcode.barcodes[i].first - myPair_minMax.first) / dx)
        rightBinNumber = floor((pers_barcode.barcodes[i].second - myPair_minMax.first) / dx)

        leftBinEnd = myPair_minMax.first + (leftBinNumber + 0.5) * dx #::Float64
        rightBinEnd = myPair_minMax.first + (rightBinNumber + 0.5) * dx #::Float64

        if leftBinEnd != rightBinEnd
            push!(binnedData, MyPair(leftBinEnd, rightBinEnd))
        end

        if dbg
            println(
                "( $(pers_barcode.barcodes[i].first), $(pers_barcode.barcodes[i].second)) gets mapped to ($(leftBinEnd), $(rightBinEnd)",
            )
            # getchar();
        end
    end

    # pers_barcode.barcodes.swap(binnedData);
    return PersistenceBarcodes(binnedData, pers_barcode.dimensionOfBarcode)
end


"""
Sort barcodes is descending order of birth (if the same, then longer lived are beofre shorter lived).
"""
function Base.sort(pers_barcode::PersistenceBarcodes; rev::Bool=false)
    # sorted = sort([1:mat_size;], by=i->(sorted_values[i],matrix_indices[i]))
    # sorted = sort(pers_barcode.barcodes, lt = compareMyPairs)
    sorted = sort(pers_barcode.barcodes, lt=isless)

    if rev
        sorted = [sorted[k] for k = size(sorted, 1):-1:1]
    end
    # sort( pers_barcode.barcodes.begin() , pers_barcode.barcodes.end() , compareMyPairs );
    return PersistenceBarcodes(sorted, pers_barcode.dimensionOfBarcode)
end

function Base.sort(bars::Vector{MyPair})
    return sort(bars, lt=isless)
end

# tested
"""
Check if two PersistenceBarcodes structures are exactly the same.

- return false if size is mismatched
- sort both PersistenceBarcodes structures
- return false if any of pairs is not exactly the same
- return tru if none of above applies
"""
function compare(
    pers_barcode::PersistenceBarcodes,
    b::PersistenceBarcodes;
    dbg::Bool=false
)::Bool
    if (dbg)
        println("pers_barcode.barcodes.size(): $(size(pers_barcode.barcodes,1))")
        println("b.barcodes.size(): $(size(b.barcodes,1))")
    end

    if (size(pers_barcode.barcodes, 1) != size(b.barcodes, 1))
        # @info "size missmatch"
        return false
    end

    sorted_pers_barcode = sort(pers_barcode)
    sorted_b = sort(b)
    for i = 1:size(sorted_pers_barcode.barcodes, 1)
        if sorted_pers_barcode.barcodes[i] != b.barcodes[i]
            # println("sorted_pers_barcode.barcodes[$(i)] = $(sorted_pers_barcode.barcodes[i])")
            # println("sorted_b.barcodes[$(i)] = $(sorted_b.barcodes[i])")
            # getchar();
            return false
        end
    end
    return true
end

"""
Rerurn a strucure which is smaller.

- reurn f if f<s
- return s otherwise
"""
function minn(f, s)
    (f < s) && return f
    return s
end


"""
Reurn average midpoint of barcodes in 'pers_barcode'.

Midpoin is expressed as average of the both ends of the bar, that is (death-birth)/2

For every persistenece barcode, compute midpoint, then compute average of all midpoints.
"""
function computeAverageOfMidpointOfBarcodes(pers_barcode::PersistenceBarcodes)::Float64
    averages = 0 #::Float64
    for i = 1:size(pers_barcode.barcodes, 1)
        averages += 0.5 * (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)
    end
    averages /= size(pers_barcode.barcodes, 1)

    return averages
end# computeAverageOfMidpointOfBarcodes


"""
Return new PersistenceBarcodes structure, where midpoint of all barcoeds is 0.
"""
function setAverageMidpointToZero(pers_barcode::PersistenceBarcodes; dbg::Bool=false)

    # average = pers_barcode.computeAverageOfMidpointOfBarcodes(); #::Float64
    average = computeAverageOfMidpointOfBarcodesWeightedByLength(pers_barcode) #::Float64

    if (dbg)
        println("average : $(average)")
    end

    # shift every barcode by -average
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        push!(
            new_pairs,
            MyPair(
                pers_barcode.barcodes[i].first - average,
                pers_barcode.barcodes[i].second - average,
            ),
        )

    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

"""
Returns new PersistenceBarcodes structure in which average barcodes length from 'pers_barcode' is 1.
"""
function setAveragedLengthToOne(pers_barcode::PersistenceBarcodes)
    # first compute average length of barcode:
    sumOfLengths = 0
    for i = 1:size(pers_barcode.barcodes, 1)
        sumOfLengths +=
            abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)
    end

    # averageLength:size(:Float64 = (double)sumOfLengths / (double)pers_barcode.barcodes,1);
    averageLength = sumOfLengths / size(pers_barcode.barcodes, 1)
    # averageLength = [barcodesLength(b) for b in pers_barcode.barcodes] |> average

    # now we need to rescale the length by 1/averageLength
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        midpoint = 0.5 * (pers_barcode.barcodes[i].first + pers_barcode.barcodes[i].second) #::Float64
        my_len =
            abs(pers_barcode.barcodes[i].first - pers_barcode.barcodes[i].second) /
            averageLength #::Float64
        push!(new_pairs, MyPair(midpoint - my_len / 2, midpoint + my_len / 2))
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

"""
Returns a new PersistenceBarcodes structure where midpoint is set to 0 and average length of barcodes is 1.
"""
function averageBarcodes(pers_barcode::PersistenceBarcodes)
    # pers_barcode = setAverageMidpointToZero(pers_barcode);
    # pers_barcode = setAveragedLengthToOne(pers_barcode);
    # return pers_barcode
    pers_barcode |> setAverageMidpointToZero |> setAveragedLengthToOne
end


# TODO this has to be expressed as setRange
function setRangeToMinusOneOne(pers_barcode::PersistenceBarcodes)
    # first we need to find min and max endpoint of intervals:
    min_val = Inf #INT_MAX; #::Float64
    max_val = -Inf #INT_MAX; #::Float64
    for i = 1:size(pers_barcode.barcodes, 1)
        a = pers_barcode.barcodes[i].first #::Float64
        b = pers_barcode.barcodes[i].second #::Float64
        if b < a
            temp = copy(a)
            a = b
            b = temp
            # swap(a,b)
        end

        if a < min_val
            min_val = a
        end

        if b > max_val
            max_val = b
        end
    end

    shiftValue = -min_val #::Float64
    max_val += shiftValue
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        push!(
            new_pairs,
            MyPair(
                (pers_barcode.barcodes[i].first + shiftValue) / max_val,
                (pers_barcode.barcodes[i].second + shiftValue) / max_val,
            ),
        )
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

# TODO this has to be expressed as a restrictBarcodesToGivenInterval
function setRange(pers_barcode::PersistenceBarcodes, beginn::Real, endd::Real)
    if beginn >= endd
        throw(DomainError("Bar ranges in the setRange procedure."))
    end

    minMax_val = minMax(pers_barcode)
    new_range = endd - beginn

    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        originalBegin = pers_barcode.barcodes[i].first #::Float64
        originalEnd = pers_barcode.barcodes[i].second #::Float64

        newBegin =
            beginn +
            (originalBegin - minMax_val.first) * new_range /
            (minMax_val.second - minMax_val.first) #::Float64
        newEnd =
            beginn +
            (originalEnd - minMax_val.first) * new_range /
            (minMax_val.second - minMax_val.first) #::Float64

        push!(new_pairs, MyPair(newBegin, newEnd))
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end


function computeAverageOfMidpointOfBarcodesWeightedByLength(
    pers_barcode::PersistenceBarcodes,
)::Float64
    averageBarcodeLength = 0.0 #::Float64

    for i = 1:size(pers_barcode.barcodes, 1)
        averageBarcodeLength +=
            (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)
    end

    averageBarcodeLength /= size(pers_barcode.barcodes, 1)

    weightedAverageOfBarcodesMidpoints = 0 #::Float64
    for i = 1:size(pers_barcode.barcodes, 1)
        weight =
            (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) /
            averageBarcodeLength #::Float64
        weightedAverageOfBarcodesMidpoints +=
            weight *
            0.5 *
            (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)
    end

    weightedAverageOfBarcodesMidpoints /= size(pers_barcode.barcodes, 1)

    # YTANIE< CZY TO MA SENS???
    return weightedAverageOfBarcodesMidpoints
end # computeAverageOfMidpointOfBarcodesWeightedByLength







"""
Returns new PersistenceBarcodes structure where all barcodes from 'pers_barcode' which lenght is smaller than
'minimalDiameterOfBarcode' are removed.
"""
function removeShortBarcodes(
    pers_barcode::PersistenceBarcodes,
    minimalDiameterOfBarcode::Real,
)

    cleanedBarcodes = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        if (
            abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) >
            minimalDiameterOfBarcode
        )
            push!(cleanedBarcodes, pers_barcode.barcodes[i])
        end
    end
    return PersistenceBarcodes(cleanedBarcodes, pers_barcode.dimensionOfBarcode)
end

"""
Returns new PersistenceBarcodes structure where birth and death times are restruced to 'interval'
"""
function restrictBarcodesToGivenInterval(
    pers_barcode::PersistenceBarcodes,
    interval::MyPair,
)::PersistenceBarcodes
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes, 1)
        if pers_barcode.barcodes[i].first >= interval.second
            @debug "First condition met"
            continue
        end
        if pers_barcode.barcodes[i].second <= interval.first
            @debug "Second condition met"
            continue
        end
        push!(
            new_pairs,
            MyPair(
                max(interval.first, pers_barcode.barcodes[i].first),
                min(interval.second, pers_barcode.barcodes[i].second),
            ),
        )
    end
    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

# function operator=(pers_barcode::PersistenceBarcodes,  rhs ::PersistenceBarcodes)::PersistenceBarcodes
#
#     # cout << "Before :size(" << pers_barcode.barcodes,1) << "\n";
#
#     pers_barcode.dimensionOfBarcode = rhs.dimensionOfBarcode;
#     pers_barcode.barcodes.clear();
#     pers_barcode.barcodes.insert( pers_barcode.barcodes.begin() , rhs.barcodes.begin() , rhs.barcodes.end() );
#
#     # cout << "after :size(" << pers_barcode.barcodes,1) << "\n";
#     # cin.ignore();
#
#     return *this;
# end

"""
Create a barcode for which:
- birth is the earliest birth in the 'pers_barcode structure'
- death is the latests death in the 'pers_barcode structure'

NOTE! This needs to be verified.
"""
function minMax(pers_barcode::PersistenceBarcodes)
    bmin = Inf # INT_MAX; #::Float64
    bmax = -Inf # INT_MIN; #::Float64
    for i = 1:size(pers_barcode.barcodes, 1)
        if pers_barcode.barcodes[i].first < bmin
            bmin = pers_barcode.barcodes[i].first
        end
        if pers_barcode.barcodes[i].second > bmax
            bmax = pers_barcode.barcodes[i].second
        end
    end
    return MyPair(bmin, bmax)
end # minMax


function computeLandscapeIntegralFromBarcodes(pers_barcode::PersistenceBarcodes)::Float64
    result = 0 #::Float64
    for i = 1:size(pers_barcode.barcodes, 1)
        a = pers_barcode.barcodes[i].second
        b = pers_barcode.barcodes[i].first
        result += (a - b)^2
    end
    result *= 0.25
    return result
end

# TODO2 -- consider adding some instructions to remove anything that is not numeric from the input stream.
# function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String)



function produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction(
    pers_barcode::PersistenceBarcodes,
    step::Int,
    minn::Float64,
    maxx::Float64;
    dbg::Bool=false
)::Vector{Int}

    if (minn == Inf)
        minMax_val = minMax(pers_barcode)
    else
        minMax_val = MyPair(minn, maxx)
    end

    bettiNumbers = zeros(Int, step)# (step+1);
    # for j = 1:step
    #     pusbettiNumbers[j] = 0;
    # end

    dx = (minMax_val.second - minMax_val.first) / step # ::Float64

    for i = 1:size(pers_barcode.barcodes, 1)
        @debug "i :size($(i), size(pers_barcode.barcodes,1)  $(pers_barcode.barcodes)"
        @debug "For a interval :$(pers_barcode.barcodes[i])we have : \n"

        first = (pers_barcode.barcodes[i].first - minMax_val.first) / dx
        second = (pers_barcode.barcodes[i].second - minMax_val.first) / dx

        @debug first, second
        # @debug getchar()
        for j = floor(Int, first):1:ceil(Int, second)
            bettiNumbers[j] += 1
        end
    end

    return bettiNumbers
end# produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction


#endif

# ===-===-===-===-===-===-===-===-===-===-===-
# File operations >>>
# not tested

function writeBarcodesSortedAccordingToLengthToAFile(
    pers_barcode::PersistenceBarcodes,
    filename::String,
)
    #     # first sort the bars according to their length
    sorted_bars = sort(pers_barcode)

    open(filename, "w") do io
        for i = 1:size(sorted_bars, 1)
            write(io, "$(sorted_bars[i].first) $(sorted_bars[i].second)")
        end
    end
end

function writeToFile(pers_barcode::PersistenceBarcodes, filename::String)
    open(filename, "w") do io
        # TODO change this to for loop with condition that last read  line was EOF line
        for i = 1:size(sorted_bars, 1)
            write(
                io,
                "$(pers_barcode.barcodes[i].first) $(pers_barcode.barcodes[i].second)",
            )
        end
    end
end

function putToAFileHistogramOfBarcodesLengths(
    pers_barcode::PersistenceBarcodes,
    filename::String,
    howMany::Real,
    shouldWeAlsoPutResponsibleBarcodes::Bool,
)

    barsLenghts = Any[]
    for i = 1:size(pers_barcode.barcodes, 1)
        bar_diff = abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)

        push!(
            barsLenghts,
            (
                bar_diff,
                MyPair(pers_barcode.barcodes[i].first, pers_barcode.barcodes[i].second),
            ),
        )
    end

    # sorted = sort(pers_barcode.barcodes, by= x-> x[1])
    # reverse( begining(barsLenghts) , ending(barsLenghts) );
    sorted = sort(pers_barcode, rev=true)

    open(filename, "w") do io
        if shouldWeAlsoPutResponsibleBarcodes
            for i = 1:min(length(barsLenghts), howMany)
                write(
                    io,
                    "$(i) $(barsLenghts[i].first) $(barsLenghts[i].second.first) $(barsLenghts[i].second.second)",
                )
            end
        else
            for i = 1:min(length(barsLenghts), howMany)
                write(io, "$(i) $(barsLenghts[i].first)")
            end
        end
    end
end # putToAFileHistogramOfBarcodesLengths


function putToAFileHistogramOfBarcodesLengths(
    pers_barcode::PersistenceBarcodes,
    filename::String,
    beginn::Real,
    endd::Real,
    shouldWeAlsoPutResponsibleBarcodes::Bool,
)
    if beginn >= endd
        throw(
            DomainError(
                "Wrong parameters of putToAFileHistogramOfBarcodesLengths procedure. Begin points is greater that the end point. Program will now terminate",
            ),
        )
    end

    # <MyPair< double, MyPair<double,double> > > barsLenghts(this->barcodes.size());
    barsLenghts = Any[]
    for i = 1:size(pers_barcode.barcodes, 1)
        bar_diff = abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)

        push!(
            barsLenghts,
            (
                bar_diff,
                MyPair(pers_barcode.barcodes[i].first, pers_barcode.barcodes[i].second),
            ),
        )
    end
    # sorted = sort(pers_barcode.barcodes, by= x-> x[1])
    sorted = sort(pers_barcode)

    # reverse
    barsLenghts = barsLenghts[end:-1:1]

    open(filename, "w") do io
        if shouldWeAlsoPutResponsibleBarcodes
            for i = min(length(barsLenghts), beginn):min(size(barsLenghts, 1), endd)
                write(
                    io,
                    "$(i) $(barsLenghts[i].first) $(barsLenghts[i].second.first) $(barsLenghts[i].second.second)",
                )
            end
        else
            for i = min(length(barsLenghts), beginn):min(size(barsLenghts, 1), endd)
                write(io, "$(i) $(barsLenghts[i].first)")
            end
        end
    end
    #=
    vector<double> barsLenghts(pers_barcode.barcodes.size());
    for i = 0:size(pers_barcode.barcodes,1)
        barsLenghts[i] = fabs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end
    sort( begining(barsLenghts) , ending(barsLenghts) );
    reverse( begining(barsLenghts) , ending(barsLenghts) );
    ofstream file;
    file.open(filename);
    for i = minn(barsLenghts.size(),beginn):size(minn(barsLenghts,1),endd)
        file << i << " " << barsLenghts[i] << endl;
    end
    file.close();
    =#
end # putToAFileHistogramOfBarcodesLengths


# function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String, startin_point::Float64, step::Float64)

# File operations <<<


# /*
# this function ocmpute L^p bottleneck distance beteen diagrams.
# MyPair< double , < MyPair< MyPair<double,double> , MyPair<double,double> > > >
# This will have to be added
# https://github.com/Gnimuc/Hungarian.jl
function computeBottleneckDistance(
    first::PersistenceBarcodes,
    second::PersistenceBarcodes,
    p::Int;
    local_debug::Bool=false
)

    # If first and second have different sizes, then I want to rename them in the way that first is the larger one:
    firstBar = MyPair(firstBar.end(), first.barcodes.begin(), first.barcodes.end())
    secondBar = MyPair(secondBar.end(), second.barcodes.begin(), second.barcodes.end())

    if local_debug
        @debug "size(firstBar)  : $(size(firstBar))"
        @debug "size(secondBar)  : $(size(secondBar))"
    end

    # Result = char[(size(firstBar)+size(secondBar))];
    # some_array = zeros(Int[(size(firstBar)+size(secondBar))];

    for i = 0:(size(firstBar)+size(secondBar))
        Result[i] = zeros((size(firstBar) + size(secondBar)))
        some_array[i] = zeros((size(firstBar) + size(secondBar)))
    end

    #=
    to illustrate how the matrix is create let us look at the following
    example. Suppose one set of bars consist of two points A, B, and another
    consist of a single point C.
     The matrix should look like this in that case:
            |      A       |      B      |  diag( C )  |
       C    |    d(A,C)    |   d(A,B)    | d(C,diag(C))|
     diag(A)| d(A,diag(A)) |    0        |  0          |
     diag(B)|     0        |d(B,diag(B)) |  0          |

     Therefore as one can clearly see, the matrix can be parition in to 4 essential parts:
         P1 | P2
         P3 | P4
     Where:
     P1 -- submatrix of distances between points
     P2 -- Distances from 'barcodes C' to diagonal
     P3 -- distances from 'barcodes a&B' to diagonal
     P4 -- matrix of zeros.

     this implementation of Hungarian algorithm accepts only int's. That is why
     I converge all the double numbers here to ints by multipling by this big
     number:
    =#

    bigNumber = 10000
    local_debug && @debug "Starting creation of cost matrix "

    for coll = 1:(size(firstBar)+size(secondBar))
        for row = 1:(size(firstBar)+size(secondBar))
            local_debug && println("row = $(row )\ncoll : $(coll )")
            if ((coll < size(firstBar)) && (row < size(secondBar)))
                # P1
                some_array[coll][row] =
                    bigNumber *
                    pow(computeDistanceOfPointsInPlane(firstBar[coll], secondBar[row]), p)

                if local_debug
                    "Region P1, computing distance between : " << firstBar[coll] <<
                    " and " << secondBar[row] << "\n"
                    "The distance is : " << some_array[coll][row]
                    "The distance is : " <<
                    computeDistanceOfPointsInPlane(firstBar[coll], secondBar[row])
                end
            end
            if ((coll >= size(firstBar)) && (row < size(secondBar)))
                # P2
                # distance between point from secondBar and its projection to diagonal
                some_array[coll][row] =
                    bigNumber * pow(
                        computeDistanceOfPointsInPlane(
                            secondBar[row],
                            projectionToDiagonal(secondBar[coll-size(firstBar)]),
                        ),
                        p,
                    )

                if local_debug
                    "Region P2, computing distance between : " << secondBar[row] <<
                    " and projection(" << secondBar[coll-size(firstBar)] <<
                    ") which is : " <<
                    projectionToDiagonal(secondBar[coll-size(firstBar)]) << "\n"
                    "The distance is : " << some_array[coll][row]
                end
            end

            if ((coll < size(firstBar)) && (row >= size(secondBar)))
                # distance between point from firstBar and its projection to diagonal
                some_array[coll][row] =
                    (int)bigNumber * pow(
                        computeDistanceOfPointsInPlane(
                            firstBar[coll],
                            projectionToDiagonal(firstBar[row-size(secondBar)]),
                        ),
                        (double)p,
                    )
                if local_debug
                    println(
                        "Region P3, computing distance between : $(firstBar[coll]) and projection($(firstBar[row-size(secondBar)])  which is : $(projectionToDiagonal(firstBar[row-size(secondBar)]))",
                    )

                    println("The distance is : $(some_array[coll][row])")
                end
            end
            if ((coll >= size(firstBar)) && (row >= size(secondBar)))
                # P4
                local_debug && println("Region P4, set to infinitey")
                some_array[coll][row] = 0
            end
            # if (local_debug)
            #      # stop wih user inpu
            # end
        end
    end

    if local_debug
        for i = 1:(size(firstBar)+size(secondBar))
            for j = 0:(size(firstBar)+size(secondBar))
                print("$(some_array[y][x]) ")
            end
            println()
        end
        "Matrix has been created\n"
        # stop wih user inpu
    end



    cost = hungarian(
        some_array,
        Result,
        (size(firstBar) + size(secondBar)),
        (size(firstBar) + size(secondBar)),
    )
    if local_debug
        for y = 0:(size(firstBar)+size(secondBar))
            for x = 0:(size(firstBar)+size(secondBar))
                print("$(Result[y][x]) ")
            end
            println()
        end
    end

    # < MyPair< MyPair<double,double> , MyPair<double,double> > > matching;
    matching = MyPair[]

    for y = 0:(size(firstBar)+size(secondBar))
        for x = 0:(size(firstBar)+size(secondBar))
            if (Result[x][y])
                store = false
                if (x < size(firstBar))
                    local_debug && print(firstBar[x])
                    store = true
                else
                    local_debug && print("projection($(secondBar[x - size(firstBar)] )")
                end
                local_debug && print(" is paired with")
                if (y < size(secondBar))
                    local_debug && print(secondBar[y])
                    store = true
                else
                    v:(lua.s_tab_complete()local_debug) &&
                        print("projection( $(firstBar[y - size(secondBar)])")
                end
                local_debug && println()

                if (store)
                    # at least one element in not from diagonal:
                    push!(matching, MyPair(firstBar[x], secondBar[y]))
                end
            end
        end
    end

    # MyPair< double , < MyPair< MyPair<double,double>,MyPair<double,double> > > > result = std::make_pair( pow(cost/(double)bigNumber,1/(double)p) , matching );
    result = MyPair(pow(cost / (double)bigNumber, 1 / (double)p), matching)
    return result
end
