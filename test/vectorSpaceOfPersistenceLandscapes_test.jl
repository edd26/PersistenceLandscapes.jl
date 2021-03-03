# example form bernadette paper:
fig5_data_a = [MyPair(2, 9), MyPair(4, 8), MyPair(4,5), MyPair(8,10)]
fig5_bars_a = PersistenceBarcodes(fig5_data_a, 1)
fig5_pl_a = PersistenceLandscape(fig5_bars_a)

fig5_data_b = [MyPair(2, 9), MyPair(4, 8), MyPair(5,6), MyPair(7,9)]
fig5_bars_b = PersistenceBarcodes(fig5_data_b, 1)
fig5_pl_b = PersistenceLandscape(fig5_bars_b)

# debug- can not handle single element in vector


@testset "Constructor for a collection of landscapes" begin

    # landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl1, pl2, pl2])
    # landscpae_collection = VectorSpaceOfPersistenceLandscapes([fig5_pl_a, fig5_pl_b])
    # average(landscpae_collection)
    # the result is not correct- it gives only the bottom border, not full average
end
