
#    Copyright 2013-2014 University of Pennsylvania
#    Created by Pawel Dlotko
#
#    This file is part of Persistence Landscape Toolbox (PLT).
#
#    PLT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    PLT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with PLT.  If not, see <http://www.gnu.org/licenses/>.



#global variables and their default values.

# DrWatson added for packing all config values into single dictionary so that it is more accesible
# using DrWatson
using UnPack
using Plots
using Eirene

import Base.:<, Base.:>, Base.==, Base.isless

# tested
struct MyPair
    first::Float64
    second::Float64
end

# based on compareMyPairs function
function isless(p1::MyPair, p2::MyPair)
    return <(p1, p2)
end

function <(p1::MyPair, p2::MyPair)
    if p1.first<p2.first
        return true
    elseif p1.first == p2.first
        if p1.second < p2.second
            return true
        end
    else
        return false
    end
end

function >(p1::MyPair, p2::MyPair)
    if p1.first>p2.first
        return true
    elseif p1.first == p2.first
        if p1.second > p2.second
            return true
        end
    else
        return false
    end
end


function ==(p1::MyPair, p2::MyPair)
    return p1.first == p2.first && p1.second == p2.second
end

# tested
function make_MyPair(val1, val2)
    return MyPair(val1, val2)
end



areThereInfiniteIntervals = false
allow_inf_intervals = areThereInfiniteIntervals
infty = -Inf
shallInfiniteBarcodesBeIgnored = true
valueOfInfinity = Inf
useGridInComputations = false
gridDiameter = 0.01
epsi = 0.000005

config_dict = Dict{Symbol, Any}()
@pack! config_dict = areThereInfiniteIntervals,
                    infty,
                    shallInfiniteBarcodesBeIgnored,
                    valueOfInfinity,
                    useGridInComputations,
                    gridDiameter,
                    epsi


function configure(;config_file_name::String = "configure", config_dict::Dict = config_dict, dbg::Bool = false)
    begin @unpack areThereInfiniteIntervals,
        infty,
        shallInfiniteBarcodesBeIgnored,
        valueOfInfinity,
        useGridInComputations,
        gridDiameter,
        epsi = config_dict
    end

    isThisAFirsLine = true
    vaiableNumber = 0

    all_lines = try
        # @info isfile(config_file_name)
        open(config_file_name , "r") do f
            readlines(f)
        end
    catch
        @warn "File not found"
        @warn "The configure file is not present in the folder. Program will now terminate. Please put the original configure file to this folder and try again."
    end

    for line in all_lines
    # while (!in.eof())
        # getline(in,line)

        if ( !(length(line) == 0 || line[1] == '#') )
            lineSS = parse(Float64,line)

            if vaiableNumber == 0
                i = lineSS
                if i == 1
                    areThereInfiniteIntervals = true
                else
                    areThereInfiniteIntervals = false
                end
                dbg && println("areThereInfiniteIntervals: $(areThereInfiniteIntervals)")
            end
            if vaiableNumber == 1
                infty = lineSS
                dbg && println("infty: $(infty)")
            end
            if vaiableNumber == 2
                shallInfiniteBarcodesBeIgnored = lineSS
                dbg && println("shallInfiniteBarcodesBeIgnored: $(shallInfiniteBarcodesBeIgnored)")
            end
            if vaiableNumber == 3
                valueOfInfinity = lineSS
                dbg && println("valueOfInfinity: $(valueOfInfinity)")
            end
            if vaiableNumber == 4
                useGridInComputations = lineSS
                dbg && println("useGridInComputations: $(useGridInComputations)")
            end
            if vaiableNumber == 5
                gridDiameter = lineSS
                dbg && println("gridDiameter: $(gridDiameter)")
            end
            if vaiableNumber == 6
                epsi = lineSS
                dbg && println("epsi: $(epsi)")
            end
            vaiableNumber += 1
        else
            println("IGNORE THIS LINE : ")

            isThisAFirsLine = false
        end
	end
    @pack! config_dict = areThereInfiniteIntervals,
                    infty,
                    shallInfiniteBarcodesBeIgnored,
                    valueOfInfinity,
                    useGridInComputations,
                    gridDiameter,
                    epsi

    return config_dict
end


#this is an old version of a configuration which do not use data readed from file. It require re-compilation each time the program is used.

#=
This is a configuration file for a Persistence Landscape Toolbox (PLT). NOTE THAT THE
PLT LIBRARY HAVE TO BE RE-COMPILED WHEN ANY OF THIS PARAMETERS IS CHANGED.

If in your files with persistence intervals there are infinite ones, please set the
variable areThereInfiniteIntervals to true. Otherwise, please set it up to false.
areThereInfiniteIntervals = false
If there are infinite persistence intervals, please provide here a values which
should be read as plus infinity:
double infty= -1
If there are infinite barcodes possible, they either can be ignored or not by the PLT.
If you do not wnat them to be ignored, please set shallInfiniteBarcodesBeIgnored to false.
shallInfiniteBarcodesBeIgnored = true
If the infinite barcodes are not to be ignored and the variable shallInfiniteBarcodesBeIgnored
is set to false, then please provide below the value which should be used by PLT in place of infinity:
double valueOfInfinity = INT_MAX

The Persistence Landscape Toolbox (PLT) can compute distances using two different
representations of landscapes. The first, and default one, is the representation that
uses pairs (critical point, critical value). Alternative representation, which may be
faster in some cases, is a grid-base one. In case of grid-base representation we assume
that the begin and end points of the intervals are sampled from a finite, uniformly
distributed grid. If this is the case in your computations, please set the variable
useGridInComputations to true.
useGridInComputations = false
in case grid is used in a computations, you need to provide a grid diameter here.
double gridDiameter = 0.01



A small number, used for a debugging purposes. Ignore when not in the debugging mode.
double epsi = 0.000005
=#
