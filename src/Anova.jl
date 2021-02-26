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

DescriptorOfTopology = Union{PersistenceLandscape, PersistenceBarcodes} # a temporary solution, as this is a function (most probably)

mutable struct Anova
    populationOfTopologicalInvariants::Vector{Vector{DescriptorOfTopology}}
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
function anova(ano::Anova, populationOfTopologicalInvariants::Vector{Vector{DescriptorOfTopology}} , functionToUse; dbg = true)
    populationOfTopologicalInvariants.characteristic = functionToUse

    for  i = 0:size(populationOfTopologicalInvariants,1)
        push!(ano.populationOfTopologicalInvariants(populationOfTopologicalInvariants[i]))
    end

    dbg && println("Data read, now computing basic statistics ")
    return computeBasicStatistics(ano)
end

function FCharacteristic(ano::Anova,)
    println("The number of DOF of numerator is:size($(ano.populationOfTopologicalInvariants)-1)")
    println("The number of DOF of denominator is:size($((ano.totalNumberOfTopologicalInvariants - ano.populationOfTopologicalInvariants)))")
    println("The value of F statistic is : $(ano.MST / ano.MSE). For the p-values please consult the appropriate tables ")
    return ano.MST / ano.MSE;
end


function computeBasicStatistics(ano::Anova; dbg = false)
    #http://cba.ualr.edu/smartstat/topics/anova/example.pdf
    #here we compute the values of a characteristic functions of the topological invariants. This is the first and the last point in which the topological invariants are used in this program.
    characteristicOfAllPopulations = VectorVector{Float64end}()
    for   populationNo = 0:size(ano.populationOfTopologicalInvariants,1) 
        #computing averages
        valuesOfCharacteristicForThisPopulation::Float64
        for   insidePopulation = 0:size(ano.populationOfTopologicalInvariants[populationNo],1) 
            valueForThisElementOfPopulation = characteristic(ano.populationOfTopologicalInvariants[populationNo][insidePopulation]);
            valuesOfCharacteristicForThisPopulation.push_back( valueForThisElementOfPopulation );
        end
        characteristicOfAllPopulations.push_back( valuesOfCharacteristicForThisPopulation );
    end
    #no persistnece landscapes are used beyond this point

    dbg && println("We are in the procedure computeBasicStatistics, starting computing basic statistics") 

    ano.overalMean = 0;
    ano.totalNumberOfTopologicalInvariants = 0;
    for   populationNo = 0:size(characteristicOfAllPopulations,1)
        dbg && println("populationNo : $(populationNo)")
        #computing averages
        averageOfThisPopulation = 0;
        for insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            averageOfThisPopulation += characteristicOfAllPopulations[populationNo][insidePopulation];
            ano.overalMean += characteristicOfAllPopulations[populationNo][insidePopulation];
        end
        ano.deegreesOfFreedomOfPopulation.push_back( characteristicOfAllPopulations[populationNo].size() );
        averageOfThisPopulation /= characteristicOfAllPopulations[populationNo].size();
        ano.averagesOfPopulations.push_back( averageOfThisPopulation );
        ano.totalNumberOfTopologicalInvariants += characteristicOfAllPopulations[populationNo].size();

        #computing standard deviation:
        standardDeviation = 0;
        for   insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            standardDeviation += ( ( characteristicOfAllPopulations[populationNo][insidePopulation] - averageOfThisPopulation ) ^ 2 );
        end
        standardDeviation /= characteristicOfAllPopulations[populationNo].size();
        standardDeviation = sqrt(standardDeviation);

        ano.standardDeviationOfPopulations.push_back( standardDeviation );
    end
    dbg && println("Exiting loop in which we compute basic average and standard deviations of populations ")
    ano.overalMean /= ano.totalNumberOfTopologicalInvariants;

    ano.SSTotal = 0;
    for   populationNo = 0:size(characteristicOfAllPopulations,1) 
        for   insidePopulation = 0:size(characteristicOfAllPopulations[populationNo],1) 
            ano.SSTotal += ((characteristicOfAllPopulations[populationNo][insidePopulation] - ano.overalMean)^2);
        end
    end
    dbg && println("SSTotal has been computed ")

    ano.SST = 0;
    ano.SSE = 0;
    for   populationNo = 0:size(averagesOfPopulations,1) 
        ano.SST += (ano.averagesOfPopulations[populationNo] - ano.overalMean)^2 * ano.deegreesOfFreedomOfPopulation[populationNo];

        ano.SSE += ( ano.deegreesOfFreedomOfPopulation[populationNo] )*((ano.standardDeviationOfPopulations[populationNo])^2);
    end
    if (dbg)
        println("SST and SSE has been computed ")
        println("ano.SSTotal : $(ano.SSTotal)")
        println("ano.SST + ano.SSE : $(ano.SST + ano.SSE)")
        println("ano.SST : $(ano.SST)")
        println("ano.SSE : $(ano.SSE)")
    end


    ano.MST = ano.SST / (ano.populationOfTopologicalInvariants.size()-1);
    ano.MSE = ano.SSE / (ano.totalNumberOfTopologicalInvariants - ano.populationOfTopologicalInvariants.size());

end#computeBasicStatistics


function printStatistics(ano::Anova)
    println("overalMean : $(ano.overalMean)")
    println("totalNumberOfTopologicalInvariants : $(ano.totalNumberOfTopologicalInvariants)")
    println("SSTotal : $(ano.SSTotal)")
    println("SST : $(ano.SST)")
    println("SSE : $(ano.SSE)")
    println("MST : $(ano.MST)")
    println("MSE : $(ano.MSE)")

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
