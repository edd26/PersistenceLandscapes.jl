a = [MyPair(0, 3), MyPair(1, 6), MyPair(2,7)]
b = [MyPair(2, 3), MyPair(2, 4), MyPair(4,7), MyPair(3, 9)]
c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9)]

pl0 = PersistenceLandscape([[MyPair(1,2)], [MyPair(2,6)]], 1)
pl1 = PersistenceLandscape([a, b], 2)
pl2 = PersistenceLandscape([a, b, c], 4)

pl_most_basic = PersistenceLandscape([[MyPair(0,2)]], 1)
# pl_most_basic = PersistenceLandscape([[MyPair(0,2)], MyPair(0,2)], 1)

# it has to be checked what is wrong in case the dim is not given for the constructor of PersistenceLandscape
# pl_most_basic = PersistenceLandscape([MyPair(0,2), MyPair(0,2)])


# debug- can not handle single element in vector


@testset "Constructor for a collection of landscapes" begin

    # landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl1, pl2, pl2])
    landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl_most_basic, pl_most_basic])
    average(landscpae_collection)
    # the result is not correct- it gives only the bottom border, not full average
end
