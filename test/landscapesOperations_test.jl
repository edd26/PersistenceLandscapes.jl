## ===-
@testset "PersistenceLandscape basic operations" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

    #
    @testset "equality" begin
        @test typeof(pl0 + pl0) == PersistenceLandscape
        @test typeof(pl0 - pl0) == PersistenceLandscape
        @test typeof(pl0 * 1) == PersistenceLandscape

        @test (pl0 * 1).land[1][1] == MyPair(1, 0)
        @test (pl0 * 1).land[1][2] == MyPair(2, 1)
        @test (pl0 * 2).land[1][1] == MyPair(1, 0)
        @test (pl0 * 2).land[1][2] == MyPair(2, 2)

        @test (pl1 == pl1) == true
        @test (pl1 == pl2) == false
        @test (pl0 == pl1) == false
    end

    #
    @testset "addition" begin
        # ===-
        # comutative test
        @test pl0 + pl0 == pl0 + pl0
        @test pl0 + pl1 == pl1 + pl0
        @test pl0 + pl2 == pl2 + pl0
        @test pl0 + pl4 == pl4 + pl0
        @test pl0 + pl5 == pl5 + pl0
        @test pl2 + pl3 == pl3 + pl2

        # ===-
        # test results correctness
        @test pl0 + pl0 == 2 * pl0
        @test pl9 + pl9 == 2 * pl9
        @test pl0 + pl1 == PersistenceLandscape(
            [[MyPair(0, 0), MyPair(1, 1), MyPair(2, 3), MyPair(3, 1), MyPair(4, 0)]],
            1,
        )
        @test pl0 + pl2 ==
              [[MyPair(0, 0), MyPair(1, 1), MyPair(2, 1), MyPair(3, 0)]] |>
              PersistenceLandscape
        @test pl2 + pl3 ==
              [[MyPair(0, 0), MyPair(1, 1), MyPair(2, 0), MyPair(3, 1), MyPair(4, 0)]] |>
              PersistenceLandscape
        @test pl2 + pl5 ==
              [[MyPair(0, 0), MyPair(1, 2), MyPair(2, 0), MyPair(3, 1), MyPair(4, 0)]] |>
              PersistenceLandscape


        # ===-
        # Landscapes with diferent number of layers
        @test length((pl6 + pl0).land) == max(length(pl6.land), length(pl0.land))
        @test (pl6 + pl0) ==
              [
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 3), MyPair(3, 1), MyPair(4, 0)],
            [MyPair(1, 0), MyPair(2, 1), MyPair(3, 0)],
        ] |> PersistenceLandscape

        @test length((pl6 + pl2).land) == max(length(pl6.land), length(pl2.land))
        @test (pl6 + pl2) ==
              [
            [MyPair(0, 0), MyPair(1, 2), MyPair(2, 2), MyPair(4, 0)],
            [MyPair(1, 0), MyPair(2, 1), MyPair(3, 0)],
        ] |> PersistenceLandscape

        @test length((pl7 + pl0).land) == max(length(pl7.land), length(pl2.land))
        @test (pl7 + pl0) ==
              [
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 3), MyPair(3, 1), MyPair(4, 0)],
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 0)],
        ] |> PersistenceLandscape

        @test length((pl7 + pl2).land) == max(length(pl7.land), length(pl2.land))
        @test (pl7 + pl2) ==
              [
            [MyPair(0, 0), MyPair(1, 2), MyPair(2, 2), MyPair(4, 0)],
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 0)],
        ] |> PersistenceLandscape

        @test length((pl6 + pl7).land) == max(length(pl6.land), length(pl7.land))
        @test (pl6 + pl7) ==
              [
            [MyPair(0, 0), MyPair(2, 4), MyPair(4, 0)],
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 1), MyPair(3, 0)],
        ] |> PersistenceLandscape

        @test length((pl7 + pl8).land) == max(length(pl7.land), length(pl8.land))
        @test (pl7 + pl8) ==
              [
            [
                MyPair(0, 0),
                MyPair(2, 2),
                MyPair(4, 2),
                MyPair(6, 0),
            ],
            [
                MyPair(0, 0),
                MyPair(1, 1),
                MyPair(2, 0),
                MyPair(3, 1),
                MyPair(4, 0),
                MyPair(5, 1),
                MyPair(6, 0),
            ],
        ] |> PersistenceLandscape

        @test length((pl0 + pl9).land) == max(length(pl0.land), length(pl9.land))
        @test (pl0 + pl9) ==
              [
            [
                MyPair(0, 0),
                MyPair(1, 1),
                MyPair(2, 3),
                MyPair(3, 3),
                MyPair(3.5, 2.5),
                MyPair(4, 3),
                MyPair(5.5, 1.5),
                MyPair(6, 2),
                MyPair(8, 0),
            ],
            [MyPair(1, 0), MyPair(3.5, 2.5), MyPair(5, 1), MyPair(5.5, 1.5), MyPair(7, 0)],
            [MyPair(3, 0), MyPair(4, 1), MyPair(4.5, 0.5), MyPair(5, 1), MyPair(6, 0)],
            [MyPair(4, 0), MyPair(4.5, 0.5), MyPair(5, 0)],
        ] |> PersistenceLandscape

        @test length((pl8 + pl9).land) == max(length(pl8.land), length(pl9.land))
        @test (pl8 + pl9) ==
              [
            [
                MyPair(0, 0),
                MyPair(2, 2),
                MyPair(3, 4),
                MyPair(3.5, 4),
                MyPair(4, 5),
                MyPair(5.5, 2),
                MyPair(6, 2),
                MyPair(8, 0),
            ],
            [
                MyPair(1, 0),
                MyPair(2, 1),
                MyPair(3, 3),
                MyPair(3.5, 3),
                MyPair(4, 2),
                MyPair(5, 2),
                MyPair(5.5, 2),
                MyPair(6, 1),
                MyPair(7, 0),
            ],
            [MyPair(3, 0), MyPair(4, 1), MyPair(4.5, 0.5), MyPair(5, 1), MyPair(6, 0)],
            [MyPair(4, 0), MyPair(4.5, 0.5), MyPair(5, 0)],
        ] |> PersistenceLandscape

        # ===-
        # first values innew landscape should be a unique colleciton of x vals from both components
        for land1 in [pl0, pl1, pl2, pl3]
            for land2 in [pl0, pl1, pl2, pl3]

                sum_res = land1 + land2
                unique_first_vals = unique(
                    sort(
                        vcat(
                            [[y.first for y in x] for x in land1.land][1],
                            [[y.first for y in x] for x in land2.land][1],
                        ),
                    ),
                )
                addition_first_vals = [[y.first for y in x] for x in sum_res.land][1]
                @test addition_first_vals == unique_first_vals
            end
        end

        # Figure tests
        # fig5_data_a = [MyPair(2, 9), MyPair(4, 8), MyPair(4,5), MyPair(8,10)]
        # fig5_bars_a = PersistenceBarcodes(fig5_data_a, 1)
        # fig5_pl_a = PersistenceLandscape(fig5_bars_a)
        #
        # fig5_data_b = [MyPair(2, 9), MyPair(4, 8), MyPair(5,6), MyPair(7,9)]
        # fig5_bars_b = PersistenceBarcodes(fig5_data_b, 1)
        # fig5_pl_b = PersistenceLandscape(fig5_bars_b)
        #
        # plt_a = plot_persistence_landscape(fig5_pl_a)
        # plot!(plt_a  , ticks=0:1:10, xlims=[1,11])
        # plt_b = plot_persistence_landscape(fig5_pl_b)
        # plot!(plt_b, ticks=0:1:10, xlims=[1,11])
        # landscpae_collection = VectorSpaceOfPersistenceLandscapes([fig5_pl_a, fig5_pl_b])
        # plt_average = plot_persistence_landscape(average(landscpae_collection))
        # plot!(plt_average , ticks=0:1:10, xlims=[1,11])
        # final_plot = plot(plt_a, plt_b, plt_average, layout=(3,1), size=(600, 400*3))
    end

    # ==-===-
    @testset "substraction test" begin

        # ===-
        # zero landscapes tests
        diff_result = pl0 - pl0
        for land_point in diff_result.land[1]
            @test land_point.second == 0
        end

        diff_result = pl6 - pl6
        for land_point in diff_result.land[1]
            @test land_point.second == 0
        end

        diff_result = pl9 - pl9
        for land_point in diff_result.land[1]
            @test land_point.second == 0
        end
        #

        # ===-===-
        # Lenght tests
        # ===-
        # single layer and single layer
        @test length((pl2 - pl3).land) == max(length(pl2.land), length(pl3.land))
        @test length((pl3 - pl2).land) == max(length(pl3.land), length(pl2.land))
        @test length((pl5 - pl0).land) == max(length(pl5.land), length(pl0.land))
        @test length((pl0 - pl5).land) == max(length(pl0.land), length(pl5.land))
        # ===-
        # single layer and two layers
        @test length((pl0 - pl6).land) == max(length(pl0.land), length(pl6.land))
        @test length((pl6 - pl0).land) == max(length(pl6.land), length(pl0.land))
        # ===-
        # many layer and two layers
        @test length((pl9 - pl8).land) == max(length(pl9.land), length(pl8.land))
        @test length((pl8 - pl9).land) == max(length(pl8.land), length(pl9.land))

        # ===-===-
        # Resutlting landscape tests
        # ===-
        @test (pl1 - pl2) ==
              [[MyPair(0, 0), MyPair(1, 0), MyPair(2, 2), MyPair(4, 0)]] |>
              PersistenceLandscape
        @test (pl2 - pl1) ==
              [[MyPair(0, 0), MyPair(1, 0), MyPair(2, -2), MyPair(4, 0)]] |>
              PersistenceLandscape
        # ===-
        @test (pl2 - pl0) ==
              [[MyPair(0, 0), MyPair(1, 1), MyPair(2, -1), MyPair(3, 0)]] |>
              PersistenceLandscape
        @test (pl0 - pl2) ==
              [[MyPair(0, 0), MyPair(1, -1), MyPair(2, 1), MyPair(3, 0)]] |>
              PersistenceLandscape
        # ===- Two layers
        @test (pl6 - pl1) ==
              [
            [MyPair(0, 0), MyPair(2, 0), MyPair(4, 0)],
            [MyPair(1, 0), MyPair(2, 1), MyPair(3, 0)],
        ] |> PersistenceLandscape
        @test (pl1 - pl6) ==
              [
            [MyPair(0, 0), MyPair(2, 0), MyPair(4, 0)],
            [MyPair(1, 0), MyPair(2, -1), MyPair(3, 0)],
        ] |> PersistenceLandscape
        # ===- Many layers
        @test (pl9 - pl4) ==
              [
            [
                MyPair(0, 0),
                MyPair(2, 0),
                MyPair(3, 2),
                MyPair(3.5, 2),
                MyPair(4, 3),
                MyPair(5, 2),
                MyPair(5.5, 1),
                MyPair(6, 1),
                MyPair(7, 1),
                MyPair(8, 0),
            ],
            [MyPair(1, 0), MyPair(3.5, 2.5), MyPair(5, 1), MyPair(5.5, 1.5), MyPair(7, 0)],
            [MyPair(3, 0), MyPair(4, 1), MyPair(4.5, 0.5), MyPair(5, 1), MyPair(6, 0)],
            [MyPair(4, 0), MyPair(4.5, 0.5), MyPair(5, 0)],
        ] |> PersistenceLandscape


        # ===-===-
        # Subtraction order
        @test (pl1 - pl2 - pl3) == ((pl1 - pl2) - pl3)
        @test (pl9 - pl1 - pl6) == ((pl9 - pl1) - pl6)

        # ===-===-
        # Tests for layered landscapes
        diff_result = pl7 - pl7
        for k = 1:2
            for land_point in diff_result.land[k]
                @test land_point.second == 0
            end
        end

        diff_result = pl6 - pl6
        for k = 1:2
            for land_point in diff_result.land[k]
                @test land_point.second == 0
            end
        end

        diff_result1 = pl7 - pl6
        diff_result2 = pl6 - pl7
        @test diff_result1.land[1] == diff_result2.land[1]
        @test diff_result1.land[2][1] == diff_result2.land[2][1]
        @test abs(diff_result1.land[2][2].second) == abs(diff_result2.land[2][2].second)
        @test abs(diff_result1.land[2][3].second) == abs(diff_result2.land[2][3].second)
        @test diff_result1.land[2][4] == diff_result2.land[2][4]
    end
    #
end


## ===-
@testset "intergal of landscapes test" begin
    #
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

    # # TODO Tests for p=0 do not make sense, as they are undefined- p is real positive value by definition
    # for p=0
    # @test computeIntegralOfLandscape(pl0) == 1
    # @test computeIntegralOfLandscape(pl1, 0) == 4
    # @test computeIntegralOfLandscape(pl2, 0) == 2
    # @test computeIntegralOfLandscape(pl3, 0) == 2
    # @test computeIntegralOfLandscape(pl4, 0) == 7
    # @test computeIntegralOfLandscape(pl5, 0) == 4
    # @test computeIntegralOfLandscape(pl6, 0) == 6
    # @test computeIntegralOfLandscape(pl7, 0) == 6
    # @test computeIntegralOfLandscape(pl8, 0) == 8
    # @test computeIntegralOfLandscape(pl9, 0) == 18

    # methods comparison
    @test computeIntegralOfLandscape(pl0) == computeIntegralOfLandscape(pl0, 1)
    @test computeIntegralOfLandscape(pl1) == computeIntegralOfLandscape(pl1, 1)
    @test computeIntegralOfLandscape(pl2) == computeIntegralOfLandscape(pl2, 1)
    @test computeIntegralOfLandscape(pl3) == computeIntegralOfLandscape(pl3, 1)
    @test computeIntegralOfLandscape(pl4) == computeIntegralOfLandscape(pl4, 1)
    @test computeIntegralOfLandscape(pl5) == computeIntegralOfLandscape(pl5, 1)
    @test computeIntegralOfLandscape(pl6) == computeIntegralOfLandscape(pl6, 1)
    @test computeIntegralOfLandscape(pl7) == computeIntegralOfLandscape(pl7, 1)
    @test computeIntegralOfLandscape(pl8) == computeIntegralOfLandscape(pl8, 1)
    @test computeIntegralOfLandscape(pl9) == computeIntegralOfLandscape(pl9, 1)

    #
end

## ===-
@testset "abs_land test" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

    # ===-
    # Test length
    @test length((abs_pl(pl0)).land) == length(pl0.land)
    @test length((abs_pl(pl6)).land) == length(pl6.land)
    @test length((abs_pl(pl9)).land) == length(pl9.land)

    @test length(abs_pl(pl6 - pl0).land) == max(length(pl6.land), length(pl0.land))
    @test length(abs_pl(pl9 - pl6).land) == max(length(pl9.land), length(pl6.land))
    @test length(abs_pl(pl6 - pl9).land) == max(length(pl6.land), length(pl9.land))

    # ===-
    # Test strucure of non-negative landscape
    @test abs_pl(pl1 + pl9) == pl1 + pl9
    @test abs_pl(pl6 + pl9) == pl6 + pl9

    # ===-
    # Test abs of diff of non-overlapping landscapes
    @test pl2 - pl3 |> abs_pl == pl2 + pl3
    @test pl8 - pl2 |> abs_pl == pl8 + pl2
    # ===-
    # Test abs of diff of overlapping landscapes
    @test pl7 - pl6 |> abs_pl == pl6 - pl7 |> abs_pl
    @test pl9 - pl6 |> abs_pl == pl6 - pl9 |> abs_pl
    @test pl9 - pl1 |> abs_pl == pl1 - pl9 |> abs_pl
    # ===-
    # Test abs structure
    @test pl7 - pl6 |> abs_pl ==
          [
        [MyPair(0, 0), MyPair(2, 0), MyPair(4, 0)],
        [MyPair(0, 0), MyPair(1, 1), MyPair(1.5, 0), MyPair(2, 1), MyPair(3, 0)],
    ] |> PersistenceLandscape
    @test pl6 - pl7 |> abs_pl ==
          [
        [MyPair(0, 0), MyPair(2, 0), MyPair(4, 0)],
        [MyPair(0, 0), MyPair(1, 1), MyPair(1.5, 0), MyPair(2, 1), MyPair(3, 0)],
    ] |> PersistenceLandscape

end

