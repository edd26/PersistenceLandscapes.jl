@testset "MyPair construction testing" begin
    @test_throws MethodError MyPair("1", 2)

    @test my_pair.first == 1
    @test my_pair.second == 2
    @test typeof(my_pair.first) <: Float64
    @test typeof(my_pair.second) <: Float64
end

@testset "MyPair birth and death testing" begin
    a_pair1 = MyPair(1,1)
    a_pair2 = MyPair(2,1)

    @test birth(a_pair1) == 1-1
    @test birth(a_pair2) == 2-1
    @test death(a_pair1) == 1+1
    @test death(a_pair2) == 2+1
end

@testset "functionValue testing" begin
    line1_point1 = MyPair(0,1)
    line1_point2 = MyPair(1,2)
    @test functionValue(line1_point1, line1_point2, 0.) == 1
    @test functionValue(line1_point1, line1_point2, 1.) == 2


    line2_point1 = MyPair(0,0)
    line2_point2 = MyPair(4,8)
    @test functionValue(line2_point1, line2_point2, 0.) == 0
    @test functionValue(line2_point1, line2_point2, 4.) == 8
    @test functionValue(line2_point1, line2_point2, 2.) == 4

    # Error throw tests
    @test_throws ArgumentError functionValue(line1_point1, line1_point1, 1.)
    @test_throws ArgumentError functionValue(MyPair(0,2), MyPair(0,3), 1.)
end

@testset "findZeroOfALineSegmentBetweenThoseTwoPoints testing" begin
    line1_point1 = MyPair(1,2)
    line1_point2 = MyPair(-2,-1)
    @test findZeroOfALineSegmentBetweenThoseTwoPoints(line1_point1, line1_point2) == -1
    @test findZeroOfALineSegmentBetweenThoseTwoPoints(line1_point1, line1_point2) ==
        findZeroOfALineSegmentBetweenThoseTwoPoints(line1_point2, line1_point1)

    line2_point1 = MyPair(-4,-8)
    line2_point2 = MyPair(4,8)
    @test findZeroOfALineSegmentBetweenThoseTwoPoints(line2_point1, line2_point2) == 0
    @test findZeroOfALineSegmentBetweenThoseTwoPoints(line2_point1, line2_point2) ==
        findZeroOfALineSegmentBetweenThoseTwoPoints(line2_point2, line2_point1)
end

@testset "compareMyPairs tests" begin
    f1 = MyPair(1, 2)
    f2 = MyPair(2, 2)
    f3 = MyPair(3, 2)

    s1 = MyPair(1, 1)
    s2 = MyPair(1, 2)
    s3 = MyPair(1, 3)
    s4 = MyPair(4, 1)
    s5 = MyPair(4, 2)

    @test !compareMyPairs(f1, s1) # return false because all s1 less
    @test !compareMyPairs(f1, s2) # return false because equal
    @test compareMyPairs(f1, s3) #return positive because s3.second

    @test !compareMyPairs(f2, s1) # return false because all s1 less
    @test !compareMyPairs(f3, s1) # return false because all s1 less

    @test !compareMyPairs(f2, s2) # return false because all s1 less
    @test !compareMyPairs(f3, s2) # return false because all s1 less

    @test !compareMyPairs(f2, s3) # return false due to 2nd if
    @test !compareMyPairs(f3, s3) # return false due to 2nd if

    @test compareMyPairs(f1, s4) # first condition positive
    @test compareMyPairs(f2, s4) # first condition positive
    @test compareMyPairs(f3, s4) # first condition positive

    @test compareMyPairs(f1, s5) # first condition positive
    @test compareMyPairs(f2, s5) # first condition positive
    @test compareMyPairs(f3, s5) # first condition positive
end
