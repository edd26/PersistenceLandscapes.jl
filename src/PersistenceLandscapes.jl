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
    include("PersistenceBarcode.jl")
    include("PersistenceLandscape.jl")
    include("LandscapesPlotting.jl")
    include("LandscapesOperations.jl")
    include("VectorSpaceOfPersistenceLandscapes.jl")
    include("Anova.jl")
    # include("Main.jl")

end
