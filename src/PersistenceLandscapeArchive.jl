#=
Module with all functions that are not required in Julia, but were defined
in the original C code
=#
# TODO Add MyPair module

using Plots
using Eirene

# copy constructor- not necessary for Julia
# function PersistenceLandscape(land::PersistenceLandscape, oryginal::PersistenceLandscape)
# println("Running copy constructor")
# land = Any[]
# for i = 1 : size(oryginal.land)
#     push!(land, (land[i].end(), oryginal.land[i].begin(), oryginal.land[i].end())
#      )
# end
# # CHANGE
# # land.land = land
# return PersistenceLandscape(land, oryginal.dimension)
# end

# if check( , )
# println("OUT OF MEMORY")

# Constructor, temporarily changed to function
# function PersistenceLandscape(land::PersistenceLandscape,  p::PersistenceBarcodes; dbg = false)
# Constructors <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

# functionzone:
# this is a general algorithm to perform linear operations on persisntece lapscapes. It perform it by doing operations on landscape points.

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Basic operations on PersistenceLandscape >>>
# function operationOnPairOfLandscapes(land1, land2 , oper);

# function /(first::PersistenceLandscape, con::Real)
#     return divideLanscapeByRealNumberNotOverwrite(first, con)
# end
#
# function /(con::Real, first::PersistenceLandscape)
#     return divideLanscapeByRealNumberNotOverwrite(first, con)
# end

# function Base.+=(this::PersistenceLandscape, rhs::PersistenceLandscape)
#     return this + rhs
# end
#
# function Base.-=(this::PersistenceLandscape, rhs::PersistenceLandscape)
#     return this - rhs
# end
#
# function Base.*=(this::PersistenceLandscape, x::Float64 )
#     return this * x
# end


# function Base./=(this::PersistenceLandscape, x::Float64 )
#     x == 0  && throw(DomainError("In Base./=, division by 0. Program terminated." ))
#     return this / x
# end

# function Base.==(this::PersistenceLandscape,rhs ::PersistenceLandscape)::Bool
#     return this == rhs
# end


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# visualization part...
# To be created in Julia





# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# CAUTION, this procedure do not work yet. Please do not use it until this warning is removed.
# PersistenceBarcodes PersistenceLandscape::convertToBarcode()
# function body removed
#
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-




# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Operations on landscapes
# this function find maximum of lambda_n
# Yet another function to smooth up the data. The idea of this one is as follows. Let us take a landscape point A which is not (+infty,0), (-infty,0) of (a,0), (b,0), where a and b denotes the
# points which support of the function begins and ends. Let B and C will be the landscape points after A. Suppose B and C are also no one as above.
# The question we are asking here is -- can we remove the point B and draw a line from A to C such that the difference in a landscape will be not greater than epsilon?
# To measure the penalty of removing B, the funcion penalty. In below, the simplese example is given:

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

# Other functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

# Print format for persistence landscape
# ostream& operator<<(ostream& out,land::PersistenceLandscape)
#     for level = 0:size(land.land,1)
#         out << "Lambda_" << level << ":"
#         for i = 0:size(land.land[level],1)
#             if land.land[level][i].first == INT_MIN
#                 out << "-inf"
#             end
#                 if land.land[level][i].first == INT_MAX
#                     out << "+inf"
#                 end
#                     out << land.land[level][i].first
#                 end
#             end
#             out << " , " << land.land[level][i].second
#         end
#     end
#     return out
# end

# function divideLanscapeByRealNumberNotOverwrite(land::PersistenceLandscape, x::Real )
#     result = Vector{Vector{MyPair}}()
#     for dim = 1 : size(land)
#         lambda_dim = MyPair[]
#         for i = 1 : size(land.land[dim],1)
#             push!(lambda_dim, make_MyPair( land.land[dim][i].first , land.land[dim][i].second/x ))
#         end
#
#         push!(result, lambda_dim)
#     end
#     # CHANGE
#     # res.land = result
#     return PersistenceLandscape(result, land.dimension)
# end# multiplyLanscapeByRealNumberOverwrite


# Edit1: original function took arguments which were m,odified in the function. Now it returns values required
# function computeMaximalDistanceNonSymmetric( pl1::PersistenceLandscape, pl2::PersistenceLandscape , nrOfLand::UInt , x::Float64, y1::Float64, y2::Float64)::PersistenceLandscape
# Edit2: This function was modified, because it was modyfying arguments and returning new results; To make it
# working again for landscapes distances, an intermidiate function had to be added.


# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# File operations >>>

# function printToFiles(land::PersistenceLandscape, char* filename , from::UInt, unsigned to )const
#     # if ( from > to )throw("Error printToFiles printToFile( char* filename , from::UInt, unsigned to ). 'from' cannot be greater than 'to'.")
#     # # if ( to > size(land,1) )throw("Error in printToFiles( char* filename , from::UInt, unsigned to ). 'to' is out of range.")
#     # if ( to > size(land,1) )to = size(land,1);end
#     # ofstream write
#     # for dim = from :to
#     #     ostringstream name
#     #     name << filename << "_" << dim << ".dat"
#     #     string fName = name.str()
#     #     char* FName = fName.c_str()
#     #     write.open(FName)
#     #     write << "#lambda_" << dim
#     #     for i = 1:size(land.land[dim],1)-1
#     #         write << land.land[dim][i].first << "  " << this->land[dim][i].second
#     #     end
#     #     write.close()
#     # end
# end
#
# function printToFiles(land::PersistenceLandscape, char* filename, int numberOfElementsLater ,  ... )const
#   # va_list arguments
#   # va_start ( arguments, numberOfElementsLater )
#   # ofstream write
#   # for ( int x = 0; x < numberOfElementsLater; x ) += 1
#   #      dim = va_arg ( arguments, unsigned )
#   #      if ( dim > size(land,1) )throw("In function generateGnuplotCommandToPlot(char* filename,int numberOfElementsLater,  ... ), one of the number provided is greater than number of nonzero landscapes")
#   #       ostringstream name
#   #      name << filename << "_" << dim << ".dat"
#   #      string fName = name.str()
#   #      char* FName = fName.c_str()
#   #      write.open(FName)
#   #      write << "#lambda_" << dim
#   #      for i = 1:size(land.land[dim],1)-1
#   #          write << land.land[dim][i].first << "  " << this->land[dim][i].second
#   #      end
#   #      write.close()
#   # end
#   # va_end ( arguments )
# end
#
# function printToFiles(land::PersistenceLandscape, char* filename )const
#     # land.printToFiles(filename , (unsigned)0 , (unsigned)size(land,1) )
# end
#
# function printToFile(land::PersistenceLandscape, char* filename , from::UInt, unsigned to )const
#     # if ( from > to )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'from' cannot be greater than 'to'.")
#     # if ( to > size(land,1) )throw("Error in printToFile( char* filename , from::UInt, unsigned to ). 'to' is out of range.")
#     # ofstream write
#     # write.open(filename)
#     # write << land.dimension
#     # for dim = from : to
#     #     write << "#lambda_" << dim
#     #     for i = 1:size(land.land[dim],1)-1
#     #         write << land.land[dim][i].first << "  " << this->land[dim][i].second
#     #     end
#     # end
#     # write.close()
# end
#
# function printToFile(land::PersistenceLandscape, char* filename  )const
#     # land.printToFile(filename,0,size(land,1))
# end

# ===-===-===-===-
# GNUplots >>>
# function generateGnuplotCommandToPlot(land::PersistenceLandscape, char* filename, from::UInt, unsigned to )const
#     # function body removed
# end
#
# function generateGnuplotCommandToPlot(land::PersistenceLandscape,char* filename,int numberOfElementsLater,  ... )const
#     # function body removed
# end
#
# function generateGnuplotCommandToPlot(land::PersistenceLandscape, char* filename )const
#     # function body removed
# end


# function printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand(land::PersistenceLandscape, char* filename )const
#     vector< std::pair<, > > histogram = land.generateBettiNumbersHistogram()
#     ostringstream result
#     for i = 0:size(histogram,1)
#         result << histogram[i].first << " " << histogram[i].second
#     end
#     ofstream write
#     write.open( filename )
#     write << result.str()
#     write.close()
#     println("The result is in the file : $(filename) . Now in gnuplot type plot \"$(filename)\" with lines")
# end# printBettiNumbersHistoramIntoFileAndGenerateGnuplotCommand
# GNUplots <<<
# ===-===-===-===-

# function plot(land::PersistenceLandscape, char* filename ,  from,  to ,xRangeBegin ,xRangeEnd ,yRangeBegin ,yRangeEnd )
#
#     # this program create a gnuplot script file that allows to plot persistence diagram.
#     ofstream out
#
#     ostringstream nameSS
#     nameSS << filename << "_GnuplotScript"
#     string nameStr = nameSS.str()
#     out.open( (char*)nameStr.c_str() )
#
#     if (xRangeBegin != -1) || (xRangeEnd != -1) || (yRangeBegin != -1) || (yRangeEnd != -1)
#         out << "set xrange [$(xRangeBegin) $(xRangeEnd)]"
#         out << "set yrange [$(yRangeBegin) $(yRangeEnd)]"
#     end
#
#     if ( from == -1 )from = 0;end
#     if ( to == -1 )to = size(land,1);end
#
#     out << "plot "
#     for lambda= min(from,size(land,1)) : min(to,size(land,1))[1]
#         out << "     '-' using 1:2 title 'l" << lambda << "' with lp"
#         if lambda+1 != min(to,size(land,1))[1]
#             out << ", \\"
#         end
#         out
#     end
#
#     for lambda= min(from,size(land,1)) : min(to,size(land,1))[1]
#         for i = 1:size(land.land[lambda],1)-1
#             out << land.land[lambda][i].first << " " << this->land[lambda][i].second
#         end
#         out << "EOF"
#     end
#     println("Gnuplot script to visualize persistence diagram written to the file: $(nameStr) $(nameStr)' in gnuplot to visualize.")
# end

# File operations <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Debug functions >>>
# functions used in PersistenceLandscape( PersistenceBarcodes& p ) constructor:
# comparePointsDBG::Bool = false
# TODO remove if all debug is removed, as it us used in debug finctions only
function comparePoints(f::MyPair, s::MyPair; local_debug::Bool=false)
    differenceBirth = birth(f) - birth(s)

    if differenceBirth < 0
        differenceBirth *= -1
    end

    differenceDeath = death(f) - death(s)
    if differenceDeath < 0
        differenceDeath *= -1
    end

    if (differenceBirth < epsi) && (differenceDeath < epsi)
        local_debug && println("CP1")
        return false
    end
    if differenceBirth < epsi
        # consider birth points the same. If we are here, we know that death points are NOT the same
        if death(f) < death(s)
            local_debug && println("CP2")
            return true
        end
        local_debug && println("CP3")

        return false
    end
    if differenceDeath < epsi
        # we consider death points the same and since we are here, the birth points are not the same!
        if birth(f) < birth(s)
            local_debug && println("CP4")

            return false
        end
        local_debug && println("CP5")

        return true
    end
    if birth(f) > birth(s)
        local_debug && println("CP6")

        return false
    end
    if birth(f) < birth(s)
        local_debug && println("CP7")

        return true
    end
    # if this is true, we assume that death(f)<=death(s) -- othervise I have had a lot of roundoff problems here!
    if death(f) <= death(s)
        local_debug && println("CP8")

        return false
    end
    local_debug && println("CP9")

    return true
end

# this function assumes birth-death coords
function comparePoints2(f::MyPair, s::MyPair)
    if f.first < s.first
        return true
    else
        if f.first > s.first
            return false
        else
            # f.first == s.first
            if f.second > s.second
                return true
            else
                return false
            end
        end
    end
end
# Debug functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-

# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
# Unused functions >>>
# functions used to add and subtract landscapes
function add(x::Float64, y::Float64)
    return x + y
end

function sub(x::Float64, y::Float64)
    return x - y
end

function lDimBegin(land::PersistenceLandscape, dim::UInt)
    if dim > size(land, 1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][1]
end

function lDimEnd(land::PersistenceLandscape, dim::UInt)
    if dim > size(land, 1)
        throw(DomainError("Calling lDimIterator in a dimension higher that dimension of landscape"))
    end
    return land[dim][size(land[dim], 1)]
end

# This function is realised by constructors, most probably not needed once consstructors are fixed.
function check_for_infs(landscape::PersistenceLandscape)
    landscape_set = Array{Array{MyPair,1},1}()
    negative_inf = MyPair(-Inf, 0)
    positive_inf = MyPair(Inf, 0)

    for land in landscape.land
        new_landscape = land
        if !(negative_inf in new_landscape)
            new_landscape = vcat(negative_inf, new_landscape)
        end

        if !(positive_inf in new_landscape)
            new_landscape = vcat(new_landscape, positive_inf)
        end
        push!(landscape_set, new_landscape)
    end

    return PersistenceLandscape(landscape_set, landscape.dimension)
end

# Unused functions <<<
# ===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
