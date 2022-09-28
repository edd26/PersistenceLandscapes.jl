#=
Get plots for basic structures. Compare results for this version and plots obtained for previous version
=#

using Pkg
Pkg.activate(".")
using Plots

[
    "../src/MyPair.jl",
    "../src/PersistenceBarcode.jl",
    "../src/LandscapesConstruction.jl",
    "../src/LandscapesOperations.jl",
    "../src/LandscapesDistances.jl",
    "../src/LandscapesPlotting.jl",
] .|> include
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
    local_alpha = 1.0

    # barcodes = all_barcodes_geom
    min_dim, max_dim = dim_range[1], dim_range[end]
    total_dims = length(dim_range)

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
        sorted_barcodes = copy(barcodes)
        for (dim_index, dim) = enumerate(min_dim:max_dim)
            # if dim == 0
            #     sorted_barcodes = sort(barcodes[dim_index], dims=1)
            # else
            permutation = sortperm(barcodes[dim_index][:, 1])
            sorted_barcodes[dim_index] = barcodes[dim_index][permutation, :]
            # end
        end
        barcodes = sorted_barcodes
    end

    plot_ref = plot()
    total_cycles = sum([size(barcodes[k], 1) for (k, dim) in enumerate(min_dim:max_dim)])
    for (p, dim) = enumerate(min_dim:max_dim)# 1:(max_dim) #TODO ths can not be starting from min_dim, because it may be 0
        b = barcodes[p][:, :]

        total_bars = size(b, 1)
        y_vals = [[k, k] for k in y_val_ranges[p]]
        lc = colors_set[p]
        for k = 1:total_bars
            # TODO change label to empty one
            plot!(b[k, :], y_vals[k]; label="",
                lc=lc,
                alpha=local_alpha
            )
        end
    end

    ylims!(0, total_cycles + 2)
    yticks!(1:total_cycles)

    return plot_ref
end

function pairs_to_matrix(pairs::Vector{MyPair})
    return vcat([[x.first x.second] for x in pairs]...)
end

## ===-===-===-===-===-===-
# Layers of crossing barcodes
# pyramids overlapping with crossings
bars = [# layer 1 of barcodes
    [0.0, 6.0],
    [2.0, 8.0],
    [4.0, 10.0],
    [6.0, 12.0],
    [8.0, 14.0],
    # layer 2 of barcodes
    [0.0, 10.0],
    [2.0, 12.0],
    [4.0, 14.0],
    #
    # layer 3 of barcodes peak split
    [0.0, 12.0],
    [2.0, 14.0],

    # layer 4 of barcodes- peak
    [0.0, 14.0],
]
pairs4 = [MyPair(x[1], x[2]) for x in bars]

barcodes4 = pairs4 |> PersistenceBarcodes
# Debugger.@enter barcodes4 |> PersistenceLandscape
## ===-===-===-===-===-===-
pairs4_land = pairs4 |> PersistenceBarcodes |> PersistenceLandscape

barcode = pairs4 |> pairs_to_matrix
reformatted_barcodes = [vcat([hcat([barcode[k, 1], barcode[k, 2]]...) for k in 1:size(barcode, 1)]...)]
reformatted_barcodes[1]

comparison_plt = plot(
    plot_bd_diagram(reformatted_barcodes),
    plot_barcodes(reformatted_barcodes),
    plot_persistence_landscape(pairs4_land);
    layout=(3, 1),
    size=(400, 1000)
);
max_death = max(barcode...)
xticks!(0:1:max_death)

## ===-===-===-===-===-===-
# Minimally not working example

small_rand(x) = rand(Float64, (2,)) ./ 100

modified_bars = [x .+ small_rand(2) for x in bars]
modified_pairs = [MyPair(x[1], x[2]) for x in modified_bars]
modified_pairs4_land = modified_pairs |> PersistenceBarcodes |> PersistenceLandscape

modified_barcode = modified_pairs |> pairs_to_matrix
modified_reformatted_barcodes = [vcat([hcat([modified_barcode[k, 1], modified_barcode[k, 2]]...) for k in 1:size(modified_barcode, 1)]...)]

modified_comparison_plt = plot(
    plot_bd_diagram(modified_reformatted_barcodes),
    plot_barcodes(modified_reformatted_barcodes),
    plot_persistence_landscape(modified_pairs4_land);
    layout=(3, 1),
    size=(400, 1000)
);
max_death = max(modified_bars...)[2]
xticks!(0:1:max_death)


do_nothing = "ok"

# ===-===-===-===-

