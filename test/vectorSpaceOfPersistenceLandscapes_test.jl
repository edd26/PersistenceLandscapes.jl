# example form bernadette paper:
fig5_data_a = [MyPair(2, 9), MyPair(4, 8), MyPair(4,5), MyPair(8,10)]
fig5_bars_a = PersistenceBarcodes(fig5_data_a, 1)
fig5_pl_a = PersistenceLandscape(fig5_bars_a)

fig5_data_b = [MyPair(2, 9), MyPair(4, 8), MyPair(5,6), MyPair(7,9)]
fig5_bars_b = PersistenceBarcodes(fig5_data_b, 1)
fig5_pl_b = PersistenceLandscape(fig5_bars_b)

# debug- can not handle single element in vector

a = [MyPair(0, 3), MyPair(1, 6), MyPair(2,7)]
b = [MyPair(2, 3), MyPair(2, 4), MyPair(4,7), MyPair(3, 9)]
c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9)]
d = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9), MyPair(-Inf, 0), MyPair(0,Inf)]

pb_a = PersistenceBarcodes(a)
pb_b = PersistenceBarcodes(b)
pb_c = PersistenceBarcodes(c)
pb_d = PersistenceBarcodes(d)

pl0 = PersistenceLandscape([[MyPair(1,2)], [MyPair(2,6)]], 1)
pl1 = PersistenceLandscape([a, b], 2)
pl2 = PersistenceLandscape([a, b, c], 4)
pl3 = PersistenceLandscape([b, c], 1)

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
    # Comutative tests
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

