module PersistenceLandscapesPlotsExt

using PersistenceLandscapes
using Plots

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Plotting functions >>>
function PersistenceLandscapes.get_peaks_and_positions(lambdas)
    filtered_pl = filter(x -> x.first != Inf, lambdas)
    filtered_pl = filter(x -> x.first != -Inf, filtered_pl)

    if isempty(filtered_pl)
        @warn "lambdas has only infinite intervals. Interrupting"
        return [], []
    end
    new_peaks_position = [x.first for x in filtered_pl]
    new_peaks = [x.second for x in filtered_pl]

    return new_peaks_position, new_peaks
end

function PersistenceLandscapes.plot_persistence_landscape(
    pl1::PersistenceLandscape;
    max_layers=size(pl1.land, 1),
    palette=:cmyk,
    max_colour_range=size(pl1.land, 1),
    plot_kwargs...
)
    if max_colour_range < max_layers
        @warn "Selected colour range is less than total layers! Changing to max layers instead"
        max_colour_range = max_layers
    end

    if max_layers > size(pl1.land, 1)
        @warn "Selected maximum for layers exceeds total layers in data structure! Executing code for maximal layers available."
        max_layers=size(pl1.land, 1)
    end

    colors = cgrad(palette, max(2, max_layers), categorical=true, rev=true)

    try
        colors = cgrad(plot_kwargs[:palette], max_colour_range, categorical=true, rev=true)
    catch
        @debug "Catched no palette"
    end

    canvas1 = plot()
    for k = 1:max_layers
        peaks_position, peaks = PersistenceLandscapes.get_peaks_and_positions(pl1.land[k])

        plot!(canvas1, peaks_position, peaks; c=colors[k], plot_kwargs...)
    end

    return canvas1
end

# Plotting functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

end
