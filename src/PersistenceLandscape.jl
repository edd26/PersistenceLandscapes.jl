#     Copyright 2013-2014 University of Pennsylvania
#     Created by Pawel Dlotko
# 
#     This file is part of Persistence Landscape Toolbox (PLT).
# 
#     PLT is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     PLT is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
# 
#     You should have received a copy of the GNU Lesser General Public License
#     along with PLT.  If not, see <http:# www.gnu.org/licenses/>.
=#

#include "Configure.h"
include("PersistenceBarcode.jl")

struct PersistenceLandscape
    land::Vector{Vector{MyPair}}
    dimension::UInt
end

function almostEqual( a::Float64 , b::Float64 )
    if abs(a-b) < eps
        return true
    end
    return false
end

function birth (a::MyPair)
    return a.first-a.second;
end

function death(a::MyPair )
    return a.first+a.second;
end

# functions used in PersistenceLandscape( PersistenceBarcodes& p ) constructor:
# comparePointsDBG::Bool = false;
function comparePoints( f::MyPair, s::MyPair )
    differenceBirth = birth(f)-birth(s);

    if differenceBirth < 0
        differenceBirth *= -1
    end

    differenceDeath = death(f)-death(s)
    if differenceDeath < 0
        differenceDeath *= -1
    end

    if (differenceBirth < epsi) && (differenceDeath < epsi)
        if comparePointsDBG
            println("CP1")
        end
        return false;
    end
    if differenceBirth < epsi
        # consider birth points the same. If we are here, we know that death points are NOT the same
        if death(f) < death(s)
            if comparePointsDBG
                println("CP2")
            end
            return true;
        end
        if(comparePointsDBG)
            println("CP3")
        end
        return false;
    end
    if differenceDeath < epsi
        # we consider death points the same and since we are here, the birth points are not the same!
        if birth(f) < birth(s)
            if(comparePointsDBG)
				println("CP4")
            end
            return false;
        end
        if(comparePointsDBG)
            println("CP5")
        end
        return true;
    end
    if birth(f) > birth(s)
        if(comparePointsDBG)
            println("CP6")
        end
        return false;
    end
    if birth(f) < birth(s)
        if(comparePointsDBG)
            println("CP7")
        end
        return true;
    end
    # if this is true, we assume that death(f)<=death(s) -- othervise I have had a lot of roundoff problems here!
    if death(f)<=death(s)
        if(comparePointsDBG)
				println("CP8")
        return false;
    end
    if(comparePointsDBG)
				println("CP9")
    return true;
end

# this function assumes birth-death coords
function comparePoints2(f::MyPair, s::MyPair )
    if f.first < s.first
        return true
    else
        if f.first > s.first
            return false;
        else
        # f.first == s.first
            if f.second > s.second
                return true;
            else
                return false;
            end
        end
    end
end

# class vectorSpaceOfPersistenceLandscapes;
# functions used to add and subtract landscapes

function add(x::Float64, y::Float64)
    return x+y
end

function sub(x::Float64, y::Float64)
    return x-y
end

# function used in computeValueAtAGivenPoint
function functionValue ( p1::MyPair, p2::MyPair , x::Float64 )
    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    a = (p2.second - p1.second)/(p2.first - p1.first);
    b = p1.second - a*p1.first;
    # cerr << "Line crossing points : (" << p1.first << "," << p1.second << ") oraz (" << p2.first << "," << p2.second << ") :";
    # cerr << "a : " << a << " , b : " << b << " , x : " << x << endl;
    return (a*x+b);
end

# class PersistenceLandscape

function lDimBegin(land::PersistenceLandscape, dim::UInt)
    if dim > size(land,1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][1]
end

function lDimEnd(unsigned dim)
    if dim > size(land,1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][end]
end

# functionzone:
# this is a general algorithm to perform linear operations on persisntece lapscapes. It perform it by doing operations on landscape points.
import Base.+, Base.-, Base.*, Base.+=
function addTwoLandscapes( land1::PersistenceLandscape, land2::PersistenceLandscape)::PersistenceLandscape
    return add(land1,land2)
end

function subtractTwoLandscapes( land1::PersistenceLandscape, land2::PersistenceLandscape)::PersistenceLandscape
    return sub(land1,land2)
end

function Base.+( first::PersistenceLandscape,second::PersistenceLandscape)
    return addTwoLandscapes(first, second );
end

function Base.-( first::PersistenceLandscape,second::PersistenceLandscape)
    return subtractTwoLandscapes(first, second );
end

function Base.*( first::PersistenceLandscape, con::Float64 )
    return multiplyLanscapeByRealNumberNotOverwrite(first, con);
end

function PersistenceLandscape operator*( con::Float64, first::PersistenceLandscape)
    return multiplyLanscapeByRealNumberNotOverwrite(first, con);
end

function Base.+=(this::PersistenceLandscape, rhs::PersistenceLandscape)
    return this + rhs
end

function Base.-=(this::PersistenceLandscape, rhs::PersistenceLandscape)
    return this - rhs
end

function Base.*=(this::PersistenceLandscape, x::Float64 )
    return this * x
end

function Base./=(this::PersistenceLandscape, x::Float64 )
    x == 0  && throw(DomainError("In Base./=, division by 0. Program terminated." ))
    return this / x
end

function Base.==(this::PersistenceLandscape,rhs ::PersistenceLandscape)::Bool
    return this == rhs
end

function computeMaximum(land::PersistenceLandscape)
    maxValue = 0;
    if size(land,1) != 0
        maxValue = -Inf
        for i = 0:size(land[0], 1)
            if land[1][i].second > maxValue
                maxValue = land[1][i].second
            end
        end
    end
    return maxValue;
end

function computeNormOfLandscape(land::PersistenceLandscape, i::Int )
    l = PersistenceLandscape()
    if i != -1
        return computeDiscanceOfLandscapes(land,l,i);
    else
        return computeMaxNormDiscanceOfLandscapes(land,l);
    end
end

# Empty constructor?
function operator()(level:UInt, x::Float64)
    return computeValueAtAGivenPoint(level,x)
end

function dim(land::PersistenceLandscape)
    @info "Not sure if this should work this way"
    return land.dimension
end

function minimalNonzeroPoint(land::PersistenceLandscape, l::UInt )
    if size(land,1) < l
        return Inf
    end
    return land.land[l][1].first
end

function maximalNonzeroPoint(land::PersistenceLandscape, l::UInt )
    if size(land,1) < l
        return -Inf
    end
    return land[l][size(land[l],1)-2].first;
end

function Base.size(land::PersistenceLandscape)
    return size(land.land,1)
end

# visualization part...
# To be created in Julia


# function PersistenceLandscape::plot( char* filename ,  from,  to , x::Float64RangeBegin , x::Float64RangeEnd , y::Float64RangeBegin , y::Float64RangeEnd )
#
#     # this program create a gnuplot script file that allows to plot persistence diagram.
#     ofstream out;
#
#     ostringstream nameSS;
#     nameSS << filename << "_GnuplotScript";
#     string nameStr = nameSS.str();
#     out.open( (char*)nameStr.c_str() );
#
#     if (xRangeBegin != -1) || (xRangeEnd != -1) || (yRangeBegin != -1) || (yRangeEnd != -1) 
#         out << "set xrange [" << xRangeBegin << " : " << xRangeEnd << "]" << endl;
#         out << "set yrange [" << yRangeBegin << " : " << yRangeEnd << "]" << endl;
#     end
#
#     if ( from == -1 )from = 0;end
#     if ( to == -1 )to = size(land,1);end
#
#     out << "plot ";
#     for lambda= min(from,size(land,1)) : min(to,size(land,1)) 
#         out << "     '-' using 1:2 title 'l" << lambda << "' with lp";
#         if lambda+1 != min(to,size(land,1))
#             out << ", \\";
#         end
#         out << endl;
#     end
#
#     for lambda= min(from,size(land,1)) : min(to,size(land,1)) 
#         for i = 1 : this->land[lambda].size()-1 
#             out << this->land[lambda][i].first << " " << this->land[lambda][i].second << endl;
#         end
#         out << "EOF" << endl;
#     end
#     cout << "Gnuplot script to visualize persistence diagram written to the file: " << nameStr << ". Type load '" << nameStr << "' in gnuplot to visualize." << endl;
# end

function PersistenceLandscape(land::::PersistenceLandscape, landscapePointsWithoutInfinities::Vector{Vector{MyPair}})
    for level = 0:size(landscapePointsWithoutInfinities)
        vector< pair > v;
        v.push_back(make_pair(INT_MIN,0));
        v.insert( v.end(), landscapePointsWithoutInfinities[level].begin(), landscapePointsWithoutInfinities[level].end() );
        v.push_back(make_pair(INT_MAX,0));
        push!(land, v );
    end
    this->dimension = 0;
end

vector< vector<std::pair > > PersistenceLandscape::gimmeProperLandscapePoints()
    vector< vector<std::pair > > result;
    for level = 0  : size(land,1) 
        vector< pair > v( this->land[level].begin()+1 , this->land[level].end()-1 );
        result.push_back(v);
    end
    return result;
end

# CAUTION, this procedure do not work yet. Please do not use it until this warning is removed.
# PersistenceBarcodes PersistenceLandscape::convertToBarcode()
#
#     bool dbg = false;
#     # for the first level, find local maxima. They are points of the diagram. Find local minima and put them to the vector v
#     # for every next level, find local maxima and put them to the list L. Find local minima and put them to the list v2
#     # Point belong to the persistence barcode if it belong to the list L, but do not belong to the list v. When you pick the peristence diagram points at this level,
#     # set v = v2.
#     # QUESTION -- is there any significnce of the points in those layers? They may give some layer-characteristic of a diagram and give a marriage between landscapes and diagrams.
#
#     vector< pair<  > > persistencePoints;
#     if this->land[0].size()
#     
#         vector< pair > localMinimas;
#
#
#
#         for level = 0 : size(land,1) 
#         
#             if dbg
#             
#                 cerr << "\n\n\n Level : " << level << endl;
#                 cerr << "Here is the list of local minima :";
#                 for i = 0 : localMinimas.size() 
#                 
#                     cerr << localMinimas[i] << " ";
#                 end
#                 cerr << "\n";
#                 getchar();
#             end
#
#              localMinimaCounter = 0;
#             vector< pair > newLocalMinimas;
#             for i = 1 : this->land[level].size()-1 
#             
#                 if dbg
#                 
#                     cerr << "Considering a pair : " << this->land[level][i] << endl;
#                 end
#                 if ( this->land[level][i].second == 0 )continue;
#
#                 if this->land[level][i].second > this->land[level][i-1].second) && (this->land[level][i].second > this->land[level][i+1].second
#                 
#                     # if this is a local maximum. The question is -- is it also a local minimum of a previous function?
#                     bool isThisALocalMinimumOfThePreviousLevel = false;
#
#                     if dbg
#                     
#                         cerr << "It is a local maximum. Now we are checking if it is also a local minimum of the previous function." << endl;
#                     end
#
#                     while ( (localMinimaCounter < localMinimas.size()) && (localMinimas[localMinimaCounter].first < this->land[level][i].first ) )
#                     
#                         if dbg
#                         
#                             cerr << "Adding : " << localMinimas[localMinimaCounter] << " to new local minima";
#                         end
#                         newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                         ++localMinimaCounter;
#                     end
#
#                     if localMinimaCounter != localMinimas.size()
#                     
#                         if localMinimas[localMinimaCounter] == this->land[level][i]
#                         
#                             isThisALocalMinimumOfThePreviousLevel = true;
#                             ++localMinimaCounter;
#                         end
#                     end
#                     if !isThisALocalMinimumOfThePreviousLevel
#                     
#                         if dbg
#                         
#                             cerr << "It is not a local minimum of the previous level, so it is a point : " << birth(this->land[level][i]) << " ,  " << death(this->land[level][i]) <<
#                             " in a persistence diagram!";
#                         end
#                         persistencePoints.push_back( make_pair(birth(this->land[level][i]), death(this->land[level][i]) ) );
#                     end
#                     if dbg) && (isThisALocalMinimumOfThePreviousLevel
#                     
#                         cerr << "It is a local minimum of the previous, so we do nothing";
#                     end
#
#                 end
#                 if this->land[level][i].second != 0
#                 
#                     if this->land[level][i].second < this->land[level][i-1].second) && (this->land[level][i].second < this->land[level][i+1].second
#                     
#                         if dbg
#                         
#                             cerr << "This point is a local minimum, so we add it to a list of local minima.\n";
#                         end
#                         # local minimum
#                         if localMinimas.size()
#                         
#                             while ( (localMinimaCounter < localMinimas.size()) && (localMinimas[localMinimaCounter].first < this->land[level][i].first) )
#                             
#                                 newLocalMinimas.push_back(localMinimas[localMinimaCounter]);
#                                 ++localMinimaCounter;
#                             end
#                         end
#                         newLocalMinimas.push_back( this->land[level][i] );
#                     end
#                 end
#
#                 # if one is larger and the other is smaller, then such a point should be consider as both local minimum and maximum.
#                 if (
#                        ( (this->land[level][i].second < this->land[level][i-1].second) && (this->land[level][i].second > this->land[level][i+1].second) )
#                        ||
#                        ( (this->land[level][i].second > this->land[level][i-1].second) && (this->land[level][i].second < this->land[level][i+1].second) )
#                    )
#                 
#                     # minimum part:
#                     newLocalMinimas.push_back( this->land[level][i] );
#                     # maximum part:
#                     bool isThisALocalMinimumOfThePreviousLevel = false;
#                     if dbg
#                     
#                         cerr << "It is a local maximum and the local minimum." << endl;
#                     end
#
#                     while ( (localMinimaCounter < localMinimas.size()) && (localMinimas[localMinimaCounter].first < this->land[level][i].first ) )
#                     
#                         newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                         ++localMinimaCounter;
#                     end
#                     if localMinimaCounter != localMinimas.size()
#                     
#                         if localMinimas[localMinimaCounter] == this->land[level][i]
#                         
#                             isThisALocalMinimumOfThePreviousLevel = true;
#                             ++localMinimaCounter;
#                         end
#                     end
#                     if !isThisALocalMinimumOfThePreviousLevel
#                     
#                         if dbg
#                         
#                             cerr << "It is not a local minimum of the previous level, so it is a point in a persistence diagram!";
#                         end
#                         persistencePoints.push_back( make_pair(birth(this->land[level][i]), death(this->land[level][i]) ) );
#                     end
#                     if dbg) && (isThisALocalMinimumOfThePreviousLevel
#                     
#                         cerr << "It is a local minimum of the previous, so we do nothing";
#                     end
#                 end
#             end
#
#             if (dbg)
#             
#                 cerr << "Exit the loop for this level, exchanging local minimas lists";
#                 cerr << "localMinimas.size() : " << localMinimas.size() << endl;
#                 cerr << "localMinimaCounter : " << localMinimaCounter << endl;
#             end
#             if localMinimas.size()
#             
#                 while ( localMinimaCounter < localMinimas.size() )
#                 
#                     newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                     ++localMinimaCounter;
#                 end
#             end
#             cerr << "here";
#             localMinimas.swap( newLocalMinimas );
#             cerr << "Done\n";
#
#
#
#         end
#     end
#
#     return PersistenceBarcodes(persistencePoints);
# end# convertToBarcode
function check_if_file_exist(char* name) 
    return ( access( name, F_OK ) != -1 );
end

PersistenceLandscape(land::::PersistenceLandscape, char* filename)
    bool dbg = false;
    if dbg
        cerr << "Using constructor : PersistenceLandscape(char* filename)" << endl;
    end
    if !check_if_file_exist( filename )
		cout << "The file : " << filename << " do not exist. The program will now terminate";
		throw "File not exist, please consult output of the program for further details.";
	end
    # this constructor reads persistence landscape form a file. This file have to be created by this software beforehead
    ifstream in;
    in.open( filename );
    unsigned dimension;
    in >> dimension;
    this->dimension = dimension;
    string line;
    getline(in,line);
    vector< pair > landscapeAtThisLevel;
    bool isThisAFirsLine = true;
    while (!in.eof())
        getline(in,line);
        if !(line.length() == 0 || line[0] == '#')
            stringstream lineSS;
            lineSS << line;
            b::Float64eginn, endd;
            lineSS >> beginn;
            lineSS >> endd;
            # if beginn > endd
            # 
            #     b = beginn;
            #     beginn = endd;
            #     endd = b;
            # end
            landscapeAtThisLevel.push_back( make_pair( beginn , endd ) );
            if (dbg)
				println("Reading a pont : " << beginn << " , " << endd << endl)
        else
            if (dbg)
                cout << "IGNORE LINE\n";
                getchar();
            end
            if !isThisAFirsLine
                landscapeAtThisLevel.push_back( make_pair( INT_MAX , 0 ) );
                push!(land,landscapeAtThisLevel);
                vector< pair > newLevelOdLandscape;
                landscapeAtThisLevel.swap(newLevelOdLandscape);
            end
            landscapeAtThisLevel.push_back( make_pair( INT_MIN , 0 ) );
            isThisAFirsLine = false;
        end
	end
	if landscapeAtThisLevel.size() > 1
        # seems that the last line of the file is not finished with the newline sign. We need to put what we have in landscapeAtThisLevel to the constructed landscape.
        landscapeAtThisLevel.push_back( make_pair( INT_MAX , 0 ) );
        push!(land,landscapeAtThisLevel);
    end
    in.close();
end

operatorEqualDbg::Bool = false;
function PersistenceLandscape::Base.== (rhs ::PersistenceLandscape)const
    if size(land,1) != rhs.land.size()
        if (operatorEqualDbg)cerr << "1\n";
        return false;
    end
    for level = 0 : size(land,1) 
        if this->land[level].size() != rhs.land[level].size()
            if (operatorEqualDbg)cerr << "this->land[level].size() : " << this->land[level].size() <<  "\n";
            if (operatorEqualDbg)cerr << "rhs.land[level].size() : " << rhs.land[level].size() <<  "\n";
            if (operatorEqualDbg)cerr << "2\n";
            return false;
        end
        for i = 0 : this->land[level].size() 
            if this->land[level][i] != rhs.land[level][i]
                if (operatorEqualDbg)cerr << "this->land[level][i] : " << this->land[level][i] << "\n";
                if (operatorEqualDbg)cerr << "rhs.land[level][i] : " << rhs.land[level][i] << "\n";
                if (operatorEqualDbg)cerr << "3\n";
                return false;
            end
        end
    end
    return true;
end

# this function find maximum of lambda_n
function PersistenceLandscape::findMax( unsigned lambda )const
    if ( size(land,1) < lambda )return 0;
    m::Float64aximum = INT_MIN;
    for i = 0 : this->land[lambda].size() 
        if this->land[lambda][i].second > maximum
            maximum = this->land[lambda][i].second
        end
    end
    return maximum;
end

# this function compute n-th moment of lambda_level
bool computeNthMomentDbg = false;
function PersistenceLandscape::computeNthMoment( unsigned n , center , unsigned level )const
    if n < 1
        cerr << "Cannot compute n-th moment for  n = " << n << ". The program will now terminate";
        throw("Cannot compute n-th moment. The program will now terminate");
    end
    r::Float64esult = 0;
    if size(land,1) > level
        for i = 2 : this->land[level].size()-1 
            if this->land[level][i].first - this->land[level][i-1].first == 0
                continue
            end
            # between this->land[level][i] and this->land[level][i-1] the lambda_level is of the form ax+b. First we need to find a and b.
            a = (this->land[level][i].second - this->land[level][i-1].second)/(this->land[level][i].first - this->land[level][i-1].first);
            b = this->land[level][i-1].second - a*this->land[level][i-1].first;
            x::Float641 = this->land[level][i-1].first;
            x::Float642 = this->land[level][i].first;
            # f::Float64irst = b*(pow((x2-center),(double)(n+1))/(n+1)-pow((x1-center),(double)(n+1))/(n+1));
            # s::Float64econd = a/(n+1)*((x2*pow((x2-center),(double)(n+1))) - (x1*pow((x1-center),(double)(n+1))) )
            #               +
            #               a/(n+1)*( pow((x2-center),(double)(n+2))/(n+2) - pow((x1-center),(double)(n+2))/(n+2) );
            # result += first;
            # result += second;
            f::Float64irst = a/(n+2)*( pow( (x2-center) , (double)(n+2) ) - pow( (x1-center) , (double)(n+2) ) );
            s::Float64econd = center/(n+1)*( pow( (x2-center) , (double)(n+1) ) - pow( (x1-center) , (double)(n+1) ) );
            t::Float64hird = b/(n+1)*( pow( (x2-center) , (double)(n+1) ) - pow( (x1-center) , (double)(n+1) ) );
            if computeNthMomentDbg
                cerr << "x1 : " << x1 << endl;
                cerr << "x2 : " << x2 << endl;
                cerr << "a : " << a << endl;
                cerr << "b : " << b << endl;
                cerr << "first : " << first << endl;
                cerr << "second : " << second << endl;
                cerr << "third : " << third << endl;
                getchar();
            end
            result += first + second + third;
        end
    end
    return result;
end# computeNthMoment
function PersistenceLandscape::testLandscape( PersistenceBarcodes& b )
    for level = 0 : size(land,1) 
        for i = 1 : this->land[level].size()-1 
            if this->land[level][i].second < epsi
                continue
            end
            # check if over this->land[level][i].first-this->land[level][i].second , this->land[level][i].first+this->land[level][i].second] there are level barcodes.
            nrOfOverlapping = 0;
            for nr = 0 : b.barcodes.size() 
                if ( b.barcodes[nr].first-epsi <= this->land[level][i].first-this->land[level][i].second
                      &&
                      ( b.barcodes[nr].second+epsi >= this->land[level][i].first+this->land[level][i].second )
                   )
                    ++nrOfOverlapping;
                end
            end
            if nrOfOverlapping != level+1
                cout << "We have a problem :";
                cout << "this->land[level][i].first : " << this->land[level][i].first << "\n";
                cout << "this->land[level][i].second : " << this->land[level][i].second << "\n";
                cout << "[" << this->land[level][i].first-this->land[level][i].second << "," << this->land[level][i].first+this->land[level][i].second << "]";
                cout << "level : " << level << " , nrOfOverlapping: " << nrOfOverlapping << endl;
                getchar();
                for nr = 0 : b.barcodes.size() 
                    if ( b.barcodes[nr].first <= this->land[level][i].first-this->land[level][i].second
                          &&
                          ( b.barcodes[nr].second >= this->land[level][i].first+this->land[level][i].second )
                       )
                        cout << "(" << b.barcodes[nr].first << "," << b.barcodes[nr].second << ")\n";
                    end
                    # this->printToFiles("out");
                    # this->generateGnuplotCommandToPlot("out");
                    # getchar();getchar();getchar();
                end
            end
        end
    end
    return true;
end

function computeLandscapeOnDiscreteSetOfPointsDBG = false;
function PersistenceLandscape::computeLandscapeOnDiscreteSetOfPoints( PersistenceBarcodes& b , d::Float64x )
     pair miMa = b.minMax();
     b::Float64min = miMa.first;
     b::Float64max = miMa.second;
     if(computeLandscapeOnDiscreteSetOfPointsDBG)
				println("bmin: " << bmin << " , bmax :" << bmax << "\n")
    # if(computeLandscapeOnDiscreteSetOfPointsDBG)end
     vector< pair<double,std::vector<double> > > result( (bmax-bmin)/(dx/2) + 2 );
     x = bmin;
     int i = 0;
     while ( x <= bmax )
         vector<double> v;
         result[i] = make_pair( x , v );
         x += dx/2.0;
         ++i;
     end
     if(computeLandscapeOnDiscreteSetOfPointsDBG)
				println("Vector initally filled in")
     for i = 0 : b.barcodes.size() 
         # adding barcode b.barcodes[i] to out mesh:
         b::Float64eginBar = b.barcodes[i].first;
         e::Float64ndBar = b.barcodes[i].second;
          index = ceil((beginBar-bmin)/(dx/2));
         while ( result[index].first < beginBar )++index;
         while ( result[index].first < beginBar )--index;
         h::Float64eight = 0;
         # I know this is silly to add dx/100000 but this is neccesarry to make it work. Othervise, because of roundoff error, the program gave wrong results. It took me a while to track this.
         while (  height <= ((endBar-beginBar)/2.0) )
             # go up
             result[index].second.push_back( height );
             height += dx/2;
             ++index;
         end
         height -= dx;
         while ( (height >= 0)  )
             # cerr << "Next iteration\n";
             # go down
             result[index].second.push_back( height );
             height -= dx/2;
             ++index;
         end
     end
     # cerr << "All barcodes has been added to the mesh";
     indexOfLastNonzeroLandscape = 0;
     i = 0;
     for  x = bmin : bmax 
         sort( result[i].second.begin() , result[i].second.end() , greater<double>() );
         if ( result[i].second.size() > indexOfLastNonzeroLandscape )indexOfLastNonzeroLandscape = result[i].second.size();
         ++i;
     end
     if ( computeLandscapeOnDiscreteSetOfPointsDBG )cout << "Now we fill in the suitable vecors in this landscape";end
     vector< vector< std::pair > > land(indexOfLastNonzeroLandscape);
     for  dim = 0 : indexOfLastNonzeroLandscape 
         land[dim].push_back( make_pair( INT_MIN,0 ) );
     end
     i = 0;
     for  x = bmin : bmax 
         for nr = 0 : result[i].second.size() 
              land[nr].push_back(make_pair( result[i].first , result[i].second[nr] ));
         end
         ++i;
     end
     for  dim = 0 : indexOfLastNonzeroLandscape 
         land[dim].push_back( make_pair( INT_MAX,0 ) );
     end
     this->land.clear();
     this->land.swap(land);
     this->reduceAlignedPoints();
end

bool multiplyByIndicatorFunctionBDG = false;
PersistenceLandscape PersistenceLandscape::multiplyByIndicatorFunction( vector<pair > indicator )const
    PersistenceLandscape result;
    for dim = 0 : size(land,1) 
        if(multiplyByIndicatorFunctionBDG)cout << "dim : " << dim << "\n";end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( 0 , INT_MIN ) );
        if indicator.size() > dim
            if (multiplyByIndicatorFunctionBDG)
                cout << "There is nonzero indicator in this dimension\n";
                cout << "[ " << indicator[dim].first << " , " << indicator[dim].second << "]";
            end
            for nr = 0 : this->land[dim].size() 
                if (multiplyByIndicatorFunctionBDG) cout << "this->land[dim][nr] : " << this->land[dim][nr].first << " , " << this->land[dim][nr].second << "\n";end
                if this->land[dim][nr].first < indicator[dim].first
                    if (multiplyByIndicatorFunctionBDG)cout << "Below treshold\n";end
                    continue;
                end
                if this->land[dim][nr].first > indicator[dim].second
                    if (multiplyByIndicatorFunctionBDG)cout << "Just pass above treshold";end
                    lambda_n.push_back( make_pair( indicator[dim].second , functionValue ( this->land[dim][nr-1] , this->land[dim][nr] , indicator[dim].second ) ) );
                    lambda_n.push_back( make_pair( indicator[dim].second , 0 ) );
                    break;
                end
                if this->land[dim][nr].first >= indicator[dim].first) && (this->land[dim][nr-1].first <= indicator[dim].first
                    if (multiplyByIndicatorFunctionBDG)cout << "Entering the indicator";end
                    lambda_n.push_back( make_pair( indicator[dim].first , 0 ) );
                    lambda_n.push_back( make_pair( indicator[dim].first , functionValue(this->land[dim][nr-1],this->land[dim][nr],indicator[dim].first) ) );
                end
                 if (multiplyByIndicatorFunctionBDG)cout << "We are here\n";end
                lambda_n.push_back( make_pair( this->land[dim][nr].first , this->land[dim][nr].second ) );
            end
        end
        lambda_n.push_back( make_pair( 0 , INT_MIN ) );
        if lambda_n.size() > 2
            result.land.push_back( lambda_n );
        end
    end
    return result;
end

function PersistenceLandscape::printToFiles( char* filename , from::UInt, unsigned to )const
    if ( from > to )throw("Error printToFiles printToFile( char* filename , from::UInt, unsigned to ). 'from' cannot be greater than 'to'.");
    # if ( to > size(land,1) )throw("Error in printToFiles( char* filename , from::UInt, unsigned to ). 'to' is out of range.");
    if ( to > size(land,1) )to = size(land,1);end
    ofstream write;
    for dim = from : to 
        ostringstream name;
        name << filename << "_" << dim << ".dat";
        string fName = name.str();
        char* FName = fName.c_str();
        write.open(FName);
        write << "#lambda_" << dim << endl;
        for i = 1 : this->land[dim].size()-1 
            write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
        end
        write.close();
    end
end

function PersistenceLandscape::printToFiles( char* filename, int numberOfElementsLater ,  ... )const
  va_list arguments;
  va_start ( arguments, numberOfElementsLater );
  ofstream write;
  for ( int x = 0; x < numberOfElementsLater; x++ )
       dim = va_arg ( arguments, unsigned );
       if ( dim > size(land,1) )throw("In function generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... ), one of the number provided is greater than number of nonzero landscapes");
        ostringstream name;
       name << filename << "_" << dim << ".dat";
       string fName = name.str();
       char* FName = fName.c_str();
       write.open(FName);
       write << "#lambda_" << dim << endl;
       for i = 1 : this->land[dim].size()-1 
           write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
       end
       write.close();
  end
  va_end ( arguments );
end

function PersistenceLandscape::printToFiles( char* filename )const
    this->printToFiles(filename , (unsigned)0 , (unsigned)size(land,1) );
end

function PersistenceLandscape::printToFile( char* filename , from::UInt, unsigned to )const
    if ( from > to )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'from' cannot be greater than 'to'.");
    if ( to > size(land,1) )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'to' is out of range.");
    ofstream write;
    write.open(filename);
    write << this->dimension << endl;
    for dim = from : to 
        write << "#lambda_" << dim << endl;
        for i = 1 : this->land[dim].size()-1 
            write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
        end
    end
    write.close();
end

function PersistenceLandscape::printToFile( char* filename  )const
    this->printToFile(filename,0,size(land,1));
end

function PersistenceLandscape::generateGnuplotCommandToPlot( char* filename, from::UInt, unsigned to )const
    if ( from > to )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'from' cannot be greater than 'to'.");
    # if ( to > size(land,1) )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'to' is out of range.");
    if ( to > size(land,1) )to = size(land,1);end
    ostringstream result;
    result << "plot ";
    for dim = from : to 
        # result << "\"" << filename << "_" << dim <<".dat\" w lp".dat\" w lp title \"L" << dim <<"\"";
        result << "\"" << filename << "_" << dim <<".dat\" with lines notitle ";
        if dim != to-1
            result << ", ";
        end
    end
    ofstream write;
    ostringstream outFile;
    outFile << filename << "_gnuplotCommand.txt";
    string outF = outFile.str();
    cout << "The gnuplot command can be found in the file \"" << outFile.str() << "\"\n";
    write.open(outF.c_str());
    write << result.str();
    write.close();
end

function PersistenceLandscape::generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... )const
   va_list arguments;
   va_start ( arguments, numberOfElementsLater );
   ostringstream result;
   result << "plot ";
   for ( int x = 0; x < numberOfElementsLater; x++ )
        dim = va_arg ( arguments, unsigned );
        if ( dim > size(land,1) )throw("In function generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... ), one of the number provided is greater than number of nonzero landscapes");
        result << "\"" << filename << "_" << dim <<".dat\" w lp title \"L" << dim <<"\"";
        if x != numberOfElementsLater-1
            result << ", ";
        end
   end
   ofstream write;
   ostringstream outFile;
    outFile << filename << "_gnuplotCommand.txt";
    string outF = outFile.str();
    cout << "The gnuplot command can be found in the file \"" << outFile.str() << "\"\n";
    write.open(outF.c_str());
   write << result.str();
   write.close();
end

function PersistenceLandscape::generateGnuplotCommandToPlot( char* filename )const
    this->generateGnuplotCommandToPlot( filename , (unsigned)0 , (unsigned)size(land,1) );
end

PersistenceLandscape(land::::PersistenceLandscape, PersistenceLandscape& oryginal)
    # cerr << "Running copy constructor";
    this->dimension = oryginal.dimension;
    vector< vector< std::pair > > land( oryginal.land.size() );
    for i = 0 : oryginal.land.size() 
        land[i].insert( land[i].end() , oryginal.land[i].begin() , oryginal.land[i].end() );
    end
    # CHANGE
    # this->land = land;
    this->land.swap(land);
end

PersistenceLandscape PersistenceLandscape::operator=(oryginal::PersistenceLandscape)
    this->dimension = oryginal.dimension;
    vector< vector< std::pair > > land( oryginal.land.size() );
    for i = 0 : oryginal.land.size() 
        land[i].insert( land[i].end() , oryginal.land[i].begin() , oryginal.land[i].end() );
    end
    # CHANGE
    # this->land = land;
    this->land.swap(land);
    return *this;
end

# TODO -- removewhen the problem is respved
function check( i::UInt, vector< pair > v )
    if i < 0) || (i >= v.size()
        cout << "you want to get to index : " << i << " while there are only  : " << v.size() << " indices";
        cin.ignore();
        return true;
    end
    return false;
end

# if check( , )
				println("OUT OF MEMORY")
PersistenceLandscape(land::::PersistenceLandscape,  PersistenceBarcodes& p )
    bool dbg = false;
    if dbg
        println("PersistenceLandscape(land::::PersistenceLandscape,  PersistenceBarcodes& p )" )
    end
    if !useGridInComputations
        if dbg
            println("PL version")
        end
        # this is a general algorithm to construct persistence landscapes.
        this->dimension = p.dimensionOfBarcode;
        vector< pair > bars;
        bars.insert( bars.begin() , p.barcodes.begin() , p.barcodes.end() );
        sort( bars.begin() , bars.end() , comparePoints2 );
        if (dbg)
            cerr << "Bars :";
            for i = 0 : bars.size() 
                cerr << bars[i] << "\n";
            end
            getchar();
        end
        vector< pair > characteristicPoints(p.barcodes.size());
        for i = 0 : bars.size() 
            characteristicPoints[i] = make_pair((bars[i].first+bars[i].second)/2.0 , (bars[i].second - bars[i].first)/2.0);
        end
        vector< vector< std::pair > > persistenceLandscape;
        while ( !characteristicPoints.empty() )
            if(dbg)
                for i = 0 : characteristicPoints.size() 
                    cout << "("  << characteristicPoints[i] << ")\n";
                end
                cin.ignore();
            end
            vector< pair > lambda_n;
            lambda_n.push_back( make_pair( INT_MIN , 0 ) );
            lambda_n.push_back( make_pair(birth(characteristicPoints[0]),0) );
            lambda_n.push_back( characteristicPoints[0] );
            if (dbg)
                cerr << "1 Adding to lambda_n : (" << make_pair( INT_MIN , 0 ) << ") , (" << std::make_pair(birth(characteristicPoints[0]),0) << ") , (" << characteristicPoints[0] << ")";
            end
            int i = 1;
            vector< pair >  newCharacteristicPoints;
            while ( i < characteristicPoints.size() )
                 p = 1;
                if birth(characteristicPoints[i]) >= birth(lambda_n[lambda_n.size()-1])) && (death(characteristicPoints[i]) > death(lambda_n[lambda_n.size()-1])
                    if birth(characteristicPoints[i]) < death(lambda_n[lambda_n.size()-1])
                        po::MyPairint = make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 );
                        lambda_n.push_back( point );
                        if (dbg)
                            cerr << "2 Adding to lambda_n : (" << point << ")\n";
                        end
                        if dbg
                            cerr << "comparePoints(point,characteristicPoints[i+p]) : " << comparePoints(point,characteristicPoints[i+p]) << "\n";
                            cerr << "characteristicPoints[i+p] : " << characteristicPoints[i+p] << "\n";
                            cerr << "point : " << point << "\n";
                            getchar();
                        end

                        while ( (i+p < characteristicPoints.size() ) && ( almostEqual(birth(point),birth(characteristicPoints[i+p])) ) && ( death(point) <= death(characteristicPoints[i+p]) ) )
                            newCharacteristicPoints.push_back( characteristicPoints[i+p] );
                            if (dbg)
                                cerr << "3.5 Adding to newCharacteristicPoints : (" << characteristicPoints[i+p] << ")\n";
                                getchar();
                            end
                            ++p;
                        end
                        newCharacteristicPoints.push_back( point );
                        if (dbg)
                            cerr << "4 Adding to newCharacteristicPoints : (" << point << ")\n";
                        end
                        while ( (i+p < characteristicPoints.size() ) && ( birth(point) <= birth(characteristicPoints[i+p]) ) && (death(point)>=death(characteristicPoints[i+p])) )
                            newCharacteristicPoints.push_back( characteristicPoints[i+p] );
                            if (dbg)
                                cerr << "characteristicPoints[i+p] : " << characteristicPoints[i+p] << "\n";
                                cerr << "point : " << point << "\n";
                                cerr << "comparePoints(point,characteristicPoints[i+p]) : " << comparePoints(point,characteristicPoints[i+p]) << endl;
                                cerr << "characteristicPoints[i+p] birth and death : " << birth(characteristicPoints[i+p]) << " , " << death(characteristicPoints[i+p]) << "\n";
                                cerr << "point birth and death : " << birth(point) << " , " << death(point) << "\n";
                                cerr << "3 Adding to newCharacteristicPoints : (" << characteristicPoints[i+p] << ")\n";
                                getchar();
                            end
                            ++p;
                        end
                    else
                        lambda_n.push_back( make_pair( death(lambda_n[lambda_n.size()-1]) , 0 ) );
                        lambda_n.push_back( make_pair( birth(characteristicPoints[i]) , 0 ) );
                        if (dbg)
                            cerr << "5 Adding to lambda_n : (" << make_pair( death(lambda_n[lambda_n.size()-1]) , 0 ) << ")\n";
                            cerr << "5 Adding to lambda_n : (" << make_pair( birth(characteristicPoints[i]) , 0 ) << ")\n";
                        end
                    end
                    lambda_n.push_back( characteristicPoints[i] );
                    if (dbg)
                        cerr << "6 Adding to lambda_n : (" << characteristicPoints[i] << ")\n";
                    end
                else
                    newCharacteristicPoints.push_back( characteristicPoints[i] );
                    if (dbg)
                        cerr << "7 Adding to newCharacteristicPoints : (" << characteristicPoints[i] << ")\n";
                    end
                end
                i = i+p;
            end
            lambda_n.push_back( make_pair(death(lambda_n[lambda_n.size()-1]),0) );
            lambda_n.push_back( make_pair( INT_MAX , 0 ) );
            # CHANGE
            characteristicPoints = newCharacteristicPoints;
            # characteristicPoints.swap(newCharacteristicPoints);
            lambda_n.erase(unique(lambda_n.begin(), lambda_n.end()), lambda_n.end());
            push!(land, lambda_n );
    else
        if dbg
				println("Constructing persistence landscape based on a grid";getchar())
        # in this case useGridInComputations is true, therefore we will build a landscape on a grid.
        extern g::Float64ridDiameter;
        this->dimension = p.dimensionOfBarcode;
        pair minMax = p.minMax();
         numberOfBins = 2*((minMax.second - minMax.first)/gridDiameter)+1;
        # first element of a pa::MyPairir< ,::Float64 vector<double> > is a x-value. Second element is a vector of values of landscapes.
        vector< pair< ,::Float64 std::vector<double> > > criticalValuesOnPointsOfGrid(numberOfBins);
        # filling up the bins:
        # Now, the idea is to iterate on this->land[lambda-1] and use only points over there. The problem is at the very beginning, when there is nothing
        # in this->land. That is why over here, we make a fate this->land[0]. It will be later deteted before moving on.
        vector< pair > aa;
        aa.push_back( make_pair( INT_MIN , 0 ) );
        x = minMax.first;
        for i = 0 : numberOfBins 
            vector<double> v;
            pair< ,::Float64 vector<double> > p = std::make_pair( x , v );
            aa.push_back( make_pair( x , 0 ) );
            criticalValuesOnPointsOfGrid[i] = p;
            if dbg
				println("x : " << x << endl)
            x += 0.5*gridDiameter;
        end
        aa.push_back( make_pair( INT_MAX , 0 ) );
        if dbg
				println("Grid has been created. Now, begin to add intervals")
        # for every peristent interval
        for intervalNo = 0 : p.size() 
             beginn = ()(2*( p.barcodes[intervalNo].first-minMax.first )/( gridDiameter ))+1;
            if dbg
				println("We are considering interval : [" << p.barcodes[intervalNo].first << "," << p.barcodes[intervalNo].second << "]. It will begin in  : " << beginn << " in the grid")
            while ( criticalValuesOnPointsOfGrid[beginn].first < p.barcodes[intervalNo].second )
                if dbg
                    cerr << "Adding a value : (" << criticalValuesOnPointsOfGrid[beginn].first << "," << min( fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ) << ") " << endl;
                end
                criticalValuesOnPointsOfGrid[beginn].second.push_back(min( fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ) );
                ++beginn;
            end
        end
        # now, the basic structure is created. We need to translate it to a persistence landscape data structure.
        # To do so, first we need to sort all the vectors in criticalValuesOnPointsOfGrid[i].second
         maxNonzeroLambda = 0;
        for i = 0 : criticalValuesOnPointsOfGrid.size() 
            sort( criticalValuesOnPointsOfGrid[i].second.begin() , criticalValuesOnPointsOfGrid[i].second.end() , greater<int>() );
            if ( criticalValuesOnPointsOfGrid[i].second.size() > maxNonzeroLambda )maxNonzeroLambda = criticalValuesOnPointsOfGrid[i].second.size();end
        end
        if dbg
            cerr << "After sorting";
            for i = 0 : criticalValuesOnPointsOfGrid.size() 
                cerr << "x : " << criticalValuesOnPointsOfGrid[i].first << " : ";
                for j = 0 : criticalValuesOnPointsOfGrid[i].second.size() 
                    cerr << criticalValuesOnPointsOfGrid[i].second[j] << " ";
                end
                cerr << "\n\n";
            end
        end
        push!(land,aa);
        for lambda = 0 : maxNonzeroLambda 
            if dbg
				println("Constructing lambda_" << lambda << endl)
            vector< pair >  nextLambbda;
            nextLambbda.push_back( make_pair(INT_MIN,0) );
            # for every element in the domain for which the previous landscape is nonzero.
            bool wasPrevoiusStepZero = true;
             nr = 1;
            while (  nr < this->land[ size(land,1)-1 ].size()-1 )
                if (dbg) cerr << "nr : " << nr << endl;
                 address = ()(2*( this->land[ size(land,1)-1 ][nr].first-minMax.first )/( gridDiameter ));
                if dbg
                    cerr << "We are considering the element x : " << this->land[ size(land,1)-1 ][nr].first << ". Its position in the structure is : " << address << endl;
                end
                if  criticalValuesOnPointsOfGrid[address].second.size() <= lambda 
                    if (!wasPrevoiusStepZero)
                        wasPrevoiusStepZero = true;
                        if dbg
				println("AAAdding : (" << criticalValuesOnPointsOfGrid[address].first << " , " << 0 << ") to lambda_" << lambda << endl;getchar())
                        nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address].first , 0 ) );
                    end
                else
                     if wasPrevoiusStepZero
                         if dbg
				println("Adding : (" << criticalValuesOnPointsOfGrid[address-1].first << " , " << 0 << ") to lambda_" << lambda << endl;getchar())
                         nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address-1].first , 0 ) );
                         wasPrevoiusStepZero = false;
                     end
                     if dbg
				println("AAdding : (" << criticalValuesOnPointsOfGrid[address].first << " , " << criticalValuesOnPointsOfGrid[address].second[lambda] << ") to lambda_" << lambda << endl;getchar())
                     nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address].first , criticalValuesOnPointsOfGrid[address].second[lambda] ) );
                end
                ++nr;
            end
            if dbg
				println("Done with : lambda_" << lambda << endl;getchar();getchar();getchar())
            if lambda == 0
                # removing the first, fake, landscape
                this->land.clear();
            end
            nextLambbda.push_back( make_pair(INT_MAX,0) );
            nextLambbda.erase( unique( nextLambbda.begin(), nextLambbda.end() ), nextLambbda.end() );
            push!(land, nextLambbda );
        end
    end
end

function PersistenceLandscape::computeIntegralOfLandscape()const
    r::Float64esult = 0;
    for i = 0 : size(land,1) 
        for nr = 2 : this->land[i].size()-1 
            # it suffices to compute every planar integral and then sum them ap for each lambda_n
            result += 0.5*( this->land[i][nr].first - this->land[i][nr-1].first )*(this->land[i][nr].second + this->land[i][nr-1].second);
        end
    end
    return result;
end

pair computeParametersOfALine( p1::MyPair , std::p2::MyPair )
    # p1.second = a*p1.first + b => b = p1.second - a*p1.first
    # p2.second = a*p2.first + b = a*p2.first + p1.second - a*p1.first = p1.second + a*( p2.first - p1.first )
    # =>
    # (p2.second-p1.second)/( p2.first - p1.first )  = a
    # b = p1.second - a*p1.first.
    a = (p2.second-p1.second)/( p2.first - p1.first );
    b = p1.second - a*p1.first;
    return make_pair(a,b);
end

bool computeIntegralOfLandscapeDbg = false;
function PersistenceLandscape::computeIntegralOfLandscape( p::Float64 )const
    r::Float64esult = 0;
    for i = 0 : size(land,1) 
        for nr = 2 : this->land[i].size()-1 
            if (computeIntegralOfLandscapeDbg)cout << "nr : " << nr << "\n";
            # In this interval, the landscape has a form f(x) = ax+b. We want to compute integral of (ax+b)^p = 1/a * (ax+b)^p+1end/(p+1)
            pair coef = computeParametersOfALine( this->land[i][nr] , this->land[i][nr-1] );
            a = coef.first;
            b = coef.second;
            if (computeIntegralOfLandscapeDbg)cout << "(" << this->land[i][nr].first << "," << this->land[i][nr].second << ") , " << this->land[i][nr-1].first << "," << this->land[i][nr].second << ")" << endl;
            if ( this->land[i][nr].first == this->land[i][nr-1].first )continue;
            if a != 0
                result += 1/(a*(p+1)) * ( pow((a*this->land[i][nr].first+b),p+1) - pow((a*this->land[i][nr-1].first+b),p+1));
            end
            else
                result += ( this->land[i][nr].first - this->land[i][nr-1].first )*( pow(this->land[i][nr].second,p) );
            end
            if computeIntegralOfLandscapeDbg
                cout << "a : " <<a << " , b : " << b << endl;
                cout << "result : " << result << endl;
            end
        end
        # if (computeIntegralOfLandscapeDbg) cin.ignore();
    end
    return result;
end

function PersistenceLandscape::computeIntegralOfLandscapeMultipliedByIndicatorFunction( vector<pair > indicator )const
    PersistenceLandscape l = this->multiplyByIndicatorFunction(indicator);
    return l.computeIntegralOfLandscape();
end

function PersistenceLandscape::computeIntegralOfLandscapeMultipliedByIndicatorFunction( vector<pair > indicator , p::Float64 )const# this function compute integral of p-th power of landscape.
    PersistenceLandscape l = this->multiplyByIndicatorFunction(indicator);
    return l.computeIntegralOfLandscape(p);
end

# This is a standard function which pairs maxima and minima which are not more than epsilon apart.
# This algorithm do not reduce all of them, just make one passage through data. In order to reduce all of them
# use the function reduceAllPairsOfLowPersistenceMaximaMinima( e::Float64psilon )
# WARNING! THIS PROCEDURE MODIFIES THE LANDSCAPE!!!
unsigned PersistenceLandscape::removePairsOfLocalMaximumMinimumOfEpsPersistence(e::Float64psilon)
    numberOfReducedPairs = 0;
    for dim = 0  : size(land,1) 
        if ( 2 > this->land[dim].size()-3 )continue; #  to make sure that the loop in below is not infinite.
        for nr = 2 : this->land[dim].size()-3 
            if fabs(this->land[dim][nr].second - this->land[dim][nr+1].second) < epsilon) && (this->land[dim][nr].second != this->land[dim][nr+1].second
                # right now we modify only the lalues of a points. That means that angles of lines in the landscape changes a bit. This is the easiest computational
                # way of doing this. But I am not sure if this is the best way of doing such a reduction of nonessential critical points. Think about this!
                if this->land[dim][nr].second < this->land[dim][nr+1].second
                    this->land[dim][nr].second = this->land[dim][nr+1].second;
                end
                else
                    this->land[dim][nr+1].second = this->land[dim][nr].second;
                end
                ++numberOfReducedPairs;
            end
        end
    end
    return numberOfReducedPairs;
end

# this procedure redue all critical points of low persistence.
function PersistenceLandscape::reduceAllPairsOfLowPersistenceMaximaMinima( e::Float64psilon )
    numberOfReducedPoints = 1;
    while ( numberOfReducedPoints )
        numberOfReducedPoints = this->removePairsOfLocalMaximumMinimumOfEpsPersistence( epsilon );
    end
end

# It may happened that some landscape points obtained as a aresult of an algorithm lies in a line. In this case, the following procedure allows to
# remove unnecesary points.
bool reduceAlignedPointsBDG = false;
function PersistenceLandscape::reduceAlignedPoints( t::Float64ollerance )# this parapeter says how much the coeficients a and b in a formula y=ax+b may be different to consider points aligned.
    for dim = 0  : size(land,1) 
         nr = 1;
        vector< pair > lambda_n;
        lambda_n.push_back( this->land[dim][0] );
        while ( nr != this->land[dim].size()-2 )
            # first, compute a and b in formula y=ax+b of a line crossing this->land[dim][nr] and this->land[dim][nr+1].
            pair res = computeParametersOfALine( this->land[dim][nr] , this->land[dim][nr+1] );
            if reduceAlignedPointsBDG
                cout << "Considering points : " << this->land[dim][nr] << " and " << this->land[dim][nr+1] << endl;
                cout << "Adding : " << this->land[dim][nr] << " to lambda_n." << endl;
            end
            lambda_n.push_back( this->land[dim][nr] );
            a = res.first;
            b = res.second;
            int i = 1;
            while ( nr+i != this->land[dim].size()-2 )
                if reduceAlignedPointsBDG
                    cout << "Checking if : " << this->land[dim][nr+i+1] << " is aligned with them " << endl;
                end
                pair res1 = computeParametersOfALine( this->land[dim][nr] , this->land[dim][nr+i+1] );
                if fabs(res1.first-a) < tollerance) && (fabs(res1.second-b)<tollerance
                    if ( reduceAlignedPointsBDG )cout << "It is aligned " << endl;end
                    ++i;
                end
                    if ( reduceAlignedPointsBDG )cout << "It is NOT aligned " << endl;end
                    break;
                end
            end
            if reduceAlignedPointsBDG
                cout << "We are out of the while loop. The number of aligned points is : " << i << endl; # std::cin.ignore();
            end
            nr += i;
        end
        if reduceAlignedPointsBDG
            cout << "Out  of main while loop, done with this dimension " << endl;
            cout << "Adding : " << this->land[dim][ this->land[dim].size()-2 ] << " to lamnda_n " << endl;
            cout << "Adding : " << this->land[dim][ this->land[dim].size()-1 ] << " to lamnda_n " << endl;
            cin.ignore();
        end
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-2 ] );
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-1 ] );
        # if something was reduced, then replace this->land[dim] with the new lambda_n.
        if lambda_n.size() < this->land[dim].size()
            if lambda_n.size() > 4
                this->land[dim].swap(lambda_n);
            end
        end
    end
end

# Yet another function to smooth up the data. The idea of this one is as follows. Let us take a landscape point A which is not (+infty,0), (-infty,0) of (a,0), (b,0), where a and b denotes the
# points which support of the function begins and ends. Let B and C will be the landscape points after A. Suppose B and C are also no one as above.
# The question we are asking here is -- can we remove the point B and draw a line from A to C such that the difference in a landscape will be not greater than epsilon?
# To measure the penalty of removing B, the funcion penalty. In below, the simplese example is given:
function penalty(pair A,pair B, std::pair C)
    return fabs(functionValue(A,C,B.first)-B.second);
end# penalty
bool reducePointsDBG = false;
unsigned PersistenceLandscape::reducePoints( t::Float64ollerance , (::Float64*penalty)(pair ,pair,std::pair) )
    numberOfPointsReduced = 0;
    for dim = 0  : size(land,1) 
         nr = 1;
        vector< pair > lambda_n;
        if ( reducePointsDBG )cout << "Adding point to lambda_n : " << this->land[dim][0] << endl;
        lambda_n.push_back( this->land[dim][0] );
        while ( nr <= this->land[dim].size()-2 )
            if ( reducePointsDBG )cout << "Adding point to lambda_n : " << this->land[dim][nr] << endl;
            lambda_n.push_back( this->land[dim][nr] );
            if penalty( this->land[dim][nr],this->land[dim][nr+1],this->land[dim][nr+2] ) < tollerance
                ++nr;
                ++numberOfPointsReduced;
            end
            ++nr;
        end
        if ( reducePointsDBG )cout << "Adding point to lambda_n : " << this->land[dim][nr] << endl;
        if ( reducePointsDBG )cout << "Adding point to lambda_n : " <<this->land[dim][nr] << endl;
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-2 ] );
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-1 ] );
        # if something was reduced, then replace this->land[dim] with the new lambda_n.
        if lambda_n.size() < this->land[dim].size()
            if lambda_n.size() > 4
                # CHANGE
                # this->land[dim] = lambda_n;
                this->land[dim].swap(lambda_n);
            end
            else
                this->land[dim].clear();
            end
        end
    end
    return numberOfPointsReduced;
end

function findZeroOfALineSegmentBetweenThoseTwoPoints ( p1::MyPair, p2::MyPair )
    if ( p1.first == p2.first )return p1.first;
    if p1.second*p2.second > 0
        ostringstream errMessage;
        errMessage <<"In function findZeroOfALineSegmentBetweenThoseTwoPoints the agguments are: (" << p1.first << "," << p1.second << ") and (" << p2.first << "," << p2.second << "). There is no zero in line between those two points. Program terminated.";
        string errMessageStr = errMessage.str();
        char* err = errMessageStr.c_str();
        throw(err);
    end
    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    a = (p2.second - p1.second)/(p2.first - p1.first);
    b = p1.second - a*p1.first;
    # cerr << "Line crossing points : (" << p1.first << "," << p1.second << ") oraz (" << p2.first << "," << p2.second << ") :";
    # cerr << "a : " << a << " , b : " << b << " , x : " << x << endl;
    return -b/a;
end

# this is O(log(n)) algorithm, where n is number of points in this->land.
bool computeValueAtAGivenPointDbg = false;
function PersistenceLandscape::computeValueAtAGivenPoint( level::UInt, x::Float64 )const
    # in such a case lambda_level = 0.
    if ( level > size(land,1) ) return 0;
    # we know that the points in this->land[level] are ordered according to x coordinate. Therefore, we can find the point by using bisection:
    coordBegin = 1;
    coordEnd = this->land[level].size()-2;
    if computeValueAtAGivenPointDbg
        cerr << "Tutaj";
        cerr << "x : " << x << "\n";
        cerr << "this->land[level][coordBegin].first : " << this->land[level][coordBegin].first << "\n";
        cerr << "this->land[level][coordEnd].first : " << this->land[level][coordEnd].first << "\n";
    end
    # in this case x is outside the support of the landscape, therefore the value of the landscape is 0.
    if ( x <= this->land[level][coordBegin].first )return 0;
    if ( x >= this->land[level][coordEnd].first )return 0;
    if (computeValueAtAGivenPointDbg)cerr << "Entering to the while loop";
    while ( coordBegin+1 != coordEnd )
        if (computeValueAtAGivenPointDbg)
            cerr << "coordBegin : " << coordBegin << "\n";
            cerr << "coordEnd : " << coordEnd << "\n";
            cerr << "this->land[level][coordBegin].first : " << this->land[level][coordBegin].first << "\n";
            cerr << "this->land[level][coordEnd].first : " << this->land[level][coordEnd].first << "\n";
        end
        newCord = (unsigned)floor((coordEnd+coordBegin)/2.0);
        if (computeValueAtAGivenPointDbg)
            cerr << "newCord : " << newCord << "\n";
            cerr << "this->land[level][newCord].first : " << this->land[level][newCord].first << "\n";
            cin.ignore();
        end
        if this->land[level][newCord].first <= x
            coordBegin = newCord;
            if ( this->land[level][newCord].first == x )return this->land[level][newCord].second;
        end
        else
            coordEnd = newCord;
        end
    end
    if (computeValueAtAGivenPointDbg)
        cout << "x : " << x << " is between : " << this->land[level][coordBegin].first << " a  " << this->land[level][coordEnd].first << "\n";
        cout << "the y coords are : " << this->land[level][coordBegin].second << " a  " << this->land[level][coordEnd].second << "\n";
        cerr << "coordBegin : " << coordBegin << "\n";
        cerr << "coordEnd : " << coordEnd << "\n";
        cin.ignore();
    end
    return functionValue( this->land[level][coordBegin] , this->land[level][coordEnd] , x );
end

ostream& operator<<(ostream& out,land::PersistenceLandscape)
    for level = 0 : land.land.size() 
        out << "Lambda_" << level << ":" << endl;
        for i = 0 : land.land[level].size() 
            if land.land[level][i].first == INT_MIN
                out << "-inf";
            end
                if land.land[level][i].first == INT_MAX
                    out << "+inf";
                end
                    out << land.land[level][i].first;
                end
            end
            out << " , " << land.land[level][i].second << endl;
        end
    end
    return out;
end

function PersistenceLandscape::multiplyLanscapeByRealNumberOverwrite( x::Float64 )
    for dim = 0 : size(land,1) 
        for i = 0 : this->land[dim].size() 
             this->land[dim][i].second *= x;
        end
    end
end

bool AbsDbg = false;
PersistenceLandscape PersistenceLandscape::abs()
    PersistenceLandscape result;
    for level = 0 : size(land,1) 
        if ( AbsDbg ) cout << "level: " << level << endl; end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( INT_MIN , 0 ) );
        for i = 1 : this->land[level].size() 
            if ( AbsDbg )cout << "this->land[" << level << "][" << i << "] : " << this->land[level][i] << endl;end
            # if a line segment between this->land[level][i-1] and this->land[level][i] crosses the x-axis, then we have to add one landscape point t oresult
            if (this->land[level][i-1].second)*(this->land[level][i].second)  < 0
                z::Float64ero = findZeroOfALineSegmentBetweenThoseTwoPoints( this->land[level][i-1] , this->land[level][i] );
                lambda_n.push_back( make_pair(zero , 0) );
                lambda_n.push_back( make_pair(this->land[level][i].first , fabs(this->land[level][i].second)) );
                if AbsDbg
                    cout << "Adding pair : (" << zero << ",0)" << std::endl;
                    cout << "In the same step adding pair : (" << this->land[level][i].first << "," << fabs(this->land[level][i].second) << ") " << std::endl;
                    cin.ignore();
                end
            else
                lambda_n.push_back( make_pair(this->land[level][i].first , fabs(this->land[level][i].second)) );
                if AbsDbg
                    cout << "Adding pair : (" << this->land[level][i].first << "," << fabs(this->land[level][i].second) << ") " << std::endl;
                    cin.ignore();
                end
            end
        end
        result.land.push_back( lambda_n );
    end
    return result;
end

PersistenceLandscape PersistenceLandscape::multiplyLanscapeByRealNumberNotOverwrite( x::Float64 )const
    vector< std::vector< std::pair > > result(size(land,1));
    for dim = 0 : size(land,1) 
        vector< std::pair > lambda_dim( this->land[dim].size() );
        for i = 0 : this->land[dim].size() 
            lambda_dim[i] = make_pair( this->land[dim][i].first , x*this->land[dim][i].second );
        end
        result[dim] = lambda_dim;
    end
    PersistenceLandscape res;
    res.dimension = this->dimension;
    # CHANGE
    # res.land = result;
    res.land.swap(result);
    return res;
end# multiplyLanscapeByRealNumberOverwrite
bool operationOnPairOfLandscapesDBG = false;
PersistenceLandscape operationOnPairOfLandscapes ( land1 , land2::PersistenceLandscape, (::Float64*oper)()::PersistenceLandscape)
    if ( operationOnPairOfLandscapesDBG )cout << "operationOnPairOfLandscapes\n";std::cin.ignore();end
    PersistenceLandscape result;
    vector< std::vector< std::pair > > land( std::max( land1.land.size() , land2.land.size() ) );
    result.land = land;
    for i = 0 : min( land1.land.size() , land2.land.size() ) 
        vector< std::pair > lambda_n;
        int p = 0;
        int q = 0;
        while ( (p+1 < land1.land[i].size()) && (q+1 < land2.land[i].size()) )
            if operationOnPairOfLandscapesDBG
                cerr << "p : " << p << "\n";
                cerr << "q : " << q << "\n";
                cout << "land1.land[i][p].first : " << land1.land[i][p].first << "\n";
                cout << "land2.land[i][q].first : " << land2.land[i][q].first << "\n";
            end
            if land1.land[i][p].first < land2.land[i][q].first
                if operationOnPairOfLandscapesDBG
                    cout << "first";
                    cout << " functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) : "<<  functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) << "\n";
                    cout << "oper( " << land1.land[i][p].second <<"," << functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) << " : " << oper( land1.land[i][p].second , functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) ) << "\n";
                end
                lambda_n.push_back( make_pair( land1.land[i][p].first , oper( land1.land[i][p].second , functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) ) ) );
                ++p;
                continue;
            end
            if land1.land[i][p].first > land2.land[i][q].first
                if operationOnPairOfLandscapesDBG
                    cout << "Second";
                    cout << "functionValue("<< land1.land[i][p-1]<<" ,"<< land1.land[i][p]<<", " << land2.land[i][q].first<<" ) : " << functionValue( land1.land[i][p-1] , land1.land[i][p-1] ,land2.land[i][q].first ) << "\n";
                    cout << "oper( " << functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) <<"," << land2.land[i][q].second <<" : " << oper( land2.land[i][q].second , functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) ) << "\n";
                end
                lambda_n.push_back( make_pair( land2.land[i][q].first , oper( functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) , land2.land[i][q].second )  )  );
                ++q;
                continue;
            end
            if land1.land[i][p].first == land2.land[i][q].first
                if (operationOnPairOfLandscapesDBG)cout << "Third";
                lambda_n.push_back( make_pair( land2.land[i][q].first , oper( land1.land[i][p].second , land2.land[i][q].second ) ) );
                ++p;++q;
            end
            if (operationOnPairOfLandscapesDBG)cout << "Next iteration";getchar();end
        end
        while ( (p+1 < land1.land[i].size())&&(q+1 >= land2.land[i].size()) )
            if (operationOnPairOfLandscapesDBG)
                cout << "New point : " << land1.land[i][p].first << "  oper(land1.land[i][p].second,0) : " <<  oper(land1.land[i][p].second,0) << std::endl;
            end
            lambda_n.push_back( make_pair(land1.land[i][p].first , oper(land1.land[i][p].second,0) ) );
            ++p;
        end
        while ( (p+1 >= land1.land[i].size())&&(q+1 < land2.land[i].size()) )
            if (operationOnPairOfLandscapesDBG)
                cout << "New point : " << land2.land[i][q].first << " oper(0,land2.land[i][q].second) : " <<  oper(0,land2.land[i][q].second) << std::endl;
            end
            lambda_n.push_back( make_pair(land2.land[i][q].first , oper(0,land2.land[i][q].second) ) );
            ++q;
        end
        lambda_n.push_back( make_pair( INT_MAX , 0 ) );
        # CHANGE
        # result.land[i] = lambda_n;
        result.land[i].swap(lambda_n);
    end
    if land1.land.size() > min( land1.land.size() , land2.land.size() )
        if (operationOnPairOfLandscapesDBG)cout << "land1.land.size() > std::min( land1.land.size() , land2.land.size() )" << std::endl;end
        for i = min( land1.land.size() , land2.land.size() ) : std::max( land1.land.size() , land2.land.size() ) 
            vector< std::pair > lambda_n( land1.land[i] );
            for nr = 0 : land1.land[i].size() 
                lambda_n[nr] = make_pair( land1.land[i][nr].first , oper( land1.land[i][nr].second , 0 ) );
            end
            # CHANGE
            # result.land[i] = lambda_n;
            result.land[i].swap(lambda_n);
        end
    end
    if land2.land.size() > min( land1.land.size() , land2.land.size() )
        if (operationOnPairOfLandscapesDBG)cout << "( land2.land.size() > std::min( land1.land.size() , land2.land.size() ) ) " << std::endl;end
        for i = min( land1.land.size() , land2.land.size() ) : std::max( land1.land.size() , land2.land.size() ) 
            vector< std::pair > lambda_n( land2.land[i] );
            for nr = 0 : land2.land[i].size() 
                lambda_n[nr] = make_pair( land2.land[i][nr].first , oper( 0 , land2.land[i][nr].second ) );
            end
            # CHANGE
            # result.land[i] = lambda_n;
            result.land[i].swap(lambda_n);
        end
    end
    if ( operationOnPairOfLandscapesDBG )cout << "operationOnPairOfLandscapes\n";std::cin.ignore();end
    return result;
end# operationOnPairOfLandscapes
function computeMaximalDistanceNonSymmetric( pl1,pl2 , unsigned& nrOfLand , double&x::PersistenceLandscape, double& y1, double& y2::PersistenceLandscape)
    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    m::Float64axDist = 0;
    int minimalNumberOfLevels = min( pl1.land.size() , pl2.land.size() );
    for  int level = 0 : minimalNumberOfLevels 
        int p2Count = 0;
        for  int i = 1 : pl1.land[level].size()-1  # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while ( true )
                if (  (pl1.land[level][i].first>=pl2.land[level][p2Count].first) && (pl1.land[level][i].first<=pl2.land[level][p2Count+1].first)  )break;
                p2Count++;
            end
            v::Float64al = fabs( functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) - pl1.land[level][i].second);
            # cerr << "functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) : " << functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) << "\n";
            # cerr << "pl1.land[level][i].second : " << pl1.land[level][i].second << "\n";
            # cerr << "pl1.land[level][i].first :" << pl1.land[level][i].first << "\n";
            # cin.ignore();
            if maxDist <= val
                maxDist = val;
                nrOfLand = level;
                x = pl1.land[level][i].first;
                y1 = pl1.land[level][i].second;
                y2 = functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first );
            end
       end
    end
    if minimalNumberOfLevels < pl1.land.size()
        for  int level = minimalNumberOfLevels : pl1.land.size() 
            for  int i = 0 : pl1.land[level].size() 
                if maxDist < pl1.land[level][i].second
                    maxDist = pl1.land[level][i].second;
                    nrOfLand = level;
                    x = pl1.land[level][i].first;
                    y1 = pl1.land[level][i].second;
                    y2 = 0;
                end
            end
        end
    end
    return maxDist;
end

function computeMaxNormDiscanceOfLandscapes( first,second , unsigned& nrOfLand , double&x::PersistenceLandscape, double& y1, double& y2::PersistenceLandscape)
    unsigned nrOfLandFirst;
    x::Float64First, y1First, y2First;
    d::Float64First = computeMaximalDistanceNonSymmetric(first,second,nrOfLandFirst,xFirst, y1First, y2First);
    unsigned nrOfLandSecond;
    x::Float64Second, y1Second, y2Second;
    d::Float64Second = computeMaximalDistanceNonSymmetric(second,first,nrOfLandSecond,xSecond, y1Second, y2Second);
    if dFirst > dSecond
        nrOfLand = nrOfLandFirst;
        x = xFirst;
        y1 = y1First;
        y2 = y2First;
    else
        nrOfLand = nrOfLandSecond;
        x = xSecond;
        # this twist in below is neccesary!
        y2 = y1Second;
        y1 = y2Second;
        # y1 = y1Second;
        # y2 = y2Second;
    end
    return max( dFirst , dSecond );
end

function computeMaximalDistanceNonSymmetric(pl1, PersistenceLandscape& pl2::PersistenceLandscape)
    bool dbg = false;
    if (dbg)cerr << " computeMaximalDistanceNonSymmetric";
    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    m::Float64axDist = 0;
    int minimalNumberOfLevels = min( pl1.land.size() , pl2.land.size() );
    for  int level = 0 : minimalNumberOfLevels 
        if (dbg)
            cerr << "Level : " << level << std::endl;
            cerr << "PL1 :";
            for  int i = 0 : pl1.land[level].size() 
                cerr << "(" <<pl1.land[level][i].first << "," << pl1.land[level][i].second << ")";
            end
            cerr << "PL2 :";
            for  int i = 0 : pl2.land[level].size() 
                cerr << "(" <<pl2.land[level][i].first << "," << pl2.land[level][i].second << ")";
            end
            cin.ignore();
        end
        int p2Count = 0;
        for  int i = 1 : pl1.land[level].size()-1  # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while ( true )
                if (  (pl1.land[level][i].first>=pl2.land[level][p2Count].first) && (pl1.land[level][i].first<=pl2.land[level][p2Count+1].first)  )break;
                p2Count++;
            end
            v::Float64al = fabs( functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) - pl1.land[level][i].second);
            if ( maxDist <= val )maxDist = val;
            if (dbg)
                cerr << pl1.land[level][i].first <<"in [" << pl2.land[level][p2Count].first << "," <<  pl2.land[level][p2Count+1].first <<"]";
                cerr << "pl1[level][i].second : " << pl1.land[level][i].second << std::endl;
                cerr << "functionValue( pl2[level][p2Count] , pl2[level][p2Count+1] , pl1[level][i].first ) : " << functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) << std::endl;
                cerr << "val : "  << val << std::endl;
                cin.ignore();
            end
        end
    end
    if (dbg)cerr << "minimalNumberOfLevels : " << minimalNumberOfLevels << std::endl;
    if minimalNumberOfLevels < pl1.land.size()
        for  int level = minimalNumberOfLevels : pl1.land.size() 
            for  int i = 0 : pl1.land[level].size() 
                if (dbg)cerr << "pl1[level][i].second  : " << pl1.land[level][i].second << std::endl;
                if ( maxDist < pl1.land[level][i].second )maxDist = pl1.land[level][i].second;
            end
        end
    end
    return maxDist;
end

function computeDiscanceOfLandscapes( first,second::PersistenceLandscape, unsigned p::PersistenceLandscape)
    # This is what we want to compute: (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p). We will do it one step at a time:
    # first-second :
    PersistenceLandscape lan = first-second;
    # | first-second |:
    lan = lan.abs();
    # \int_- \inftyend^+\inftyend| first-second |^p
    r::Float64esult;
    if p != 1
        result = lan.computeIntegralOfLandscape(p);
    else
        result = lan.computeIntegralOfLandscape();
    end
    # (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p)
    return pow( result , 1/(double)p );
end

function computeMaxNormDiscanceOfLandscapes(first, PersistenceLandscape& second::PersistenceLandscape)
    return max( computeMaximalDistanceNonSymmetric(first,second) , computeMaximalDistanceNonSymmetric(second,first) );
end

function comparePairsForMerging( pair< ,::Float64 unsigned > first , std::pair< ,::Float64 unsigned > second )
    return (first.first < second.first);
end

vector< std::pair< ,::Float64 unsigned > > PersistenceLandscape::generateBettiNumbersHistogram()const
    bool dbg = false;
    vector< std::pair< ,::Float64 unsigned > > resultRaw;
    for dim = 0 : size(land,1) 
        vector< std::pair< ,::Float64 unsigned > > rangeOfLandscapeInThisDimension;
        if dim > 0
            for i = 1 : this->land[dim].size()-1 
                if this->land[dim][i].second == 0
                    rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , dim+1));
                end
            end
        else
            # dim == 0.
            bool first = true;
            for i = 1 : this->land[dim].size()-1 
                if this->land[dim][i].second == 0
                    if ( first ) rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , 0)); end
                    rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , dim+1));
                    if ( !first ) rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , 0)); end
                    first = !first;
                end
            end
        end
        vector< std::pair< ,::Float64 unsigned > > resultRawNew( resultRaw.size() + rangeOfLandscapeInThisDimension.size() );
        merge( resultRaw.begin() , resultRaw.end() , rangeOfLandscapeInThisDimension.begin() , rangeOfLandscapeInThisDimension.end() , resultRawNew.begin() , comparePairsForMerging );
        resultRaw.swap( resultRawNew );
        if dbg
            cerr << "Raw result : for dim : " << dim << std::endl;
            for i = 0 : resultRaw.size() 
                cerr << "(" << resultRaw[i].first << " , " << resultRaw[i].second << ")" << std::endl;
            end
            getchar();
        end
    end
    if dbg
        cerr << "Raw result : " << std::endl;
        for i = 0 : resultRaw.size() 
            cerr << "(" << resultRaw[i].first << " , " << resultRaw[i].second << ")" << std::endl;
        end
        getchar();
    end
    # now we should make it into a step function by adding a points in the jumps:
    vector< std::pair< ,::Float64 unsigned > > result;
    if ( resultRaw.size() == 0 )return result;
    for i = 1 : resultRaw.size() 
        result.push_back( resultRaw[i-1] );
        if resultRaw[i-1].second <= resultRaw[i].second
            result.push_back( make_pair( resultRaw[i].first , resultRaw[i-1].second ) );
        else
            result.push_back( make_pair( resultRaw[i-1].first , resultRaw[i].second ) );
        end
    end
    result.erase( unique( result.begin(), result.end() ), result.end() );

    vector< std::pair< ,::Float64 unsigned > > resultNew;
     i = 0 ;
    while ( i != result.size() )
        x = result[i].first;
        m::Float64axBetti = result[i].second;
        m::Float64inBetti = result[i].second;
        while ( (i != result.size()) && (fabs(result[i].first - x) < 0.000001) )
            if ( maxBetti < result[i].second )maxBetti = result[i].second;
            if ( minBetti > result[i].second )minBetti = result[i].second;
            ++i;
        end
        if minBetti != maxBetti
            if resultNew.size() == 0 || (resultNew[resultNew.size()-1].second <= minBetti
                # going up
                resultNew.push_back( make_pair( x , minBetti ) );
                resultNew.push_back( make_pair( x , maxBetti ) );
            end
            else
                # going down
                resultNew.push_back( make_pair( x , maxBetti ) );
                resultNew.push_back( make_pair( x , minBetti ) );
            end
        else
            resultNew.push_back( make_pair( x , minBetti ) );
        end
    end
    result.swap(resultNew);
    if dbg
        cerr << "Final result : " << std::endl;
        for i = 0 : result.size() 
            cerr << "(" << result[i].first << " , " << result[i].second << ")" << std::endl;
        end
        getchar();
    end
    return result;
end# generateBettiNumbersHistogram

function PersistenceLandscape::printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand( char* filename )const
    vector< std::pair< ,::Float64 > > histogram = this->generateBettiNumbersHistogram();
    ostringstream result;
    for i = 0 : histogram.size() 
        result << histogram[i].first << " " << histogram[i].second << endl;
    end
    ofstream write;
    write.open( filename );
    write << result.str();
    write.close();
    cout << "The result is in the file : " << filename <<" . Now in gnuplot type plot \"" << filename << "\" with lines" << std::endl;
end# printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand

function computeInnerProduct( l1::PersistenceLandscape,l2::PersistenceLandscape)
    bool dbg = true;
    r::Float64esult = 0;
    for level = 0 : min( l1.size() , l2.size() )
        if dbg
				println("Computing inner product for a level : " << level << endl;getchar())
        if ( l1.land[level].size() * l2.land[level].size() == 0 )continue;
        # endpoints of the interval on which we will compute the inner product of two locally linear functions:
        x::Float641 = INT_MIN;
        x::Float642;
        if l1.land[level][1].first < l2.land[level][1].first
            x2 = l1.land[level][1].first;
        end
        else
            x2 = l2.land[level][1].first;
        end
        # iterators for the landscapes l1 and l2
         l1It = 0;
         l2It = 0;
        while ( (l1It < l1.land[level].size()-1) && (l2It < l2.land[level].size()-1) )
            # compute the value of a inner product on a interval [x1,x2]
            a::Float64,b,c,d;
            a = (l1.land[level][l1It+1].second - l1.land[level][l1It].second)/(l1.land[level][l1It+1].first - l1.land[level][l1It].first);
            b = l1.land[level][l1It].second - a*l1.land[level][l1It].first;
            c = (l2.land[level][l2It+1].second - l2.land[level][l2It].second)/(l2.land[level][l2It+1].first - l2.land[level][l2It].first);
            d = l2.land[level][l2It].second - c*l2.land[level][l2It].first;
            contributionFromThisPart
            =
            (a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2) - (a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1);
            result += contributionFromThisPart;
            if dbg
                cerr << "[l1.land[level][l1It].first,l1.land[level][l1It+1].first] : " << l1.land[level][l1It].first << " , " << l1.land[level][l1It+1].first << endl;
                cerr << "[l2.land[level][l2It].first,l2.land[level][l2It+1].first] : " << l2.land[level][l2It].first << " , " << l2.land[level][l2It+1].first << endl;
                cerr << "a : " << a << ", b : " << b << " , c: " << c << ", d : " << d << endl;
                cerr << "x1 : " << x1 << " , x2 : " << x2 << endl;
                cerr << "contributionFromThisPart : " << contributionFromThisPart << endl;
                cerr << "result : " << result << endl;
                getchar();
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
                    ++l2It;
                    if dbg
				println("Incrementing both")
                else
                    if dbg
				println("Incrementing first")
                end
                ++l1It;
            else
                # in this case we increment l2It
                ++l2It;
                if ( dbg )cerr << "Incrementing second"
                end
            end
            # Now, we shift x1 and x2:
            x1 = x2;
            if l1.land[level][l1It+1].first < l2.land[level][l2It+1].first
                x2 = l1.land[level][l1It+1].first;
            else
                x2 = l2.land[level][l2It+1].first;
            end
        end
    end
    return result;
end

#endif
