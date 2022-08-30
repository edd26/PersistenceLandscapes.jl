# TODO add explicitly static variables declaration for singular_landscape variables

@testset "Constructor for a collection of landscapes" begin
    # TODO add tests for less trivial cases
    landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl1, pl2, pl2])

    @test length(landscpae_collection.vectOfLand) == 3
    @test size(landscpae_collection.vectOfLand, 1) == 3
    @test size(landscpae_collection) == 3
    for (land1, land2) in zip(landscpae_collection.vectOfLand, [pl1, pl2, pl2])
        @test land1 == land2
    end
    # landscpae_collection = VectorSpaceOfPersistenceLandscapes([fig5_pl_a, fig5_pl_b])
    # average(landscpae_collection)
    # the result is not correct- it gives only the bottom border, not full average
end

