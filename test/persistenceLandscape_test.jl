# ===-
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
## ===-
@testset "constructors tests" begin
    #
    bars1 = [MyPair(0, 3), MyPair(0, 6), MyPair(0, 10)]
    bars2 = [MyPair(0, 3), MyPair(3, 6), MyPair(6, 9)]
    bars3 = [MyPair(0, 4), MyPair(2, 10), MyPair(3, 7), MyPair(6, 14)]
    bars4 = [MyPair(2, 6), MyPair(4, 12), MyPair(5, 9), MyPair(8, 16)]
    #

    target_sizes = [length(bars1), length(bars2), length(bars3) + 1, length(bars4) + 1]
    target_sizes2 = [length(bars1), length(bars2), length(bars3), length(bars4)]
    all_bars = [bars1, bars2, bars3, bars4]

    #
    @testset "from barcodes" begin
        for (ind, bar) in enumerate(all_bars)
            barcodes = PersistenceBarcodes(bar)
            pl = PersistenceLandscape(barcodes)

            filtered_pl = filter(x -> x.first != Inf, pl.land[1])
            filtered_pl = filter(x -> x.first != -Inf, filtered_pl)
            filtered_pl = filter(x -> x.first != 0 && x.second != 0, filtered_pl)

            @debug filtered_pl
            @test length(filtered_pl) == target_sizes[ind]
        end
    end
    #

    @testset "from Vector{Vector{MyPair}}" begin
        for (ind, bar1) in enumerate(all_bars)
            pl = PersistenceLandscape([bar1])

            filtered_pl = filter(x -> x.first != Inf, pl.land[1])
            filtered_pl = filter(x -> x.first != -Inf, filtered_pl)
            # filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)

            @debug filtered_pl
            @test length(filtered_pl) == target_sizes2[ind]
        end

    end
    # @test typeof(pl1.land) == Vector{Vector{MyPair}}
    # @test pl1.land == [a, b]
    # @test pl1.land[1] == a
    # @test pl1.land[2] == b
    #
    # @test pl1.land[1][1] == a[1]
    # @test length(pl1.land) == 2
    # @test length(pl1.land[1]) == 3
    # @test length(pl1.land[2]) == 4
    #
    # @test size(pl1.land,1) == 2
    # @test size(pl1.land[1],1) == 3
    # @test size(pl1.land[2],1) == 4
    #
    # @test min(size(pl1.land), size(pl2.land)) == (2,)
    #
    # @test_throws BoundsError pl1.land[3]

    #move constructor tests here

end

## ===-
# @testset "Check for infs check" begin
#     pl_infs1 = PersistenceLandscape([[MyPair(-Inf, 0)]], 1)
#     pl_infs2 = PersistenceLandscape([[MyPair(0, Inf)]], 1)
#     pl_infs3 = PersistenceLandscape([[MyPair(-Inf, 0), MyPair(0, Inf)]], 1)
#     pl_infs4 = PersistenceLandscape([[MyPair(0, Inf), MyPair(-Inf, 0)]], 1)
#
#     pl_infs5 = PersistenceLandscape([c], 1)
#     pl_infs6 = PersistenceLandscape([d], 1)
#
#     @test check_for_infs(pl_infs1) != pl_infs1
#     @test check_for_infs(pl_infs2) != pl_infs2
#     @test check_for_infs(pl_infs3) == pl_infs3
#     @test check_for_infs(pl_infs4) == pl_infs4
#
#     @test check_for_infs(pl_infs5) != pl_infs5
#     @test check_for_infs(pl_infs6) == pl_infs6
# end


## ===-
@testset "PersistenceLandscape operations" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

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
            [MyPair(0, 0), MyPair(1, 2), MyPair(2, 4), MyPair(4, 0)],
            [MyPair(0, 0), MyPair(1, 1), MyPair(2, 1), MyPair(3, 0)],
        ] |> PersistenceLandscape

        @test length((pl7 + pl8).land) == max(length(pl7.land), length(pl8.land))
        @test (pl7 + pl8) ==
              [
            [
                MyPair(0, 0),
                MyPair(1, 1),
                MyPair(2, 2),
                MyPair(3, 2),
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
end
##

## ===-
@testset "Distances tests" begin
    @testset "(regular) distance of landscapes" begin

    end

    @testset "max norm distance of landscapes" begin


    end
end



## ===-
@testset "intergal of landscapes test" begin
    #
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

    # for p=0
    @test_broken computeIntegralOfLandscape(pl0) == 2
    @test computeIntegralOfLandscape(pl1, 0) == 4
    @test computeIntegralOfLandscape(pl2, 0) == 2
    @test computeIntegralOfLandscape(pl3, 0) == 2
    @test computeIntegralOfLandscape(pl4, 0) == 6
    @test computeIntegralOfLandscape(pl5, 0) == 4
    @test computeIntegralOfLandscape(pl6, 0) == 6
    @test computeIntegralOfLandscape(pl7, 0) == 6
    @test computeIntegralOfLandscape(pl8, 0) == 8
    @test computeIntegralOfLandscape(pl9, 0) == 18

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

    diff_result = abs_pl(pl6 - pl6)
    for k = 1:2
        for land_point in diff_result.land[k]
            @test land_point.second == 0
        end
    end

    diff_result = abs_pl(pl6 - pl7)
    for k = 1:2
        for land_point in diff_result.land[k]
            @test land_point.second >= 0
        end
    end

    diff_result = abs_pl(pl7 - pl6)
    for k = 1:2
        for land_point in diff_result.land[k]
            @test land_point.second >= 0
        end
    end

    # diff_result = abs_pl(two_layer_landscape_d - two_layer_landscape_c)
    for k = 1:2
        for land_point in diff_result.land[k]
            @test land_point.second >= 0
        end
    end

end


## ===-
@testset "computeDiscanceOfLandscapes test" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

    @test computeDiscanceOfLandscapes(pl0, pl0, 1) == 0
    @test computeDiscanceOfLandscapes(pl1, pl2, 1) == 1
    @test computeDiscanceOfLandscapes(pl2, pl3, 1) > 0

    @test computeDiscanceOfLandscapes(pl0, pl0, 1) == 0
    @test computeDiscanceOfLandscapes(pl1, pl2, 1) > 0
end

## ===-
@testset "PersistenceLandscape test on eirene results" begin
    # Reproduction of figure 4 from Bernadete paper about average landscape
    x1 = 10
    x2 = x1 + 1
    x3 = x2 + 1
    x4 = x3 + 1
    x5 = x4 + 1
    x6 = x5 + 1
    hexa_matrix = [
        0 1 8 7 9 6
        1 0 2 x1 x2 x3
        8 2 0 3 x4 x5
        7 x1 3 0 4 x6
        9 x2 x4 4 0 5
        6 x3 x5 x6 5 0
    ]

    x = collect(1:45) .+ 6
    x = zeros(Int, 45) .+ 7
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix = [
        0 1 3 5 x[1] x[2] 3 5 4 7 5 1 # a
        1 0 1 x[6] x[7] x[8] 6 x[9] x[10] x[11] x[12] x[13] # b
        3 1 0 1 3 x[14] 5 x[15] x[16] x[17] x[18] x[19] # c
        5 x[6] 1 0 1 x[20] 5 x[20] x[21] x[22] x[23] x[24] # d
        x[1] x[7] 3 1 0 1 3 x[25] x[26] x[27] x[28] x[29] # e
        x[2] x[8] x[14] x[20] 1 0 2 x[30] x[31] x[32] x[33] x[34] # f
        3 6 5 5 3 2 0 1 x[35] x[36] x[37] x[38] # g
        5 x[9] x[15] x[20] x[25] x[30] 1 0 1 x[39] x[40] x[41] # h
        4 x[10] x[16] x[21] x[26] x[31] x[35] 1 0 2 x[42] x[43] # i
        7 x[11] x[17] x[22] x[27] x[32] x[36] x[39] 2 0 1 x[44] # j
        5 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42] 1 0 1 # k
        1 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44] 1 0 # l
    ]


    x = collect(1:45) .+ 7
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix_modified = [
        0 1 3 6 x[1] x[2] 3 5 4 8 5 1 # a
        1 0 1 x[6] x[7] x[8] 7 x[9] x[10] x[11] x[12] x[13] # b
        3 1 0 1 3 x[14] 6 x[15] x[16] x[17] x[18] x[19] # c
        6 x[6] 1 0 1 x[20] 6 x[20] x[21] x[22] x[23] x[24] # d
        x[1] x[7] 3 1 0 1 3 x[25] x[26] x[27] x[28] x[29] # e
        x[2] x[8] x[14] x[20] 1 0 2 x[30] x[31] x[32] x[33] x[34] # f
        3 7 6 6 3 2 0 1 x[35] x[36] x[37] x[38] # g
        5 x[9] x[15] x[20] x[25] x[30] 1 0 1 x[39] x[40] x[41] # h
        4 x[10] x[16] x[21] x[26] x[31] x[35] 1 0 2 x[42] x[43] # i
        8 x[11] x[17] x[22] x[27] x[32] x[36] x[39] 2 0 1 x[44] # j
        5 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42] 1 0 1 # k
        1 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44] 1 0 # l
    ]


    x = collect(1:45) .+ 22
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix_modified2 = [
        0 1 13 18 x[2] x[3] 14 19 17 x[1] 20 10 # a
        1 0 2 x[6] x[7] x[8] 23 x[9] x[10] x[11] x[12] x[13] # b
        13 2 0 3 15 x[14] 21 x[15] x[16] x[17] x[18] x[19] # c
        18 x[6] 3 0 4 x[20] 22 x[20] x[21] x[22] x[23] x[24] # d
        x[2] x[7] 15 4 0 5 16 x[25] x[26] x[27] x[28] x[29] # e
        x[3] x[8] x[14] x[20] 5 0 11 x[30] x[31] x[32] x[33] x[34] # f
        14 23 21 22 16 11 0 6 x[35] x[36] x[37] x[38] # g
        19 x[9] x[15] x[20] x[25] x[30] 6 0 7 x[39] x[40] x[41] # h
        17 x[10] x[16] x[21] x[26] x[31] x[35] 7 0 12 x[42] x[43] # i
        x[1] x[11] x[17] x[22] x[27] x[32] x[36] x[39] 12 0 8 x[44] # j
        20 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42] 8 0 9 # k
        10 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44] 9 0 # l
    ]

    # Eirene computations

    # ===-
    vertices_labels =
        ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o"]

    ord_matrices = Dict(
        :simpler_case => hexa_matrix,
        :fig4 => fig4_matrix,
        :fig4_modified => fig4_matrix_modified,
        :fig4_modified2 => fig4_matrix_modified2,
    )
    all_keys = [:simpler_case, :fig4, :fig4_modified, :fig4_modified2]
    C_ord_mat = Dict()

    max_B_dim = 3
    key = all_keys[3]
    # for key in all_keys
    # total_points = size(ord_matrices[key], 1)
    #
    # C_ord_mat[key] = eirene(ord_matrices[key],
    #                         maxdim=max_B_dim,
    #                         model="vr",
    #                         pointlabels=vertices_labels[1:total_points])
    #
    # plotbarcode_pjs(C_ord_mat[key])
    # selected_dim = 1
    # barcodes = barcode(C_ord_mat[key], dim=selected_dim )
    # bar = [MyPair(barcodes[k,1], barcodes[k,2]) for k in 1:size(barcodes,1)]
    # pair_barcodes  = PersistenceBarcodes(bar, selected_dim)
    #
    # pl1 = PersistenceLandscape(pair_barcodes)
    # plot_persistence_landscape(pl1)
    # end # for
end

