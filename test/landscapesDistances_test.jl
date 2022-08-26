
## ===-
@testset "Distances tests" begin
    @testset "computeDiscanceOfLandscapes test" begin
        pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

        @test computeDiscanceOfLandscapes(pl0, pl0, 0) == 0
        @test computeDiscanceOfLandscapes(pl1, pl2, 0) == Inf
        @test computeDiscanceOfLandscapes(pl2, pl3, 0) == Inf

        @test computeDiscanceOfLandscapes(pl0, pl0, 1) == 0
        @test computeDiscanceOfLandscapes(pl1, pl2, 1) == 3
        @test computeDiscanceOfLandscapes(pl2, pl3, 1) == 2
    end

    @testset "(regular) distance of landscapes" begin

    end

    @testset "max norm distance of landscapes" begin


    end
end
