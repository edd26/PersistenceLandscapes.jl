using Eirene

@testset "constructors tests" begin
    bars1 = [MyPair(0, 3), MyPair(0, 6), MyPair(0,10)]
    bars2 = [MyPair(0, 3), MyPair(3, 6), MyPair(6,9)]
    bars3 = [MyPair(0, 4), MyPair(2, 10), MyPair(3,7), MyPair(6,14)]
    bars4 = [MyPair(2, 6), MyPair(4, 12), MyPair(5,9), MyPair(8,16)]

    target_sizes = [length(bars1), length(bars2), length(bars3)+1, length(bars4)+1]
    target_sizes2 = [length(bars1), length(bars2), length(bars3), length(bars4)]
    all_bars = [bars1, bars2, bars3, bars4]

    @testset "from barcodes" begin
        for (ind, bar) in enumerate(all_bars)
            barcodes = PersistenceBarcodes(bar)
            pl = PersistenceLandscape(barcodes)

            filtered_pl = filter(x-> x.first!=Inf, pl.land[1])
            filtered_pl = filter(x-> x.first!=-Inf, filtered_pl)
            filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)

            @debug filtered_pl
            @test length(filtered_pl) == target_sizes[ind]
        end
    end

    @testset "from Vector{Vector{MyPair}}" begin
        for (ind, bar1) in enumerate(all_bars)
            pl = PersistenceLandscape([bar1])

            filtered_pl = filter(x-> x.first!=Inf, pl.land[1])
            filtered_pl = filter(x-> x.first!=-Inf, filtered_pl)
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


@testset "PersistenceLandscape operations" begin
    singular_landscape_a = PersistenceLandscape(PersistenceBarcodes([MyPair(1,3)],1))
    singular_landscape_b = PersistenceLandscape(PersistenceBarcodes([MyPair(0,4)],1))
    singular_landscape_c = PersistenceLandscape(PersistenceBarcodes([MyPair(0,2)],1))
    singular_landscape_d = PersistenceLandscape(PersistenceBarcodes([MyPair(2,4)],1))
    @testset "equality" begin
        @test typeof(pl0+pl0) == PersistenceLandscape
        @test typeof(pl0-pl0) == PersistenceLandscape
        @test typeof(pl0*1) == PersistenceLandscape

        @test (pl0*1).land[1][1] == MyPair(1,2)
        @test (pl0*1).land[2][1] == MyPair(2,6)
        @test (pl0*2).land[1][1] == MyPair(1,4)
        @test (pl0*2).land[2][1] == MyPair(2,12)

        @test (pl1==pl1) == true
        @test (pl1==pl2) == false
        @test (pl0==pl1) == false
    end

    @testset "addition" begin

        # Check adding single element

        # comutative test
        @test singular_landscape_a + singular_landscape_a == singular_landscape_a + singular_landscape_a
        @test singular_landscape_a + singular_landscape_b == singular_landscape_b + singular_landscape_a
        @test singular_landscape_a + singular_landscape_c == singular_landscape_c + singular_landscape_a
        @test singular_landscape_c + singular_landscape_d == singular_landscape_d + singular_landscape_c


        @test singular_landscape_a + singular_landscape_a == 2*singular_landscape_a
        @test singular_landscape_a + singular_landscape_b == PersistenceLandscape([[
                                                                                    MyPair(0,0),
                                                                                    MyPair(1,1),
                                                                                    MyPair(2,3),
                                                                                    MyPair(3,1),
                                                                                    MyPair(4,0)
                                                                                   ]],1)
        @test singular_landscape_a + singular_landscape_c == PersistenceLandscape([[MyPair(0, 0),
                                                                                    MyPair(1, 1),
                                                                                    MyPair(2, 1),
                                                                                    MyPair(3, 0)
                                                                                   ]],1)
        @test singular_landscape_c + singular_landscape_d == PersistenceLandscape([[MyPair(0, 0),
                                                                                    MyPair(1, 1),
                                                                                    MyPair(2, 0),
                                                                                    MyPair(3, 1),
                                                                                    MyPair(4, 0)
                                                                                   ]], 1)

        # first values innew landscape should be a unique colleciton of x vals from both components
        for land1 = [singular_landscape_a, singular_landscape_b, singular_landscape_c, singular_landscape_d]
            for land2 = [singular_landscape_a, singular_landscape_b, singular_landscape_c, singular_landscape_d]

                sum_res = land1 + land2
                unique_first_vals = unique( sort( vcat(
                                [[y.first for y in x] for x in land1.land][1],
                                [[y.first for y in x] for x in land2.land][1]
                                )))
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


end


@testset "PersistenceLandscape test on eirene results" begin
# Reproduction of figure 4 from Bernadete paper about average landscape
    x1 = 10
    x2 = x1+1
    x3 = x2+1
    x4 = x3+1
    x5 = x4+1
    x6 = x5+1
    hexa_matrix = [ 0  1  8  7  9  6;
                    1  0  2 x1 x2 x3;
                    8  2  0  3 x4 x5;
                    7 x1  3  0  4 x6;
                    9 x2 x4  4  0  5 ;
                    6 x3 x5 x6  5  0;
                    ]

    x = collect(1:45) .+ 6
    x = zeros(Int, 45) .+7
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix = [     0     1     3     5  x[1]  x[2]     3     5     4     7     5     1; # a
                        1     0     1  x[6]  x[7]  x[8]     6  x[9] x[10] x[11] x[12] x[13]; # b
                        3     1     0     1     3 x[14]     5 x[15] x[16] x[17] x[18] x[19]; # c
                        5  x[6]     1     0     1 x[20]     5 x[20] x[21] x[22] x[23] x[24]; # d
                     x[1]  x[7]     3     1     0     1     3 x[25] x[26] x[27] x[28] x[29]; # e
                     x[2]  x[8] x[14] x[20]     1     0     2 x[30] x[31] x[32] x[33] x[34]; # f
                        3     6     5     5     3     2     0     1 x[35] x[36] x[37] x[38]; # g
                        5  x[9] x[15] x[20] x[25] x[30]     1     0     1 x[39] x[40] x[41]; # h
                        4 x[10] x[16] x[21] x[26] x[31] x[35]     1     0     2 x[42] x[43]; # i
                        7 x[11] x[17] x[22] x[27] x[32] x[36] x[39]     2     0     1 x[44]; # j
                        5 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42]     1     0     1; # k
                        1 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44]     1     0; # l
                 ]


    x = collect(1:45) .+ 7
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix_modified= [
                        0     1     3     6  x[1]  x[2]     3     5     4     8     5     1; # a
                        1     0     1  x[6]  x[7]  x[8]     7  x[9] x[10] x[11] x[12] x[13]; # b
                        3     1     0     1     3 x[14]     6 x[15] x[16] x[17] x[18] x[19]; # c
                        6  x[6]     1     0     1 x[20]     6 x[20] x[21] x[22] x[23] x[24]; # d
                     x[1]  x[7]     3     1     0     1     3 x[25] x[26] x[27] x[28] x[29]; # e
                     x[2]  x[8] x[14] x[20]     1     0     2 x[30] x[31] x[32] x[33] x[34]; # f
                        3     7     6     6     3     2     0     1 x[35] x[36] x[37] x[38]; # g
                        5  x[9] x[15] x[20] x[25] x[30]     1     0     1 x[39] x[40] x[41]; # h
                        4 x[10] x[16] x[21] x[26] x[31] x[35]     1     0     2 x[42] x[43]; # i
                        8  x[11] x[17] x[22] x[27] x[32] x[36] x[39]     2     0     1 x[44]; # j
                        5 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42]     1     0     1; # k
                        1 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44]     1     0; # l
                 ]


    x = collect(1:45) .+ 22
    #                   a     b     c     d     e     f     g     h     i     j     k     l;
    fig4_matrix_modified2 = [
                        0     1     13   18  x[2]  x[3]    14    19    17  x[1]    20    10; # a
                        1     0     2  x[6]  x[7]  x[8]    23  x[9] x[10] x[11] x[12] x[13]; # b
                       13     2     0     3    15 x[14]    21 x[15] x[16] x[17] x[18] x[19]; # c
                       18  x[6]     3     0     4  x[20]   22 x[20] x[21] x[22] x[23] x[24]; # d
                     x[2]  x[7]    15     4     0     5    16 x[25] x[26] x[27] x[28] x[29]; # e
                     x[3]  x[8] x[14] x[20]     5     0    11 x[30] x[31] x[32] x[33] x[34]; # f
                       14    23    21    22    16    11     0     6 x[35] x[36] x[37] x[38]; # g
                       19  x[9] x[15] x[20] x[25] x[30]     6     0     7 x[39] x[40] x[41]; # h
                       17 x[10] x[16] x[21] x[26] x[31] x[35]     7     0    12 x[42] x[43]; # i
                     x[1] x[11] x[17] x[22] x[27] x[32] x[36] x[39]    12     0     8 x[44]; # j
                       20 x[12] x[18] x[23] x[28] x[33] x[37] x[40] x[42]     8     0     9; # k
                       10 x[13] x[19] x[24] x[29] x[34] x[38] x[41] x[43] x[44]     9     0; # l
                 ]

    # Eirene computations

    # ===-
    vertices_labels = [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
                        "m", "n", "o"]

    ord_matrices = Dict(:simpler_case => hexa_matrix,
                         :fig4 => fig4_matrix,
                         :fig4_modified => fig4_matrix_modified,
                         :fig4_modified2 => fig4_matrix_modified2,
                         )
    all_keys = [:simpler_case, :fig4, :fig4_modified, :fig4_modified2]
    C_ord_mat = Dict()

    max_B_dim = 3
    key = all_keys[3]
    # for key in all_keys
        total_points = size(ord_matrices[key], 1)

        C_ord_mat[key] = eirene(ord_matrices[key],
                                maxdim=max_B_dim,
                                model="vr",
                                pointlabels=vertices_labels[1:total_points])

        plotbarcode_pjs(C_ord_mat[key])
        selected_dim = 1
        barcodes = barcode(C_ord_mat[key], dim=selected_dim )
        bar = [MyPair(barcodes[k,1], barcodes[k,2]) for k in 1:size(barcodes,1)]
        pair_barcodes  = PersistenceBarcodes(bar, selected_dim)

        pl1 = PersistenceLandscape(pair_barcodes)
        plot_persistence_landscape(pl1)
    # end # for
end
