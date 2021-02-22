#=
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
#pragma once
#ifndef PERISTENCELANDSCAPE_H
#define PERISTENCELANDSCAPE_H
#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <algorithm>
#include <cmath>
#include <list>
#include <climits>
#include <limits>
#include <cstdarg>
#include <iomanip>
#include <unistd.h>
#include "Configure.h"
#include "PersistenceBarcode.h"
function almostEqual( a::Float64 , b::Float64 )
    if ( abs(a-b) < eps )
        return true;
    return false;
end
function birth(pair a)
    return a.first-a.second;
end
function death( pair a )
    return a.first+a.second;
end
# functions used in PersistenceLandscape( const PersistenceBarcodes& p ) constructor:
comparePointsDBG::Bool = false;
function comparePoints( pair f, pair s )
    double differenceBirth = birth(f)-birth(s);
    if ( differenceBirth < 0 )differenceBirth *= -1;
    double differenceDeath = death(f)-death(s);
    if ( differenceDeath < 0 )differenceDeath *= -1;
    if ( (differenceBirth < epsi) && (differenceDeath < epsi)  )
        if(comparePointsDBG)cerr << "CP1 \n";end
        return false;
    end
    if ( (differenceBirth < epsi) )
        # consider birth points the same. If we are here, we know that death points are NOT the same
        if ( death(f) < death(s) )
            if(comparePointsDBG)cerr << "CP2 \n";end
            return true;
        end
        if(comparePointsDBG)cerr << "CP3 \n";end
        return false;
    end
    if ( differenceDeath < epsi )
        # we consider death points the same and since we are here, the birth points are not the same!
        if ( birth(f) < birth(s) )
            if(comparePointsDBG)cerr << "CP4 \n";end
            return false;
        end
        if(comparePointsDBG)cerr << "CP5 \n";end
        return true;
    end
    if ( birth(f) > birth(s) )
        if(comparePointsDBG)cerr << "CP6 \n";end
        return false;
    end
    if ( birth(f) < birth(s) )
        if(comparePointsDBG)cerr << "CP7 \n";end
        return true;
    end
    # if this is true, we assume that death(f)<=death(s) -- othervise I have had a lot of roundoff problems here!
    if ( (death(f)<=death(s)) )
        if(comparePointsDBG)cerr << "CP8 \n";end
        return false;
    end
    if(comparePointsDBG)cerr << "CP9 \n";end
    return true;
end
# this function assumes birth-death coords
function comparePoints2(f,s )
    if ( f.first < s.first )
        return true;
    else
    # f.first >= s.first
        if ( f.first > s.first )
            return false;
        else
        # f.first == s.first
            if ( f.second > s.second )
                return true;
            else
                return false;
            end
        end
    end
end
class vectorSpaceOfPersistenceLandscapes;
# functions used to add and subtract landscapes
function add(double x, double y)return x+y;end
function sub(double x, double y)return x-y;end
# function used in computeValueAtAGivenPoint
function functionValue ( pair p1, pair p2 , double x )
    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    double a = (p2.second - p1.second)/(p2.first - p1.first);
    double b = p1.second - a*p1.first;
    # cerr << "Line crossing points : (" << p1.first << "," << p1.second << ") oraz (" << p2.first << "," << p2.second << ") : \n";
    # cerr << "a : " << a << " , b : " << b << " , x : " << x << endl;
    return (a*x+b);
end
class PersistenceLandscape
public:
    # bool testLandscape( const PersistenceBarcodes& b );# for tests only!
    #
    # PersistenceLandscape()this->dimension = 0;end
    # PersistenceLandscape( const PersistenceBarcodes& p );
    # PersistenceLandscape operator=( const PersistenceLandscape& org );
    # PersistenceLandscape(const PersistenceLandscape&);
    # PersistenceLandscape(char* filename);
    #
    # PersistenceLandscape(vector< std::vector<std::pair > > landscapePointsWithoutInfinities);
    # vector< std::vector<std::pair > > gimmeProperLandscapePoints();
    #
    #
    # double computeIntegralOfLandscape()const;
    # double computeIntegralOfLandscape( double p )const;# this function compute integral of p-th power of landscape.
    # double computeIntegralOfLandscapeMultipliedByIndicatorFunction( vector<std::pair > indicator )const;
    # double computeIntegralOfLandscapeMultipliedByIndicatorFunction( vector<std::pair > indicator,double p )const;# this function compute integral of p-th power of landscape multiplied by the indicator function.
    # PersistenceLandscape multiplyByIndicatorFunction( vector<std::pair > indicator )const;
    #
    # unsigned removePairsOfLocalMaximumMinimumOfEpsPersistence(double errorTolerance);
    # void reduceAllPairsOfLowPersistenceMaximaMinima( double epsilon );
    # void reduceAlignedPoints(double tollerance = 0.000001);
    # unsigned reducePoints( double tollerance , double (*penalty)(pair ,pair,std::pair) );
    # double computeValueAtAGivenPoint( unsigned level , double x )const;
    # function ostream& operator<<(ostream& out, PersistenceLandscape& land );
    #
    # void computeLandscapeOnDiscreteSetOfPoints( PersistenceBarcodes& b , double dx );
    #
    # typedef vector< pair >::iterator lDimIterator;
    function lDimBegin(unsigned dim)
        if ( dim > this->land.size() )
            throw("Calling lDimIterator in a dimension higher that dimension of landscape");
        return this->land[dim].begin();
    end
    function lDimEnd(unsigned dim)
        if ( dim > this->land.size() )
            throw("Calling lDimIterator in a dimension higher that dimension of landscape");
        return this->land[dim].end();
    end
    # PersistenceLandscape multiplyLanscapeByRealNumberNotOverwrite( double x )const;
    # void multiplyLanscapeByRealNumberOverwrite( double x );
    #
    # void plot( char* filename , from=-1,  to=-1 ,  double xRangeBegin = -1 , double xRangeEnd = -1 , double yRangeBegin = -1 , double yRangeEnd = -1 );
    #
    #
    # PersistenceBarcodes convertToBarcode();
# functionzone:
    # this is a general algorithm to perform linear operations on persisntece lapscapes. It perform it by doing operations on landscape points.
    # function operationOnPairOfLandscapes ( const PersistenceLandscape& land1 ,  const PersistenceLandscape& land2 , double (*oper)() );
    function addTwoLandscapes ( const PersistenceLandscape& land1 ,  const PersistenceLandscape& land2 ) :: PersistenceLandscape
        return operationOnPairOfLandscapes(land1,land2,add);
    end
    function subtractTwoLandscapes ( const PersistenceLandscape& land1 ,  const PersistenceLandscape& land2 ):: PersistenceLandscape 
        return operationOnPairOfLandscapes(land1,land2,sub);
    end
    function PersistenceLandscape operator+( const PersistenceLandscape& first , const PersistenceLandscape& second )
        return addTwoLandscapes( first,second );
    end
    function PersistenceLandscape operator-( const PersistenceLandscape& first , const PersistenceLandscape& second )
        return subtractTwoLandscapes( first,second );
    end
    function PersistenceLandscape operator*( const PersistenceLandscape& first , double con )
        return first.multiplyLanscapeByRealNumberNotOverwrite(con);
    end
    function PersistenceLandscape operator*( double con , const PersistenceLandscape& first  )
        return first.multiplyLanscapeByRealNumberNotOverwrite(con);
    end
    function operator += ( const PersistenceLandscape& rhs )
        *this = *this + rhs;
        return *this;
    end
    function operator -= ( const PersistenceLandscape& rhs )
        *this = *this - rhs;
        return *this;
    end
    function operator *= ( double x )
        *this = *this*x;
        return *this;
    end
    function operator /= ( double x )
        if ( x == 0 )throw( "In operator /=, division by 0. Program terminated." );
        *this = *this * (1/x);
        return *this;
    end
    bool operator == ( const PersistenceLandscape& rhs  )const;
    function computeMaximum()
        maxValue = 0;
        if ( this->land.size() )
            maxValue = -INT_MAX;
            for (  i = 0 ; i != this->land[0].size() ; ++i )
                if ( this->land[0][i].second > maxValue )maxValue = this->land[0][i].second;
            end
        end
        return maxValue;
    end
    function computeNormOfLandscape( int i )
        PersistenceLandscape l;
        if ( i != -1 )
            return computeDiscanceOfLandscapes(*this,l,i);
        else
            return computeMaxNormDiscanceOfLandscapes(*this,l);
        end
    end
    double operator()(unsigned level,double x)constreturn this->computeValueAtAGivenPoint(level,x);end
    # function double computeMaxNormDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second );
    # function double computeMaxNormDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second , unsigned& nrOfLand , double&x , double& y1, double& y2 );
    #
    # function double computeDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second , unsigned p );
    #
    # function double computeMaximalDistanceNonSymmetric( const PersistenceLandscape& pl1, const PersistenceLandscape& pl2 );
    #
    # function double computeMaximalDistanceNonSymmetric( const PersistenceLandscape& pl1, const PersistenceLandscape& pl2 , unsigned& nrOfLand , double&x , double& y1, double& y2 );
    # this function additionally returns integer n and double x, y1, y2 such that the maximal distance is obtained betwenn lambda_n's on a coordinate x
    # such that the value of the first landscape is y1, and the vale of the second landscape is y2.
    function class vectorSpaceOfPersistenceLandscapes;
    unsigned dim()constreturn this->dimension;end
    function minimalNonzeroPoint( unsigned l )
        if ( this->land.size() < l )return INT_MAX;
        return this->land[l][1].first;
    end
    function maximalNonzeroPoint( unsigned l )
        if ( this->land.size() < l )return INT_MIN;
        return this->land[l][ this->land[l].size()-2 ].first;
    end
    PersistenceLandscape abs();
    function size()
        return this->land.size()
    end
    double findMax( unsigned lambda )const;
    function double computeInnerProduct( const PersistenceLandscape& l1 , const PersistenceLandscape& l2 );
    # visualization part...
#     void printToFiles( const char* filename , unsigned from , unsigned to )const;
#     void printToFiles( const char* filename )const;
#     void printToFiles( const char* filename, int numberOfElementsLater,  ... )const;
#     void printToFile( const char* filename , unsigned from , unsigned to )const;
#     void printToFile( const char* filename )const;
#     void generateGnuplotCommandToPlot( const char* filename , unsigned from , unsigned to )const;
#     void generateGnuplotCommandToPlot(const char* filename)const;
#     void generateGnuplotCommandToPlot(const char* filename,int numberOfElementsLater,  ... )const;
#
#     # this function compute n-th moment of lambda_level
#     double computeNthMoment( unsigned n , double center , unsigned level )const;
#
#    # those are two new functions to generate histograms of Betti numbers across the filtration values.
#     vector< pair< double , unsigned > > generateBettiNumbersHistogram()const;
#     void printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand( char* filename )const;
# private:
#     vector< vector< std::pair > > land;
#     unsigned dimension;
end;
# function PersistenceLandscape::plot( char* filename ,  from,  to , double xRangeBegin , double xRangeEnd , double yRangeBegin , double yRangeEnd )
#
#     # this program create a gnuplot script file that allows to plot persistence diagram.
#     ofstream out;
#
#     ostringstream nameSS;
#     nameSS << filename << "_GnuplotScript";
#     string nameStr = nameSS.str();
#     out.open( (char*)nameStr.c_str() );
#
#     if ( (xRangeBegin != -1) || (xRangeEnd != -1) || (yRangeBegin != -1) || (yRangeEnd != -1)  )
#         out << "set xrange [" << xRangeBegin << " : " << xRangeEnd << "]" << endl;
#         out << "set yrange [" << yRangeBegin << " : " << yRangeEnd << "]" << endl;
#     end
#
#     if ( from == -1 )from = 0;end
#     if ( to == -1 )to = this->land.size();end
#
#     out << "plot ";
#     for (  lambda= min(from,this->land.size()) ; lambda != min(to,this->land.size()) ; ++lambda )
#         out << "     '-' using 1:2 title 'l" << lambda << "' with lp";
#         if ( lambda+1 != min(to,this->land.size()) )
#             out << ", \\";
#         end
#         out << endl;
#     end
#
#     for (  lambda= min(from,this->land.size()) ; lambda != min(to,this->land.size()) ; ++lambda )
#         for (  i = 1 ; i != this->land[lambda].size()-1 ; ++i )
#             out << this->land[lambda][i].first << " " << this->land[lambda][i].second << endl;
#         end
#         out << "EOF" << endl;
#     end
#     cout << "Gnuplot script to visualize persistence diagram written to the file: " << nameStr << ". Type load '" << nameStr << "' in gnuplot to visualize." << endl;
# end
function PersistenceLandscape::PersistenceLandscape(vector< vector<std::pair > > landscapePointsWithoutInfinities)
    for (  level = 0 ; level != landscapePointsWithoutInfinities.size() ; ++level )
        vector< pair > v;
        v.push_back(make_pair(INT_MIN,0));
        v.insert( v.end(), landscapePointsWithoutInfinities[level].begin(), landscapePointsWithoutInfinities[level].end() );
        v.push_back(make_pair(INT_MAX,0));
        this->land.push_back( v );
    end
    this->dimension = 0;
end
vector< vector<std::pair > > PersistenceLandscape::gimmeProperLandscapePoints()
    vector< vector<std::pair > > result;
    for (  level = 0  ; level != this->land.size() ; ++level )
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
#     if ( this->land[0].size() )
#     
#         vector< pair > localMinimas;
#
#
#
#         for (  level = 0 ; level != this->land.size() ; ++level )
#         
#             if ( dbg )
#             
#                 cerr << "\n\n\n Level : " << level << endl;
#                 cerr << "Here is the list of local minima : \n";
#                 for (  i = 0 ; i != localMinimas.size() ; ++i )
#                 
#                     cerr << localMinimas[i] << " ";
#                 end
#                 cerr << "\n";
#                 getchar();
#             end
#
#              localMinimaCounter = 0;
#             vector< pair > newLocalMinimas;
#             for (  i = 1 ; i != this->land[level].size()-1 ; ++i )
#             
#                 if ( dbg )
#                 
#                     cerr << "Considering a pair : " << this->land[level][i] << endl;
#                 end
#                 if ( this->land[level][i].second == 0 )continue;
#
#                 if ( (this->land[level][i].second > this->land[level][i-1].second) && (this->land[level][i].second > this->land[level][i+1].second) )
#                 
#                     # if this is a local maximum. The question is -- is it also a local minimum of a previous function?
#                     bool isThisALocalMinimumOfThePreviousLevel = false;
#
#                     if ( dbg )
#                     
#                         cerr << "It is a local maximum. Now we are checking if it is also a local minimum of the previous function." << endl;
#                     end
#
#                     while ( (localMinimaCounter < localMinimas.size()) && (localMinimas[localMinimaCounter].first < this->land[level][i].first ) )
#                     
#                         if ( dbg )
#                         
#                             cerr << "Adding : " << localMinimas[localMinimaCounter] << " to new local minima \n";
#                         end
#                         newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                         ++localMinimaCounter;
#                     end
#
#                     if ( localMinimaCounter != localMinimas.size() )
#                     
#                         if ( localMinimas[localMinimaCounter] == this->land[level][i] )
#                         
#                             isThisALocalMinimumOfThePreviousLevel = true;
#                             ++localMinimaCounter;
#                         end
#                     end
#                     if ( !isThisALocalMinimumOfThePreviousLevel )
#                     
#                         if ( dbg )
#                         
#                             cerr << "It is not a local minimum of the previous level, so it is a point : " << birth(this->land[level][i]) << " ,  " << death(this->land[level][i]) <<
#                             " in a persistence diagram! \n";
#                         end
#                         persistencePoints.push_back( make_pair(birth(this->land[level][i]), death(this->land[level][i]) ) );
#                     end
#                     if ( (dbg) && (isThisALocalMinimumOfThePreviousLevel) )
#                     
#                         cerr << "It is a local minimum of the previous, so we do nothing \n";
#                     end
#
#                 end
#                 if ( this->land[level][i].second != 0 )
#                 
#                     if ( (this->land[level][i].second < this->land[level][i-1].second) && (this->land[level][i].second < this->land[level][i+1].second) )
#                     
#                         if ( dbg )
#                         
#                             cerr << "This point is a local minimum, so we add it to a list of local minima.\n";
#                         end
#                         # local minimum
#                         if ( localMinimas.size() )
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
#                     if ( dbg )
#                     
#                         cerr << "It is a local maximum and the local minimum." << endl;
#                     end
#
#                     while ( (localMinimaCounter < localMinimas.size()) && (localMinimas[localMinimaCounter].first < this->land[level][i].first ) )
#                     
#                         newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                         ++localMinimaCounter;
#                     end
#                     if ( localMinimaCounter != localMinimas.size() )
#                     
#                         if ( localMinimas[localMinimaCounter] == this->land[level][i] )
#                         
#                             isThisALocalMinimumOfThePreviousLevel = true;
#                             ++localMinimaCounter;
#                         end
#                     end
#                     if ( !isThisALocalMinimumOfThePreviousLevel )
#                     
#                         if ( dbg )
#                         
#                             cerr << "It is not a local minimum of the previous level, so it is a point in a persistence diagram! \n";
#                         end
#                         persistencePoints.push_back( make_pair(birth(this->land[level][i]), death(this->land[level][i]) ) );
#                     end
#                     if ( (dbg) && (isThisALocalMinimumOfThePreviousLevel) )
#                     
#                         cerr << "It is a local minimum of the previous, so we do nothing \n";
#                     end
#                 end
#             end
#
#             if (dbg)
#             
#                 cerr << "Exit the loop for this level, exchanging local minimas lists \n";
#                 cerr << "localMinimas.size() : " << localMinimas.size() << endl;
#                 cerr << "localMinimaCounter : " << localMinimaCounter << endl;
#             end
#             if ( localMinimas.size() )
#             
#                 while ( localMinimaCounter < localMinimas.size() )
#                 
#                     newLocalMinimas.push_back( localMinimas[localMinimaCounter] );
#                     ++localMinimaCounter;
#                 end
#             end
#             cerr << "here \n";
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
function check_if_file_exist(const char* name) 
    return ( access( name, F_OK ) != -1 );
end
PersistenceLandscape::PersistenceLandscape(char* filename)
    bool dbg = false;
    if ( dbg )
        cerr << "Using constructor : PersistenceLandscape(char* filename)" << endl;
    end
    if ( !check_if_file_exist( filename ) )
		cout << "The file : " << filename << " do not exist. The program will now terminate \n";
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
        if ( !(line.length() == 0 || line[0] == '#') )
            stringstream lineSS;
            lineSS << line;
            double beginn, endd;
            lineSS >> beginn;
            lineSS >> endd;
            # if ( beginn > endd )
            # 
            #     double b = beginn;
            #     beginn = endd;
            #     endd = b;
            # end
            landscapeAtThisLevel.push_back( make_pair( beginn , endd ) );
            if (dbg)cerr << "Reading a pont : " << beginn << " , " << endd << endl;end
        else
            if (dbg)
                cout << "IGNORE LINE\n";
                getchar();
            end
            if ( !isThisAFirsLine )
                landscapeAtThisLevel.push_back( make_pair( INT_MAX , 0 ) );
                this->land.push_back(landscapeAtThisLevel);
                vector< pair > newLevelOdLandscape;
                landscapeAtThisLevel.swap(newLevelOdLandscape);
            end
            landscapeAtThisLevel.push_back( make_pair( INT_MIN , 0 ) );
            isThisAFirsLine = false;
        end
	end
	if ( landscapeAtThisLevel.size() > 1 )
        # seems that the last line of the file is not finished with the newline sign. We need to put what we have in landscapeAtThisLevel to the constructed landscape.
        landscapeAtThisLevel.push_back( make_pair( INT_MAX , 0 ) );
        this->land.push_back(landscapeAtThisLevel);
    end
    in.close();
end
operatorEqualDbg::Bool = false;
function PersistenceLandscape::operator == ( const PersistenceLandscape& rhs  )const
    if ( this->land.size() != rhs.land.size() )
        if (operatorEqualDbg)cerr << "1\n";
        return false;
    end
    for (  level = 0 ; level != this->land.size() ; ++level )
        if ( this->land[level].size() != rhs.land[level].size() )
            if (operatorEqualDbg)cerr << "this->land[level].size() : " << this->land[level].size() <<  "\n";
            if (operatorEqualDbg)cerr << "rhs.land[level].size() : " << rhs.land[level].size() <<  "\n";
            if (operatorEqualDbg)cerr << "2\n";
            return false;
        end
        for (  i = 0 ; i != this->land[level].size() ; ++i )
            if ( this->land[level][i] != rhs.land[level][i] )
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
    if ( this->land.size() < lambda )return 0;
    double maximum = INT_MIN;
    for (  i = 0 ; i != this->land[lambda].size() ; ++i )
        if ( this->land[lambda][i].second > maximum )
            maximum = this->land[lambda][i].second
        end
    end
    return maximum;
end
# this function compute n-th moment of lambda_level
bool computeNthMomentDbg = false;
function PersistenceLandscape::computeNthMoment( unsigned n , double center , unsigned level )const
    if ( n < 1 )
        cerr << "Cannot compute n-th moment for  n = " << n << ". The program will now terminate \n";
        throw("Cannot compute n-th moment. The program will now terminate \n");
    end
    double result = 0;
    if ( this->land.size() > level )
        for (  i = 2 ; i != this->land[level].size()-1 ; ++i )
            if ( this->land[level][i].first - this->land[level][i-1].first == 0 )
                continue
            end
            # between this->land[level][i] and this->land[level][i-1] the lambda_level is of the form ax+b. First we need to find a and b.
            double a = (this->land[level][i].second - this->land[level][i-1].second)/(this->land[level][i].first - this->land[level][i-1].first);
            double b = this->land[level][i-1].second - a*this->land[level][i-1].first;
            double x1 = this->land[level][i-1].first;
            double x2 = this->land[level][i].first;
            # double first = b*(pow((x2-center),(double)(n+1))/(n+1)-pow((x1-center),(double)(n+1))/(n+1));
            # double second = a/(n+1)*((x2*pow((x2-center),(double)(n+1))) - (x1*pow((x1-center),(double)(n+1))) )
            #               +
            #               a/(n+1)*( pow((x2-center),(double)(n+2))/(n+2) - pow((x1-center),(double)(n+2))/(n+2) );
            # result += first;
            # result += second;
            double first = a/(n+2)*( pow( (x2-center) , (double)(n+2) ) - pow( (x1-center) , (double)(n+2) ) );
            double second = center/(n+1)*( pow( (x2-center) , (double)(n+1) ) - pow( (x1-center) , (double)(n+1) ) );
            double third = b/(n+1)*( pow( (x2-center) , (double)(n+1) ) - pow( (x1-center) , (double)(n+1) ) );
            if ( computeNthMomentDbg )
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
function PersistenceLandscape::testLandscape( const PersistenceBarcodes& b )
    for (  level = 0 ; level != this->land.size() ; ++level )
        for (  i = 1 ; i != this->land[level].size()-1 ; ++i )
            if ( this->land[level][i].second < epsi )
                continue
            end
            # check if over this->land[level][i].first-this->land[level][i].second , this->land[level][i].first+this->land[level][i].second] there are level barcodes.
            unsigned nrOfOverlapping = 0;
            for (  nr = 0 ; nr != b.barcodes.size() ; ++nr )
                if ( ( b.barcodes[nr].first-epsi <= this->land[level][i].first-this->land[level][i].second )
                      &&
                      ( b.barcodes[nr].second+epsi >= this->land[level][i].first+this->land[level][i].second )
                   )
                    ++nrOfOverlapping;
                end
            end
            if ( nrOfOverlapping != level+1 )
                cout << "We have a problem : \n";
                cout << "this->land[level][i].first : " << this->land[level][i].first << "\n";
                cout << "this->land[level][i].second : " << this->land[level][i].second << "\n";
                cout << "[" << this->land[level][i].first-this->land[level][i].second << "," << this->land[level][i].first+this->land[level][i].second << "] \n";
                cout << "level : " << level << " , nrOfOverlapping: " << nrOfOverlapping << endl;
                getchar();
                for (  nr = 0 ; nr != b.barcodes.size() ; ++nr )
                    if ( ( b.barcodes[nr].first <= this->land[level][i].first-this->land[level][i].second )
                          &&
                          ( b.barcodes[nr].second >= this->land[level][i].first+this->land[level][i].second )
                       )
                        cout << "(" << b.barcodes[nr].first << "," << b.barcodes[nr].second << ")\n";
                    end
                    /*
                    cerr << "( b.barcodes[nr].first-epsi <= this->land[level][i].first-this->land[level][i].second ) : "<< ( b.barcodes[nr].first-epsi <= this->land[level][i].first-this->land[level][i].second ) << endl;
                    cerr << "( b.barcodes[nr].second+epsi >= this->land[level][i].first+this->land[level][i].second ) : " << ( b.barcodes[nr].second+epsi >= this->land[level][i].first+this->land[level][i].second ) << endl;
                    cerr << "( this->land[level][i].first-this->land[level][i].second ) " << ( this->land[level][i].first-this->land[level][i].second )  << endl;
                    cout << setprecision(20) << "We want : [" << this->land[level][i].first-this->land[level][i].second << "," << this->land[level][i].first+this->land[level][i].second << "] \n";
                    cout << "(" << b.barcodes[nr].first << "," << b.barcodes[nr].second << ")\n";
                    getchar();
                    */
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
function PersistenceLandscape::computeLandscapeOnDiscreteSetOfPoints( PersistenceBarcodes& b , double dx )
     pair miMa = b.minMax();
     double bmin = miMa.first;
     double bmax = miMa.second;
     if(computeLandscapeOnDiscreteSetOfPointsDBG)cerr << "bmin: " << bmin << " , bmax :" << bmax << "\n";end
    # if(computeLandscapeOnDiscreteSetOfPointsDBG)end
     vector< pair<double,std::vector<double> > > result( (bmax-bmin)/(dx/2) + 2 );
     double x = bmin;
     int i = 0;
     while ( x <= bmax )
         vector<double> v;
         result[i] = make_pair( x , v );
         x += dx/2.0;
         ++i;
     end
     if(computeLandscapeOnDiscreteSetOfPointsDBG)cerr << "Vector initally filled in \n";end
     for (  i = 0 ; i != b.barcodes.size() ; ++i )
         # adding barcode b.barcodes[i] to out mesh:
         double beginBar = b.barcodes[i].first;
         double endBar = b.barcodes[i].second;
          index = ceil((beginBar-bmin)/(dx/2));
         while ( result[index].first < beginBar )++index;
         while ( result[index].first < beginBar )--index;
         double height = 0;
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
     # cerr << "All barcodes has been added to the mesh \n";
     unsigned indexOfLastNonzeroLandscape = 0;
     i = 0;
     for ( double x = bmin ; x <= bmax ; x = x+(dx/2) )
         sort( result[i].second.begin() , result[i].second.end() , greater<double>() );
         if ( result[i].second.size() > indexOfLastNonzeroLandscape )indexOfLastNonzeroLandscape = result[i].second.size();
         ++i;
     end
     if ( computeLandscapeOnDiscreteSetOfPointsDBG )cout << "Now we fill in the suitable vecors in this landscape \n";end
     vector< vector< std::pair > > land(indexOfLastNonzeroLandscape);
     for ( unsigned dim = 0 ; dim != indexOfLastNonzeroLandscape ; ++dim )
         land[dim].push_back( make_pair( INT_MIN,0 ) );
     end
     i = 0;
     for ( double x = bmin ; x <= bmax ; x = x+(dx/2) )
         for (  nr = 0 ; nr != result[i].second.size() ; ++nr )
              land[nr].push_back(make_pair( result[i].first , result[i].second[nr] ));
         end
         ++i;
     end
     for ( unsigned dim = 0 ; dim != indexOfLastNonzeroLandscape ; ++dim )
         land[dim].push_back( make_pair( INT_MAX,0 ) );
     end
     this->land.clear();
     this->land.swap(land);
     this->reduceAlignedPoints();
end
bool multiplyByIndicatorFunctionBDG = false;
PersistenceLandscape PersistenceLandscape::multiplyByIndicatorFunction( vector<pair > indicator )const
    PersistenceLandscape result;
    for (  dim = 0 ; dim != this->land.size() ; ++dim )
        if(multiplyByIndicatorFunctionBDG)cout << "dim : " << dim << "\n";end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( 0 , INT_MIN ) );
        if ( indicator.size() > dim )
            if (multiplyByIndicatorFunctionBDG)
                cout << "There is nonzero indicator in this dimension\n";
                cout << "[ " << indicator[dim].first << " , " << indicator[dim].second << "] \n";
            end
            for (  nr = 0 ; nr != this->land[dim].size() ; ++nr )
                if (multiplyByIndicatorFunctionBDG) cout << "this->land[dim][nr] : " << this->land[dim][nr].first << " , " << this->land[dim][nr].second << "\n";end
                if ( this->land[dim][nr].first < indicator[dim].first )
                    if (multiplyByIndicatorFunctionBDG)cout << "Below treshold\n";end
                    continue;
                end
                if ( this->land[dim][nr].first > indicator[dim].second )
                    if (multiplyByIndicatorFunctionBDG)cout << "Just pass above treshold \n";end
                    lambda_n.push_back( make_pair( indicator[dim].second , functionValue ( this->land[dim][nr-1] , this->land[dim][nr] , indicator[dim].second ) ) );
                    lambda_n.push_back( make_pair( indicator[dim].second , 0 ) );
                    break;
                end
                if ( (this->land[dim][nr].first >= indicator[dim].first) && (this->land[dim][nr-1].first <= indicator[dim].first) )
                    if (multiplyByIndicatorFunctionBDG)cout << "Entering the indicator \n";end
                    lambda_n.push_back( make_pair( indicator[dim].first , 0 ) );
                    lambda_n.push_back( make_pair( indicator[dim].first , functionValue(this->land[dim][nr-1],this->land[dim][nr],indicator[dim].first) ) );
                end
                 if (multiplyByIndicatorFunctionBDG)cout << "We are here\n";end
                lambda_n.push_back( make_pair( this->land[dim][nr].first , this->land[dim][nr].second ) );
            end
        end
        lambda_n.push_back( make_pair( 0 , INT_MIN ) );
        if ( lambda_n.size() > 2 )
            result.land.push_back( lambda_n );
        end
    end
    return result;
end
function PersistenceLandscape::printToFiles( const char* filename , unsigned from , unsigned to )const
    if ( from > to )throw("Error printToFiles printToFile( char* filename , unsigned from , unsigned to ). 'from' cannot be greater than 'to'.");
    # if ( to > this->land.size() )throw("Error in printToFiles( char* filename , unsigned from , unsigned to ). 'to' is out of range.");
    if ( to > this->land.size() )to = this->land.size();end
    ofstream write;
    for (  dim = from ; dim != to ; ++dim )
        ostringstream name;
        name << filename << "_" << dim << ".dat";
        string fName = name.str();
        const char* FName = fName.c_str();
        write.open(FName);
        write << "#lambda_" << dim << endl;
        for (  i = 1 ; i != this->land[dim].size()-1 ; ++i )
            write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
        end
        write.close();
    end
end
function PersistenceLandscape::printToFiles( const char* filename, int numberOfElementsLater ,  ... )const
  va_list arguments;
  va_start ( arguments, numberOfElementsLater );
  ofstream write;
  for ( int x = 0; x < numberOfElementsLater; x++ )
       unsigned dim = va_arg ( arguments, unsigned );
       if ( dim > this->land.size() )throw("In function generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... ), one of the number provided is greater than number of nonzero landscapes");
        ostringstream name;
       name << filename << "_" << dim << ".dat";
       string fName = name.str();
       const char* FName = fName.c_str();
       write.open(FName);
       write << "#lambda_" << dim << endl;
       for (  i = 1 ; i != this->land[dim].size()-1 ; ++i )
           write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
       end
       write.close();
  end
  va_end ( arguments );
end
function PersistenceLandscape::printToFiles( const char* filename )const
    this->printToFiles(filename , (unsigned)0 , (unsigned)this->land.size() );
end
function PersistenceLandscape::printToFile( const char* filename , unsigned from , unsigned to )const
    if ( from > to )throw("Error in printToFile( char* filename , unsigned from , unsigned to ). 'from' cannot be greater than 'to'.");
    if ( to > this->land.size() )throw("Error in printToFile( char* filename , unsigned from , unsigned to ). 'to' is out of range.");
    ofstream write;
    write.open(filename);
    write << this->dimension << endl;
    for (  dim = from ; dim != to ; ++dim )
        write << "#lambda_" << dim << endl;
        for (  i = 1 ; i != this->land[dim].size()-1 ; ++i )
            write << this->land[dim][i].first << "  " << this->land[dim][i].second << endl;
        end
    end
    write.close();
end
function PersistenceLandscape::printToFile( const char* filename  )const
    this->printToFile(filename,0,this->land.size());
end
function PersistenceLandscape::generateGnuplotCommandToPlot( const char* filename, unsigned from , unsigned to )const
    if ( from > to )throw("Error in printToFile( char* filename , unsigned from , unsigned to ). 'from' cannot be greater than 'to'.");
    # if ( to > this->land.size() )throw("Error in printToFile( char* filename , unsigned from , unsigned to ). 'to' is out of range.");
    if ( to > this->land.size() )to = this->land.size();end
    ostringstream result;
    result << "plot ";
    for (  dim = from ; dim != to ; ++dim )
        # result << "\"" << filename << "_" << dim <<".dat\" w lp".dat\" w lp title \"L" << dim <<"\"";
        result << "\"" << filename << "_" << dim <<".dat\" with lines notitle ";
        if ( dim != to-1 )
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
function PersistenceLandscape::generateGnuplotCommandToPlot(const char* filename,int numberOfElementsLater,  ... )const
   va_list arguments;
   va_start ( arguments, numberOfElementsLater );
   ostringstream result;
   result << "plot ";
   for ( int x = 0; x < numberOfElementsLater; x++ )
        unsigned dim = va_arg ( arguments, unsigned );
        if ( dim > this->land.size() )throw("In function generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... ), one of the number provided is greater than number of nonzero landscapes");
        result << "\"" << filename << "_" << dim <<".dat\" w lp title \"L" << dim <<"\"";
        if ( x != numberOfElementsLater-1 )
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
function PersistenceLandscape::generateGnuplotCommandToPlot( const char* filename )const
    this->generateGnuplotCommandToPlot( filename , (unsigned)0 , (unsigned)this->land.size() );
end
PersistenceLandscape::PersistenceLandscape(const PersistenceLandscape& oryginal)
    # cerr << "Running copy constructor \n";
    this->dimension = oryginal.dimension;
    vector< vector< std::pair > > land( oryginal.land.size() );
    for (  i = 0 ; i != oryginal.land.size() ; ++i )
        land[i].insert( land[i].end() , oryginal.land[i].begin() , oryginal.land[i].end() );
    end
    # CHANGE
    # this->land = land;
    this->land.swap(land);
end
PersistenceLandscape PersistenceLandscape::operator=( const PersistenceLandscape& oryginal )
    this->dimension = oryginal.dimension;
    vector< vector< std::pair > > land( oryginal.land.size() );
    for (  i = 0 ; i != oryginal.land.size() ; ++i )
        land[i].insert( land[i].end() , oryginal.land[i].begin() , oryginal.land[i].end() );
    end
    # CHANGE
    # this->land = land;
    this->land.swap(land);
    return *this;
end
/*
bool dbg = false;
PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p )
    this->dimension = p.dimensionOfBarcode;
    vector< pair > characteristicPoints(p.barcodes.size());
    for (  i = 0 ; i != p.barcodes.size() ; ++i )
        characteristicPoints[i] = make_pair((p.barcodes[i].first+p.barcodes[i].second)/2.0 , (p.barcodes[i].second - p.barcodes[i].first)/2.0) ;
    end
    sort( characteristicPoints.begin() , characteristicPoints.end() , comparePoints );
    while ( !characteristicPoints.empty() )
        if ( dbg )
            cerr << "Characteristic points at the very beginning :\n";
            for (  aa = 0 ; aa != characteristicPoints.size() ; ++aa )
                cerr << "(" << characteristicPoints[aa] << ") , ";
            end
            cerr << "\n";
        end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( INT_MIN , 0 ) );
        lambda_n.push_back( make_pair(birth(characteristicPoints[0]),0) );
        lambda_n.push_back( characteristicPoints[0] );
        if ( dbg )
            cout << "Adding : " << make_pair( INT_MIN , 0 ) << " to lambda_n \n";
            cout << "Adding : " << make_pair(birth(characteristicPoints[0]),0) << " to lambda_n \n";
            cout << "Adding : " << characteristicPoints[0] << " to lambda_n \n";
        end
         q = 1;
        list< pair > newCharacteristicPoints;
        list< pair >::iterator pos = newCharacteristicPoints.end();
        while ( q <= characteristicPoints.size()-1 )
             p = 0;
            if ( dbg )cout << "characteristicPoints[q] : " << characteristicPoints[q] << "\n";cin.ignore();end
            while ( ( q<characteristicPoints.size() ) && ( death(characteristicPoints[q]) <= death( lambda_n[lambda_n.size()-1] ) ) )
                if ( dbg )cout << "Rewriting new characteristic point : " << characteristicPoints[q] << "\n";end
                newCharacteristicPoints.push_back( characteristicPoints[q] );
                ++q;
            end
            if ( q < characteristicPoints.size() )
                if ( birth(characteristicPoints[q]) <= death(lambda_n[lambda_n.size()-1]) )
                    pair pair =   make_pair(
                                                       0.5*(birth(characteristicPoints[q])+death(lambda_n[lambda_n.size()-1]))
                                                       ,
                                                       0.5*((death(lambda_n[lambda_n.size()-1]) - birth(characteristicPoints[q])) )
                                                      );
                    if ( dbg )cout << "Adding : " << pair << " to lambda_n\n";end
                    p = q+1;
                    if ( dbg )
                        cerr << "Jestesmy zaraz przed petla \n";cin.ignore();
                        cerr << "(p < characteristicPoints.size() ) : " << (p < characteristicPoints.size() ) << "\n";
                        cerr << "!comparePoints(characteristicPoints[p],pair) : " << comparePoints(characteristicPoints[p],pair) << "\n";
                    end
                    while ( (p < characteristicPoints.size() ) && comparePoints(characteristicPoints[p],pair) )
                        if ( dbg )cout << "Adding new characteristic point in while loop: " << characteristicPoints[p] << "\n";
                        newCharacteristicPoints.push_back( characteristicPoints[p] );
                        ++p;
                    end
                    if ( dbg )cout << "Adding new characteristic point: " << pair << "\n";
                    newCharacteristicPoints.push_back( pair );
                    lambda_n.push_back( pair );
                end
                else
                    lambda_n.push_back( make_pair( death(lambda_n[lambda_n.size()-1]) , 0 ) );
                    lambda_n.push_back( make_pair( birth(characteristicPoints[q]) , 0 ) );
                    p = 1;
                    if ( dbg )cout << "Aadding : (" << death(lambda_n[lambda_n.size()-1]) << ", 0 ) to lambda_n \n";
                    if ( dbg )cout << "Aadding : (" << birth(characteristicPoints[q]) << ", 0 ) to lambda_n \n";
                end
                 if ( dbg )cout << "Adding at the end of while : (" << characteristicPoints[q] << ") to lambda_n \n";
                 lambda_n.push_back( characteristicPoints[q] );
                 q += p;
                 if ( dbg )cin.ignore();
            end
        end
        characteristicPoints.clear();
        characteristicPoints.insert( characteristicPoints.end() , newCharacteristicPoints.begin() , newCharacteristicPoints.end() );
        if ( dbg )
            cerr << "newCharacteristicPoints : \n";
            for ( vector< pair >::iterator it = characteristicPoints.begin() ; it != characteristicPoints.end() ; ++it )
                cerr << "(" << *it << ")  ";
            end
            cerr << "\n\n";
        end
        lambda_n.push_back( make_pair(death(lambda_n[lambda_n.size()-1]),0) );
        if ( dbg )cout << "Adding : " << make_pair(death(lambda_n[lambda_n.size()-1]),0) << " to lambda_n \n";
        lambda_n.push_back( make_pair( INT_MAX , 0 ) );
        if ( dbg )
            cout << "Adding : " << make_pair( INT_MAX , 0 ) << " to lambda_n \n";
            cout << "That is a new iteration of while \n\n\n\n";
            cin.ignore();
        end
        lambda_n.erase(unique(lambda_n.begin(), lambda_n.end()), lambda_n.end());
        this->land.push_back( lambda_n );
    end
end
*/
# TODO -- removewhen the problem is respved
function check( unsigned i , vector< pair > v )
    if ( (i < 0) || (i >= v.size()) )
        cout << "you want to get to index : " << i << " while there are only  : " << v.size() << " indices \n";
        cin.ignore();
        return true;
    end
    return false;
end
# if ( check( , ) )cerr << "OUT OF MEMORY \n";end
PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p )
    bool dbg = false;
    if ( dbg )cerr << "PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p )" << endl;end
    if ( !useGridInComputations )
        if ( dbg )cerr << "PL version" << endl;getchar();end
        # this is a general algorithm to construct persistence landscapes.
        this->dimension = p.dimensionOfBarcode;
        vector< pair > bars;
        bars.insert( bars.begin() , p.barcodes.begin() , p.barcodes.end() );
        sort( bars.begin() , bars.end() , comparePoints2 );
        if (dbg)
            cerr << "Bars : \n";
            for (  i = 0 ; i != bars.size() ; ++i )
                cerr << bars[i] << "\n";
            end
            getchar();
        end
        vector< pair > characteristicPoints(p.barcodes.size());
        for (  i = 0 ; i != bars.size() ; ++i )
            characteristicPoints[i] = make_pair((bars[i].first+bars[i].second)/2.0 , (bars[i].second - bars[i].first)/2.0);
        end
        vector< vector< std::pair > > persistenceLandscape;
        while ( !characteristicPoints.empty() )
            if(dbg)
                for (  i = 0 ; i != characteristicPoints.size() ; ++i )
                    cout << "("  << characteristicPoints[i] << ")\n";
                end
                cin.ignore();
            end
            vector< pair > lambda_n;
            lambda_n.push_back( make_pair( INT_MIN , 0 ) );
            lambda_n.push_back( make_pair(birth(characteristicPoints[0]),0) );
            lambda_n.push_back( characteristicPoints[0] );
            if (dbg)
                cerr << "1 Adding to lambda_n : (" << make_pair( INT_MIN , 0 ) << ") , (" << std::make_pair(birth(characteristicPoints[0]),0) << ") , (" << characteristicPoints[0] << ") \n";
            end
            int i = 1;
            vector< pair >  newCharacteristicPoints;
            while ( i < characteristicPoints.size() )
                 p = 1;
                if ( (birth(characteristicPoints[i]) >= birth(lambda_n[lambda_n.size()-1])) && (death(characteristicPoints[i]) > death(lambda_n[lambda_n.size()-1])) )
                    if ( birth(characteristicPoints[i]) < death(lambda_n[lambda_n.size()-1]) )
                        pair point = make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 );
                        lambda_n.push_back( point );
                        if (dbg)
                            cerr << "2 Adding to lambda_n : (" << point << ")\n";
                        end
                        if ( dbg )
                            cerr << "comparePoints(point,characteristicPoints[i+p]) : " << comparePoints(point,characteristicPoints[i+p]) << "\n";
                            cerr << "characteristicPoints[i+p] : " << characteristicPoints[i+p] << "\n";
                            cerr << "point : " << point << "\n";
                            getchar();
                        end
                        /*
                        while ( (i+p < characteristicPoints.size() ) && (comparePoints(point,characteristicPoints[i+p])) && ( death(point) >= death(characteristicPoints[i+p]) ) )
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
                        */
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
            this->land.push_back( lambda_n );
        end
    end
    else
        if ( dbg )cerr << "Constructing persistence landscape based on a grid \n";getchar();end
        # in this case useGridInComputations is true, therefore we will build a landscape on a grid.
        extern double gridDiameter;
        this->dimension = p.dimensionOfBarcode;
        pair minMax = p.minMax();
         numberOfBins = 2*((minMax.second - minMax.first)/gridDiameter)+1;
        # first element of a pair pair< double , vector<double> > is a x-value. Second element is a vector of values of landscapes.
        vector< pair< double , std::vector<double> > > criticalValuesOnPointsOfGrid(numberOfBins);
        # filling up the bins:
        # Now, the idea is to iterate on this->land[lambda-1] and use only points over there. The problem is at the very beginning, when there is nothing
        # in this->land. That is why over here, we make a fate this->land[0]. It will be later deteted before moving on.
        vector< pair > aa;
        aa.push_back( make_pair( INT_MIN , 0 ) );
        double x = minMax.first;
        for (  i = 0 ; i != numberOfBins ; ++i )
            vector<double> v;
            pair< double , vector<double> > p = std::make_pair( x , v );
            aa.push_back( make_pair( x , 0 ) );
            criticalValuesOnPointsOfGrid[i] = p;
            if ( dbg )cerr << "x : " << x << endl;end
            x += 0.5*gridDiameter;
        end
        aa.push_back( make_pair( INT_MAX , 0 ) );
        if ( dbg )cerr << "Grid has been created. Now, begin to add intervals \n";end
        # for every peristent interval
        for (  intervalNo = 0 ; intervalNo != p.size() ; ++intervalNo )
             beginn = ()(2*( p.barcodes[intervalNo].first-minMax.first )/( gridDiameter ))+1;
            if ( dbg )cerr << "We are considering interval : [" << p.barcodes[intervalNo].first << "," << p.barcodes[intervalNo].second << "]. It will begin in  : " << beginn << " in the grid \n";end
            while ( criticalValuesOnPointsOfGrid[beginn].first < p.barcodes[intervalNo].second )
                if ( dbg )
                    cerr << "Adding a value : (" << criticalValuesOnPointsOfGrid[beginn].first << "," << min( fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ) << ") " << endl;
                end
                criticalValuesOnPointsOfGrid[beginn].second.push_back(min( fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].first) ,fabs(criticalValuesOnPointsOfGrid[beginn].first-p.barcodes[intervalNo].second) ) );
                ++beginn;
            end
        end
        # now, the basic structure is created. We need to translate it to a persistence landscape data structure.
        # To do so, first we need to sort all the vectors in criticalValuesOnPointsOfGrid[i].second
         maxNonzeroLambda = 0;
        for (  i = 0 ; i != criticalValuesOnPointsOfGrid.size() ; ++i )
            sort( criticalValuesOnPointsOfGrid[i].second.begin() , criticalValuesOnPointsOfGrid[i].second.end() , greater<int>() );
            if ( criticalValuesOnPointsOfGrid[i].second.size() > maxNonzeroLambda )maxNonzeroLambda = criticalValuesOnPointsOfGrid[i].second.size();end
        end
        if ( dbg )
            cerr << "After sorting \n";
            for (  i = 0 ; i != criticalValuesOnPointsOfGrid.size() ; ++i )
                cerr << "x : " << criticalValuesOnPointsOfGrid[i].first << " : ";
                for (  j = 0 ; j != criticalValuesOnPointsOfGrid[i].second.size() ; ++j )
                    cerr << criticalValuesOnPointsOfGrid[i].second[j] << " ";
                end
                cerr << "\n\n";
            end
        end
        this->land.push_back(aa);
        for (  lambda = 0 ; lambda != maxNonzeroLambda ; ++lambda )
            if ( dbg )cerr << "Constructing lambda_" << lambda << endl;end
            vector< pair >  nextLambbda;
            nextLambbda.push_back( make_pair(INT_MIN,0) );
            # for every element in the domain for which the previous landscape is nonzero.
            bool wasPrevoiusStepZero = true;
             nr = 1;
            while (  nr < this->land[ this->land.size()-1 ].size()-1 )
                if (dbg) cerr << "nr : " << nr << endl;
                 address = ()(2*( this->land[ this->land.size()-1 ][nr].first-minMax.first )/( gridDiameter ));
                if ( dbg )
                    cerr << "We are considering the element x : " << this->land[ this->land.size()-1 ][nr].first << ". Its position in the structure is : " << address << endl;
                end
                if (  criticalValuesOnPointsOfGrid[address].second.size() <= lambda  )
                    if (!wasPrevoiusStepZero)
                        wasPrevoiusStepZero = true;
                        if ( dbg )cerr << "AAAdding : (" << criticalValuesOnPointsOfGrid[address].first << " , " << 0 << ") to lambda_" << lambda << endl;getchar();end
                        nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address].first , 0 ) );
                    end
                end
                else
                     if ( wasPrevoiusStepZero )
                         if ( dbg )cerr << "Adding : (" << criticalValuesOnPointsOfGrid[address-1].first << " , " << 0 << ") to lambda_" << lambda << endl;getchar();end
                         nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address-1].first , 0 ) );
                         wasPrevoiusStepZero = false;
                     end
                     if ( dbg )cerr << "AAdding : (" << criticalValuesOnPointsOfGrid[address].first << " , " << criticalValuesOnPointsOfGrid[address].second[lambda] << ") to lambda_" << lambda << endl;getchar();end
                     nextLambbda.push_back( make_pair( criticalValuesOnPointsOfGrid[address].first , criticalValuesOnPointsOfGrid[address].second[lambda] ) );
                end
                ++nr;
            end
            if ( dbg )cerr << "Done with : lambda_" << lambda << endl;getchar();getchar();getchar();end
            if ( lambda == 0 )
                # removing the first, fake, landscape
                this->land.clear();
            end
            nextLambbda.push_back( make_pair(INT_MAX,0) );
            nextLambbda.erase( unique( nextLambbda.begin(), nextLambbda.end() ), nextLambbda.end() );
            this->land.push_back( nextLambbda );
        end
    end
end
/*
        # and now it remains to fill in the structure of the peristence landscape:
        # We are using this extra structure for the following reason: in the naive algorithm we would have to iterate through the whole criticalValuesOnPointsOfGrid
        # as many times as there are nonzero lambda_n's. But we know that the support of lambda_n contains support of lambda_n+1end. So, when we already know that the
        # domain of lambda_n is very restricted, there is no need to look for lambda_n+1end outside of this domain. That is why we need those bounds for the support of the
        # previous landscape function.
        cerr << "HereAA \n";getchar();
        vector<double> placesWherePreviousLandscapeIsNonzero;
        for (  i = 0 ; i != criticalValuesOnPointsOfGrid.size() ; ++i )
            if ( (criticalValuesOnPointsOfGrid[i].second.size() ) && (criticalValuesOnPointsOfGrid[i].second[0] == 0.5) )
                if ( dbg )cerr << "Found a place, where lambda_0 became nonzero : " << i << endl;end
                placesWherePreviousLandscapeIsNonzero.push_back( i );
                # if at the next step it again became zero, we need to duplicate this point in the placesWherePreviousLandscapeIsNonzero vector.
                if ( criticalValuesOnPointsOfGrid[i+1].second.size() == 0 )
                    placesWherePreviousLandscapeIsNonzero.push_back( i );
                end
            end
        end
        cerr << "Here \n";getchar();
        # vector< vector< std::pair > > land;
        for (  level = 0 ; level != maxNonzeroLambda ; ++level )
            if ( dbg )
                cerr << "placesWherePreviousLandscapeIsNonzero.size() : " << placesWherePreviousLandscapeIsNonzero.size() << endl;
                cerr << "placesWherePreviousLandscapeIsNonzero : \n";
                for (  i = 0 ; i != placesWherePreviousLandscapeIsNonzero.size() ; ++i )
                    cerr << placesWherePreviousLandscapeIsNonzero[i] << " ";
                end
                cerr << endl;
                getchar();
            end
            cerr << "maxNonzeroLambda : " << maxNonzeroLambda << endl;# aaa
            vector<double> newPlacesWherePreviousLandscapeIsNonzero;
            if ( dbg )cerr << "Begin construction of lambda_" << level << endl;end
            vector< pair > lambdaLevel;
            lambdaLevel.push_back( make_pair(INT_MIN,0) );
            # construct lambda_level. We should do it in a smart way...
            for (  j = 0 ; j <= placesWherePreviousLandscapeIsNonzero.size()-1 ; j+=2 )
                if (dbg)cerr << "j : " << j << endl;
                 k = placesWherePreviousLandscapeIsNonzero[j];
                while ( k <= placesWherePreviousLandscapeIsNonzero[j+1] )
                    if (dbg)cerr << "k : " << k << endl;
                    if (dbg)cerr << "placesWherePreviousLandscapeIsNonzero[j+1] : " << placesWherePreviousLandscapeIsNonzero[j+1] << endl;
                    cerr << "criticalValuesOnPointsOfGrid[k].second.size() : " << criticalValuesOnPointsOfGrid[k].second.size() << endl;
                    bool wasCriticalValueAtZeroAdded = false;
                    if ( criticalValuesOnPointsOfGrid[k].second.size() > level )
                        if ( criticalValuesOnPointsOfGrid[k].second[level] == 0.5 )
                            # in this case we need to add a critical point at zero before or after this critical point.
                            if ( lambdaLevel.size() == 1 )
                                # this is the first point, we need to add zero critical point
                                lambdaLevel.push_back( make_pair( criticalValuesOnPointsOfGrid[k].first-gridDiameter/2 , 0 ) );
                                if ( dbg )cerr << "Adding : (" << criticalValuesOnPointsOfGrid[k].first-gridDiameter/2 << "," << 0<< ")" << endl;end
                                wasCriticalValueAtZeroAdded = true;
                            end
                            else
                                # we know that lambdaLevel.size() is always > 1.
                                if ( lambdaLevel[lambdaLevel.size()-1].second == 0 )
                                    # new connected component of the support just begins
                                    lambdaLevel.push_back( make_pair( criticalValuesOnPointsOfGrid[k].first-gridDiameter/2 , 0 ) );
                                    if ( dbg )cerr << "AAAdding : (" << criticalValuesOnPointsOfGrid[k].first-gridDiameter/2 << "," << 0<< ")" << endl;end
                                    wasCriticalValueAtZeroAdded = true;
                                end
                            end
                        end
                        lambdaLevel.push_back( make_pair( criticalValuesOnPointsOfGrid[k].first , criticalValuesOnPointsOfGrid[k].second[level] ) );
                        if ( dbg )cerr << "Level : " << level << " adding a critical point : (" << criticalValuesOnPointsOfGrid[k].first << "," <<criticalValuesOnPointsOfGrid[k].second[level] << ")\n";getchar();end
                        getchar();
                        if ( criticalValuesOnPointsOfGrid[k].second[level] == 0.5 )
                            # cerr << "newPlacesWherePreviousLandscapeIsNonzero.push_back(" << k << ") \n";
                            newPlacesWherePreviousLandscapeIsNonzero.push_back(k);
                            if ( wasCriticalValueAtZeroAdded )
                                # if the critical value (x,0) was not added before this point, it have to be added after it.
                                lambdaLevel.push_back( make_pair( criticalValuesOnPointsOfGrid[k].first+gridDiameter/2 , 0 ) );
                                if ( dbg )cerr << "Adding : (" << criticalValuesOnPointsOfGrid[k].first+gridDiameter/2 << "," << 0<< ")" << endl;end
                            end
                        end
                    end
                    ++k;
                end
            end
            placesWherePreviousLandscapeIsNonzero.swap( newPlacesWherePreviousLandscapeIsNonzero );
            if ( dbg )cerr << "Adding the closing point : (" << INT_MAX << " , " << 0 << ")" << endl;end
            lambdaLevel.push_back( make_pair(INT_MAX,0) );
            this->land.push_back( lambdaLevel );
        end
*/
/*
bool dbg = false;
PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p )
    if (dbg)
        cerr << "PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p ) \n";
        cerr << "p.barcodes.size() : " << p.barcodes.size() << "\n";
    end
    this->dimension = p.dimensionOfBarcode;
    vector< pair > characteristicPoints(p.barcodes.size());
    for (  i = 0 ; i != p.barcodes.size() ; ++i )
        characteristicPoints[i] = make_pair((p.barcodes[i].first+p.barcodes[i].second)/2.0 , (p.barcodes[i].second - p.barcodes[i].first)/2.0) ;
    end
    if (dbg)cerr << "Soering\n";
    sort( characteristicPoints.begin() , characteristicPoints.end() , comparePoints );
    vector< vector< std::pair > > persistenceLandscape;
    while ( !characteristicPoints.empty() )
        if (dbg)cerr << "Next iteration of the while loop \n";
        if (dbg)
            cerr << "characteristicPoints.size() : " << characteristicPoints.size() << "\n";
            cerr << "Characteristic points : \n";
            for (  i = 0 ; i != characteristicPoints.size() ; ++i )
                cout << characteristicPoints[i].first << "," << characteristicPoints[i].second << "\n";
            end
            # cin.ignore();
        end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( INT_MIN , 0 ) );
        lambda_n.push_back( make_pair(birth(characteristicPoints[0]),0) );
        lambda_n.push_back( characteristicPoints[0] );
        if (dbg)cerr << "Adding to lambda_n : " << make_pair( INT_MIN , 0 ) << "\n";
        if (dbg)cerr << "Adding to lambda_n : " << make_pair(birth(characteristicPoints[0]),0) << "\n";
        if (dbg)cerr << "Adding to lambda_n : " << characteristicPoints[0] << "\n";
        int i = 1;
        if (dbg)cerr << "First characteristic point: " << characteristicPoints[0].first << " , " << characteristicPoints[0].second << endl;
        list< pair >  newCharacteristicPoints;
        while ( i != characteristicPoints.size() )
             p = 1;
            if (dbg)cerr << "i : " << i << endl;
            # (death(characteristicPoints[i]) >= death(lambda_n[lambda_n.size()-1]))
            if ( (birth(characteristicPoints[i]) > birth(lambda_n[lambda_n.size()-1])) && (death(characteristicPoints[i]) > death(lambda_n[lambda_n.size()-1])) )
                if (dbg)cerr << "I have found the next characteristic point : " << characteristicPoints[i].first << " , " << characteristicPoints[i].second << endl;
                if ( birth(characteristicPoints[i]) < death(lambda_n[lambda_n.size()-1]) )
                    if (dbg)cerr << "Creation of a new characteristic point  :" << (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 << " , " << (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 << endl;
                    pair point = make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 );
                    if ( dbg )cout << "lambda_n ass : " << make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 ) << "\n";
                    lambda_n.push_back( make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 ) );
                    if ( dbg )
                        cerr << "Jestesmy zaraz przed petla \n";# cin.ignore();
                        cerr << "(p < characteristicPoints.size() ) : " << (p < characteristicPoints.size() ) << "\n";
                        cerr << "!comparePoints(characteristicPoints[p],point) : " << comparePoints(characteristicPoints[p],point) << "\n";
                    end
                    while ( (i+p < characteristicPoints.size() ) && comparePoints(characteristicPoints[i+p],point) )
                        if ( dbg )cout << "Adding new characteristic point in while loop: " << characteristicPoints[i+p] << "\n";
                        newCharacteristicPoints.push_back( characteristicPoints[i+p] );
                        ++p;
                    end
                    newCharacteristicPoints.push_back( point );
                end
                else
                    lambda_n.push_back( make_pair( death(lambda_n[lambda_n.size()-1]) , 0 ) );
                    lambda_n.push_back( make_pair( birth(characteristicPoints[i]) , 0 ) );
                    if (dbg)cout << "lamnda_n adding : " << make_pair( death(lambda_n[lambda_n.size()-1]) , 0 ) << "\n";
                    if (dbg)cout << "lamnda_n adding : " << make_pair( birth(characteristicPoints[i]) , 0 ) << "\n";
                end
                if (dbg)cout << "lamnda_n adding : " << characteristicPoints[i] << "\n";
                lambda_n.push_back( characteristicPoints[i] );
            end
            else
                if (dbg)
                        cerr << "Writing new point as newCharacteristicPoints : " << characteristicPoints[i].first << " , " << characteristicPoints[i].second << endl;# std::cin.ignore();
                end
                newCharacteristicPoints.push_back( characteristicPoints[i] );
            end
            i = i+p;
        end
        lambda_n.push_back( make_pair(death(lambda_n[lambda_n.size()-1]),0) );
        lambda_n.push_back( make_pair( INT_MAX , 0 ) );
        # cerr << "Lamnda_" << this->land.size() << " has been created\n";
        if ( dbg )
            cerr << "lambda_" << persistenceLandscape.size() << ": \n";
            for (  aa = 0  ; aa != lambda_n.size() ; ++aa )
                cerr << lambda_n[aa].first << " , " << lambda_n[aa].second << endl;
            end
        end
        # CHANGE
        # characteristicPoints = newCharacteristicPoints;
        characteristicPoints.clear();
        characteristicPoints.insert( characteristicPoints.begin() , newCharacteristicPoints.begin() , newCharacteristicPoints.end() );
        lambda_n.erase(unique(lambda_n.begin(), lambda_n.end()), lambda_n.end());
        this->land.push_back( lambda_n );
    end
end
*/
/*
PersistenceLandscape::PersistenceLandscape( const PersistenceBarcodes& p )
    this->dimension = p.dimensionOfBarcode;
    vector< pair > characteristicPoints(p.barcodes.size());
    for (  i = 0 ; i != p.barcodes.size() ; ++i )
        characteristicPoints[i] = make_pair((p.barcodes[i].first+p.barcodes[i].second)/2.0 , (p.barcodes[i].second - p.barcodes[i].first)/2.0) ;
    end
    sort( characteristicPoints.begin() , characteristicPoints.end() , comparePoints );
    vector< vector< std::pair > > persistenceLandscape;
    while ( !characteristicPoints.empty() )
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( INT_MIN , 0 ) );
        lambda_n.push_back( make_pair(birth(characteristicPoints[0]),0) );
        lambda_n.push_back( characteristicPoints[0] );
        int i = 1;
        vector< pair >  newCharacteristicPoints;
        while ( i != characteristicPoints.size() )
            # (death(characteristicPoints[i]) >= death(lambda_n[lambda_n.size()-1]))
            if ( (birth(characteristicPoints[i]) > birth(lambda_n[lambda_n.size()-1])) && (death(characteristicPoints[i]) >= death(lambda_n[lambda_n.size()-1])) )
                if ( birth(characteristicPoints[i]) < death(lambda_n[lambda_n.size()-1]) )
                    newCharacteristicPoints.push_back( make_pair(
                                                                      (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 ,
                                                                      (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2
                                                                      )
                                                      );
                    lambda_n.push_back( make_pair( (birth(characteristicPoints[i])+death(lambda_n[lambda_n.size()-1]))/2 , (death(lambda_n[lambda_n.size()-1])-birth(characteristicPoints[i]))/2 ) );
                end
                lambda_n.push_back( characteristicPoints[i] );
            end
                newCharacteristicPoints.push_back( characteristicPoints[i] );
            end
            ++i;
        end
        lambda_n.push_back( make_pair(death(lambda_n[lambda_n.size()-1]),0) );
        lambda_n.push_back( make_pair( INT_MAX , 0 ) );
        characteristicPoints = newCharacteristicPoints;
        lambda_n.erase(unique(lambda_n.begin(), lambda_n.end()), lambda_n.end());
        this->land.push_back( lambda_n );
    end
end*/
function PersistenceLandscape::computeIntegralOfLandscape()const
    double result = 0;
    for (  i = 0 ; i != this->land.size() ; ++i )
        for (  nr = 2 ; nr != this->land[i].size()-1 ; ++nr )
            # it suffices to compute every planar integral and then sum them ap for each lambda_n
            result += 0.5*( this->land[i][nr].first - this->land[i][nr-1].first )*(this->land[i][nr].second + this->land[i][nr-1].second);
        end
    end
    return result;
end
pair computeParametersOfALine( pair p1 , std::pair p2 )
    # p1.second = a*p1.first + b => b = p1.second - a*p1.first
    # p2.second = a*p2.first + b = a*p2.first + p1.second - a*p1.first = p1.second + a*( p2.first - p1.first )
    # =>
    # (p2.second-p1.second)/( p2.first - p1.first )  = a
    # b = p1.second - a*p1.first.
    double a = (p2.second-p1.second)/( p2.first - p1.first );
    double b = p1.second - a*p1.first;
    return make_pair(a,b);
end
bool computeIntegralOfLandscapeDbg = false;
function PersistenceLandscape::computeIntegralOfLandscape( double p )const
    double result = 0;
    for (  i = 0 ; i != this->land.size() ; ++i )
        for (  nr = 2 ; nr != this->land[i].size()-1 ; ++nr )
            if (computeIntegralOfLandscapeDbg)cout << "nr : " << nr << "\n";
            # In this interval, the landscape has a form f(x) = ax+b. We want to compute integral of (ax+b)^p = 1/a * (ax+b)^p+1end/(p+1)
            pair coef = computeParametersOfALine( this->land[i][nr] , this->land[i][nr-1] );
            double a = coef.first;
            double b = coef.second;
            if (computeIntegralOfLandscapeDbg)cout << "(" << this->land[i][nr].first << "," << this->land[i][nr].second << ") , " << this->land[i][nr-1].first << "," << this->land[i][nr].second << ")" << endl;
            if ( this->land[i][nr].first == this->land[i][nr-1].first )continue;
            if ( a != 0 )
                result += 1/(a*(p+1)) * ( pow((a*this->land[i][nr].first+b),p+1) - pow((a*this->land[i][nr-1].first+b),p+1));
            end
            else
                result += ( this->land[i][nr].first - this->land[i][nr-1].first )*( pow(this->land[i][nr].second,p) );
            end
            if ( computeIntegralOfLandscapeDbg )
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
function PersistenceLandscape::computeIntegralOfLandscapeMultipliedByIndicatorFunction( vector<pair > indicator , double p )const# this function compute integral of p-th power of landscape.
    PersistenceLandscape l = this->multiplyByIndicatorFunction(indicator);
    return l.computeIntegralOfLandscape(p);
end
# This is a standard function which pairs maxima and minima which are not more than epsilon apart.
# This algorithm do not reduce all of them, just make one passage through data. In order to reduce all of them
# use the function reduceAllPairsOfLowPersistenceMaximaMinima( double epsilon )
# WARNING! THIS PROCEDURE MODIFIES THE LANDSCAPE!!!
unsigned PersistenceLandscape::removePairsOfLocalMaximumMinimumOfEpsPersistence(double epsilon)
    unsigned numberOfReducedPairs = 0;
    for (  dim = 0  ; dim != this->land.size() ; ++dim )
        if ( 2 > this->land[dim].size()-3 )continue; #  to make sure that the loop in below is not infinite.
        for (  nr = 2 ; nr != this->land[dim].size()-3 ; ++nr )
            if ( (fabs(this->land[dim][nr].second - this->land[dim][nr+1].second) < epsilon) && (this->land[dim][nr].second != this->land[dim][nr+1].second) )
                # right now we modify only the lalues of a points. That means that angles of lines in the landscape changes a bit. This is the easiest computational
                # way of doing this. But I am not sure if this is the best way of doing such a reduction of nonessential critical points. Think about this!
                if ( this->land[dim][nr].second < this->land[dim][nr+1].second )
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
function PersistenceLandscape::reduceAllPairsOfLowPersistenceMaximaMinima( double epsilon )
    unsigned numberOfReducedPoints = 1;
    while ( numberOfReducedPoints )
        numberOfReducedPoints = this->removePairsOfLocalMaximumMinimumOfEpsPersistence( epsilon );
    end
end
# It may happened that some landscape points obtained as a aresult of an algorithm lies in a line. In this case, the following procedure allows to
# remove unnecesary points.
bool reduceAlignedPointsBDG = false;
function PersistenceLandscape::reduceAlignedPoints( double tollerance )# this parapeter says how much the coeficients a and b in a formula y=ax+b may be different to consider points aligned.
    for (  dim = 0  ; dim != this->land.size() ; ++dim )
         nr = 1;
        vector< pair > lambda_n;
        lambda_n.push_back( this->land[dim][0] );
        while ( nr != this->land[dim].size()-2 )
            # first, compute a and b in formula y=ax+b of a line crossing this->land[dim][nr] and this->land[dim][nr+1].
            pair res = computeParametersOfALine( this->land[dim][nr] , this->land[dim][nr+1] );
            if ( reduceAlignedPointsBDG )
                cout << "Considering points : " << this->land[dim][nr] << " and " << this->land[dim][nr+1] << endl;
                cout << "Adding : " << this->land[dim][nr] << " to lambda_n." << endl;
            end
            lambda_n.push_back( this->land[dim][nr] );
            double a = res.first;
            double b = res.second;
            int i = 1;
            while ( nr+i != this->land[dim].size()-2 )
                if ( reduceAlignedPointsBDG )
                    cout << "Checking if : " << this->land[dim][nr+i+1] << " is aligned with them " << endl;
                end
                pair res1 = computeParametersOfALine( this->land[dim][nr] , this->land[dim][nr+i+1] );
                if ( (fabs(res1.first-a) < tollerance) && (fabs(res1.second-b)<tollerance) )
                    if ( reduceAlignedPointsBDG )cout << "It is aligned " << endl;end
                    ++i;
                end
                    if ( reduceAlignedPointsBDG )cout << "It is NOT aligned " << endl;end
                    break;
                end
            end
            if ( reduceAlignedPointsBDG )
                cout << "We are out of the while loop. The number of aligned points is : " << i << endl; # std::cin.ignore();
            end
            nr += i;
        end
        if ( reduceAlignedPointsBDG )
            cout << "Out  of main while loop, done with this dimension " << endl;
            cout << "Adding : " << this->land[dim][ this->land[dim].size()-2 ] << " to lamnda_n " << endl;
            cout << "Adding : " << this->land[dim][ this->land[dim].size()-1 ] << " to lamnda_n " << endl;
            cin.ignore();
        end
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-2 ] );
        lambda_n.push_back( this->land[dim][ this->land[dim].size()-1 ] );
        # if something was reduced, then replace this->land[dim] with the new lambda_n.
        if ( lambda_n.size() < this->land[dim].size() )
            if ( lambda_n.size() > 4 )
                this->land[dim].swap(lambda_n);
            end
            /*else
                this->land[dim].clear();
            end*/
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
unsigned PersistenceLandscape::reducePoints( double tollerance , double (*penalty)(pair ,pair,std::pair) )
    unsigned numberOfPointsReduced = 0;
    for (  dim = 0  ; dim != this->land.size() ; ++dim )
         nr = 1;
        vector< pair > lambda_n;
        if ( reducePointsDBG )cout << "Adding point to lambda_n : " << this->land[dim][0] << endl;
        lambda_n.push_back( this->land[dim][0] );
        while ( nr <= this->land[dim].size()-2 )
            if ( reducePointsDBG )cout << "Adding point to lambda_n : " << this->land[dim][nr] << endl;
            lambda_n.push_back( this->land[dim][nr] );
            if ( penalty( this->land[dim][nr],this->land[dim][nr+1],this->land[dim][nr+2] ) < tollerance )
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
        if ( lambda_n.size() < this->land[dim].size() )
            if ( lambda_n.size() > 4 )
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
function findZeroOfALineSegmentBetweenThoseTwoPoints ( pair p1, pair p2 )
    if ( p1.first == p2.first )return p1.first;
    if ( p1.second*p2.second > 0 )
        ostringstream errMessage;
        errMessage <<"In function findZeroOfALineSegmentBetweenThoseTwoPoints the agguments are: (" << p1.first << "," << p1.second << ") and (" << p2.first << "," << p2.second << "). There is no zero in line between those two points. Program terminated.";
        string errMessageStr = errMessage.str();
        const char* err = errMessageStr.c_str();
        throw(err);
    end
    # we assume here, that x \in [ p1.first, p2.first ] and p1 and p2 are points between which we will put the line segment
    double a = (p2.second - p1.second)/(p2.first - p1.first);
    double b = p1.second - a*p1.first;
    # cerr << "Line crossing points : (" << p1.first << "," << p1.second << ") oraz (" << p2.first << "," << p2.second << ") : \n";
    # cerr << "a : " << a << " , b : " << b << " , x : " << x << endl;
    return -b/a;
end
# this is O(log(n)) algorithm, where n is number of points in this->land.
bool computeValueAtAGivenPointDbg = false;
function PersistenceLandscape::computeValueAtAGivenPoint( unsigned level , double x )const
    # in such a case lambda_level = 0.
    if ( level > this->land.size() ) return 0;
    # we know that the points in this->land[level] are ordered according to x coordinate. Therefore, we can find the point by using bisection:
    unsigned coordBegin = 1;
    unsigned coordEnd = this->land[level].size()-2;
    if ( computeValueAtAGivenPointDbg )
        cerr << "Tutaj \n";
        cerr << "x : " << x << "\n";
        cerr << "this->land[level][coordBegin].first : " << this->land[level][coordBegin].first << "\n";
        cerr << "this->land[level][coordEnd].first : " << this->land[level][coordEnd].first << "\n";
    end
    # in this case x is outside the support of the landscape, therefore the value of the landscape is 0.
    if ( x <= this->land[level][coordBegin].first )return 0;
    if ( x >= this->land[level][coordEnd].first )return 0;
    if (computeValueAtAGivenPointDbg)cerr << "Entering to the while loop \n";
    while ( coordBegin+1 != coordEnd )
        if (computeValueAtAGivenPointDbg)
            cerr << "coordBegin : " << coordBegin << "\n";
            cerr << "coordEnd : " << coordEnd << "\n";
            cerr << "this->land[level][coordBegin].first : " << this->land[level][coordBegin].first << "\n";
            cerr << "this->land[level][coordEnd].first : " << this->land[level][coordEnd].first << "\n";
        end
        unsigned newCord = (unsigned)floor((coordEnd+coordBegin)/2.0);
        if (computeValueAtAGivenPointDbg)
            cerr << "newCord : " << newCord << "\n";
            cerr << "this->land[level][newCord].first : " << this->land[level][newCord].first << "\n";
            cin.ignore();
        end
        if ( this->land[level][newCord].first <= x )
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
ostream& operator<<(ostream& out, PersistenceLandscape& land )
    for (  level = 0 ; level != land.land.size() ; ++level )
        out << "Lambda_" << level << ":" << endl;
        for (  i = 0 ; i != land.land[level].size() ; ++i )
            if ( land.land[level][i].first == INT_MIN )
                out << "-inf";
            end
                if ( land.land[level][i].first == INT_MAX )
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
function PersistenceLandscape::multiplyLanscapeByRealNumberOverwrite( double x )
    for (  dim = 0 ; dim != this->land.size() ; ++dim )
        for (  i = 0 ; i != this->land[dim].size() ; ++i )
             this->land[dim][i].second *= x;
        end
    end
end
bool AbsDbg = false;
PersistenceLandscape PersistenceLandscape::abs()
    PersistenceLandscape result;
    for (  level = 0 ; level != this->land.size() ; ++level )
        if ( AbsDbg ) cout << "level: " << level << endl; end
        vector< pair > lambda_n;
        lambda_n.push_back( make_pair( INT_MIN , 0 ) );
        for (  i = 1 ; i != this->land[level].size() ; ++i )
            if ( AbsDbg )cout << "this->land[" << level << "][" << i << "] : " << this->land[level][i] << endl;end
            # if a line segment between this->land[level][i-1] and this->land[level][i] crosses the x-axis, then we have to add one landscape point t oresult
            if ( (this->land[level][i-1].second)*(this->land[level][i].second)  < 0 )
                double zero = findZeroOfALineSegmentBetweenThoseTwoPoints( this->land[level][i-1] , this->land[level][i] );
                lambda_n.push_back( make_pair(zero , 0) );
                lambda_n.push_back( make_pair(this->land[level][i].first , fabs(this->land[level][i].second)) );
                if ( AbsDbg )
                    cout << "Adding pair : (" << zero << ",0)" << std::endl;
                    cout << "In the same step adding pair : (" << this->land[level][i].first << "," << fabs(this->land[level][i].second) << ") " << std::endl;
                    cin.ignore();
                end
            else
                lambda_n.push_back( make_pair(this->land[level][i].first , fabs(this->land[level][i].second)) );
                if ( AbsDbg )
                    cout << "Adding pair : (" << this->land[level][i].first << "," << fabs(this->land[level][i].second) << ") " << std::endl;
                    cin.ignore();
                end
            end
        end
        result.land.push_back( lambda_n );
    end
    return result;
end
PersistenceLandscape PersistenceLandscape::multiplyLanscapeByRealNumberNotOverwrite( double x )const
    vector< std::vector< std::pair > > result(this->land.size());
    for (  dim = 0 ; dim != this->land.size() ; ++dim )
        vector< std::pair > lambda_dim( this->land[dim].size() );
        for (  i = 0 ; i != this->land[dim].size() ; ++i )
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
PersistenceLandscape operationOnPairOfLandscapes ( const PersistenceLandscape& land1 ,  const PersistenceLandscape& land2 , double (*oper)() )
    if ( operationOnPairOfLandscapesDBG )cout << "operationOnPairOfLandscapes\n";std::cin.ignore();end
    PersistenceLandscape result;
    vector< std::vector< std::pair > > land( std::max( land1.land.size() , land2.land.size() ) );
    result.land = land;
    for (  i = 0 ; i != min( land1.land.size() , land2.land.size() ) ; ++i )
        vector< std::pair > lambda_n;
        int p = 0;
        int q = 0;
        while ( (p+1 < land1.land[i].size()) && (q+1 < land2.land[i].size()) )
            if ( operationOnPairOfLandscapesDBG )
                cerr << "p : " << p << "\n";
                cerr << "q : " << q << "\n";
                cout << "land1.land[i][p].first : " << land1.land[i][p].first << "\n";
                cout << "land2.land[i][q].first : " << land2.land[i][q].first << "\n";
            end
            if ( land1.land[i][p].first < land2.land[i][q].first )
                if ( operationOnPairOfLandscapesDBG )
                    cout << "first \n";
                    cout << " functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) : "<<  functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) << "\n";
                    cout << "oper( " << land1.land[i][p].second <<"," << functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) << " : " << oper( land1.land[i][p].second , functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) ) << "\n";
                end
                lambda_n.push_back( make_pair( land1.land[i][p].first , oper( land1.land[i][p].second , functionValue(land2.land[i][q-1],land2.land[i][q],land1.land[i][p].first) ) ) );
                ++p;
                continue;
            end
            if ( land1.land[i][p].first > land2.land[i][q].first )
                if ( operationOnPairOfLandscapesDBG )
                    cout << "Second \n";
                    cout << "functionValue("<< land1.land[i][p-1]<<" ,"<< land1.land[i][p]<<", " << land2.land[i][q].first<<" ) : " << functionValue( land1.land[i][p-1] , land1.land[i][p-1] ,land2.land[i][q].first ) << "\n";
                    cout << "oper( " << functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) <<"," << land2.land[i][q].second <<" : " << oper( land2.land[i][q].second , functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) ) << "\n";
                end
                lambda_n.push_back( make_pair( land2.land[i][q].first , oper( functionValue( land1.land[i][p] , land1.land[i][p-1] ,land2.land[i][q].first ) , land2.land[i][q].second )  )  );
                ++q;
                continue;
            end
            if ( land1.land[i][p].first == land2.land[i][q].first )
                if (operationOnPairOfLandscapesDBG)cout << "Third \n";
                lambda_n.push_back( make_pair( land2.land[i][q].first , oper( land1.land[i][p].second , land2.land[i][q].second ) ) );
                ++p;++q;
            end
            if (operationOnPairOfLandscapesDBG)cout << "Next iteration \n";getchar();end
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
    if ( land1.land.size() > min( land1.land.size() , land2.land.size() ) )
        if (operationOnPairOfLandscapesDBG)cout << "land1.land.size() > std::min( land1.land.size() , land2.land.size() )" << std::endl;end
        for (  i = min( land1.land.size() , land2.land.size() ) ; i != std::max( land1.land.size() , land2.land.size() ) ; ++i )
            vector< std::pair > lambda_n( land1.land[i] );
            for (  nr = 0 ; nr != land1.land[i].size() ; ++nr )
                lambda_n[nr] = make_pair( land1.land[i][nr].first , oper( land1.land[i][nr].second , 0 ) );
            end
            # CHANGE
            # result.land[i] = lambda_n;
            result.land[i].swap(lambda_n);
        end
    end
    if ( land2.land.size() > min( land1.land.size() , land2.land.size() ) )
        if (operationOnPairOfLandscapesDBG)cout << "( land2.land.size() > std::min( land1.land.size() , land2.land.size() ) ) " << std::endl;end
        for (  i = min( land1.land.size() , land2.land.size() ) ; i != std::max( land1.land.size() , land2.land.size() ) ; ++i )
            vector< std::pair > lambda_n( land2.land[i] );
            for (  nr = 0 ; nr != land2.land[i].size() ; ++nr )
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
function computeMaximalDistanceNonSymmetric( const PersistenceLandscape& pl1, const PersistenceLandscape& pl2 , unsigned& nrOfLand , double&x , double& y1, double& y2 )
    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    double maxDist = 0;
    int minimalNumberOfLevels = min( pl1.land.size() , pl2.land.size() );
    for ( int level = 0 ; level != minimalNumberOfLevels ; ++level )
        int p2Count = 0;
        for ( int i = 1 ; i != pl1.land[level].size()-1 ; ++i ) # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while ( true )
                if (  (pl1.land[level][i].first>=pl2.land[level][p2Count].first) && (pl1.land[level][i].first<=pl2.land[level][p2Count+1].first)  )break;
                p2Count++;
            end
            double val = fabs( functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) - pl1.land[level][i].second);
            # cerr << "functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) : " << functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) << "\n";
            # cerr << "pl1.land[level][i].second : " << pl1.land[level][i].second << "\n";
            # cerr << "pl1.land[level][i].first :" << pl1.land[level][i].first << "\n";
            # cin.ignore();
            if ( maxDist <= val )
                maxDist = val;
                nrOfLand = level;
                x = pl1.land[level][i].first;
                y1 = pl1.land[level][i].second;
                y2 = functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first );
            end
       end
    end
    if ( minimalNumberOfLevels < pl1.land.size() )
        for ( int level = minimalNumberOfLevels ; level != pl1.land.size() ; ++ level )
            for ( int i = 0 ; i != pl1.land[level].size() ; ++i )
                if ( maxDist < pl1.land[level][i].second )
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
function computeMaxNormDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second , unsigned& nrOfLand , double&x , double& y1, double& y2 )
    unsigned nrOfLandFirst;
    double xFirst, y1First, y2First;
    double dFirst = computeMaximalDistanceNonSymmetric(first,second,nrOfLandFirst,xFirst, y1First, y2First);
    unsigned nrOfLandSecond;
    double xSecond, y1Second, y2Second;
    double dSecond = computeMaximalDistanceNonSymmetric(second,first,nrOfLandSecond,xSecond, y1Second, y2Second);
    if ( dFirst > dSecond )
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
function computeMaximalDistanceNonSymmetric( const PersistenceLandscape& pl1, const PersistenceLandscape& pl2 )
    bool dbg = false;
    if (dbg)cerr << " computeMaximalDistanceNonSymmetric \n";
    # this distance is not symmetric. It compute ONLY distance between inflection points of pl1 and pl2.
    double maxDist = 0;
    int minimalNumberOfLevels = min( pl1.land.size() , pl2.land.size() );
    for ( int level = 0 ; level != minimalNumberOfLevels ; ++ level )
        if (dbg)
            cerr << "Level : " << level << std::endl;
            cerr << "PL1 : \n";
            for ( int i = 0 ; i  != pl1.land[level].size() ; ++i )
                cerr << "(" <<pl1.land[level][i].first << "," << pl1.land[level][i].second << ") \n";
            end
            cerr << "PL2 : \n";
            for ( int i = 0 ; i  != pl2.land[level].size() ; ++i )
                cerr << "(" <<pl2.land[level][i].first << "," << pl2.land[level][i].second << ") \n";
            end
            cin.ignore();
        end
        int p2Count = 0;
        for ( int i = 1 ; i != pl1.land[level].size()-1 ; ++i ) # w tym przypadku nie rozwarzam punktow w nieskocznosci
            while ( true )
                if (  (pl1.land[level][i].first>=pl2.land[level][p2Count].first) && (pl1.land[level][i].first<=pl2.land[level][p2Count+1].first)  )break;
                p2Count++;
            end
            double val = fabs( functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) - pl1.land[level][i].second);
            if ( maxDist <= val )maxDist = val;
            if (dbg)
                cerr << pl1.land[level][i].first <<"in [" << pl2.land[level][p2Count].first << "," <<  pl2.land[level][p2Count+1].first <<"] \n";
                cerr << "pl1[level][i].second : " << pl1.land[level][i].second << std::endl;
                cerr << "functionValue( pl2[level][p2Count] , pl2[level][p2Count+1] , pl1[level][i].first ) : " << functionValue( pl2.land[level][p2Count] , pl2.land[level][p2Count+1] , pl1.land[level][i].first ) << std::endl;
                cerr << "val : "  << val << std::endl;
                cin.ignore();
            end
        end
    end
    if (dbg)cerr << "minimalNumberOfLevels : " << minimalNumberOfLevels << std::endl;
    if ( minimalNumberOfLevels < pl1.land.size() )
        for ( int level = minimalNumberOfLevels ; level != pl1.land.size() ; ++ level )
            for ( int i = 0 ; i != pl1.land[level].size() ; ++i )
                if (dbg)cerr << "pl1[level][i].second  : " << pl1.land[level][i].second << std::endl;
                if ( maxDist < pl1.land[level][i].second )maxDist = pl1.land[level][i].second;
            end
        end
    end
    return maxDist;
end
function computeDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second , unsigned p )
    # This is what we want to compute: (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p). We will do it one step at a time:
    # first-second :
    PersistenceLandscape lan = first-second;
    # | first-second |:
    lan = lan.abs();
    # \int_- \inftyend^+\inftyend| first-second |^p
    double result;
    if ( p != 1 )
        result = lan.computeIntegralOfLandscape(p);
    else
        result = lan.computeIntegralOfLandscape();
    end
    # (\int_- \inftyend^+\inftyend| first-second |^p)^(1/p)
    return pow( result , 1/(double)p );
end
function computeMaxNormDiscanceOfLandscapes( const PersistenceLandscape& first, const PersistenceLandscape& second )
    return max( computeMaximalDistanceNonSymmetric(first,second) , computeMaximalDistanceNonSymmetric(second,first) );
end
function comparePairsForMerging( pair< double , unsigned > first , std::pair< double , unsigned > second )
    return (first.first < second.first);
end
vector< std::pair< double , unsigned > > PersistenceLandscape::generateBettiNumbersHistogram()const
    bool dbg = false;
    vector< std::pair< double , unsigned > > resultRaw;
    for (  dim = 0 ; dim != this->land.size() ; ++dim )
        vector< std::pair< double , unsigned > > rangeOfLandscapeInThisDimension;
        if ( dim > 0 )
            for (  i = 1 ; i != this->land[dim].size()-1 ; ++i )
                if ( this->land[dim][i].second == 0 )
                    rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , dim+1));
                end
            end
        else
            # dim == 0.
            bool first = true;
            for (  i = 1 ; i != this->land[dim].size()-1 ; ++i )
                if ( this->land[dim][i].second == 0 )
                    if ( first ) rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , 0)); end
                    rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , dim+1));
                    if ( !first ) rangeOfLandscapeInThisDimension.push_back(make_pair(this->land[dim][i].first , 0)); end
                    first = !first;
                end
            end
        end
        vector< std::pair< double , unsigned > > resultRawNew( resultRaw.size() + rangeOfLandscapeInThisDimension.size() );
        merge( resultRaw.begin() , resultRaw.end() , rangeOfLandscapeInThisDimension.begin() , rangeOfLandscapeInThisDimension.end() , resultRawNew.begin() , comparePairsForMerging );
        resultRaw.swap( resultRawNew );
        if ( dbg )
            cerr << "Raw result : for dim : " << dim << std::endl;
            for (  i = 0 ;  i != resultRaw.size() ; ++i )
                cerr << "(" << resultRaw[i].first << " , " << resultRaw[i].second << ")" << std::endl;
            end
            getchar();
        end
    end
    if ( dbg )
        cerr << "Raw result : " << std::endl;
        for (  i = 0 ;  i != resultRaw.size() ; ++i )
            cerr << "(" << resultRaw[i].first << " , " << resultRaw[i].second << ")" << std::endl;
        end
        getchar();
    end
    # now we should make it into a step function by adding a points in the jumps:
    vector< std::pair< double , unsigned > > result;
    if ( resultRaw.size() == 0 )return result;
    for (  i = 1 ;  i != resultRaw.size() ; ++i )
        result.push_back( resultRaw[i-1] );
        if ( resultRaw[i-1].second <= resultRaw[i].second )
            result.push_back( make_pair( resultRaw[i].first , resultRaw[i-1].second ) );
        else
            result.push_back( make_pair( resultRaw[i-1].first , resultRaw[i].second ) );
        end
    end
    result.erase( unique( result.begin(), result.end() ), result.end() );
/*
    # cleaning for Cathy
    vector< std::pair< double , unsigned > > resultNew;
     i = 0;
    while ( i != result.size() )
        int j = 1;
        resultNew.push_back( make_pair(result[i].first , maxBetti) );
        unsigned maxBetti = result[i].second;
        while ( (i+j<=result.size() ) && (result[i].first == result[i+j].first) )
            if ( maxBetti < result[i+j].second )maxBetti = result[i+j].second;end
            ++j;
        end
        # i += max(j,1);
        resultNew.push_back( make_pair(result[i].first , maxBetti) );
        i += j;
    end
    result.swap(resultNew);
*/
    vector< std::pair< double , unsigned > > resultNew;
     i = 0 ;
    while ( i != result.size() )
        double x = result[i].first;
        double maxBetti = result[i].second;
        double minBetti = result[i].second;
        while ( (i != result.size()) && (fabs(result[i].first - x) < 0.000001) )
            if ( maxBetti < result[i].second )maxBetti = result[i].second;
            if ( minBetti > result[i].second )minBetti = result[i].second;
            ++i;
        end
        if ( minBetti != maxBetti )
            if ( (resultNew.size() == 0) || (resultNew[resultNew.size()-1].second <= minBetti) )
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
    if ( dbg )
        cerr << "Final result : " << std::endl;
        for (  i = 0 ;  i != result.size() ; ++i )
            cerr << "(" << result[i].first << " , " << result[i].second << ")" << std::endl;
        end
        getchar();
    end
    return result;
end# generateBettiNumbersHistogram
function PersistenceLandscape::printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand( char* filename )const
    vector< std::pair< double , unsigned > > histogram = this->generateBettiNumbersHistogram();
    ostringstream result;
    for (  i = 0 ; i != histogram.size() ; ++i )
        result << histogram[i].first << " " << histogram[i].second << endl;
    end
    ofstream write;
    write.open( filename );
    write << result.str();
    write.close();
    cout << "The result is in the file : " << filename <<" . Now in gnuplot type plot \"" << filename << "\" with lines" << std::endl;
end# printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand
/*
function computeInnerProduct( const PersistenceLandscape& l1 , const PersistenceLandscape& l2 )
    bool dbg = true;
    double result = 0;
    for (  level = 0 ; level != min( l1.size() , l2.size() ) ; ++level )
        if ( dbg )cerr << "Compute inner product in the level : " << level << endl;getchar();end
        # we start from 1 and go all the way to size-1 since we do not want to bother with +-infty.
         l1It = 1;
         l2It = 1;
        double lastX = INT_MIN;
        while ( ( l1It <= l1.land[level].size()-2 ) && ( l2It <= l2.land[level].size()-2 ) )
            # first let us move the pointers to the point where the overlap:
            while ( ( l1It < l1.land[level].size()-2 ) && ( l1.land[level][l1It+1].first < l2.land[level][l2It].first ) )
                lastX = l1.land[level][l1It+1].first;
                ++l1It;
            end
            while ( ( l2It < l2.land[level].size()-2 ) && ( l2.land[level][l2It+1].first < l1.land[level][l1It].first ) )
                lastX = l2.land[level][l2It+1].first;
                ++l2It;
            end
            # now they should overlap
            # if ( (l1It > l1.land[level].size()-2) || ( l2It > l2.land[level].size()-2 ) )break;
            if ( dbg )
                cerr << "L1It : " << l1It << ", l2It : " << l2It << endl;
            end
            double x1 = l1.land[level][l1It].first;
            double x2 = l2.land[level][l2It].first;
            if ( x1 > x2 )
                # swap x1 and x2
                double b = x1;
                x1 = x2;
                x2 = b;
            end
            if ( x1 == lastX )
                x1 = x2;
                if ( l1.land[level][l1It+1].first <= l2.land[level][l2It+1].first )
                    x2 = l1.land[level][l1It+1].first;
                end
                else
                    x2 = l2.land[level][l2It+1].first;
                end
            end
            lastX = x1;
            double a,b,c,d;
            a=b=c=d=0;
            if ( l1.land[level][l1It].first < l2.land[level][l2It].first )
                a = (l1.land[level][l1It+1].second - l1.land[level][l1It].second)/(l1.land[level][l1It+1].first - l1.land[level][l1It].first);
                b = l1.land[level][l1It].second - a*l1.land[level][l1It].first;
                c = (l2.land[level][l2It].second - l2.land[level][l2It-1].second)/(l2.land[level][l2It].first - l2.land[level][l2It-1].first);
                d = l2.land[level][l2It-1].second - c*l2.land[level][l2It-1].first;
            else
                if ( l1.land[level][l1It].first > l2.land[level][l2It].first )
                    a = (l1.land[level][l1It].second - l1.land[level][l1It-1].second)/(l1.land[level][l1It].first - l1.land[level][l1It-1].first);
                    b = l1.land[level][l1It-1].second - a*l1.land[level][l1It-1].first;
                    c = (l2.land[level][l2It+1].second - l2.land[level][l2It].second)/(l2.land[level][l2It+1].first - l2.land[level][l2It].first);
                    d = l2.land[level][l2It].second - c*l2.land[level][l2It].first;
                else
                    # in this case those guys have to be equal:
                    a = (l1.land[level][l1It+1].second - l1.land[level][l1It].second)/(l1.land[level][l1It+1].first - l1.land[level][l1It].first);
                    b = l1.land[level][l1It].second - a*l1.land[level][l1It].first;
                    c = (l2.land[level][l2It+1].second - l2.land[level][l2It].second)/(l2.land[level][l2It+1].first - l2.land[level][l2It].first);
                    d = l2.land[level][l2It].second - c*l2.land[level][l2It].first;
                    x2 = min( l1.land[level][l1It+1].first , l2.land[level][l2It+1].first );
                end
            end
            if ( dbg )
                cerr << "a : " << a << ", b : " << b << " , c: " << c << ", d : " << d << endl;
                cerr << "x1 : " << x1 << " , x2 : " << x2 << endl;
                cerr << "lastX : "  << lastX << endl;
                getchar();
            end
            double contributionFromThisPart
            =
            (a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2) - (a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1);
            result += contributionFromThisPart;
            if ( dbg )
                # cerr << "l1.land[level][" << l1It << "].first : " << l1.land[level][l1It].first << endl;
                # cerr << "l1.land[level][" << l1It+1 << "].first : " << l1.land[level][l1It+1].first << endl;
                # cerr << "l2.land[level][" << l2It << "].first : " << l2.land[level][l2It].first << endl;
                # cerr << "l2.land[level][" << l2It+1 << "].first : " << l2.land[level][l2It+1].first << endl;
                # cerr << "a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2 : " << a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2 << endl;
                # cerr << "a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1 : " << a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1 << endl;
                # cerr << "a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2 - a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1 : " << ((a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2) - (a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1)) << endl;
                cerr << "contributionFromThisPart : " << contributionFromThisPart << endl;
                cerr << "result : " << result << endl;
                getchar();
            end
            if ( l1.land[level][l1It].first < l2.land[level][l2It].first )
                if ( l1.land[level][l1It+1].first <= l2.land[level][l2It+1].first )
                    ++l1It;
                    if ( dbg )cerr << "Incrementing l1It \n";end
                end
                else
                    ++l2It;
                    if ( dbg )cerr << "Incrementing l2It \n";end
                end
            end
            else
                if ( l1.land[level][l1It].first > l2.land[level][l2It].first )
                    if ( l2.land[level][l2It+1].first <= l1.land[level][l1It+1].first )
                        ++l2It;
                        if ( dbg )cerr << "Incrementing l2It \n";end
                    else
                        ++l1It;
                        if ( dbg )cerr << "Incrementing l1It \n";end
                    end
                else
                    # they are equal, so I need to increase both:
                    if ( l2.land[level][l2It+1].first == l1.land[level][l1It+1].first )
                        ++l1It;
                        ++l2It;
                        if ( dbg )cerr << "Increasing both\n";end
                    else
                        if ( l1.land[level][l1It+1].first < l2.land[level][l2It+1].first )
                            ++l1It;if ( dbg )cerr << "Incrementing l1It \n";end
                        else
                            ++l2It;
                            if ( dbg )cerr << "Incrementing l2It \n";end
                        end
                    end
                end
            end
            if ( dbg )getchar();
        end
    end
    return result;
end
*/
function computeInnerProduct( const PersistenceLandscape& l1 , const PersistenceLandscape& l2 )
    bool dbg = true;
    double result = 0;
    for (  level = 0 ; level != min( l1.size() , l2.size() ) ; ++level )
        if ( dbg )cerr << "Computing inner product for a level : " << level << endl;getchar();end
        if ( l1.land[level].size() * l2.land[level].size() == 0 )continue;
        # endpoints of the interval on which we will compute the inner product of two locally linear functions:
        double x1 = INT_MIN;
        double x2;
        if ( l1.land[level][1].first < l2.land[level][1].first )
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
            double a,b,c,d;
            a = (l1.land[level][l1It+1].second - l1.land[level][l1It].second)/(l1.land[level][l1It+1].first - l1.land[level][l1It].first);
            b = l1.land[level][l1It].second - a*l1.land[level][l1It].first;
            c = (l2.land[level][l2It+1].second - l2.land[level][l2It].second)/(l2.land[level][l2It+1].first - l2.land[level][l2It].first);
            d = l2.land[level][l2It].second - c*l2.land[level][l2It].first;
            double contributionFromThisPart
            =
            (a*c*x2*x2*x2/3 + (a*d+b*c)*x2*x2/2 + b*d*x2) - (a*c*x1*x1*x1/3 + (a*d+b*c)*x1*x1/2 + b*d*x1);
            result += contributionFromThisPart;
            if ( dbg )
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
            if ( x2 == l1.land[level][l1It+1].first )
                if ( x2 == l2.land[level][l2It+1].first )
                    # in this case, we increment both:
                    ++l2It;
                    if ( dbg )cerr << "Incrementing both \n";end
                else
                    if ( dbg )cerr << "Incrementing first \n";end
                end
                ++l1It;
            else
                # in this case we increment l2It
                ++l2It;
                if ( dbg )cerr << "Incrementing second \n"
                end
            end
            # Now, we shift x1 and x2:
            x1 = x2;
            if ( l1.land[level][l1It+1].first < l2.land[level][l2It+1].first )
                x2 = l1.land[level][l1It+1].first;
            else
                x2 = l2.land[level][l2It+1].first;
            end
        end
    end
    return result;
end
#endif
