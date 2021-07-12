using Test
using PersistenceLandscapes

include("tests_configuration.jl")

@testset "Test construction of PersistenceBarcode" begin
    include("persistenceBarcode_tests.jl")
end


@testset "Test contruction of PersistenceLandscape " begin
    include("persistenceLandscape_test.jl")
end

# @testset "Configure tests" begin
#     include("configure_test.jl")
# end

# @testset "Anova tests" begin
#     include("anova_test.jl")
# end

# @testset "Main tests" begin
#     include("main_test.jl")
# end

@testset "Test contruction of VectorSpaceOfPersistenceLandscapes" begin
    include("vectorSpaceOfPersistenceLandscapes_test.jl")
end
