#=     Copyright 2013-2014 University of Pennsylvania
#     Copyright 2020-2022 University of Hertfordshire
#     C version created by Pawel Dlotko; Julia version created by Emil Dmitruk
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
module PersistenceLandscapes

    # PersistenceBarcodes exports
    export MyPair,
            PersistenceBarcodes,
            size,
            isempty,
            copy,
            dim,
            compareAccordingToLength,
            removeBarcodesThatBeginsBeforeGivenNumber,
            putToBins,
            compareMyPairs,
            sort,
            compare,
            minn,
            computeAverageOfMidpointOfBarcodes,
            setAverageMidpointToZero,
            setAveragedLengthToOne,
            averageBarcodes,
            setRangeToMinusOneOne,
            setRange,
            computeAverageOfMidpointOfBarcodesWeightedByLength,
            compareForHistograms,
            removeShortBarcodes,
            restrictBarcodesToGivenInterval,
            minMax,
            computeLandscapeIntegralFromBarcodes,
            produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction,
            check_for_infs

    # TODO add file writing functions here

    # PersistenceLandscape exports
    export almostEqual,
           PersistenceLandscape,
           create_PersistenceLandscape,
           plot_persistence_landscape,
           get_peaks_and_positions,
           computeDiscanceOfLandscapes,
           abs_pl,
            computeIntegralOfLandscape

    # VectorSpaceOfPersistenceLandscapes exports
    export VectorSpaceOfPersistenceLandscapes,
           average,
           standardDeviation

    # export configure

    # export main
    include("Configure.jl")

    include("MyPair.jl")
    include("PersistenceBarcode.jl")
    include("LandscapesConstruction.jl")

    include("LandscapesOperations.jl")
    include("LandscapesDistances.jl")
    include("LandscapesPlotting.jl")

    include("VectorSpaceOfPersistenceLandscapes.jl")
    include("Anova.jl")
    # include("Main.jl")

end
