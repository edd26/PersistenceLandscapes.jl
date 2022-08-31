using Test
using PersistenceLandscapes

##
generate_testing_lanscapes() = map(
    x -> x |> PersistenceBarcodes |> PersistenceLandscape,
    [
        [MyPair(1, 3)],
        [MyPair(0, 4)],
        [MyPair(0, 2)],
        [MyPair(2, 4)],
        [MyPair(0, 4), MyPair(5, 7)],
        [MyPair(0, 2), MyPair(2, 4)],
        [MyPair(1, 3), MyPair(0, 4)],
        [MyPair(0, 2), MyPair(0, 4)],
        [MyPair(2, 6), MyPair(2, 4), MyPair(4, 6)],
        [MyPair(0, 6), MyPair(1, 7), MyPair(4, 8), MyPair(3, 5)],
    ],
)
generate_testing_pairs() = [
    # 3 piramids within each othe
    [MyPair(0, 3), MyPair(0, 6), MyPair(0, 10)],
    # 3 consecutive pyramids
    [MyPair(0, 3), MyPair(3, 6), MyPair(6, 9)],
    # Pyramid at the crossing of highe lvl pyramids
    [MyPair(0, 8), MyPair(3, 11), MyPair(3, 8), MyPair(6, 14)],
    # Layers of crossing barcodes
    [# layer 1 of barcodes
        MyPair(2, 6),
        MyPair(4, 8),
        MyPair(6, 10),
        MyPair(8, 12),
        MyPair(10, 14),
        # layer 2 of barcodes
        MyPair(2, 10),
        MyPair(4, 12),
        MyPair(8, 14),
        #
        # layer 3 of barcodes peak split
        MyPair(2, 12),
        MyPair(4, 14),

        # layer 4 of barcodes- peak
        MyPair(2, 14),
    ], # pyramids overlapping with crossings
    # barcodes repetition
    [MyPair(0, 3), MyPair(0, 6), MyPair(0, 3)],
]
##
include("tests_configuration.jl")

## ===-
@testset "Test construction of MyPair" begin
    include("myPair_test.jl")
end

## ===-
@testset "Test construction of PersistenceBarcode" begin
    include("persistenceBarcode_tests.jl")
end

## ===-
@testset "Compare results with results from C++ version of PLT" begin
    include("results_comparison_test.jl")
end

## ===-
@testset "Test contruction of PersistenceLandscapes" begin
    include("persistenceLandscape_test.jl")
    #     include("landscapesConstruction_test.jl")
end

## ===-
@testset "Test operations on PersistenceLandscapes" begin
    include("landscapesOperations_test.jl")
end

## ===-
@testset "Test distances of PersistenceLandscapes" begin
    include("landscapesDistances_test.jl")
end

## ===-
@testset "Test contruction of VectorSpaceOfPersistenceLandscapes" begin
    include("vectorSpaceOfPersistenceLandscapes_test.jl")
end

## ===-
# @testset "Test PersistenceLandscapes plotting" begin
#     include("landscapesPlotting_test.jl")
# end

## ===-
# @testset "Anova tests" begin
#     include("anova_test.jl")
# end

