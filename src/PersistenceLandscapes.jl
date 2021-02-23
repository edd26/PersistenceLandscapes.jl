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
            produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction
    # TODO add file writing functions here

    export almostEqual

    include("PersistenceBarcode.jl")
    include("PersistenceLandscape.jl")

end
