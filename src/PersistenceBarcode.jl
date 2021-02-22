
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

import Base.size, Base.isempty, Base.copy, Base.sort

#include "Configure.h"

# code taken from http://ranger.uta.edu/~weems/NOTES5311/hungarian.c
//#include "HungarianC.h"

# tested
struct MyPair
    first::Float64
    second::Float64
end

# tested
function make_MyPair(val1, val2)
    return MyPair(val1, val2)
end

# tested
struct PersistenceBarcodes
    barcodes::Vector{MyPair}
    dimensionOfBarcode::UInt
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

# function writeBarcodesSortedAccordingToLengthToAFile(pers_barcode::PersistenceBarcodes,  filename::String )
#
#     # first sort the bars according to their length
#     vector< MyPair> sortedBars;
#     sortedBars.insert( sortedBars.end() , pers_barcode.barcodes.begin() , pers_barcode.barcodes.end() );
#     sort( sortedBars.begin() , sortedBars.end() ,compareAccordingToLength );
#
#     ofstream out;
#     out.open(filename);
#     for i = 0:size(sortedBars,1)
#         out << sortedBars[i].first << " " << sortedBars[i].second << endl;
#     end
#     out.close();
# end

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

function sort(pers_barcode::PersistenceBarcodes)
	# sorted = sort([1:mat_size;], by=i->(sorted_values[i],matrix_indices[i]))
	sorted = sort(pers_barcode.barcodes, by= x-> x.first)
    # sort( pers_barcode.barcodes.begin() , pers_barcode.barcodes.end() , compareMyPairs );
    return PersistenceBarcodes(sorted, pers_barcode.dimensionOfBarcode)
end

# tested
function compare(pers_barcode::PersistenceBarcodes,  b::PersistenceBarcodes; dbg::Bool = true)::Bool
    if ( dbg )
        # cerr << "pers_barcode.barcodes.size() :size(" << pers_barcode.barcodes,1) << endl;
        # cerr << "b.barcodes.size() :size(" << b.barcodes,1) << endl;
    end

    if ( pers_barcode.barcodes.size() != b.barcodes.size() )
        return false
    end

    sort(pers_barcode);
    sort(b);
    for i = 0:size(pers_barcode.barcodes,1)
        if pers_barcode.barcodes[i] != b.barcodes[i]
            cerr << "pers_barcode.barcodes["<<i<<"] = " << pers_barcode.barcodes[i] << endl;
            cerr << "b.barcodes["<<i<<"] = " << b.barcodes[i] << endl;
            getchar();
            return false;
        end
    end
    return true;
end

function minn(f,  s )
    if ( f < s )
        return f
    end
    return s;
end


function  computeAverageOfMidpointOfBarcodes(pers_barcode::PersistenceBarcodes, )::Float64
    averages = 0; #::Float64
    for i = 0:size(pers_barcode.barcodes,1)
        averages += 0.5*(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end
    averages /= pers_barcode.barcodes.size();

    return averages;
end# computeAverageOfMidpointOfBarcodes


function setAverageMidpointToZero(pers_barcode::PersistenceBarcodes, )
    dbg::Bool = false;
    # average = pers_barcode.computeAverageOfMidpointOfBarcodes(); #::Float64
    average = computeAverageOfMidpointOfBarcodesWeightedByLength(); #::Float64

    if (dbg)
        cerr << "average :" << average << endl
    end

    # shift every barcode by -average
    for i = 0:size(pers_barcode.barcodes,1)
        pers_barcode.barcodes[i].first -= average;
        pers_barcode.barcodes[i].second -= average;
    end
end

function setAveragedLengthToOne(pers_barcode::PersistenceBarcodes, )
    # first compute average length of barcode:
     sumOfLengths = 0;
    for i = 0:size(pers_barcode.barcodes,1)
        sumOfLengths += fabs( pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first );
    end
    # averageLength:size(:Float64 = (double)sumOfLengths / (double)pers_barcode.barcodes,1);
    averageLength = sumOfLengths / size(pers_barcode.barcodes,1);
    # now we need to rescale the length by 1/averageLength
    for i = 0:size(pers_barcode.barcodes,1)
        midpoint = 0.5 * (pers_barcode.barcodes[i].first+pers_barcode.barcodes[i].second); #::Float64
        length = fabs( pers_barcode.barcodes[i].first-pers_barcode.barcodes[i].second )/averageLength; #::Float64
        pers_barcode.barcodes[i].first = midpoint - length/2;
        pers_barcode.barcodes[i].second = midpoint + length/2;
    end
end

function averageBarcodes(pers_barcode::PersistenceBarcodes, )
    pers_barcode = setAverageMidpointToZero(pers_barcode);
    pers_barcode = setAveragedLengthToOne(pers_barcode);
    return pers_barcode
end


function setRangeToMinusOneOne(pers_barcode::PersistenceBarcodes, )
    # first we need to find min and max endpoint of intervals:
    minn = Inf #INT_MAX; #::Float64
    maxx = -Inf #INT_MAX; #::Float64
    for i = 0:size(pers_barcode.barcodes,1)
        a = pers_barcode.barcodes[i].first; #::Float64
        b = pers_barcode.barcodes[i].second; #::Float64
        if b < a
            swap(a,b)
        end

        if a < minn
            minn = a
        end
        if b > maxx
            maxx = b
        end
    end

    shiftValue = -minn; #::Float64
    maxx += shiftValue;
    for i = 0:size(pers_barcode.barcodes,1)
        pers_barcode.barcodes[i].first += shiftValue;
        pers_barcode.barcodes[i].first /= maxx;
        pers_barcode.barcodes[i].second += shiftValue;
        pers_barcode.barcodes[i].second /= maxx;
    end
end

function setRange(pers_barcode::PersistenceBarcodes,  beginn::Float64, endd::Float64)
    if ( beginn >= endd )
        throw("Bar ranges in the setRange procedure.")
    end

    minMax::MyPair = pers_barcode.minMax();

    for i = 0:size(pers_barcode.barcodes,1)
        originalBegin = pers_barcode.barcodes[i].first; #::Float64
        originalEnd = pers_barcode.barcodes[i].second; #::Float64

        newBegin = beginn + ( originalBegin - minMax.first )*(endd-beginn)/( minMax.second - minMax.first ); #::Float64
        newEnd = beginn + ( originalEnd - minMax.first )*(endd-beginn)/( minMax.second - minMax.first ); #::Float64

        pers_barcode.barcodes[i].first = newBegin;
        pers_barcode.barcodes[i].second = newEnd;
    end
end

# function writeToFile(pers_barcode::PersistenceBarcodes,  filename::String )
#     # ofstream out;
#     out.open( filename );
#     for i = 0:size(pers_barcode.barcodes,1)
#         out << pers_barcode.barcodes[i].first << " " << pers_barcode.barcodes[i].second << endl;
#     end
#     out.close();
# end

function  computeAverageOfMidpointOfBarcodesWeightedByLength(pers_barcode::PersistenceBarcodes, )::Float64
    averageBarcodeLength = 0; #::Float64
    for i = 0:size(pers_barcode.barcodes,1)
        averageBarcodeLength += (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end
    averageBarcodeLength /= pers_barcode.barcodes.size();

    weightedAverageOfBarcodesMidpoints = 0; #::Float64
    for i = 0:size(pers_barcode.barcodes,1)
        weight = (pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first)/averageBarcodeLength; #::Float64
        weightedAverageOfBarcodesMidpoints += weight * 0.5*(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first);
    end
    weightedAverageOfBarcodesMidpoints /= pers_barcode.barcodes.size();

    # YTANIE< CZY TO MA SENS???
    return weightedAverageOfBarcodesMidpoints;
end # computeAverageOfMidpointOfBarcodesWeightedByLength



function compareForHistograms( f::MyPair, s::MyPair)::Bool
    return f.first < s.first;
end


# ===-===-===-
# Missin and new functions >>>
function beginning(bars_length)
    return true
end

function ending(bars_length)
    return true
end

# Missin and new functions <<<
# ===-===-===-
function putToAFileHistogramOfBarcodesLengths(pers_barcode::PersistenceBarcodes, filename::String ,  howMany , shouldWeAlsoPutResponsibleBarcodes::Bool )

    # std::vector<std::pair< double , std::pair<double,double> > > barsLenghts(this->barcodes.size());
    # vector<MyPair< double , pair> > barsLenghts(pers_barcode.barcodes.size());

    for i = 0:size(pers_barcode.barcodes,1)
        barsLenghts[i] = make_MyPair(fabs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) , make_pair( pers_barcode.barcodes[i].first , pers_barcode.barcodes[i].second ) );
    end
    sort( beginning(barsLenghts) , ending(barsLenghts) , compareForHistograms );
    reverse( begining(barsLenghts) , ending(barsLenghts) );
    # ofstream file;
    # file.open(filename);
    # if ( shouldWeAlsoPutResponsibleBarcodes )
    #     for i = 0:size(minn(barsLenghts,1),howMany)
    #         file << i << " " << barsLenghts[i].first << " " << barsLenghts[i].second.first << " " << barsLenghts[i].second.second << endl;
    #     end
    # else
    #     for i = 0:size(minn(barsLenghts,1),howMany)
    #         file << i << " " << barsLenghts[i].first << endl;
    #     end
    # end
    # file.close();
end # putToAFileHistogramOfBarcodesLengths


function putToAFileHistogramOfBarcodesLengths(pers_barcode::PersistenceBarcodes,  filename::String ,  beginn ,  endd , shouldWeAlsoPutResponsibleBarcodes::Bool )
    if ( beginn >= endd )
        throw("Wrong parameters of putToAFileHistogramOfBarcodesLengths provedure. Begin points is greater that the end point. Program will now terminate")
    end

    # std::vector<std::pair< double , std::pair<double,double> > > barsLenghts(this->barcodes.size());
    barsLenghts = size(pers_barcode.barcodes.size());

    for i = 0:size(pers_barcode.barcodes,1)
        barsLenghts[i] = make_MyPair(fabs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) , make_pair( pers_barcode.barcodes[i].first , pers_barcode.barcodes[i].second ) );
    end
    sort( begining(barsLenghts) , ending(barsLenghts) , compareForHistograms );
    reverse( begining(barsLenghts) , ending(barsLenghts) );
    # ofstream file;
    # file.open(filename);
    # if ( shouldWeAlsoPutResponsibleBarcodes )
    #     for i = minn(barsLenghts.size(),beginn):size(minn(barsLenghts,1),endd)
    #         file << i << " " << barsLenghts[i].first << " " << barsLenghts[i].second.first << " " << barsLenghts[i].second.second << endl;
    #     end
    # else
    #     for i = minn(barsLenghts.size(),beginn):size(minn(barsLenghts,1),endd)
    #         file << i << " " << barsLenghts[i].first << endl;
    #     end
    # end
    # file.close();
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


function removeShortBarcodes(pers_barcode::PersistenceBarcodes,  minimalDiameterOfBarcode::Float64)

    cleanedBarcodes = Vector{MyPair}
    for i = 0:size(pers_barcode.barcodes,1)
        if ( fabs(pers_barcode.barcodes[i].second - pers_barcode.barcodes[i].first) > minimalDiameterOfBarcode )
            cleanedBarcodes.push_back(pers_barcode.barcodes[i]);
        end
    end
    return swap(pers_barcode.barcodes, cleanedBarcodes );
end


function restrictBarcodesToGivenInterval(pers_barcode::PersistenceBarcodes,  MyPairinterval )::PersistenceBarcodes

    result::PersistenceBarcodes;
    result.dimensionOfBarcode = pers_barcode.dimensionOfBarcode;
    for i = 0:size(pers_barcode.barcodes,1)
        if pers_barcode.barcodes[i].first >= interval.second
            continue
        end
        if pers_barcode.barcodes[i].second <= interval.first
            continue
        end
        push!(result.barcodes, make_MyPair( max( interval.first , pers_barcode.barcodes[i].first ) , min( interval.second , pers_barcode.barcodes[i].second ) ) );
    end
    return result;
end


function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, orgyginal::PersistenceBarcodes)

    pers_barcode.dimensionOfBarcode = orgyginal.dimensionOfBarcode;
    pers_barcode.barcodes.insert( pers_barcode.barcodes.end() , orgyginal.barcodes.begin() , orgyginal.barcodes.end() );
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

function  computeLandscapeIntegralFromBarcodes(pers_barcode::PersistenceBarcodes, )::Float64

    result = 0; #::Float64
    for i = 0:size(pers_barcode.barcodes,1)
        result += (pers_barcode.barcodes[i].second-pers_barcode.barcodes[i].first)*(pers_barcode.barcodes[i].second-pers_barcode.barcodes[i].first);
    end
    result *= 0.25;
    return result;
end



# TODO2 -- consider adding some instructions to remove anything that is not numeric from the input stream.
# function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String)

function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String , bbegin::Float64, step::Float64)
    1+1
end

function PersistenceBarcodes(pers_barcode::PersistenceBarcodes,  bars::Vector{MyPair} )

    infty = 0.0;
    pers_barcode.dimensionOfBarcode = 0;
    sizeOfBarcode::UInt = 0;
    for i = 0:size(bars,1)
        if ( bars[i].second != infty )
            sizeOfBarcode += 1
        end
        if ( bars[i].second < bars[i].first )
            sec = bars[i].second; #::Float64
            bars[i].second = bars[i].first;
            bars[i].first = sec;
        end
    end
    barcodes = Vector{MyPair}#  ( sizeOfBarcode );
    nr::Unt = 0;
    for i = 0:size(bars,1)
        if ( bars[i].second != infty )
            # this is a finite interval
            barcodes[nr] =  make_MyPair( bars[i].first , bars[i].second );
            nr += 1
        end
        # to keep it all compact for now I am removing infinite intervals from consideration.
        #=else
            # this is infinite interval:
            barcodes[i] =  make_MyPair( bars[i].first , INT_MAX );
        }=#
    end
    # CHANGE
    # pers_barcode.barcodes = barcodes;
    pers_barcode.barcodes.swap( barcodes );
end


function PersistenceBarcodes(pers_barcode::PersistenceBarcodes, filename::String , dimensionOfBarcode::UInt )
 1+1
    # *this = PersistenceBarcodes(filename);
    # pers_barcode.dimensionOfBarcode = dimensionOfBarcode;
end

function PersistenceBarcodes(pers_barcode::PersistenceBarcodes,  vect::Vector , dimensionOfBarcode::UInt )

    1+1
    # *this = PersistenceBarcodes(vect);
    # pers_barcode.dimensionOfBarcode = dimensionOfBarcode;
end

function  produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction(pers_barcode::PersistenceBarcodes,  step::UInt  , minn::Float64, maxx::Float64)::Vector{UInt}

    dbg::Bool = false;
    minMax = MyPair(0,0) ;
    if ( minn == INT_MAX )
        minMax = pers_barcode.minMax();
    else
        minMax = make_MyPair( minn,maxx );
    end


    vector< unsigned > bettiNumbers(step+1);
    for j = 0:step
        bettiNumbers[j] = 0;
    end

    dx = (minMax.second-minMax.first)/step; # ::Float64

    for i = 0:size(pers_barcode.barcodes,1)
        @debug "i :size($(i), size(pers_barcode.barcodes,1)  $(pers_barcode.barcodes)"
        @debug "For a interval :$(pers_barcode.barcodes[i])we have : \n"
        first::UInt = (pers_barcode.barcodes[i].first-minMax.first)/dx;
        second::UInt = (pers_barcode.barcodes[i].second-minMax.first)/dx;
        @debug first , second
        @debug getchar()
        for j = first:second
            bettiNumbers[j]+=1;
        end
    end

    return bettiNumbers;
end# produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction


#endif
