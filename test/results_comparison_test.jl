@testset "Compare landscaspes structures with original code results" begin
    # Average landscape computed for a single barcode
    # Original code was run on the barcodes that are used to construct pl8 and pl9
    # Following results are comparing both strucutres

    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    # ===-===-
    @testset "paris1 comparison " begin
        @test pairs1.land |> length == 3 # there 2 files generated with c version of the code
        # Lambda 0
        @test pairs1.land[1] |> length == 3
        @test pairs1.land[1][1] == MyPair(0, 0)
        @test pairs1.land[1][2] == MyPair(5, 5)
        @test pairs1.land[1][3] == MyPair(10, 0)
        # Lambda 1
        @test pairs1.land[2] |> length == 3
        @test pairs1.land[2][1] == MyPair(0, 0)
        @test pairs1.land[2][2] == MyPair(3, 3)
        @test pairs1.land[2][3] == MyPair(6, 0)
        # Lambda 2
        @test pairs1.land[3] |> length == 3
        @test pairs1.land[3][1] == MyPair(0, 0)
        @test pairs1.land[3][2] == MyPair(1.5, 1.5)
        @test pairs1.land[3][3] == MyPair(3, 0)
    end

    # ===-===-
    @testset "paris2 comparison " begin
        @test pairs2.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pairs2.land[1] |> length == 7
        @test pairs2.land[1][1] == MyPair(0, 0)
        @test pairs2.land[1][2] == MyPair(1.5, 1.5)
        @test pairs2.land[1][3] == MyPair(3, 0)
        @test pairs2.land[1][4] == MyPair(4.5, 1.5)
        @test pairs2.land[1][5] == MyPair(6, 0)
        @test pairs2.land[1][6] == MyPair(7.5, 1.5)
        @test pairs2.land[1][7] == MyPair(9, 0)
    end

    # ===-===-
    @testset "paris2 comparison " begin
        @test pairs2.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pairs2.land[1] |> length == 7
        @test pairs2.land[1][1] == MyPair(0, 0)
        @test pairs2.land[1][2] == MyPair(1.5, 1.5)
        @test pairs2.land[1][3] == MyPair(3, 0)
        @test pairs2.land[1][4] == MyPair(4.5, 1.5)
        @test pairs2.land[1][5] == MyPair(6, 0)
        @test pairs2.land[1][6] == MyPair(7.5, 1.5)
        @test pairs2.land[1][7] == MyPair(9, 0)
    end

    # ===-===-
    @testset "paris3 comparison " begin
        # While the results are the same (C++ and julia), they are not correct- broken tests are pen&paper correct and C++ incompatible
        @test pairs3.land |> length == 3 # there 2 files generated with c version of the code, while the truth is 3
        @testset "lambda 0" begin
            @test pairs3.land[1] |> length == 7
            @test pairs3.land[1][1] == MyPair(0, 0)
            @test pairs3.land[1][2] == MyPair(4, 4)
            @test pairs3.land[1][3] == MyPair(5.5, 2.5)
            @test pairs3.land[1][4] == MyPair(7, 4)
            @test pairs3.land[1][5] == MyPair(8.5, 2.5)
            @test pairs3.land[1][6] == MyPair(10, 4)
            @test pairs3.land[1][7] == MyPair(14, 0)
        end
        @testset "lambda 1" begin
            @test pairs3.land[2] |> length == 5
            @test pairs3.land[2][1] == MyPair(3, 0)
            @test pairs3.land[2][2] == MyPair(5.5, 2.5)
            @test pairs3.land[2][3] == MyPair(7, 1)
            @test pairs3.land[2][4] == MyPair(8.5, 2.5)
            @test pairs3.land[2][5] == MyPair(11, 0)

        end
        @testset "lambda 2" begin
            @test pairs3.land[3] |> length == 3
            @test pairs3.land[3][1] == MyPair(6, 0) # passing test is pen&paper result which is different from C++ version
            @test pairs3.land[3][2] == MyPair(7, 1) # passing test is pen&paper result which is different from C++ version
            @test pairs3.land[3][3] == MyPair(8, 0)
        end
    end

    # ===-===-
    @testset "paris4 comparison " begin
        # While the results are the same (C++ and julia), they are not correct!!!!
        @test_broken pairs4.land |> length == 7 # there 7 files generated with c version of the code, fixed is 6
        @testset "lambda 0" begin
            @test pairs4.land[1] |> length == 3
            @test pairs4.land[1][1] == MyPair(2, 0)
            @test pairs4.land[1][2] == MyPair(8, 6)
            @test pairs4.land[1][3] == MyPair(14, 0)
        end
        @testset "lambda 1" begin
            @test pairs4.land[2] |> length == 5
            @test pairs4.land[2][1] == MyPair(2, 0)
            @test pairs4.land[2][2] == MyPair(7, 5)
            @test pairs4.land[2][3] == MyPair(8, 4)
            @test pairs4.land[2][4] == MyPair(9, 5)
            @test pairs4.land[2][5] == MyPair(14, 0)
        end
        @testset "lambda 2" begin
            # Lambda 2
            @test pairs4.land[3] |> length == 7
            @test pairs4.land[3][1] == MyPair(2, 0)
            @test pairs4.land[3][2] == MyPair(6, 4)
            @test pairs4.land[3][3] == MyPair(7, 3)
            @test pairs4.land[3][4] == MyPair(8, 4)
            @test pairs4.land[3][5] == MyPair(9, 3)
            @test pairs4.land[3][6] == MyPair(10, 4)
            @test pairs4.land[3][7] == MyPair(14, 0)
        end
        @testset "lambda 3" begin
            @test_broken pairs4.land[4] |> length == 7 # 7 points within C results, fixed is 10 points
            @test pairs4.land[4][1] == MyPair(2, 0)
            @test pairs4.land[4][2] == MyPair(4, 2)
            @test pairs4.land[4][3] == MyPair(5, 1)
            @test_broken pairs4.land[4][4] == MyPair(8, 4) # broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[4][5] == MyPair(11, 1)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[4][6] == MyPair(12, 2)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[4][7] == MyPair(14, 0)# broken because correct with pen&paper but different from C++ version
        end
        @testset "lambda 4" begin
            @test_broken pairs4.land[5] |> length == 5 # 5 barcodes in C++ version, # broken because correct with pen&paper but different from C++ version
            @test pairs4.land[5][1] == MyPair(4, 0)
            @test_broken pairs4.land[5][2] == MyPair(7, 3)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[5][3] == MyPair(8, 2)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[5][4] == MyPair(9, 3)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[5][5] == MyPair(12, 0)# broken because correct with pen&paper but different from C++ version
        end
        @testset "lambda 5" begin
            @test_broken pairs4.land[6] |> length == 7 # 7 barcodes in C++ version # broken because correct with pen&paper but different from C++ version
            @test pairs4.land[6][1] == MyPair(4, 0)
            @test_broken pairs4.land[6][2] == MyPair(6, 2)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[6][3] == MyPair(7, 1)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[6][4] == MyPair(8, 2)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[6][5] == MyPair(9, 1)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[6][6] == MyPair(10, 2)# broken because correct with pen&paper but different from C++ version
            @test_broken pairs4.land[6][7] == MyPair(12, 0)# broken because correct with pen&paper but different from C++ version
        end
        if pairs4.land |> length > 6
            # this prevents from error indexing error when test on len fails
            @testset "lambda 6" begin
                @test_broken pairs4.land[7] |> length == 7
                @test pairs4.land[7][1] == MyPair(4, 0)
                @test pairs4.land[7][2] == MyPair(5, 1)
                @test pairs4.land[7][3] == MyPair(6, 0)
                @test_broken pairs4.land[7][4] == MyPair(8, 2)
                @test_broken pairs4.land[7][5] == MyPair(10, 2)
                @test_broken pairs4.land[7][6] == MyPair(11, 1)
                @test_broken pairs4.land[7][7] == MyPair(12, 0)
            end
            @testset "lambda 7" begin
                @test_broken pairs4.land[8] |> length == 5
                if pairs4.land[8] |> length == 5
                    @test pairs4.land[8][1] == MyPair(6, 0)
                    @test pairs4.land[8][2] == MyPair(7, 1)
                    @test pairs4.land[8][3] == MyPair(8, 0)
                    @test pairs4.land[8][4] == MyPair(9, 1)
                    @test pairs4.land[8][5] == MyPair(10, 0)
                end
            end
        end
    end
    #
    # ===-===-
    @testset "paris5 comparison " begin
        # While the results are the same (C++ and julia), they are not correct!!!!
        @test pairs5.land |> length == 2 # two barcodes are repeated, and there should be 2 landsapes
        @testset "lambda 0" begin
            @test pairs5.land[1] |> length == 3
            @test pairs5.land[1][1] == MyPair(0, 0)
            @test pairs5.land[1][2] == MyPair(3, 3)
            @test pairs5.land[1][3] == MyPair(6, 0)
        end
        @testset "lambda 1" begin
            @test pairs5.land[2] |> length == 3
            @test pairs5.land[2][1] == MyPair(0, 0)
            @test pairs5.land[2][2] == MyPair(1.5, 1.5)
            @test pairs5.land[2][3] == MyPair(3, 0)
        end
    end

    # ===-===-
    # Pl8
    @testset "PL8 comparison " begin

        #  [MyPair(2, 6), MyPair(2, 4), MyPair(4, 6)],
        @test pl8.land |> length == 2 # there 2 files generated with c version of the code

        # Lambda 0
        @test pl8.land[1] |> length == 3
        @test pl8.land[1][1] == MyPair(2, 0)
        @test pl8.land[1][2] == MyPair(4, 2)
        @test pl8.land[1][3] == MyPair(6, 0)
        # Lambda 1
        @test pl8.land[2] |> length == 5
        @test pl8.land[2][1] == MyPair(2, 0)
        @test pl8.land[2][2] == MyPair(3, 1)
        @test pl8.land[2][3] == MyPair(4, 0)
        @test pl8.land[2][4] == MyPair(5, 1)
        @test pl8.land[2][5] == MyPair(6, 0)
    end

    # ===-===-
    # Pl9
    @testset "PL9 comparison " begin
        @test pl9.land |> length == 4 # there 4 files generated with c version of the code

        # Lambda 0
        @test pl9.land[1] |> length == 7
        @test pl9.land[1][1] == MyPair(0, 0)
        @test pl9.land[1][2] == MyPair(3, 3)
        @test pl9.land[1][3] == MyPair(3.5, 2.5)
        @test pl9.land[1][4] == MyPair(4, 3)
        @test pl9.land[1][5] == MyPair(5.5, 1.5)
        @test pl9.land[1][6] == MyPair(6, 2)
        @test pl9.land[1][7] == MyPair(8, 0)
        # Lambda 1
        @test pl9.land[2] |> length == 5
        @test pl9.land[2][1] == MyPair(1, 0)
        @test pl9.land[2][2] == MyPair(3.5, 2.5)
        @test pl9.land[2][3] == MyPair(5, 1)
        @test pl9.land[2][4] == MyPair(5.5, 1.5)
        @test pl9.land[2][5] == MyPair(7, 0)
        # Lambda 2
        @test pl9.land[3] |> length == 5
        @test pl9.land[3][1] == MyPair(3, 0)
        @test pl9.land[3][2] == MyPair(4, 1)
        @test pl9.land[3][3] == MyPair(4.5, 0.5)
        @test pl9.land[3][4] == MyPair(5, 1)
        @test pl9.land[3][5] == MyPair(6, 0)
        # Lambda 3
        @test pl9.land[4] |> length == 3
        @test pl9.land[4][1] == MyPair(4, 0)
        @test pl9.land[4][2] == MyPair(4.5, 0.5)
        @test pl9.land[4][3] == MyPair(5, 0)
    end
end


#
@testset "Compare landscaspes averaging with original code results" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    @testset "average of 2 x same structure" begin
        avg_land1 = [pairs1, pairs1] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land1.land |> length == 3
        @test avg_land1.land[1] |> length == 3
        @test avg_land1.land[1][1] == MyPair(0, 0)
        @test avg_land1.land[1][2] == MyPair(5, 10) # this is the same as C++, but might be wrong
        @test avg_land1.land[1][3] == MyPair(10, 0)

        @test avg_land1.land[2] |> length == 3
        @test avg_land1.land[2][1] == MyPair(0, 0)
        @test avg_land1.land[2][2] == MyPair(3, 6)
        @test avg_land1.land[2][3] == MyPair(6, 0)

        @test avg_land1.land[3] |> length == 3
        @test avg_land1.land[3][1] == MyPair(0, 0)
        @test avg_land1.land[3][2] == MyPair(1.5, 3)
        @test avg_land1.land[3][3] == MyPair(3, 0)
    end

    @testset "average of non-overlapping structures" begin
        avg_land2 = [pl2, pl3] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land2.land |> length == 1
        @test avg_land2.land[1] |> length == 5
        @test avg_land2.land[1][1] == MyPair(0, 0)
        @test avg_land2.land[1][2] == MyPair(1, 1)
        @test avg_land2.land[1][3] == MyPair(2, 0)
        @test avg_land2.land[1][4] == MyPair(3, 1)
        @test avg_land2.land[1][5] == MyPair(4, 0)
    end

    @testset "average of overlapping structures" begin
        avg_land3 = [pl0, pl1] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land3.land |> length == 1
        @test avg_land3.land[1] |> length == 5
        @test avg_land3.land[1][1] == MyPair(0, 0)
        @test avg_land3.land[1][2] == MyPair(1, 1)
        @test avg_land3.land[1][3] == MyPair(2, 3)
        @test avg_land3.land[1][4] == MyPair(3, 1)
        @test avg_land3.land[1][5] == MyPair(4, 0)
    end

    @testset "average of 2-layered structure" begin
        avg_land4 = [pl6, pl7] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land4.land |> length == 2
        # lambda 0
        @test avg_land4.land[1] |> length == 3
        @test avg_land4.land[1][1] == MyPair(0, 0)
        @test avg_land4.land[1][2] == MyPair(2, 4)
        @test avg_land4.land[1][3] == MyPair(4, 0)
        # lambda 1
        @test avg_land4.land[2] |> length == 4
        @test avg_land4.land[2][1] == MyPair(0, 0)
        @test avg_land4.land[2][2] == MyPair(1, 1)
        @test avg_land4.land[2][3] == MyPair(2, 1)
        @test avg_land4.land[2][4] == MyPair(3, 0)
    end

    @testset "average of complex structure" begin
        avg_land5 = [pl2, pl9] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land5.land |> length == 4
        # lambda 0
        @test avg_land5.land[1] |> length == 9
        @test avg_land5.land[1][1] == MyPair(0, 0)
        @test avg_land5.land[1][2] == MyPair(1, 2)
        @test avg_land5.land[1][3] == MyPair(2, 2)
        @test avg_land5.land[1][4] == MyPair(3, 3)
        @test avg_land5.land[1][5] == MyPair(3.5, 2.5)
        @test avg_land5.land[1][6] == MyPair(4, 3)
        @test avg_land5.land[1][7] == MyPair(5.5, 1.5)
        @test avg_land5.land[1][8] == MyPair(6, 2)
        @test avg_land5.land[1][9] == MyPair(8, 0)
        # lambda 1
        @test avg_land5.land[2] |> length == 5
        @test avg_land5.land[2][1] == MyPair(1, 0)
        @test avg_land5.land[2][2] == MyPair(3.5, 2.5)
        @test avg_land5.land[2][3] == MyPair(5, 1)
        @test avg_land5.land[2][4] == MyPair(5.5, 1.5)
        @test avg_land5.land[2][5] == MyPair(7, 0)
        # lambda 2
        @test avg_land5.land[3] |> length == 5
        @test avg_land5.land[3][1] == MyPair(3, 0)
        @test avg_land5.land[3][2] == MyPair(4, 1)
        @test avg_land5.land[3][3] == MyPair(4.5, 0.5)
        @test avg_land5.land[3][4] == MyPair(5, 1)
        @test avg_land5.land[3][5] == MyPair(6, 0)
        # lambda 3
        @test avg_land5.land[4] |> length == 3
        @test avg_land5.land[4][1] == MyPair(4, 0)
        @test avg_land5.land[4][2] == MyPair(4.5, 0.5)
        @test avg_land5.land[4][3] == MyPair(5, 0)
    end

    @testset "average of more than 2 structures" begin
        avg_land6 = [pl1, pl3, pl4] |> VectorSpaceOfPersistenceLandscapes |> average
        @test avg_land6.land |> length == 1
        # lambda 0
        @test avg_land6.land[1] |> length == 7
        @test avg_land6.land[1][1] == MyPair(0, 0)
        @test avg_land6.land[1][2] == MyPair(2, 4)
        @test avg_land6.land[1][3] == MyPair(3, 3)
        @test avg_land6.land[1][4] == MyPair(4, 0)
        @test avg_land6.land[1][5] == MyPair(5, 0)
        @test avg_land6.land[1][6] == MyPair(6, 1)
        @test avg_land6.land[1][7] == MyPair(7, 0)
    end

end

##

@testset "Compare landscaspes subtraction with original code results" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    @testset "distance of 2 x same structure" begin
        p1_diff = pairs1 - pairs1
        @test p1_diff.land |> length == 3 # there 2 files generated with c version of the code
        # Lambda 0
        @test p1_diff.land[1] |> length == 3
        @test p1_diff.land[1][1] == MyPair(0, 0)
        @test p1_diff.land[1][2] == MyPair(5, 0)
        @test p1_diff.land[1][3] == MyPair(10, 0)
        # Lambda 1
        @test p1_diff.land[2] |> length == 3
        @test p1_diff.land[2][1] == MyPair(0, 0)
        @test p1_diff.land[2][2] == MyPair(3, 0)
        @test p1_diff.land[2][3] == MyPair(6, 0)
        # Lambda 2
        @test p1_diff.land[3] |> length == 3
        @test p1_diff.land[3][1] == MyPair(0, 0)
        @test p1_diff.land[3][2] == MyPair(1.5, 0)
        @test p1_diff.land[3][3] == MyPair(3, 0)
    end

    @testset "distance of non-overlapping structures" begin
        pl23_diff = pl2 - pl3
        @test pl23_diff.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl23_diff.land[1] |> length == 5
        @test pl23_diff.land[1][1] == MyPair(0, 0)
        @test pl23_diff.land[1][2] == MyPair(1, 1)
        @test pl23_diff.land[1][3] == MyPair(2, 0)
        @test pl23_diff.land[1][4] == MyPair(3, -1)
        @test pl23_diff.land[1][5] == MyPair(4, 0)
    end

    @testset "distance of overlapping structures" begin
        pl01_diff = pl0 - pl1
        @test pl01_diff.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl01_diff.land[1] |> length == 5
        @test pl01_diff.land[1][1] == MyPair(0, 0)
        @test pl01_diff.land[1][2] == MyPair(1, -1)
        @test pl01_diff.land[1][3] == MyPair(2, -1)
        @test pl01_diff.land[1][4] == MyPair(3, -1)
        @test pl01_diff.land[1][5] == MyPair(4, 0)
    end

    @testset "distance of 2-layered structure" begin
        pl67_diff = pl6 - pl7
        @test pl67_diff.land |> length == 2 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl67_diff.land[1] |> length == 3
        @test pl67_diff.land[1][1] == MyPair(0, 0)
        @test pl67_diff.land[1][2] == MyPair(2, 0)
        @test pl67_diff.land[1][3] == MyPair(4, 0)
        # Lambda 1
        @test pl67_diff.land[2] |> length == 4
        @test pl67_diff.land[2][1] == MyPair(0, 0)
        @test pl67_diff.land[2][2] == MyPair(1, -1)
        @test pl67_diff.land[2][3] == MyPair(2, 1)
        @test pl67_diff.land[2][4] == MyPair(3, 0)
    end

    @testset "distance of complex structure" begin
        pl29_diff = pl2 - pl9
        @test pl29_diff.land |> length == 4 # there 4 files generated with c version of the code

        # Lambda 0
        @test pl29_diff.land[1] |> length == 9
        @test pl29_diff.land[1][1] == MyPair(0, 0)
        @test pl29_diff.land[1][2] == MyPair(1, 0)
        @test pl29_diff.land[1][3] == MyPair(2, -2)
        @test pl29_diff.land[1][4] == MyPair(3, -3)
        @test pl29_diff.land[1][5] == MyPair(3.5, -2.5)
        @test pl29_diff.land[1][6] == MyPair(4, -3)
        @test pl29_diff.land[1][7] == MyPair(5.5, -1.5)
        @test pl29_diff.land[1][8] == MyPair(6, -2)
        @test pl29_diff.land[1][9] == MyPair(8, 0)
        # Lambda 1
        @test pl29_diff.land[2] |> length == 5
        @test pl29_diff.land[2][1] == MyPair(1, 0)
        @test pl29_diff.land[2][2] == MyPair(3.5, -2.5)
        @test pl29_diff.land[2][3] == MyPair(5, -1)
        @test pl29_diff.land[2][4] == MyPair(5.5, -1.5)
        @test pl29_diff.land[2][5] == MyPair(7, 0)
        # Lambda 2
        @test pl29_diff.land[3] |> length == 5
        @test pl29_diff.land[3][1] == MyPair(3, 0)
        @test pl29_diff.land[3][2] == MyPair(4, -1)
        @test pl29_diff.land[3][3] == MyPair(4.5, -0.5)
        @test pl29_diff.land[3][4] == MyPair(5, -1)
        @test pl29_diff.land[3][5] == MyPair(6, 0)
        # Lambda 3
        @test pl29_diff.land[4] |> length == 3
        @test pl29_diff.land[4][1] == MyPair(4, 0)
        @test pl29_diff.land[4][2] == MyPair(4.5, -0.5)
        @test pl29_diff.land[4][3] == MyPair(5, 0)
    end
end

##
@testset "Compare landscaspes absolute value with original code results" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    @testset "distance of 2 x same structure" begin
        p1_abs = abs_pl(pairs1 - pairs1)
        @test p1_abs.land |> length == 3 # there 2 files generated with c version of the code
        # Lambda 0
        @test p1_abs.land[1] |> length == 3
        @test p1_abs.land[1][1] == MyPair(0, 0)
        @test p1_abs.land[1][2] == MyPair(5, 0)
        @test p1_abs.land[1][3] == MyPair(10, 0)
        # Lambda 1
        @test p1_abs.land[2] |> length == 3
        @test p1_abs.land[2][1] == MyPair(0, 0)
        @test p1_abs.land[2][2] == MyPair(3, 0)
        @test p1_abs.land[2][3] == MyPair(6, 0)
        # Lambda 2
        @test p1_abs.land[3] |> length == 3
        @test p1_abs.land[3][1] == MyPair(0, 0)
        @test p1_abs.land[3][2] == MyPair(1.5, 0)
        @test p1_abs.land[3][3] == MyPair(3, 0)
    end

    @testset "distance of non-overlapping structures" begin
        pl23_abs = abs_pl(pl2 - pl3)
        @test pl23_abs.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl23_abs.land[1] |> length == 5
        @test pl23_abs.land[1][1] == MyPair(0, 0)
        @test pl23_abs.land[1][2] == MyPair(1, 1)
        @test pl23_abs.land[1][3] == MyPair(2, 0)
        @test pl23_abs.land[1][4] == MyPair(3, 1)
        @test pl23_abs.land[1][5] == MyPair(4, 0)
    end

    @testset "distance of overlapping structures" begin
        pl01_abs = abs_pl(pl0 - pl1)
        @test pl01_abs.land |> length == 1 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl01_abs.land[1] |> length == 5
        @test pl01_abs.land[1][1] == MyPair(0, 0)
        @test pl01_abs.land[1][2] == MyPair(1, 1)
        @test pl01_abs.land[1][3] == MyPair(2, 1)
        @test pl01_abs.land[1][4] == MyPair(3, 1)
        @test pl01_abs.land[1][5] == MyPair(4, 0)
    end

    ##
    @testset "distance of 2-layered structure" begin
        pl67_abs = abs_pl(pl6 - pl7)
        @test pl67_abs.land |> length == 2 # there 2 files generated with c version of the code
        # Lambda 0
        @test pl67_abs.land[1] |> length == 3
        @test pl67_abs.land[1][1] == MyPair(0, 0)
        @test pl67_abs.land[1][2] == MyPair(2, 0)
        @test pl67_abs.land[1][3] == MyPair(4, 0)
        # Lambda 1
        @test pl67_abs.land[2] |> length == 5
        @test pl67_abs.land[2][1] == MyPair(0, 0)
        @test pl67_abs.land[2][2] == MyPair(1, 1)
        @test pl67_abs.land[2][3] == MyPair(1.5, 0)
        @test pl67_abs.land[2][4] == MyPair(2, 1)
    end
    ##

    @testset "distance of complex structure" begin
        pl29_abs = abs_pl(pl2 - pl9)
        @test pl29_abs.land |> length == 4 # there 4 files generated with c version of the code

        # Lambda 0
        @test pl29_abs.land[1] |> length == 9
        @test pl29_abs.land[1][1] == MyPair(0, 0)
        @test pl29_abs.land[1][2] == MyPair(1, 0)
        @test pl29_abs.land[1][3] == MyPair(2, 2)
        @test pl29_abs.land[1][4] == MyPair(3, 3)
        @test pl29_abs.land[1][5] == MyPair(3.5, 2.5)
        @test pl29_abs.land[1][6] == MyPair(4, 3)
        @test pl29_abs.land[1][7] == MyPair(5.5, 1.5)
        @test pl29_abs.land[1][8] == MyPair(6, 2)
        @test pl29_abs.land[1][9] == MyPair(8, 0)
        # Lambda 1
        @test pl29_abs.land[2] |> length == 5
        @test pl29_abs.land[2][1] == MyPair(1, 0)
        @test pl29_abs.land[2][2] == MyPair(3.5, 2.5)
        @test pl29_abs.land[2][3] == MyPair(5, 1)
        @test pl29_abs.land[2][4] == MyPair(5.5, 1.5)
        @test pl29_abs.land[2][5] == MyPair(7, 0)
        # Lambda 2
        @test pl29_abs.land[3] |> length == 5
        @test pl29_abs.land[3][1] == MyPair(3, 0)
        @test pl29_abs.land[3][2] == MyPair(4, 1)
        @test pl29_abs.land[3][3] == MyPair(4.5, 0.5)
        @test pl29_abs.land[3][4] == MyPair(5, 1)
        @test pl29_abs.land[3][5] == MyPair(6, 0)
        # Lambda 3
        @test pl29_abs.land[4] |> length == 3
        @test pl29_abs.land[4][1] == MyPair(4, 0)
        @test pl29_abs.land[4][2] == MyPair(4.5, 0.5)
        @test pl29_abs.land[4][3] == MyPair(5, 0)
    end
    ##
end
##

@testset "Compare landscaspes distances with original code results" begin
    pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()
    pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

    @testset "distance of 2 x same structure" begin
        @test computeDiscanceOfLandscapes(pairs1, pairs1, 1) == 0
        @test computeDiscanceOfLandscapes(pairs1, pairs1, 2) == 0
        @test computeDiscanceOfLandscapes(pairs1, pairs1, 0) == Inf
    end

    @testset "distance of non-overlapping structures" begin
        @test computeDiscanceOfLandscapes(pl2, pl3, 1) == 2
        @test isapprox(computeDiscanceOfLandscapes(pl2, pl3, 2), 1.547; atol=1.0e-0)
        @test computeDiscanceOfLandscapes(pl2, pl3, 0) == Inf
    end

    @testset "distance of overlapping structures" begin
        @test computeDiscanceOfLandscapes(pl0, pl1, 1) == 3
        @test isapprox(computeDiscanceOfLandscapes(pl0, pl1, 2), 1.63299; atol=1.0e-5)
        @test computeDiscanceOfLandscapes(pl0, pl1, 0) == Inf
    end

    @testset "distance of 2-layered structure" begin
        @test computeDiscanceOfLandscapes(pl6, pl7, 1) == 1.5
        @test computeDiscanceOfLandscapes(pl6, pl7, 2) == 1
        @test computeDiscanceOfLandscapes(pl6, pl7, 0) == Inf
    end

    @testset "distance of complex structure" begin
        @test computeDiscanceOfLandscapes(pl2, pl9, 1) == 22
        @test isapprox(computeDiscanceOfLandscapes(pl2, pl9, 2), 6.37704; atol=1.0e-5)
        @test computeDiscanceOfLandscapes(pl2, pl9, 0) == Inf
    end
end
