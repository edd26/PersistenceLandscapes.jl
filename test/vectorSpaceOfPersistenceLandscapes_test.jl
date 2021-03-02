a = [MyPair(0, 3), MyPair(1, 6), MyPair(2,7)]
b = [MyPair(2, 3), MyPair(2, 4), MyPair(4,7), MyPair(3, 9)]
c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf,7), MyPair(0, 9)]

pl0 = PersistenceLandscape([[MyPair(1,2)], [MyPair(2,6)]], 1)
pl1 = PersistenceLandscape([a, b], 2)
pl2 = PersistenceLandscape([a, b, c], 4)

include("VectorSpaceOfPersistenceLandscapes.jl")

@testset "Constructor for a collection of landscapes" begin

    landscpae_collection = VectorSpaceOfPersistenceLandscapes([pl1, pl2, pl2])
    average(landscpae_collection)
end
