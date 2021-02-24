a = [MyPair(0, 3), MyPair(1, 6), MyPair(2,7)]
b = [MyPair(2, 3), MyPair(2, 4), MyPair(4,7), MyPair(3, 9)]
c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9)]

pl0 = PersistenceLandscape([[MyPair(1,2)], [MyPair(2,6)]], 1)
pl1 = PersistenceLandscape([a, b], 2)
pl2 = PersistenceLandscape([a, b, c], 4)

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

    for (ind, bar) in enumerate([bars1, bars2, bars3, bars4])
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


