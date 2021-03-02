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
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with PLT.  If not, see <http://www.gnu.org/licenses/>.


#include "Anova.h"
#include "FunctionsOfPersistenceLandscapes.h"
#include "FilesReader.h"
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    # ===
    # confidenceValue = atof( argv[3+numberOfClasses] );
    numberOfClasses = 1
    confidenceValue = atof( s[3+numberOfClasses] );

    @add_arg_table! s begin
        "--numberOfClasses", "-n"
            help = "Number of classes to be found"
            arg_type = Int
            default = 0
        "--numberOfFunction ", "-f"
            help = "Maximal dimension for Betti curves"
            arg_type = Int
            default = 1
        "--confidenceValue ", "-c"
            help = "Maximal dimension for Betti curves"
            arg_type = Real
            default = 1
    end

    return parse_args(s)
end

include("Anova.jl")
include("FunctionsOfPersistenceLandscapes.jl")
#include("FilesReader.jl")


const programInfo = """
This is anova program which is a part of Peristence Landscape Toolbox by Pawel Dlotko. It takes as input the following parameter:
A positive integer N indicating the number of classes that are to be tested,
N files containing a list of files with persistence landscapes (.lan files) or persistence barcodes have to be provided. The next parameter is a function 
the average value of which will be compared by using anova. We have provided here some basic functions, but uses should feel free to implement his own function 
in a file functionsOfPersistenceLandscapes.h. In this file it is indicated how to use that function.
You should provide number of a function as a parameter of this program. The list of available functions is given below
In this case the program returns the value of F-statistics and the user have to verify the corresponding p-value in the appropriate table.
"""
# TODO add argument parsing

function main()
    configure(config_file_name="/Users/emil/Programming/Julia/PersistenceLandscapes.jl/src/configure")
    println("programInfo listOfAvailableFunctions")

    # ===-===-===-===-===-===-===-===-
    # argument parsing >>>
    parsed_args = parse_commandline()
    begin @unpack max_dim, min_dim, total_matrices, prefix,
                    do_hc, do_sch, do_plots, do_save,
                    do_areas, do_max_bettis, data_folder, results_folder,
                    do_lifetime, do_max_lifetimes, do_db_ratio, do_max_db_ratio,
                    do_thresholding, threshold  = parsed_args
    end
    # argument parsing <<<
    # ===-===-===-===-===-===-===-===-


    if ( numberOfClasses < 1 )
        println("Number of classes is : $(numberOfClasses) which is not a correct value. The program will terminate now.")
        return 1;
    end
    classes = Vector{Vector{String}}
    for classNo = 0 : numberOfClasses
        #println("Reading : $(argv[2+classNo])")
        namesOfFilesFirstFamilly = readFileNames( argv[2+classNo] );
        if ( namesOfFilesFirstFamilly.size() == 0 )
            println("Class number : $(classNo) is empty. This is not a correct input to the program. Please remove the class or correct the file name. The program will terminate now.")
            return 1;
        end
        push!(classes,  namesOfFilesFirstFamilly );
    end
    numberOfFunction = atoi( argv[2+numberOfClasses] );
    confidenceValue = atof( argv[3+numberOfClasses] );

    println("Number of function : $(numberOfFunction)")
    println("Confidence value : $(confidenceValue)")

    println("The parameter of the program are : ")
    println("Number of classes : $(numberOfClasses)")
    println("Names of files with different landscapes or barcodes classes:")
    for classNo = 0:size(classes,1)
        println("Class number : $(classNo+1)")
        for  fileNo = 0:size(classes[classNo],1)
            println(classes[classNo][fileNo])
        end
    end

    #now generate landscapes based on that files:
    println("Creating Persistence Landscapes.")
    landscapes = Vector{Vector{PersistenceLandscape}};
    for classNo = 0:size(classes,1)
        landscapesThisFamilly = createLandscapesFromTheFiles( classes[classNo] );
        push!(landscapes, landscapesThisFamilly);
    end
    println("Landscapes has been created.")

    functionToUse = gimmeFunctionOfANumnber(numberOfFunction);

    println("Constructing anova \n")

    k = Anova(landscapes, functionToUse )
    FCharacteristic(k);

    #for debug only
    #k.printStatistics();

    println("That is all. Have a good day!")
	return 1;
end
