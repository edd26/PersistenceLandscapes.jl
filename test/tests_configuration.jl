my_pair = MyPair(1, 2)
my_pair1 = my_pair
my_pair2 = MyPair(1, 3)
my_pair3 = MyPair(3, 7)
my_pair4 = MyPair(6, 7)
my_persi_barcode = PersistenceBarcodes([my_pair], 2)
my_persi_barcode2 = PersistenceBarcodes([my_pair,
        my_pair1,
        my_pair2,
        my_pair3,
        my_pair4], 2)
my_persi_barcode3 = PersistenceBarcodes([my_pair,
        my_pair1,
        my_pair3,
        my_pair3,
        my_pair4], 2)


negative_inf = MyPair(-Inf, 0)
positive_inf = MyPair(0, Inf)

# pb_a = [MyPair(0, 3), MyPair(1, 6), MyPair(2, 7)] |> PersistenceBarcodes
# pb_b = [MyPair(2, 3), MyPair(2, 4), MyPair(4, 7), MyPair(3, 9)] |> PersistenceBarcodes
# pb_c = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf, 7), MyPair(0, 9)] |> PersistenceBarcodes
# pb_d = [MyPair(0, 3), MyPair(2, Inf), MyPair(-Inf, 7), MyPair(0, 9), MyPair(-Inf, 0), MyPair(0, Inf)] |> PersistenceBarcodes

# pl0 = PersistenceLandscape([[MyPair(1, 2)], [MyPair(2, 6)]], 1)
# pl1 = PersistenceLandscape([a, b], 2)
# pl2 = PersistenceLandscape([a, b, c], 4)
# pl3 = PersistenceLandscape([b, c], 1)

# pl_single_element1 = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2)]), 1)
# pl_single_element2 = PersistenceLandscape(PersistenceBarcodes([MyPair(2, 4)]), 1)
# pl_single_element3 = PersistenceLandscape(PersistenceBarcodes([MyPair(3, 4)]), 1)
# pl_single_element4 = PersistenceLandscape(PersistenceBarcodes([MyPair(4, 1)]), 1)

# pl_double_element1 = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2), MyPair(0, 4)]), 1)
# pl_double_element2 = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2), MyPair(2, 4)]), 1)
# pl_double_element3 = PersistenceLandscape(PersistenceBarcodes([MyPair(0, 2), MyPair(3, 4)]), 1)

negative_inf = MyPair(-Inf, 0)
positive_inf = MyPair(0, Inf)

# fig1_data = [MyPair(0, 4), MyPair(2, 10), MyPair(3, 7), MyPair(6, 14)]
# fig1_bars = PersistenceBarcodes(fig1_data, 1)
# fig1_pl = PersistenceLandscape(fig1_bars)

# example form bernadette paper:
fig5_data_a = [MyPair(2, 9), MyPair(4, 8), MyPair(4, 5), MyPair(8, 10)]
fig5_bars_a = PersistenceBarcodes(fig5_data_a, 1)
fig5_pl_a = PersistenceLandscape(fig5_bars_a)

fig5_data_b = [MyPair(2, 9), MyPair(4, 8), MyPair(5, 6), MyPair(7, 9)]
fig5_bars_b = PersistenceBarcodes(fig5_data_b, 1)
fig5_pl_b = PersistenceLandscape(fig5_bars_b)


generate_testing_lanscapes() = map(
    x -> x |> PersistenceBarcodes |> PersistenceLandscape,
    [
        [MyPair(1, 3)], # P0
        [MyPair(0, 4)], # P1
        [MyPair(0, 2)], # P2
        [MyPair(2, 4)], # P3
        [MyPair(0, 4), MyPair(5, 7)], # P4
        [MyPair(0, 2), MyPair(2, 4)], # P5
        [MyPair(1, 3), MyPair(0, 4)], # P6
        [MyPair(0, 2), MyPair(0, 4)], # P7
        [MyPair(2, 6), MyPair(2, 4), MyPair(4, 6)], # P8
        [MyPair(0, 6), MyPair(1, 7), MyPair(4, 8), MyPair(3, 5)], # P9
    ],
)
generate_testing_pairs() = [
    # 3 piramids within each other
    [MyPair(0, 3), MyPair(0, 6), MyPair(0, 10)],
    # 3 consecutive pyramids
    [MyPair(0, 3), MyPair(3, 6), MyPair(6, 9)],
    # Pyramid at the crossing of highe lvl pyramids
    [MyPair(0, 8), MyPair(3, 11), MyPair(3, 8), MyPair(6, 14)],
    # Layers of crossing barcodes
    [# layer 1 of barcodes
        MyPair(2, 6),
        MyPair(4, 8),
        MyPair(6, 10),
        MyPair(8, 12),
        MyPair(10, 14),
        # layer 2 of barcodes
        MyPair(2, 10),
        MyPair(4, 12),
        MyPair(8, 14),
        #
        # layer 3 of barcodes peak split
        MyPair(2, 12),
        MyPair(4, 14),

        # layer 4 of barcodes- peak
        MyPair(2, 14),
    ], # pyramids overlapping with crossings
    # barcodes repetition
    [MyPair(0, 3), MyPair(0, 6), MyPair(0, 3)],
]
