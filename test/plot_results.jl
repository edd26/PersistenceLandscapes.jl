#=
Get plots for basic structures. Compare results for this version and plots obtained for previous version
=#
version_name = "fixed2"
version_name = "newest"
version_name = "old"

# # Newest:
using PersistenceLandscapes

# include("tests_configuration.jl")
## ===-===-
using Plots

## ===-
function plot_bd_diagram(barcodes::Vector; dims=1:size(barcodes, 2),
    normilised_diagonal::Bool=false,
    alpha=0.4,
    kwargs...)

    plot_ref = plot(; xlims=(0, 1), ylims=(0, 1))# kwargs...)
    # Add diagonal
    if normilised_diagonal
        max_coord = 1
    else
        max_x = max([k for k in vcat([barcodes[d][:, 1] for (d, dim) in dims |> enumerate]...) if !isinf(k)]...)
        max_y = max([k for k in vcat([barcodes[d][:, 2] for (d, dim) in dims |> enumerate]...) if !isinf(k)]...)
        max_coord = max(max_x, max_y)
    end

    scaling_factor = 1.05
    min_val = -0.05
    plot!([0, scaling_factor * max_coord], [0, scaling_factor * max_coord], label="", aspectratio=1)
    xlims!(min_val, scaling_factor * max_coord)
    ylims!(min_val, scaling_factor * max_coord)

    for (p, dim) in enumerate(dims)
        my_vec = barcodes[p]

        args = (
            label="β$(dim)",
            aspect_ratio=1,
            size=(600, 600),
            legend=:bottomright,
            framestyle=:origin,
            alpha=alpha,
            kwargs...)

        plot!(my_vec[:, 1], my_vec[:, 2], seriestype=:scatter; args...)
    end

    xlabel!("birth")
    ylabel!("death")

    return plot_ref
end

function plot_barcodes(barcodes::Vector; dim_range=1:1,
    sort_by_birth::Bool=true,
    alpha::Float64=1.0,
    kwargs...)

    plot_ref = plot()
    # barcodes = all_barcodes_geom
    min_dim, max_dim = dim_range[1], dim_range[end]
    total_dims = length(dim_range)

    lw = 8

    dims_indices = 1:length(min_dim:max_dim)
    all_sizes = [size(barcodes[k], 1) for k = dims_indices]
    ranges_sums = vcat(0, [sum(all_sizes[1:k]) for k = dims_indices])
    y_val_ranges = [ranges_sums[k]+1:ranges_sums[k+1] for k = dims_indices]

    if total_dims == 1
        colors_set = [palette(:roma, 2)[1]]
    else
        colors_set = palette(:roma, length(total_dims))
    end

    if sort_by_birth
        for (dim_index, dim) = enumerate(min_dim:max_dim)
            if dim == 0
                sort!(barcodes[dim_index], dims=1)
            else
                sort!(barcodes[dim_index], dims=1)
            end
        end
    end

    total_cycles = sum([size(barcodes[k], 1) for (k, dim) in enumerate(min_dim:max_dim)])
    for (p, dim) = enumerate(min_dim:max_dim)# 1:(max_dim) #TODO ths can not be starting from min_dim, because it may be 0
        b = barcodes[p][:, :]

        # if dim == 0
        #     b = sort(b, dims=1)
        # end

        total_bars = size(b, 1)
        y_vals = [[k, k] for k in y_val_ranges[p]]
        lc = colors_set[p]
        for k = 1:total_bars
            # TODO change label to empty one
            plot!(b[k, :], y_vals[k]; label="",
                lc=lc,
                alpha=alpha
            )
        end
    end

    ylims!(0, total_cycles + 2)

    return plot_ref
end

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
        MyPair(6, 14),
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

## ===-===-
bar0 = [1 3] # P0
bar1 = [0 4] # P1
bar2 = [0 2] # P2
bar3 = [2 4] # P3
bar4 = [0 4; 5 7] # P4
bar5 = [0 2; 2 4] # P5
bar6 = [1 3; 0 4] # P6
bar7 = [0 2; 0 4] # P7
bar8 = [2 6; 2 4; 4 6] # P8
bar9 = [0 6; 1 7; 4 8; 3 5] # P9
pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9 = generate_testing_lanscapes()

## ===-
lands_vec = [pl0, pl1, pl2, pl3, pl4, pl5, pl6, pl7, pl8, pl9]
bars_vec = [bar0, bar1, bar2, bar3, bar4, bar5, bar6, bar7, bar8, bar9]
begin
    for (k, (bar, land)) in zip(bars_vec, lands_vec) |> enumerate
        iterator = k - 1
        reformatted_barcodes = [vcat([hcat([bar[k, 1], bar[k, 2]]...) for k in 1:size(bar, 1)]...)]
        comparison_plt = plot(
            plot_bd_diagram(reformatted_barcodes),
            plot_barcodes(reformatted_barcodes),
            plot_persistence_landscape(land);
            layout=(3, 1),
            size=(400, 1000)
        )
        max_death = max(bar9...)
        xticks!(0:1:max_death)
        title!("bar$(iterator), $(version_name)_version")

        @info "pwd= " pwd()
        homedir = pwd()
        # full_path = homedir * "/plots" * "/lands" * "/newest/"
        full_path = homedir * "/plots" * "/lands" * "/$(version_name)/"
        !ispath(full_path) && mkpath(full_path)

        file_name = "$(iterator)_lands_$(version_name).png"
        savefig(comparison_plt, full_path * file_name)
    end
end

## ===-===-===-===-===-===-
function pairs_to_matrix(pairs::Vector{MyPair})
    return vcat([[x.first x.second] for x in pairs]...)
end
pairs1, pairs2, pairs3, pairs4, pairs5 = generate_testing_pairs() .|> pairs_to_matrix
pairs1_land, pairs2_land, pairs3_land, pairs4_land, pairs5_land = generate_testing_pairs() .|> PersistenceBarcodes .|> PersistenceLandscape

bars_vec = [pairs1, pairs2, pairs3, pairs4, pairs5]
lands_vec = [pairs1_land, pairs2_land, pairs3_land, pairs4_land, pairs5_land]
begin
    for (k, (bar, land)) in zip(bars_vec, lands_vec) |> enumerate
        iterator = k
        reformatted_barcodes = [vcat([hcat([bar[k, 1], bar[k, 2]]...) for k in 1:size(bar, 1)]...)]
        comparison_plt = plot(
            plot_bd_diagram(reformatted_barcodes),
            plot_barcodes(reformatted_barcodes),
            plot_persistence_landscape(land);
            layout=(3, 1),
            size=(400, 1000)
        )
        max_death = max(bar9...)
        xticks!(0:1:max_death)
        title!("bar$(iterator), $(version_name)_version")

        @info "pwd= " pwd()
        homedir = pwd()
        # full_path = homedir * "/plots" * "/pairs" * "/newest/"
        full_path = homedir * "/plots" * "/pairs" * "/$(version_name)/"
        !ispath(full_path) && mkpath(full_path)

        file_name = "$(iterator)_paris_$(version_name).png"
        savefig(comparison_plt, full_path * file_name)
    end
end

## ===-===-===-===
lands_vec = [
    pl0 + pl1,
    pl1 + pl2 + pl3,
    pl6 + pl0,
    pl6 + pl2,
    pl6 + pl0 + pl2,
    [pl0, pl0] |> VectorSpaceOfPersistenceLandscapes |> average,
    [pl0, pl1] |> VectorSpaceOfPersistenceLandscapes |> average,
    [pl6, pl2] |> VectorSpaceOfPersistenceLandscapes |> average,
]

bars_vec = [
    vcat(bar0, bar1),
    vcat(bar1, bar2, bar3),
    vcat(bar6, bar0),
    vcat(bar6, bar2),
    vcat(bar6, bar2, bar0),
    vcat(bar0, bar0),
    vcat(bar0, bar1),
    vcat(bar6, bar2),
]
begin
    for (k, (bar, land)) in zip(bars_vec, lands_vec) |> enumerate
        iterator = k
        reformatted_barcodes = [vcat([hcat([bar[k, 1], bar[k, 2]]...) for k in 1:size(bar, 1)]...)]
        comparison_plt = plot(
            plot_bd_diagram(reformatted_barcodes),
            plot_barcodes(reformatted_barcodes),
            plot_persistence_landscape(land);
            layout=(3, 1),
            size=(400, 1000)
        )
        max_death = max(bar9...)
        xticks!(0:1:max_death)
        title!("bar$(iterator), $(version_name)_version")

        @info "pwd= " pwd()
        homedir = pwd()
        # full_path = homedir * "/plots" * "/pairs" * "/newest/"
        full_path = homedir * "/plots" * "/operations" * "/$(version_name)/"
        !ispath(full_path) && mkpath(full_path)

        file_name = "$(iterator)_operations_$(version_name).png"
        savefig(comparison_plt, full_path * file_name)
    end
end
do_nothing = "ok"




# fig5_data_a = [MyPair(2, 9), MyPair(4, 8), MyPair(4,5), MyPair(8,10)]
# fig5_bars_a = PersistenceBarcodes(fig5_data_a, 1)
# fig5_pl_a = PersistenceLandscape(fig5_bars_a)
#
# fig5_data_b = [MyPair(2, 9), MyPair(4, 8), MyPair(5,6), MyPair(7,9)]
# fig5_bars_b = PersistenceBarcodes(fig5_data_b, 1)
# fig5_pl_b = PersistenceLandscape(fig5_bars_b)
#
# plt_a = plot_persistence_landscape(fig5_pl_a)
# plot!(plt_a  , ticks=0:1:10, xlims=[1,11])
# plt_b = plot_persistence_landscape(fig5_pl_b)
# plot!(plt_b, ticks=0:1:10, xlims=[1,11])
# landscpae_collection = VectorSpaceOfPersistenceLandscapes([fig5_pl_a, fig5_pl_b])
# plt_average = plot_persistence_landscape(average(landscpae_collection))
# plot!(plt_average , ticks=0:1:10, xlims=[1,11])
# final_plot = plot(plt_a, plt_b, plt_average, layout=(3,1), size=(600, 400*3))