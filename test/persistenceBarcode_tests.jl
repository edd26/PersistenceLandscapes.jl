my_pair = MyPair(1, 2)
my_pair1 = my_pair
my_pair2 = MyPair(1, 3)
my_pair3 = MyPair(3, 7)
my_pair4 = MyPair(6, 7)
my_persi_barcode = PersistenceBarcodes([my_pair], 2)
my_persi_barcode2  = PersistenceBarcodes([my_pair,
                                        my_pair1,
                                        my_pair2,
                                        my_pair3,
                                        my_pair4], 2)
my_persi_barcode3  = PersistenceBarcodes([my_pair,
                                        my_pair1,
                                        my_pair3,
                                        my_pair3,
                                        my_pair4], 2)


@testset "MyPair basic tests" begin
    @test_throws MethodError MyPair("1", 2)

    @test my_pair.first == 1
    @test my_pair.second == 2
    @test typeof(my_pair.first) <: Float64
    @test typeof(my_pair.second) <: Float64

    # TODO add test for the section below
    # @testset "PersistenceBarcodes from PersistenceBarcodes test" begin
    # end

    @testset "PersistenceBarcodes from vector of MyPairs test" begin
        new_pers_barcodes = PersistenceBarcodes([my_pair1, my_pair2, my_pair3 ])

        @test PersistenceBarcodes([my_pair1, my_pair2, my_pair3 ]).barcodes == [my_pair1, my_pair2, my_pair3 ]
        @test PersistenceBarcodes([my_pair1, my_pair2, my_pair3, MyPair(12, Inf)]).barcodes == [my_pair1, my_pair2, my_pair3 ]
    end
end

@testset "PersistenceBarcodes Base functions tests" begin

    @test_throws MethodError PersistenceBarcodes("1", 2)

    @test typeof(my_persi_barcode.barcodes) <: Array{MyPair, 1}
    @test typeof(my_persi_barcode.dimensionOfBarcode) <: UInt

    @test my_persi_barcode.barcodes == [my_pair]
    @test my_persi_barcode.dimensionOfBarcode == 2

    @test typeof(my_persi_barcode.dimensionOfBarcode) <: UInt


    @test copy(my_persi_barcode) == my_persi_barcode


    # @test diagonal_symmetrize(square_matrix, below_over_upper=true)[1,end] == square_matrix[end,1]
    # @test diagonal_symmetrize(square_matrix, below_over_upper=true)[1,2] == square_matrix[2,1]
end

@testset "basic PersistenceBarcode info tests" begin
    @test size(my_persi_barcode) == 1
    @test_broken empty(my_persi_barcode)
    @test dim(my_persi_barcode) == 2

end

@testset "compareAccordingToLength tests" begin
    @test compareAccordingToLength(my_pair2, my_pair1)
end


@testset "removeBarcodesThatBeginsBeforeGivenNumber tests" begin
    mb = removeBarcodesThatBeginsBeforeGivenNumber(my_persi_barcode2, 3)
    @test size(mb)== 2
    @test mb.barcodes == [my_pair3, my_pair4]
end




@testset "putToBins tests" begin
    modified_pers_barcode1 = putToBins(my_persi_barcode, 1)
    modified_pers_barcode2 = putToBins(my_persi_barcode2, 2)

    @test size(modified_pers_barcode1.barcodes,1 ) == size(my_persi_barcode.barcodes,1 )
    # @test size(modified_pers_barcode2.barcodes,1 ) == size(my_persi_barcode2.barcodes,1 )

    @test modified_pers_barcode1.dimensionOfBarcode  == my_persi_barcode.dimensionOfBarcode
    @test modified_pers_barcode2.dimensionOfBarcode  == my_persi_barcode2.dimensionOfBarcode

    # Test if the values are changed correctly
end



@testset "compareMyPairs tests" begin
    f1 = MyPair(1, 2)
    f2 = MyPair(2, 2)
    f3 = MyPair(3, 2)

    s1 = MyPair(1, 1)
    s2 = MyPair(1, 2)
    s3 = MyPair(1, 3)
    s4 = MyPair(4, 1)
    s5 = MyPair(4, 2)

    @test !compareMyPairs(f1, s1) # return false because all s1 less
    @test !compareMyPairs(f1, s2) # return false because equal
    @test compareMyPairs(f1, s3) #return positive because s3.second

    @test !compareMyPairs(f2, s1) # return false because all s1 less
    @test !compareMyPairs(f3, s1) # return false because all s1 less

    @test !compareMyPairs(f2, s2) # return false because all s1 less
    @test !compareMyPairs(f3, s2) # return false because all s1 less

    @test !compareMyPairs(f2, s3) # return false due to 2nd if
    @test !compareMyPairs(f3, s3) # return false due to 2nd if

    @test compareMyPairs(f1, s4) # first condition positive
    @test compareMyPairs(f2, s4) # first condition positive
    @test compareMyPairs(f3, s4) # first condition positive

    @test compareMyPairs(f1, s5) # first condition positive
    @test compareMyPairs(f2, s5) # first condition positive
    @test compareMyPairs(f3, s5) # first condition positive
end

@testset "sort tests" begin
    @test sort(my_persi_barcode).barcodes == my_persi_barcode.barcodes
    @test sort(my_persi_barcode).dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    sorted_my_persi_barcode2 = sort(my_persi_barcode2)
    @test sorted_my_persi_barcode2.dimensionOfBarcode == my_persi_barcode2.dimensionOfBarcode
    @test sorted_my_persi_barcode2.barcodes == [my_pair,
                                                    my_pair1,
                                                    my_pair2,
                                                    my_pair3,
                                                    my_pair4]
end

@testset "compare tests" begin
    # mismatched size 
    @test !compare(my_persi_barcode, my_persi_barcode2)

    # elementwise comparison
    @test compare(my_persi_barcode, my_persi_barcode)
    @test compare(my_persi_barcode2, my_persi_barcode2)

    @test !compare(my_persi_barcode2, my_persi_barcode3)

    @test_throws MethodError compare(my_persi_barcode2, [my_pair,
                                        my_pair1,
                                        my_pair2,
                                        my_pair3,
                                        my_pair4])
end



@testset "minn tests" begin
    @test minn(1, 2) == 1
    @test minn(3, 2) == 2
end

@testset "computeAverageOfMidpointOfBarcodes tests" begin
    average_midpoints = computeAverageOfMidpointOfBarcodes(my_persi_barcode)
    average_midpoints2 = computeAverageOfMidpointOfBarcodes(my_persi_barcode2)
    average_midpoints3 = computeAverageOfMidpointOfBarcodes(my_persi_barcode3)

    @test average_midpoints == 0.5
    @test average_midpoints2 == 0.9
    @test average_midpoints3 == 1.1
end


@testset "setAverageMidpointToZero tests" begin
    moved_midpoint1 = setAverageMidpointToZero(my_persi_barcode)
    moved_midpoint2 = setAverageMidpointToZero(my_persi_barcode2)
    moved_midpoint3 = setAverageMidpointToZero(my_persi_barcode3)

    @test moved_midpoint1.barcodes[1] == MyPair(0.5, 1.5)
    @test size(moved_midpoint1.barcodes,1) == 1
    @test moved_midpoint1.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test moved_midpoint2.barcodes != my_persi_barcode2.barcodes
    @test size(moved_midpoint2.barcodes) == size(my_persi_barcode2.barcodes)
    @test moved_midpoint2.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test moved_midpoint3.barcodes != my_persi_barcode3.barcodes
    @test size(moved_midpoint3.barcodes) == size(my_persi_barcode3.barcodes)
    @test moved_midpoint3.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

end

@testset "setAveragedLengthToOne tests" begin
    moved_midpoint1 = setAveragedLengthToOne(my_persi_barcode)
    moved_midpoint2 = setAveragedLengthToOne(my_persi_barcode2)
    moved_midpoint3 = setAveragedLengthToOne(my_persi_barcode3)

    @test moved_midpoint1.barcodes[1] == MyPair(1.0, 2.0)
    @test size(moved_midpoint1.barcodes,1) == 1
    @test moved_midpoint1.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test moved_midpoint2.barcodes != my_persi_barcode2.barcodes
    @test size(moved_midpoint2.barcodes) == size(my_persi_barcode2.barcodes)
    @test moved_midpoint2.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test moved_midpoint3.barcodes != my_persi_barcode3.barcodes
    @test size(moved_midpoint3.barcodes) == size(my_persi_barcode3.barcodes)
    @test moved_midpoint3.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

end

@testset "averageBarcodes test" begin
    avg_barcodes1 = averageBarcodes(my_persi_barcode)
    avg_barcodes2 = averageBarcodes(my_persi_barcode2)
    avg_barcodes3 = averageBarcodes(my_persi_barcode3)

    @test avg_barcodes1.barcodes[1] == MyPair(0.5, 1.5)
    @test avg_barcodes1.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test size(avg_barcodes2.barcodes,1) == size(my_persi_barcode2.barcodes,1)
    @test avg_barcodes2.dimensionOfBarcode == my_persi_barcode2.dimensionOfBarcode

    @test size(avg_barcodes3.barcodes,1) == size(my_persi_barcode3.barcodes,1)
    @test avg_barcodes3.dimensionOfBarcode == my_persi_barcode3.dimensionOfBarcode

end

@testset "setRangeToMinusOneOne tests" begin
    one_to_one_ranged1 = setRangeToMinusOneOne(my_persi_barcode)
    one_to_one_ranged2 = setRangeToMinusOneOne(my_persi_barcode2)
    one_to_one_ranged3 = setRangeToMinusOneOne(my_persi_barcode3)

    @test one_to_one_ranged1.barcodes[1] == MyPair(0.0, 1.0)
    @test one_to_one_ranged1.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode

    @test size(one_to_one_ranged2.barcodes,1) == size(my_persi_barcode2.barcodes,1)
    @test one_to_one_ranged2.dimensionOfBarcode == my_persi_barcode2.dimensionOfBarcode

    @test size(one_to_one_ranged3.barcodes,1) == size(my_persi_barcode3.barcodes,1)
    @test one_to_one_ranged3.dimensionOfBarcode == my_persi_barcode3.dimensionOfBarcode

    @test findmin([x.first for x in one_to_one_ranged1.barcodes])[1] >= -1
    @test findmin([x.second for x in one_to_one_ranged1.barcodes])[1] <= 1
    @test findmin([x.first for x in one_to_one_ranged2.barcodes])[1] >= -1
    @test findmin([x.second for x in one_to_one_ranged2.barcodes])[1] <= 1
    @test findmin([x.first for x in one_to_one_ranged3.barcodes])[1] >= -1
    @test findmin([x.second for x in one_to_one_ranged3.barcodes])[1] <= 1
end


@testset "setRange tests" begin
    new_start = 12
    new_end = 15
    new_ranged_pbarcodes1 = setRange(my_persi_barcode, new_start, new_end)
    new_ranged_pbarcodes2 = setRange(my_persi_barcode2, new_start, new_end)
    new_ranged_pbarcodes3 = setRange(my_persi_barcode3, new_start, new_end)

    @test_throws DomainError setRange(my_persi_barcode, new_end, new_start)
    @test_throws DomainError setRange(my_persi_barcode, new_start, new_start)
    @test_throws DomainError setRange(my_persi_barcode, new_end, new_end)

    @test new_ranged_pbarcodes1.barcodes[1] == MyPair(new_start, new_end)
    @test size(new_ranged_pbarcodes1.barcodes, 1) == 1
    @test new_ranged_pbarcodes1.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode
    @test findmin([x.first for x in new_ranged_pbarcodes1.barcodes])[1] == new_start
    @test findmax([x.second for x in new_ranged_pbarcodes1.barcodes])[1] == new_end

    @test size(new_ranged_pbarcodes2.barcodes,1) == size(my_persi_barcode2.barcodes,1)
    @test new_ranged_pbarcodes2.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode
    @test findmin([x.first for x in new_ranged_pbarcodes2.barcodes])[1] == new_start
    @test findmax([x.second for x in new_ranged_pbarcodes2.barcodes])[1] == new_end

    @test size(new_ranged_pbarcodes3.barcodes,1) == size(my_persi_barcode3.barcodes,1)
    @test new_ranged_pbarcodes3.dimensionOfBarcode == my_persi_barcode.dimensionOfBarcode
    @test findmin([x.first for x in new_ranged_pbarcodes3.barcodes])[1] == new_start
    @test findmax([x.second for x in new_ranged_pbarcodes3.barcodes])[1] == new_end

end

@testset "computeAverageOfMidpointOfBarcodesWeightedByLength tests" begin
    lengthwise_comparison1 = computeAverageOfMidpointOfBarcodesWeightedByLength(my_persi_barcode)
    lengthwise_comparison2 = computeAverageOfMidpointOfBarcodesWeightedByLength(my_persi_barcode2)
    lengthwise_comparison3 = computeAverageOfMidpointOfBarcodesWeightedByLength(my_persi_barcode3)

    @test lengthwise_comparison1 == 0.5
    @test lengthwise_comparison2 <= 1.28
    @test lengthwise_comparison2 >= 1.26
    @test lengthwise_comparison3 <= 1.59090909099
    @test lengthwise_comparison3 >= 1.59090909090
end

@testset "compareForHistograms tests" begin
    @test compareForHistograms(MyPair(1, 1), MyPair(1, 1)) == false
    @test compareForHistograms(MyPair(2, 1), MyPair(1, 1)) == false
    @test compareForHistograms(MyPair(1, 1), MyPair(2, 1)) == true

    @test compareForHistograms(MyPair(1, 1), MyPair(1, 2)) == false
    @test compareForHistograms(MyPair(2, 1), MyPair(1, 2)) == false
    @test compareForHistograms(MyPair(1, 1), MyPair(2, 2)) == true

    @test compareForHistograms(MyPair(1, 2), MyPair(1, 2)) == false
    @test compareForHistograms(MyPair(2, 2), MyPair(1, 2)) == false
    @test compareForHistograms(MyPair(1, 2), MyPair(2, 2)) == true

    @test compareForHistograms(MyPair(1, 2), MyPair(1, 1)) == false
    @test compareForHistograms(MyPair(2, 2), MyPair(1, 1)) == false
    @test compareForHistograms(MyPair(1, 2), MyPair(2, 1)) == true
end


@testset "removeShortBarcodes tests" begin
    minimal_diameter = 1
    short_barcodes_removed1 = removeShortBarcodes(my_persi_barcode,  minimal_diameter )
    short_barcodes_removed2 = removeShortBarcodes(my_persi_barcode2,  minimal_diameter )
    short_barcodes_removed3 = removeShortBarcodes(my_persi_barcode3,  minimal_diameter )

    @test isempty(short_barcodes_removed1.barcodes)

    @test short_barcodes_removed2.barcodes[1] == my_pair2
    @test short_barcodes_removed2.barcodes[2] == my_pair3
    @test size(short_barcodes_removed2.barcodes, 1) == 2

    @test short_barcodes_removed3.barcodes[1] == my_pair3
    @test short_barcodes_removed3.barcodes[2] == my_pair3
    @test size(short_barcodes_removed2.barcodes, 1) == 2


    @test removeShortBarcodes(my_persi_barcode,  0.5).barcodes == my_persi_barcode.barcodes
    @test removeShortBarcodes(my_persi_barcode2,  0.5).barcodes == my_persi_barcode2.barcodes
    @test removeShortBarcodes(my_persi_barcode3,  0.5).barcodes == my_persi_barcode3.barcodes


    @test isempty(removeShortBarcodes(my_persi_barcode,  12).barcodes)
    @test isempty(removeShortBarcodes(my_persi_barcode2,  12).barcodes)
    @test isempty(removeShortBarcodes(my_persi_barcode3,  12).barcodes)
end


@testset "restrictBarcodesToGivenInterval tests" begin
    interval1 = MyPair(0, 12)

    @test restrictBarcodesToGivenInterval(my_persi_barcode,  interval1).barcodes == my_persi_barcode.barcodes
    @test restrictBarcodesToGivenInterval(my_persi_barcode2,  interval1).barcodes == my_persi_barcode2.barcodes
    @test restrictBarcodesToGivenInterval(my_persi_barcode3,  interval1).barcodes == my_persi_barcode3.barcodes


    interval2 = MyPair(0, 1)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode,  interval2).barcodes)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode2,  interval2).barcodes)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode3,  interval2).barcodes)


    interval3 = MyPair(6, 12)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode,  interval3).barcodes)
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode2,  interval3).barcodes,1) == 2
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode3,  interval3).barcodes,1) == 3

    interval4 = MyPair(3, 12)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode,  interval4).barcodes)
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode2,  interval4).barcodes,1) == 2
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode3,  interval4).barcodes,1) == 3

    interval5 = MyPair(3, 4)
    @test isempty(restrictBarcodesToGivenInterval(my_persi_barcode,  interval5).barcodes)
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode2,  interval5).barcodes,1) == 1
    @test size(restrictBarcodesToGivenInterval(my_persi_barcode3,  interval5).barcodes,1) == 2

end

@testset "minMax tests" begin
    min_max_pb = minMax(my_persi_barcode2)
    @test typeof(min_max_pb) <: MyPair
    @test min_max_pb.first == 1
    @test min_max_pb.second == 7

end


@testset "computeLandscapeIntegralFromBarcodes tests" begin
    @test computeLandscapeIntegralFromBarcodes(my_persi_barcode) == 0.25
    @test computeLandscapeIntegralFromBarcodes(my_persi_barcode2) == 5.75
    @test computeLandscapeIntegralFromBarcodes(my_persi_barcode3) == 8.75
end


# This function does not give correct results but it is untested from original code hwo it should work
@testset "produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction tests" begin
    produceBettiNumbersOnAGridFromMinToMaxRangeWithAStepBeingParameterOfThisFunction(my_persi_barcode, UInt(250), 0.0, 12.0)

end
# @testset "putToBins tests" begin
# end
