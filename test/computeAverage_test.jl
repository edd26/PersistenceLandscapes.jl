
@testset "average" begin
    # TODO add cases for less tricial cases
    # TODO !!! add average for a:q list of landscapes
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1, 3)], 1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 4)], 1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2)], 1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2, 4)], 1))

    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    avg_land1 = [pairs1, pairs1] |> VectorSpaceOfPersistenceLandscapes |> average
    @test avg_land1.land |> length == 3
    @test avg_land1.land[1] |> length == 3
    @test avg_land1.land[1][1] == MyPair(0, 0)
    @test avg_land1.land[1][2] == MyPair(5, 10)
    @test avg_land1.land[1][3] == MyPair(10, 0)

    @test avg_land1.land[2] |> length == 3
    @test avg_land1.land[2][1] == MyPair(0, 0)
    @test avg_land1.land[2][2] == MyPair(3, 6)
    @test avg_land1.land[2][3] == MyPair(6, 0)

    @test avg_land1.land[3] |> length == 3
    @test avg_land1.land[3][1] == MyPair(0, 0)
    @test avg_land1.land[3][2] == MyPair(1.5, 3)
    @test avg_land1.land[3][3] == MyPair(3, 0)

    # for land1 in [
    #     singular_landscape_a,
    #     singular_landscape_b,
    #     singular_landscape_c,
    #     singular_landscape_d,
    # ]
    #     for land2 in [
    #         singular_landscape_a,
    #         singular_landscape_b,
    #         singular_landscape_c,
    #         singular_landscape_d,
    #     ]
    #
    #         landscpae_collection = VectorSpaceOfPersistenceLandscapes([land1, land2])
    #         avg_res = average(landscpae_collection)
    #         unique_first_vals = unique(
    #             sort(
    #                 vcat(
    #                     [[y.first for y in x] for x in land1.land][1],
    #                     [[y.first for y in x] for x in land2.land][1],
    #                 ),
    #             ),
    #         )
    #         average_first_vals = [[y.first for y in x] for x in avg_res.land][1]
    #         @test average_first_vals == unique_first_vals
    #     end
    # end

    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Comutation tests
    @test_broken average(singular_landscape_a, singular_landscape_a) == singular_landscape_a # broken after in version v.0.3.1

    @test average(singular_landscape_a, singular_landscape_b) ==
          average(singular_landscape_b, singular_landscape_a)
    @test average(singular_landscape_a, singular_landscape_c) ==
          average(singular_landscape_c, singular_landscape_a)
    @test average(singular_landscape_c, singular_landscape_d) ==
          average(singular_landscape_d, singular_landscape_c)
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Simple examples average tests
    @test_broken average(singular_landscape_a, singular_landscape_a) == singular_landscape_a# broken after in version v.0.3.1

    @test_broken average(singular_landscape_a, singular_landscape_b) == PersistenceLandscape(
        [[
            MyPair(0, 0),
            MyPair(1, 1 / 2),
            MyPair(2, 3 / 2),
            MyPair(3, 1 / 2),
            MyPair(4, 0 / 2),
        ]],
        1,
    )# broken after in version v.0.3.1
    @test_broken average(singular_landscape_a, singular_landscape_c) == PersistenceLandscape(
        [[MyPair(0, 0 / 2), MyPair(1, 1 / 2), MyPair(2, 1 / 2), MyPair(3, 0)]],
        1,
    )# broken after in version v.0.3.1
    @test_broken average(singular_landscape_c, singular_landscape_d) == PersistenceLandscape(
        [[
            MyPair(0, 0 / 2),
            MyPair(1, 1 / 2),
            MyPair(2, 0),
            MyPair(3, 1 / 2),
            MyPair(4, 0),
        ]],
        1,
    )# broken after in version v.0.3.1
end


@testset "standard deviation tests" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1, 3)], 1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 4)], 1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2)], 1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2, 4)], 1))

    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_a])
    @test_broken standardDeviation(landscpae_collection) == 0.0# broken after in version v.0.3.1
    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_b, singular_landscape_b])
    @test_broken standardDeviation(landscpae_collection) == 0.0# broken after in version v.0.3.1

    # Non zero std value
    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_a, singular_landscape_c])
    @test_broken standardDeviation(landscpae_collection) == 0.75# broken after in version v.0.3.1

    landscpae_collection =
        VectorSpaceOfPersistenceLandscapes([singular_landscape_c, singular_landscape_d])
    @test standardDeviation(landscpae_collection) == 1.0

end


@testset "real average" begin
    # This tests average that sums all points and then divides values by total number of landscapes

    # ===-===-===-===-===-===-===-===-===-===-===-===-
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    avg_land1 = [pairs1, pairs1] |> VectorSpaceOfPersistenceLandscapes |> real_average
    @test avg_land1.land |> length == 3
    @test avg_land1.land[1] |> length == 3
    @test avg_land1.land[1] == pairs1.land[1]

    @test avg_land1.land[2] |> length == 3
    @test avg_land1.land[2] == pairs1.land[2]

    @test avg_land1.land[3] |> length == 3
    @test avg_land1.land[3] == pairs1.land[3]


    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Comutation tests
    @test [pl0, pl1] |> VectorSpaceOfPersistenceLandscapes |> real_average ==
          [pl1, pl0] |> VectorSpaceOfPersistenceLandscapes |> real_average
    @test [pl1, pl2] |> VectorSpaceOfPersistenceLandscapes |> real_average ==
          [pl2, pl1] |> VectorSpaceOfPersistenceLandscapes |> real_average
    @test [pl2, pl3] |> VectorSpaceOfPersistenceLandscapes |> real_average ==
          [pl3, pl2] |> VectorSpaceOfPersistenceLandscapes |> real_average

    @test [pairs4, pairs5] |> VectorSpaceOfPersistenceLandscapes |> real_average ==
          [pairs5, pairs4] |> VectorSpaceOfPersistenceLandscapes |> real_average

    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Comutation tests
    @test [pl0, pl0] |> VectorSpaceOfPersistenceLandscapes |> real_average == pl0/1
    @test [pl0, pl0, pl0] |> VectorSpaceOfPersistenceLandscapes |> real_average == pl0/1

    @test [pl0, pl1] |> VectorSpaceOfPersistenceLandscapes |> real_average == (pl0 + pl1) /2
    @test [pl0, pl1, pl2] |> VectorSpaceOfPersistenceLandscapes |> real_average == (pl0 + pl1 + pl2) /3
    # ===-===-===-===-===-===-===-===-===-===-===-===-
    # Simple examples average tests
    # @test average(singular_landscape_a, singular_landscape_a) == singular_landscape_a
end
