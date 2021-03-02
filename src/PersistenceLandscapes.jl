module PersistenceLandscapes

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

    export almostEqual,
           PersistenceLandscape,
           create_PersistenceLandscape,
           plot_persistence_landscape,
           get_peaks_and_positions

    export VectorSpaceOfPersistenceLandscapes,
           average

    export configure

    export main

    include("VectorSpaceOfPersistenceLandscapes.jl")
    # include("PersistenceBarcode.jl")
    # include("PersistenceLandscape.jl")
    include("Anova.jl")
    # include("Main.jl")

end
