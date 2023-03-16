using Plots

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Plotting functions >>>
function get_peaks_and_positions(lambdas)
    # TODO lowest leve, below unity and separate peaks are not found corrrectly
    filtered_pl = filter(x -> x.first != Inf, lambdas)
    filtered_pl = filter(x -> x.first != -Inf, filtered_pl)
    # filtered_pl = filter(x-> x.first!=0 && x.second!=0, filtered_pl)

    if isempty(filtered_pl)
        @warn "lambdas has only infinite intervals. Interrupting"
        return [], []
    end
    new_peaks_position = [x.first for x in filtered_pl]
    new_peaks = [x.second for x in filtered_pl]
    # peaks_position = [x.first for x in filtered_pl]
    # peaks = [x.second for x in filtered_pl]
    #
    # # find an index of pair for which first peak was found
    # index_peak1 = findall(x->x.first == peaks_position[1], lambdas)
    #
    # # find an index of pair for which last peak was found
    # index_peak_last = findall(x->x.first == peaks_position[end], lambdas)
    #
    #
    # # add starting point for the plot
    # peaks_position = vcat(peaks_position[1]-lambdas[index_peak1][1].second, peaks_position) # add starting poin
    # peaks = vcat(0, peaks) # add starting poin
    #
    # # add ending point for the plot
    # peaks_position = vcat(peaks_position, peaks_position[end]+lambdas[index_peak_last ][1].second) # add starting poin
    # peaks = vcat(peaks, 0) # add starting poin
    #
    # new_peaks = Real[]
    # new_peaks_position = Real[]
    # push!(new_peaks, peaks[1])
    # push!(new_peaks, peaks[2])
    # push!(new_peaks_position, peaks_position[1])
    # push!(new_peaks_position, peaks_position[2])
    #
    # # for every point, check if next peak position is within rach of range. if not, add zero poin
    # for k in 2:length(peaks_position)-1
    #     # this is peak position
    #     right_limit = peaks_position[k] + peaks[k]
    #     if right_limit < peaks_position[k+1]
    #
    #         push!(new_peaks, peaks[k])
    #         push!(new_peaks_position, peaks_position[k])
    #
    #         # add closing zero
    #         push!(new_peaks, 0)
    #         push!(new_peaks_position, right_limit)
    #
    #         # add opening zero
    #         left_limit = peaks_position[k+1] - peaks[k+1]
    #         push!(new_peaks, 0)
    #         push!(new_peaks_position, left_limit)
    #     else
    #         push!(new_peaks, peaks[k])
    #         push!(new_peaks_position, peaks_position[k])
    #     end
    # end
    #
    # push!(new_peaks, peaks[end])
    # push!(new_peaks_position, peaks_position[end])


    return new_peaks_position, new_peaks
end

function plot_persistence_landscape(
    pl1::PersistenceLandscape;
    max_layers=size(pl1.land, 1),
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

    colors = cgrad(:cmyk, max(2, max_colour_range), categorical=true, rev=true)

    try
        colors = cgrad(plot_kwargs[:palette], max_colour_range, categorical=true, rev=true)
    catch
        @debug "Catched no palette"
    end

    canvas1 = plot()
    for k = 1:max_layers
        peaks_position, peaks = get_peaks_and_positions(pl1.land[k])

        plot!(canvas1, peaks_position, peaks; c=colors[k], plot_kwargs...)
    end

    return canvas1
end

# Plotting functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
