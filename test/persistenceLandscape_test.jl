a = [MyPair(1, 3), MyPair(1, 6), MyPair(2,7)]
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


@testset "create PersistenceLandscpae from barcodes"


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
