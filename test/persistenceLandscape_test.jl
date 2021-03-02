using Eirene

a = [MyPair(0, 3), MyPair(1, 6), MyPair(2,7)]
b = [MyPair(2, 3), MyPair(2, 4), MyPair(4,7), MyPair(3, 9)]
c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9)]

pl0 = PersistenceLandscape([[MyPair(1,2)], [MyPair(2,6)]], 1)
pl1 = PersistenceLandscape([a, b], 2)
pl2 = PersistenceLandscape([a, b, c], 4)

pl_single_element = PersistenceLandscape([[MyPair(0,2)]], 1)
pl_double_element1 = PersistenceLandscape([[MyPair(0,2), MyPair(0, 4)]], 1)
pl_double_element2 = PersistenceLandscape([[MyPair(0,2), MyPair(2, 4)]], 1)
pl_double_element3 = PersistenceLandscape([[MyPair(0,2), MyPair(3, 4)]], 1)

@testset "PersistenceLandscape constructors tests" begin

    @test typeof(pl1.land) == Vector{Vector{MyPair}}
    @test pl1.land == [a, b]
    @test pl1.land[1] == a
    @test pl1.land[2] == b

    @test pl1.land[1][1] == a[1]
    @test length(pl1.land) == 2
    @test length(pl1.land[1]) == 3
    @test length(pl1.land[2]) == 4

    @test size(pl1.land,1) == 2
    @test size(pl1.land[1],1) == 3
    @test size(pl1.land[2],1) == 4

    @test min(size(pl1.land), size(pl2.land)) == (2,)

    @test_throws BoundsError pl1.land[3]

    #move constructor tests here

end


@testset "create PersistenceLandscape from barcodes" begin
    bars1 = [MyPair(0, 3), MyPair(0, 6), MyPair(0,10)]
    bars2 = [MyPair(0, 3), MyPair(3, 6), MyPair(6,9)]
    bars3 = [MyPair(0, 4), MyPair(2, 10), MyPair(3,7), MyPair(6,14)]
    bars4 = [MyPair(2, 6), MyPair(4, 12), MyPair(5,9), MyPair(8,16)]

    target_sizes = [length(bars1), length(bars2), length(bars3)+1, length(bars4)+1]
    all_bars = [bars1, bars2, bars3, bars4]

    for (ind, bar) in enumerate(all_bars)
        barcodes = PersistenceBarcodes(bar, 1)
        pl = create_PersistenceLandscape(barcodes)

        filtered_pl = filter(x-> x.first!=Inf, pl.land[1])
        filtered_pl = filter(x-> x.first!=-Inf, filtered_pl)
        filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)

        @info filtered_pl
        @test length(filtered_pl) == target_sizes[ind]
    end

    # Check if code below does not throw errors
    barcodes = PersistenceBarcodes(bars3, 1)
    pl1 = create_PersistenceLandscape(barcodes)
    plot_persistence_landscape(pl1)

end


@testset "PersistenceLandscape operations" begin
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
        # addition is not working properly
        @test pl_single_element + pl_single_element == PersistenceLandscape([[MyPair(0, 4)]], pl_single_element.dimension)

        @test pl_single_element + pl_double_element1 == PersistenceLandscape([[MyPair(0, 4), MyPair(0, 4)]], pl_single_element.dimension)
        @test pl_single_element + pl_double_element2 == PersistenceLandscape([[MyPair(0, 4), MyPair(2, 4)]], pl_single_element.dimension)
        @test pl_single_element + pl_double_element3 == PersistenceLandscape([[MyPair(0, 4), MyPair(3, 4)]], pl_single_element.dimension)

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
    for key in all_keys
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

        pl1 = create_PersistenceLandscape(pair_barcodes)
        plot_persistence_landscape(pl1)
    end

end
