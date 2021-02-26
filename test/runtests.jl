using Test
using PersistenceLandscapes

@testset "PersistenceBarcode tests" begin
    include("persistenceBarcode_tests.jl")
end


@testset "PersistenceLandscape tests" begin
    include("persistenceLandscape_test.jl")
end


@test "Anova tests" begin
    include("anova_test.jl")
end

@test "Main tests" begin
    include("main_test.jl")
end
