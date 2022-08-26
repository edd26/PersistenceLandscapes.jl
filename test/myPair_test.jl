
@testset "MyPair construction testing" begin
    @test_throws MethodError MyPair("1", 2)

    @test my_pair.first == 1
    @test my_pair.second == 2
    @test typeof(my_pair.first) <: Float64
    @test typeof(my_pair.second) <: Float64
end

@testset "MyPair birth and death testing" begin
    a_pair1(1,1)
    a_pair2(1,2)

    @test birth(a_pair1) == 1-1
    @test birth(a_pair2) == 2-1
    @test death(a_pair1) == 1+1
    @test death(a_pair2) == 2+1
end

## ===-
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
