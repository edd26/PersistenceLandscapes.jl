using Test
using PersistenceLandscapes

##
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
    include("landscapesConstruction_test.jl")
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

