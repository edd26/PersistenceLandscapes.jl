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


@testset "MyPair basic tests" begin
    @test_throws MethodError MyPair("1", 2)

    @test my_pair.first == 1
    @test my_pair.second == 2
    @test typeof(my_pair.first) <: Float64
    @test typeof(my_pair.second) <: Float64

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


@testset "minMax tests" begin
    min_max_pb = minMax(my_persi_barcode2)
    @test typeof(min_max_pb) <: MyPair
    @test min_max_pb.first == 1
    @test min_max_pb.second == 7

end


@testset "putToBins tests" begin
    modified_pers_barcode1 = putToBins(my_persi_barcode, 1)
    modified_pers_barcode2 = putToBins(my_persi_barcode2, 2)

    @test size(modified_pers_barcode1.barcodes,1 ) == size(my_persi_barcode.barcodes,1 )
    @test size(modified_pers_barcode2.barcodes,1 ) == size(my_persi_barcode2.barcodes,1 )

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
    # @test compare(my_persi_barcode, my_persi_barcode)
    # @test compare(my_persi_barcode2, my_persi_barcode2)
    @test !compare(my_persi_barcode, my_persi_barcode2)

    # elementwise comparison
end



# @testset "putToBins tests" begin
# end
# @testset "putToBins tests" begin
# end
# @testset "putToBins tests" begin
# end
# @testset "putToBins tests" begin
# end
# @testset "putToBins tests" begin
# end
# @testset "putToBins tests" begin
# end
