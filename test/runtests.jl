using Test
using PersistenceLandscapes

@testset "PersistenceBarcode tests" begin
    include("persistenceBarcode_tests.jl")
end


@testset "PersistenceLandscape tests" begin
    include("persistenceLandscape_tests.jl")
end

