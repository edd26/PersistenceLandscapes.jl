# TODO add explicitly static variables declaration for singular_landscape variables

@testset "Constructor for a collection of landscapes" begin
    # TODO add tests for less trivial cases
    landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl1, pl2, pl2])

    @test length(landscpae_collection.vectOfLand) == 3
    @test size(landscpae_collection.vectOfLand,1) == 3
    @test size(landscpae_collection) == 3
    for (land1, land2) = zip(landscpae_collection.vectOfLand, [pl1, pl2, pl2])
        @test land1 == land2
    end
    # landscpae_collection = VectorSpaceOfPersistenceLandscapes([fig5_pl_a, fig5_pl_b])
    # average(landscpae_collection)
    # the result is not correct- it gives only the bottom border, not full average
end

@testset "average" begin
    # TODO add cases for less tricial cases
    # TODO !!! add average for a:q list of landscapes
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))

    landscpae_collection = VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_a])
    average(singular_landscape_a, singular_landscape_a)
    # @test average(landscpae_collection) = singular_landscape_a

    for land1 = [singular_landscape_a, singular_landscape_b, singular_landscape_c, singular_landscape_d]
        for land2 = [singular_landscape_a, singular_landscape_b, singular_landscape_c, singular_landscape_d]

            landscpae_collection = VectorSpaceOfPersistenceLandscapes([land1, land2])
            avg_res = average(landscpae_collection)
            unique_first_vals = unique( sort( vcat(
                            [[y.first for y in x] for x in land1.land][1],
                            [[y.first for y in x] for x in land2.land][1]
                            )))
            average_first_vals = [[y.first for y in x] for x in avg_res.land][1]
            @test average_first_vals == unique_first_vals
        end
    end

    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Comutation tests
    @test average(singular_landscape_a, singular_landscape_a) == singular_landscape_a

    @test average(singular_landscape_a,
                  singular_landscape_b) == average(singular_landscape_b,
                                                   singular_landscape_a)
    @test average(singular_landscape_a,
                  singular_landscape_c) == average(singular_landscape_c,
                                                   singular_landscape_a)
    @test average(singular_landscape_c,
                  singular_landscape_d) == average(singular_landscape_d,
                                                   singular_landscape_c)
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Simple examples average tests
    @test average(singular_landscape_a,
                  singular_landscape_a) == singular_landscape_a

    @test average(singular_landscape_a,
                  singular_landscape_b) == PersistenceLandscape([[ MyPair(0,0),
                                                                    MyPair(1,1/2),
                                                                    MyPair(2,3/2),
                                                                    MyPair(3,1/2),
                                                                    MyPair(4,0/2)
                                                                    ]],1)
    @test average(singular_landscape_a,
                  singular_landscape_c) == PersistenceLandscape([[MyPair(0, 0/2),
                                                                    MyPair(1, 1/2),
                                                                    MyPair(2, 1/2),
                                                                    MyPair(3, 0)
                                                                    ]],1)
    @test average(singular_landscape_c,
                  singular_landscape_d) == PersistenceLandscape([[MyPair(0, 0/2),
                                                                    MyPair(1, 1/2),
                                                                    MyPair(2, 0),
                                                                    MyPair(3, 1/2),
                                                                    MyPair(4, 0)
                                                                    ]], 1)
end

@testset "intergal of landscapes test" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))
    singular_landscape_e = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4), MyPair(5,7)],1))

    function get_traingle_area(landscape)
        # this function is only applicable to singular landscapes for testing
        start_pt = landscape.land[1][1].first
        end_pt = landscape.land[1][3].first
        base_len= end_pt - start_pt
        h = landscape.land[1][2].second

        return (base_len*h)/2
    end

    @test computeIntegralOfLandscape(singular_landscape_a, 0) == get_traingle_area(singular_landscape_a)
    @test computeIntegralOfLandscape(singular_landscape_a, 1) == get_traingle_area(singular_landscape_a) /2
    @test computeIntegralOfLandscape(singular_landscape_a, 1) == computeIntegralOfLandscape(singular_landscape_a)

    @test computeIntegralOfLandscape(singular_landscape_b, 0) == get_traingle_area(singular_landscape_b)
    @test computeIntegralOfLandscape(singular_landscape_b, 0) == get_traingle_area(singular_landscape_b)
    @test computeIntegralOfLandscape(singular_landscape_b, 1) == get_traingle_area(singular_landscape_b) /2

    @test computeIntegralOfLandscape(singular_landscape_c, 0) == get_traingle_area(singular_landscape_c)
    @test computeIntegralOfLandscape(singular_landscape_c, 0) == get_traingle_area(singular_landscape_c)
    @test computeIntegralOfLandscape(singular_landscape_c, 1) == get_traingle_area(singular_landscape_c) /2

    @test computeIntegralOfLandscape(singular_landscape_d, 0) == get_traingle_area(singular_landscape_d)
    @test computeIntegralOfLandscape(singular_landscape_d, 0) == get_traingle_area(singular_landscape_d)
    @test computeIntegralOfLandscape(singular_landscape_d, 1) == get_traingle_area(singular_landscape_d) /2

    # same area, different position tests
    @test computeIntegralOfLandscape(singular_landscape_c, 0) == computeIntegralOfLandscape(singular_landscape_d, 0)
    @test computeIntegralOfLandscape(singular_landscape_c, 1) == computeIntegralOfLandscape(singular_landscape_d, 1)
    @test computeIntegralOfLandscape(singular_landscape_c, 2) == computeIntegralOfLandscape(singular_landscape_d, 2)

    singular_landscape_e 

    # Tests for layered landscapes
    two_layer_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4), MyPair(0,2)],1))
    two_layer_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4), MyPair(1,3)],1))
    two_layer_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4), MyPair(2,4)],1))

    two_layer_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3), MyPair(0,4)],1))
    two_layer_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3), MyPair(0,4)],1))
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))

end

@testset "landscape distance test" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))

    computeDiscanceOfLandscapes(singular_landscape_a, singular_landscape_a,1)
end

@testset "standard deviation tests" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))

    landscpae_collection = VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_a])
    @test standardDeviation(landscpae_collection) == 0.0
    landscpae_collection = VectorSpaceOfPersistenceLandscapes([singular_landscape_b, singular_landscape_b])
    @test standardDeviation(landscpae_collection) == 0.0

    # Non zero std value
    landscpae_collection = VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_c])
    @test standardDeviation(landscpae_collection) == 0.0

    landscpae_collection = VectorSpaceOfPersistenceLandscapes([singular_landscape_c, singular_landscape_d])
    @test standardDeviation(landscpae_collection) == 0.0

end
