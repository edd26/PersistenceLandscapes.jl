## ===-
@testset "constructors tests" begin
    #
    # 3 piramids within each othe
    bars1 = [MyPair(0, 3), MyPair(0, 6), MyPair(0, 10)]
    # 3 consecutive pyramids
    bars2 = [MyPair(0, 3), MyPair(3, 6), MyPair(6, 9)]
    # Pyramid at the crossing of highe lvl pyramids
    bars3 = [MyPair(0, 8), MyPair(3, 11), MyPair(3, 8), MyPair(6, 14)]
    # Layers of crossing barcodes
    bars4 = [# layer 1 of barcodes
        MyPair(2, 6),
        MyPair(4, 8),
        MyPair(6, 10),
        MyPair(8, 12),
        MyPair(10, 14),
        # layer 2 of barcodes
        MyPair(2, 10),
        MyPair(4, 12),
        MyPair(8, 14),
        #
        # layer 3 of barcodes peak split
        MyPair(2, 12),
        MyPair(4, 14),

        # layer 4 of barcodes- peak
        MyPair(2, 14),
    ] # pyramids overlapping with crossings
    bars5 = [MyPair(0, 3), MyPair(0, 6), MyPair(0, 3)] # barcodes repetition
    all_bars = [bars1, bars2, bars3, bars4, bars5]


    @testset "from barcodes" begin
        pland1 = bars1 |> PersistenceBarcodes |> PersistenceLandscape
        @test length(pland1.land) == 3
        @test length(pland1.land[1]) == (bars1 |> length)
        @test length(pland1.land[2]) == (bars1 |> length)
        @test length(pland1.land[3]) == (bars1 |> length)

        pland2 = bars2 |> PersistenceBarcodes |> PersistenceLandscape
        @test length(pland2.land) == 1
        @test length(pland2.land[1]) == 7

        pland3 = bars3 |> PersistenceBarcodes |> PersistenceLandscape
        @test length(pland3.land) == 3 # no longer broken after fixing landscapes creation with version v0.3.0
        @test length(pland3.land[1]) == 7
        @test length(pland3.land[2]) == 5
        @test length(pland3.land[3]) == 3

        pland4 = bars4 |> PersistenceBarcodes |> PersistenceLandscape
        # broken, because upper lvls crossing overlay with pyramids comming form persistence barcodes
        @test length(pland4.land) == 6 # no longer broken after fixing landscapes creation with version v0.3.0
        @test length(pland4.land[1]) == 3
        @test length(pland4.land[2]) == 5
        @test length(pland4.land[3]) == 7
        @test_broken length(pland4.land[4]) == 9
        @test_broken length(pland4.land[5]) == 11

        pland5 = bars5 |> PersistenceBarcodes |> PersistenceLandscape
        @test length(pland5.land) == 2 # same as above # no longer broken after fixing landscapes creation with version v0.3.0
        @test length(pland5.land[1]) == 3
        @test length(pland5.land[2]) == 3
    end
    #

    # @testset "from Vector{Vector{MyPair}}" begin
    #     for (ind, bar1) in enumerate(all_bars)
    #         pl = PersistenceLandscape([bar1])
    #
    #         filtered_pl = filter(x -> x.first != Inf, pl.land[1])
    #         filtered_pl = filter(x -> x.first != -Inf, filtered_pl)
    #         # filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)
    #
    #         @test length(filtered_pl) == target_sizes2[ind]
    #     end
    #
    # end
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

