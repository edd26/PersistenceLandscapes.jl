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


include("PersistenceLandscape.jl")
include("VectorSpaceOfPersistenceLandscapes.jl")

mutable struct Anova
    populationOfTopologicalInvariants::VectorVector{DescriptorOfTopology}
    characteristic::DescriptorOfTopology
    averagesOfPopulations::Float64
    standardDeviationOfPopulations::Float64
    deegreesOfFreedomOfPopulation::Int
    overalMean::Float64
    totalNumberOfTopologicalInvariants::Float64

    SSTotal::Float64
    SST::Float64
    SSE::Float64

    MST::Float64
    MSE::Float64
end
#constructor
function anova(vector< vector< DescriptorOfTopology > > populationOfTopologicalInvariants , (*functionToUse)(const DescriptorOfTopology&))

    bool dbg = true;
    this.characteristic = functionToUse;
    for   i = 0:size(populationOfTopologicalInvariants,1)
        this.populationOfTopologicalInvariants.push_back( populationOfTopologicalInvariants[i] );
    end
    dbg && println("Data read, now computing basic statistics ")
    computeBasicStatistics(this)
end

function FCharacteristic()
    println("The number of DOF of numerator is:size($(this.populationOfTopologicalInvariants,1)-1)")
    println("The number of DOF of denominator is:size($((this.totalNumberOfTopologicalInvariants - this.populationOfTopologicalInvariants,1)))")
    println("The value of F statistic is : $(this.MST / this.MSE). For the p-values please consult the appropriate tables ")
    return this.MST / this.MSE;
end


function computeBasicStatistics(this::Anova;dbg = false)
    #http://cba.ualr.edu/smartstat/topics/anova/example.pdf
    #here we compute the values of a characteristic functions of the topological invariants. This is the first and the last point in which the topological invariants are used in this program.
    characteristicOfAllPopulations = VectorVector{Float64end}()
    for   populationNo = 0:size(this.populationOfTopologicalInvariants,1) 
        #computing averages
        valuesOfCharacteristicForThisPopulation::Float64
        for   insidePopulation = 0:size(this.populationOfTopologicalInvariants[populationNo],1) 
            valueForThisElementOfPopulation = characteristic(this.populationOfTopologicalInvariants[populationNo][insidePopulation]);
            valuesOfCharacteristicForThisPopulation.push_back( valueForThisElementOfPopulation );
        end
        characteristicOfAllPopulations.push_back( valuesOfCharacteristicForThisPopulation );
    end
    #no persistnece landscapes are used beyond this point

    dbg && println("We are in the procedure computeBasicStatistics, starting computing basic statistics") 

    this.overalMean = 0;
    this.totalNumberOfTopologicalInvariants = 0;
    for   populationNo = 0:size(characteristicOfAllPopulations,1)
        dbg && println("populationNo : $(populationNo)")
        #computing averages
        averageOfThisPopulation = 0;
        for insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            averageOfThisPopulation += characteristicOfAllPopulations[populationNo][insidePopulation];
            this.overalMean += characteristicOfAllPopulations[populationNo][insidePopulation];
        end
        this.deegreesOfFreedomOfPopulation.push_back( characteristicOfAllPopulations[populationNo].size() );
        averageOfThisPopulation /= characteristicOfAllPopulations[populationNo].size();
        this.averagesOfPopulations.push_back( averageOfThisPopulation );
        this.totalNumberOfTopologicalInvariants += characteristicOfAllPopulations[populationNo].size();

        #computing standard deviation:
        standardDeviation = 0;
        for   insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            standardDeviation += ( ( characteristicOfAllPopulations[populationNo][insidePopulation] - averageOfThisPopulation ) ^ 2 );
        end
        standardDeviation /= characteristicOfAllPopulations[populationNo].size();
        standardDeviation = sqrt(standardDeviation);

        this.standardDeviationOfPopulations.push_back( standardDeviation );
    end
    dbg && println("Exiting loop in which we compute basic average and standard deviations of populations ")
    this.overalMean /= this.totalNumberOfTopologicalInvariants;

    this.SSTotal = 0;
    for   populationNo = 0:size(characteristicOfAllPopulations,1) 
        for   insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            this.SSTotal += ((characteristicOfAllPopulations[populationNo][insidePopulation] - this.overalMean)^2);
        end
    end
    dbg && println("SSTotal has been computed ")

    this.SST = 0;
    this.SSE = 0;
    for   populationNo = 0:size(averagesOfPopulations,1) 
        this.SST += (this.averagesOfPopulations[populationNo] - this.overalMean)^2 * this.deegreesOfFreedomOfPopulation[populationNo];

        this.SSE += ( this.deegreesOfFreedomOfPopulation[populationNo] )*((this.standardDeviationOfPopulations[populationNo])^2);
    end
    if (dbg)
        println("SST and SSE has been computed ")
        println("this.SSTotal : $(this.SSTotal)")
        println("this.SST + this.SSE : $(this.SST + this.SSE)")
        println("this.SST : $(this.SST)")
        println("this.SSE : $(this.SSE)")
    end


    this.MST = this.SST / (this.populationOfTopologicalInvariants.size()-1);
    this.MSE = this.SSE / (this.totalNumberOfTopologicalInvariants - this.populationOfTopologicalInvariants.size());

end#computeBasicStatistics


function printStatistics(this::Anova)
    println("overalMean : $(this.overalMean)")
    println("totalNumberOfTopologicalInvariants : $(this.totalNumberOfTopologicalInvariants)")
    println("SSTotal : $(this.SSTotal)")
    println("SST : $(this.SST)")
    println("SSE : $(this.SSE)")
    println("MST : $(this.MST)")
    println("MSE : $(this.MSE)")

    println("averagesOfPopulations : ")
    for   i = 0:size(averagesOfPopulations,1) 
        println(averagesOfPopulations[i])
    end
    println("standardDeviationOfPopulations : ")
    for   i = 0:size(standardDeviationOfPopulations,1) 
        println(standardDeviationOfPopulations[i])
    end
    println("deegreesOfFreedomOfPopulation : ")
    for   i = 0:size(deegreesOfFreedomOfPopulation,1) 
        println(deegreesOfFreedomOfPopulation[i])
    end
end
