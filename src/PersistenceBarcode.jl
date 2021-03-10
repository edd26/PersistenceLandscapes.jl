
#    Copyright 2013-2014 University of Pennsylvania
#    Created by Pawel Dlotko
#
#    This file is part of Persistence Landscape Toolbox (PLT).
#
#    PLT is free software:you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    PLT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with PLT.  If not, see <http://www.gnu.org/licenses/>.

include("Configure.jl")
import Base.size, Base.isempty, Base.copy, Base.sort
# import Base.abs


# code taken from http://ranger.uta.edu/~weems/NOTES5311/hungarian.c
#include "HungarianC.h"

# tested
# struct MyPair
#     first::Float64
#     second::Float64
# end
#
# # tested
# function make_MyPair(val1, val2)
#     return MyPair(val1, val2)
# end

# tested
struct PersistenceBarcodes
    barcodes::Vector{MyPair}
    dimensionOfBarcode::UInt

    function PersistenceBarcodes(bars::Vector{MyPair}, number::Real)
        new(PersistenceBarcodes(bars).barcodes, UInt(number))
    end

    # This hould be transformed into constructor from matrix nx2
    # function PersistenceBarcodes(pers_barcode::PersistenceBarcodes,  vect::Vector , dimensionOfBarcode::UInt )
    #     1+1
    #     # *this = PersistenceBarcodes(vect);
    #     # pers_barcode.dimensionOfBarcode = dimensionOfBarcode;
    # end

    # This is constructor function and should be put in the struct
    function PersistenceBarcodes(pers_barcode::PersistenceBarcodes)
        # @info typeof(pers_barcodes.barcodes)
        # @info typeof(pers_barcodes.dimensionOfBarcode)
        new(pers_barcode.barcodes, UInt(pers_barcode.dimensionOfBarcode))
    end


    function PersistenceBarcodes(bars::Vector{MyPair})
        total_pairs = size(bars, 1)
        infty = Inf
        dimensionOfBarcode = 0;
        # sizeOfBarcode = 0 # ::UInt


        for i = 1:total_pairs
            # if ( bars[i].second != infty )
            #     sizeOfBarcode += 1
            # end
            if ( bars[i].second < bars[i].first )
                bars[i] = MyPair(bars[i].second, bars[i].first)
            end
        end

        barcodes = MyPair[] #  ( sizeOfBarcode );
        nr = 1 # ::Unt
        for i = 1:total_pairs
            if ( bars[i].second != infty )
                # this is a finite interval
                push!(barcodes, make_MyPair( bars[i].first , bars[i].second ))
                nr += 1
            end
            # to keep it all compact for now I am removing infinite intervals from consideration.
            #=else
                # this is infinite interval:
                barcodes[i] =  make_MyPair( bars[i].first , INT_MAX );
            }=#
        end
        barcodes = sort(barcodes)

        # CHANGE
        new(barcodes, UInt(dimensionOfBarcode))
    end


end


function  computeDistanceOfPointsInPlane(p1::MyPair, p2::MyPair)::Float64
    # cerr << "Computing distance of points :(" << p1.first << "," << p1.second << ") and (" << p2.first << "," << p2.second << ")\n";
    # cerr << "Distance :" << sqrt( (p1.first-p2.first)*(p1.first-p2.first) + (p1.second-p2.second)*(p1.second-p2.second) ) << "\n";
    return sqrt((p1.first-p2.first)^2 + (p1.second-p2.second)^2);
end # computeDistanceOfPointsInPlane


function projectionToDiagonal(p::MyPair )::MyPair

    return make_MyPair( 0.5*(p.first+p.second),0.5*(p.first+p.second) );
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
function operator_to_std(out, bar::PersistenceBarcodes) # operator<<

    for i = 0:size(bar.barcodes,1)
        printline("$(bar.barcodes[i].first) $(bar.barcodes[i].second)")
    end
    return out;
end

# tested
function Base.size(pers_barcode::PersistenceBarcodes)
    return length(pers_barcode.barcodes)
end

# tested
function Base.copy(pers_barcode::PersistenceBarcodes)
    return PersistenceBarcodes(pers_barcode.barcodes, pers_barcode.dimensionOfBarcode)
end


# function Base.isempty(pers_barcode::PersistenceBarcodes)::Bool
#     return length(pers_barcode.barcodes) == 0
# end

# tested
function dim(pers_barcode::PersistenceBarcodes)::UInt
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
function compareAccordingToLength( f::MyPair , s::MyPair)::Bool
    l1 = abs(f.second - f.first); #::Float64
    l2 = abs(s.second - s.first); #::Float64
    return (l1 > l2);
end

# tested
function removeBarcodesThatBeginsBeforeGivenNumber(pers_barcode::PersistenceBarcodes,  number::Int )
    newBarcodes = MyPair[]

    for i = 1:length(pers_barcode.barcodes)
        if pers_barcode.barcodes[i].first > number
            push!(newBarcodes, pers_barcode.barcodes[i])
        else
            # pers_barcode.barcodes[i].first <= number
            if ( pers_barcode.barcodes[i].second > number )
                push!(newBarcodes, make_MyPair( number , pers_barcode.barcodes[i].second) );
            end
            # in the opposite case pers_barcode.barcodes[i].second <= in which case, we totally ignore this point.
        end
    end
    # pers_barcode.barcodes.swap(newBarcodes);
    return PersistenceBarcodes(newBarcodes, pers_barcode.dimensionOfBarcode)
end


# tested
function putToBins(pers_barcode::PersistenceBarcodes, numberOfBins; dbg::Bool = false)
    myPair_minMax = minMax(pers_barcode);
    binnedData = MyPair[];
    dx = ( myPair_minMax.second - myPair_minMax.first )/numberOfBins; #::Float64

    if dbg
        println("Min : $(myPair_minMax.first)")
        println("Max : $(myPair_minMax.second)")
        println("dx :$(dx)")
    end

    for i = 1:size(pers_barcode.barcodes,1)
         leftBinNumber = floor( (pers_barcode.barcodes[i].first - myPair_minMax.first)/dx );
         rightBinNumber = floor( (pers_barcode.barcodes[i].second - myPair_minMax.first)/dx );

        leftBinEnd = myPair_minMax.first+(leftBinNumber+0.5)*dx; #::Float64
        rightBinEnd = myPair_minMax.first+(rightBinNumber+0.5)*dx; #::Float64

        if leftBinEnd != rightBinEnd
            push!(binnedData, make_MyPair(leftBinEnd , rightBinEnd) )
        end

        if dbg
            println("( $(pers_barcode.barcodes[i].first), $(pers_barcode.barcodes[i].second)) gets mapped to ($(leftBinEnd), $(rightBinEnd)")
            # getchar();
        end
    end

    # pers_barcode.barcodes.swap(binnedData);
    return PersistenceBarcodes(binnedData, pers_barcode.dimensionOfBarcode)
end

# tested
function compareMyPairs( f::MyPair, s::MyPair)::Bool

    if f.first < s.first
        return true
    end

    if f.first > s.first
        return false
    end

    if f.second < s.second
        return true
    end
    return false;
end

function Base.sort(pers_barcode::PersistenceBarcodes)
	# sorted = sort([1:mat_size;], by=i->(sorted_values[i],matrix_indices[i]))
	sorted = sort(pers_barcode.barcodes, lt= compareMyPairs)
    # sort( pers_barcode.barcodes.begin() , pers_barcode.barcodes.end() , compareMyPairs );
    return PersistenceBarcodes(sorted, pers_barcode.dimensionOfBarcode)
end

function Base.sort(bars::Vector{MyPair})
    return sort(bars, lt=compareMyPairs)
end

# tested
function compare(pers_barcode::PersistenceBarcodes,  b::PersistenceBarcodes; dbg::Bool = false)::Bool
    if ( dbg )
        println("pers_barcode.barcodes.size(): $(size(pers_barcode.barcodes,1))")
        println("b.barcodes.size(): $(size(b.barcodes,1))")
    end

    if ( size(pers_barcode.barcodes,1) != size(b.barcodes, 1) )
        # @info "size missmatch"
        return false
    end

    sorted_pers_barcode = sort(pers_barcode);
    sorted_b = sort(b);
    for i = 1:size(sorted_pers_barcode.barcodes,1)
        if sorted_pers_barcode.barcodes[i] != b.barcodes[i]
            # println("sorted_pers_barcode.barcodes[$(i)] = $(sorted_pers_barcode.barcodes[i])")
            # println("sorted_b.barcodes[$(i)] = $(sorted_b.barcodes[i])")
            # getchar();
            return false;
        end
    end
    return true;
end

function minn(f,  s )
    (f < s) && return f
    return s;
end


function computeAverageOfMidpointOfBarcodes(pers_barcode::PersistenceBarcodes)::Float64
    averages = 0; #::Float64
    for i = 1:size(pers_barcode.barcodes,1)
        averages += 0.5*(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end
    averages /= size(pers_barcode.barcodes,1);

    return averages;
end# computeAverageOfMidpointOfBarcodes


function setAverageMidpointToZero(pers_barcode::PersistenceBarcodes; dbg::Bool = false)

    # average = pers_barcode.computeAverageOfMidpointOfBarcodes(); #::Float64
    average = computeAverageOfMidpointOfBarcodesWeightedByLength(pers_barcode); #::Float64

    if (dbg)
        println("average : $(average)")
    end

    # shift every barcode by -average
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        push!(new_pairs,
              MyPair( pers_barcode.barcodes[i].first - average, pers_barcode.barcodes[i].second - average)
             )

    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

function setAveragedLengthToOne(pers_barcode::PersistenceBarcodes)
    # first compute average length of barcode:
    sumOfLengths = 0
    for i = 1:size(pers_barcode.barcodes,1)
        sumOfLengths += abs( pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first )
    end

    # averageLength:size(:Float64 = (double)sumOfLengths / (double)pers_barcode.barcodes,1);
    averageLength = sumOfLengths / size(pers_barcode.barcodes,1)

    # now we need to rescale the length by 1/averageLength
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        midpoint = 0.5 * (pers_barcode.barcodes[i].first+pers_barcode.barcodes[i].second); #::Float64
        my_len = abs( pers_barcode.barcodes[i].first - pers_barcode.barcodes[i].second )/averageLength; #::Float64
        push!(new_pairs,
              MyPair( midpoint - my_len/2, midpoint + my_len/2)
             )
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

function averageBarcodes(pers_barcode::PersistenceBarcodes, )
    pers_barcode = setAverageMidpointToZero(pers_barcode);
    pers_barcode = setAveragedLengthToOne(pers_barcode);
    return pers_barcode
end


function setRangeToMinusOneOne(pers_barcode::PersistenceBarcodes, )
    # first we need to find min and max endpoint of intervals:
    min_val = Inf #INT_MAX; #::Float64
    max_val = -Inf #INT_MAX; #::Float64
    for i = 1:size(pers_barcode.barcodes,1)
        a = pers_barcode.barcodes[i].first; #::Float64
        b = pers_barcode.barcodes[i].second; #::Float64
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

    shiftValue = -min_val; #::Float64
    max_val += shiftValue;
    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        push!(new_pairs, MyPair(
                               (pers_barcode.barcodes[i].first + shiftValue) / max_val,
                               (pers_barcode.barcodes[i].second+ shiftValue) / max_val,
                                )
             )
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end

function setRange(pers_barcode::PersistenceBarcodes,  beginn::Real, endd::Real)
    if beginn >= endd
        throw(DomainError("Bar ranges in the setRange procedure."))
    end

    minMax_val = minMax(pers_barcode)# ::MyPair
    new_range = endd-beginn

    new_pairs = MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        originalBegin = pers_barcode.barcodes[i].first #::Float64
        originalEnd = pers_barcode.barcodes[i].second #::Float64

        newBegin = beginn + ( originalBegin - minMax_val.first )*new_range/( minMax_val.second - minMax_val.first ); #::Float64
        newEnd   = beginn + ( originalEnd - minMax_val.first )*new_range/( minMax_val.second - minMax_val.first ); #::Float64

        push!(new_pairs, MyPair(newBegin, newEnd))
    end

    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode)
end


function  computeAverageOfMidpointOfBarcodesWeightedByLength(pers_barcode::PersistenceBarcodes)::Float64
    averageBarcodeLength = 0.0; #::Float64

    for i = 1:size(pers_barcode.barcodes,1)
        averageBarcodeLength += (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end

    averageBarcodeLength /= size(pers_barcode.barcodes,1)

    weightedAverageOfBarcodesMidpoints = 0; #::Float64
    for i = 1:size(pers_barcode.barcodes,1)
        weight = (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)/averageBarcodeLength; #::Float64
        weightedAverageOfBarcodesMidpoints += weight * 0.5*(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end

    weightedAverageOfBarcodesMidpoints /= size(pers_barcode.barcodes,1)

    # YTANIE< CZY TO MA SENS???
    return weightedAverageOfBarcodesMidpoints
end # computeAverageOfMidpointOfBarcodesWeightedByLength



function compareForHistograms( f::MyPair, s::MyPair)::Bool
    return f.first < s.first;
end




function removeShortBarcodes(pers_barcode::PersistenceBarcodes,  minimalDiameterOfBarcode::Real)

    cleanedBarcodes = MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        if ( abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) > minimalDiameterOfBarcode )
            push!(cleanedBarcodes, pers_barcode.barcodes[i])
        end
    end
    return PersistenceBarcodes(cleanedBarcodes, pers_barcode.dimensionOfBarcode)
end


function restrictBarcodesToGivenInterval(pers_barcode::PersistenceBarcodes,  interval::MyPair )::PersistenceBarcodes
    new_pairs= MyPair[]
    for i = 1:size(pers_barcode.barcodes,1)
        if pers_barcode.barcodes[i].first >= interval.second
            @debug "First condition met"
            continue
        end
        if pers_barcode.barcodes[i].second <= interval.first
            @debug "Second condition met"
            continue
        end
        push!(new_pairs,
                make_MyPair(
                    max( interval.first , pers_barcode.barcodes[i].first ),
                    min( interval.second , pers_barcode.barcodes[i].second )
                   )
               )
    end
    return PersistenceBarcodes(new_pairs, pers_barcode.dimensionOfBarcode);
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

function minMax(pers_barcode::PersistenceBarcodes)
    bmin = Inf # INT_MAX; #::Float64
    bmax = -Inf # INT_MIN; #::Float64
    for i = 1:size(pers_barcode.barcodes,1)
        if pers_barcode.barcodes[i].first < bmin
            bmin = pers_barcode.barcodes[i].first
        end
        if pers_barcode.barcodes[i].second > bmax
            bmax = pers_barcode.barcodes[i].second
        end
    end
    return make_MyPair( bmin , bmax );
end # minMax


function computeLandscapeIntegralFromBarcodes(pers_barcode::PersistenceBarcodes)::Float64
    result = 0; #::Float64
    for i = 1:size(pers_barcode.barcodes,1)
        a = pers_barcode.barcodes[i].second
        b = pers_barcode.barcodes[i].first
        result += (a-b)^2;
    end
    result *= 0.25;
    return result;
end

# TODO2 -- consider adding some instructions to remove anything that is not numeric from the input stream.
# function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String)



function  produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction(pers_barcode::PersistenceBarcodes,  step::UInt  , minn::Float64, maxx::Float64; dbg::Bool = false)::Vector{UInt}

    if ( minn == Inf)
        minMax_val = minMax(pers_barcode);
    else
        minMax_val = make_MyPair(minn, maxx);
    end

    bettiNumbers = zeros(UInt, step)# (step+1);
    # for j = 1:step
    #     pusbettiNumbers[j] = 0;
    # end

    dx = (minMax_val.second-minMax_val.first)/step; # ::Float64

    for i = 1:size(pers_barcode.barcodes,1)
        @debug "i :size($(i), size(pers_barcode.barcodes,1)  $(pers_barcode.barcodes)"
        @debug "For a interval :$(pers_barcode.barcodes[i])we have : \n"

        first = (pers_barcode.barcodes[i].first-minMax_val.first)/dx;
        second = (pers_barcode.barcodes[i].second-minMax_val.first)/dx;

        @debug first , second
        # @debug getchar()
        for j = floor(Int, first):1:ceil(Int, second)
            bettiNumbers[j] += 1
        end
    end

    return bettiNumbers;
end# produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction


#endif

# ===-===-===-===-===-===-===-===-===-===-===-
# File operations >>>
# not tested

function writeBarcodesSortedAccordingToLengthToAFile(pers_barcode::PersistenceBarcodes,  filename::String )
#     # first sort the bars according to their length
    sorted_bars = sort(pers_barcode)

    open(filename, "w") do io
        for i = 1:size(sorted_bars,1)
            write(io, "$(sortedBars[i].first) $(sortedBars[i].second)")
        end
    end
end

function writeToFile(pers_barcode::PersistenceBarcodes,  filename::String )
    open(filename, "w") do io
        for i = 1:size(sorted_bars,1)
            write(io, "$(pers_barcode.barcodes[i].first) $(pers_barcode.barcodes[i].second)")
        end
    end
end

function putToAFileHistogramOfBarcodesLengths(pers_barcode::PersistenceBarcodes, filename::String ,  howMany::Real , shouldWeAlsoPutResponsibleBarcodes::Bool )

    barsLenghts = Any[]
    for i = 1:size(pers_barcode.barcodes,1)
        bar_diff = abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)

        push!(barsLenghts, (bar_diff , MyPair(pers_barcode.barcodes[i].first , pers_barcode.barcodes[i].second )))
    end

    sorted = sort(pers_barcode.barcodes, by= x-> x[1])
    reverse( begining(barsLenghts) , ending(barsLenghts) );

    open(filename, "w") do io
        if shouldWeAlsoPutResponsibleBarcodes
            for i = 1:min(length(barsLenghts), howMany)
                write(io, "$(i) $(barsLenghts[i].first) $(barsLenghts[i].second.first) $(barsLenghts[i].second.second)")
            end
        else
            for i = 1:min(length(barsLenghts), howMany)
                write(io, "$(i) $(barsLenghts[i].first)")
            end
        end
    end
end # putToAFileHistogramOfBarcodesLengths


function putToAFileHistogramOfBarcodesLengths(pers_barcode::PersistenceBarcodes,  filename::String ,  beginn::Real ,  endd::Real , shouldWeAlsoPutResponsibleBarcodes::Bool )
    if beginn >= endd
        throw(DomainError("Wrong parameters of putToAFileHistogramOfBarcodesLengths procedure. Begin points is greater that the end point. Program will now terminate"))
    end

    # std::vector<std::pair< double , std::pair<double,double> > > barsLenghts(this->barcodes.size());
    barsLenghts = Any[]
    for i = 1:size(pers_barcode.barcodes,1)
        bar_diff = abs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)

        push!(barsLenghts, (bar_diff , MyPair(pers_barcode.barcodes[i].first , pers_barcode.barcodes[i].second )))
    end
    sorted = sort(pers_barcode.barcodes, by= x-> x[1])

    # reverse
    barsLenghts = barsLenghts[end:-1:1]

    open(filename, "w") do io
        if shouldWeAlsoPutResponsibleBarcodes
            for i = min(length(barsLenghts),beginn):min(size(barsLenghts,1),endd)
                write(io, "$(i) $(barsLenghts[i].first) $(barsLenghts[i].second.first) $(barsLenghts[i].second.second)")
            end
        else
            for i = min(length(barsLenghts),beginn):min(size(barsLenghts,1),endd)
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


function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String , startin_point::Float64, step::Float64)
    barcodes= MyPair[]
    infty = Inf;
    dimensionOfBarcode = 0;
    open(filename, "r") do io
        # read till end of file
        while !eof(io)
            s = readline(io)
            splitted = split(s, " ")
            beginning = splitted[1]
            ending= splitted[2]
            if ending != infty
                if ending < beginning
                    z = ending;
                    ending = beginning;
                    beginning = z;
                end
                if ( begin != end )
                    push!(barcodes, MyPair( startin_point+beginning*step,startin_point+ending*step ) )
                end
            end
        end
    end

end

function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String , dimensionOfBarcode::UInt )
    my_pairs = MyPair[]
    open(filename, "r") do io
        # read till end of file
        while !eof(io)
            s = readline(f)
            splitted = split(s, " ")
            push!(my_pairs, MyPair(splitted[1], splitted[2]))
        end
    end
    return PersistenceBarcodes(my_pairs, dimensionOfBarcode)
end

# File operations <<<
