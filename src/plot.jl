function single_color_cmap(rgb::Vector{Float64})
    args = [(t, v, v) for t = 0.0:1.0, v in rgb]
    ColorMap("", args[:, 1], args[:, 2], args[:, 3])
end

function plot_mesh!(
    ax,
    points,
    connectivity;
    elem_numbers = false,
    node_numbers = false,
    elem_color = [0.8, 1.0, 0.8],
    vertex_score = []
)
    ts = Array([connectivity[1:3, :] connectivity[[1, 3, 4], :]]' .- 1)

    ax.tripcolor(
        points[1, :],
        points[2, :],
        ts,
        0 * ts[:, 1],
        cmap = single_color_cmap(elem_color),
    )
    xy = vcat([[points[:, [el; el[1]]]'; NaN NaN] for el in eachcol(connectivity)]...)
    ax.plot(xy[:, 1], xy[:, 2], "k", linewidth = 1.0)

    if elem_numbers

        tpars = Dict(
            :color => "k",
            :horizontalalignment => "center",
            :verticalalignment => "center",
            :fontfamily => "sans-serif",
            :fontsize => 10,
        )
        for (idx, nodes) in enumerate(eachcol(connectivity))
            pc = sum(points[:, nodes], dims = 2) / 4
            ax.text(pc[1], pc[2], "$idx"; tpars...)
        end
    end

    if node_numbers

        tpars = Dict(
            :color => "k",
            :horizontalalignment => "center",
            :verticalalignment => "center",
            :fontfamily => "sans-serif",
            :fontsize => 10,
        )
        plot(
            points[1, :],
            points[2, :],
            markersize = 12,
            marker = "o",
            linestyle = "none",
            color = [0.6, 0.8, 1],
        )
        for (idx, point) in enumerate(eachcol(points))
            ax.text(point[1], point[2], "$idx"; tpars...)
        end
    end

    if length(vertex_score) > 0
        @assert length(vertex_score) == size(points, 2) "Dimension mismatch between vertex scores and points"

        tpars = Dict(
            :color => "w",
            #:fontfamily=>"sans-serif",
            :horizontalalignment => "center",
            :verticalalignment => "center",
            :fontsize => 12,
            :fontweight => "bold",
        )

        ax.scatter(points[1, vertex_score.<0], points[2, vertex_score.<0], 450, color = "r")
        ax.scatter(points[1, vertex_score.>0], points[2, vertex_score.>0], 450, color = "m")
        # ax.scatter(m.p[dd.==0, 1], m.p[dd.==0, 2], 450, color = "b")
        for (i, point) in enumerate(eachcol(points))
            if vertex_score[i] != 0
                txt = string(vertex_score[i])
                if vertex_score[i] > 0
                    txt = "+" * txt
                end
                ax.text(point[1], point[2], txt; tpars...)
            end
        end
    end

end

function plot_mesh(
    points,
    connectivity;
    elem_numbers = false,
    node_numbers = false,
    elem_color = [0.8, 1.0, 0.8],
    vertex_score = []
)

    fig, ax = subplots()
    ax.axis("equal")
    ax.axis("off")
    plot_mesh!(
        ax,
        points,
        connectivity,
        elem_numbers = elem_numbers,
        node_numbers = node_numbers,
        elem_color = elem_color,
        vertex_score = vertex_score
    )
    return fig, ax
end
