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

    include("PersistenceBarcode.jl")
# Write your package code here.

end
