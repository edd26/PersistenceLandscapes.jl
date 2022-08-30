
@testset "average" begin
    # TODO add cases for less tricial cases
    # TODO !!! add average for a:q list of landscapes
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1, 3)], 1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 4)], 1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2)], 1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2, 4)], 1))

    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_a])
    average(singular_landscape_a, singular_landscape_a)
    # @test average(landscpae_collection) = singular_landscape_a

    for land1 in [
        singular_landscape_a,
        singular_landscape_b,
        singular_landscape_c,
        singular_landscape_d,
    ]
        for land2 in [
            singular_landscape_a,
            singular_landscape_b,
            singular_landscape_c,
            singular_landscape_d,
        ]

            landscpae_collection = VectorSpaceOfPersistenceLandscapes([land1, land2])
            avg_res = average(landscpae_collection)
            unique_first_vals = unique(
                sort(
                    vcat(
                        [[y.first for y in x] for x in land1.land][1],
                        [[y.first for y in x] for x in land2.land][1],
                    ),
                ),
            )
            average_first_vals = [[y.first for y in x] for x in avg_res.land][1]
            @test average_first_vals == unique_first_vals
        end
    end

    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Comutation tests
    @test average(singular_landscape_a, singular_landscape_a) == singular_landscape_a

    @test average(singular_landscape_a, singular_landscape_b) ==
          average(singular_landscape_b, singular_landscape_a)
    @test average(singular_landscape_a, singular_landscape_c) ==
          average(singular_landscape_c, singular_landscape_a)
    @test average(singular_landscape_c, singular_landscape_d) ==
          average(singular_landscape_d, singular_landscape_c)
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Simple examples average tests
    @test average(singular_landscape_a, singular_landscape_a) == singular_landscape_a

    @test average(singular_landscape_a, singular_landscape_b) == PersistenceLandscape(
        [[
            MyPair(0, 0),
            MyPair(1, 1 / 2),
            MyPair(2, 3 / 2),
            MyPair(3, 1 / 2),
            MyPair(4, 0 / 2),
        ]],
        1,
    )
    @test average(singular_landscape_a, singular_landscape_c) == PersistenceLandscape(
        [[MyPair(0, 0 / 2), MyPair(1, 1 / 2), MyPair(2, 1 / 2), MyPair(3, 0)]],
        1,
    )
    @test average(singular_landscape_c, singular_landscape_d) == PersistenceLandscape(
        [[
            MyPair(0, 0 / 2),
            MyPair(1, 1 / 2),
            MyPair(2, 0),
            MyPair(3, 1 / 2),
            MyPair(4, 0),
        ]],
        1,
    )
end


@testset "standard deviation tests" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1, 3)], 1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 4)], 1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2)], 1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2, 4)], 1))

    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_a])
    @test standardDeviation(landscpae_collection) == 0.0
    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_b, singular_landscape_b])
    @test standardDeviation(landscpae_collection) == 0.0

    # Non zero std value
    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_c])
    @test standardDeviation(landscpae_collection) == 0.75

    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_c, singular_landscape_d])
    @test standardDeviation(landscpae_collection) == 1.0

end
