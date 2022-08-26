using Test
using PersistenceLandscapes

generate_testing_lanscapes() =
    map(
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
# include("test/tests_configuration.jl")
# include("tests_configuration.jl")

## ===-
@testset "Test construction of PersistenceBarcode" begin
    include("persistenceBarcode_tests.jl")
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
@testset "Test PersistenceLandscapes plotting" begin
    include("landscapesPlotting_test.jl")
end

## ===-
# @testset "Configure tests" begin
#     include("configure_test.jl")
# end

## ===-
# @testset "Anova tests" begin
#     include("anova_test.jl")
# end

## ===-
# @testset "Main tests" begin
#     include("main_test.jl")
# end

## ===-
@testset "Test contruction of VectorSpaceOfPersistenceLandscapes" begin
    include("vectorSpaceOfPersistenceLandscapes_test.jl")
end

## ===-
@testset "Compare results with results from C++ version of PLT" begin
    include("results_comparison_test.jl")
end
