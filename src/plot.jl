function single_color_cmap(rgb::Vector{Float64})
    args = [(t, v, v) for t = 0.0:1.0, v in rgb]
    ColorMap("", args[:, 1], args[:, 2], args[:, 3])
end

function plot_mesh!(
    ax,
    points,
    connectivity;
    elem_color=[0.8, 1.0, 0.8],
)
    ts = Array([connectivity[1:3, :] connectivity[[1, 3, 4], :]]' .- 1)

    ax.tripcolor(
        points[1, :],
        points[2, :],
        ts,
        0 * ts[:, 1],
        cmap=single_color_cmap(elem_color),
    )
    xy = vcat([[points[:, [el; el[1]]]'; NaN NaN] for el in eachcol(connectivity)]...)
    ax.plot(xy[:, 1], xy[:, 2], "k", linewidth=1.0)

end

function plot_node_numbers!(ax, points)
    tpars = Dict(
        :color => "k",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontfamily => "sans-serif",
        :fontsize => 10,
    )
    ax.plot(
        points[1, :],
        points[2, :],
        markersize=12,
        marker="o",
        linestyle="none",
        color=[0.6, 0.8, 1],
    )
    for (idx, point) in enumerate(eachcol(points))
        ax.text(point[1], point[2], "$idx"; tpars...)
    end
end

function plot_elem_numbers!(ax, points, connectivity)
    tpars = Dict(
        :color => "k",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontfamily => "sans-serif",
        :fontsize => 10,
    )
    for (idx, nodes) in enumerate(eachcol(connectivity))
        pc = sum(points[:, nodes], dims=2) / 4
        ax.text(pc[1], pc[2], "$idx"; tpars...)
    end
end

function plot_vertex_score!(ax, points, vertex_score)
    @assert length(vertex_score) == size(points, 2) "Dimension mismatch between vertex scores and points"

    tpars = Dict(
        :color => "w",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontsize => 12,
        :fontweight => "bold",
    )

    ax.scatter(points[1, vertex_score.<0], points[2, vertex_score.<0], 450, color="r")
    ax.scatter(points[1, vertex_score.>0], points[2, vertex_score.>0], 450, color="m")

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

function plot_element_internal_order!(ax, points, tpars; scale = 0.25)
    @assert size(points, 2) == 4
    centroid = sum(points, dims=2)/4
    displacement = scale*(centroid .- points)
    coords = points + displacement

    for (idx, point) in enumerate(eachcol(coords))
        txt = string(idx)
        ax.text(point[1], point[2], txt; tpars...)
    end
end

function plot_internal_order!(ax, points, connectivity)
    tpars = Dict(
        :color => "r",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontsize => 12,
        :fontweight => "bold",
    )

    for (elem_id, conn) in enumerate(eachcol(connectivity))
        p = points[:, conn]
        plot_element_internal_order!(ax, p, tpars)
    end
end

function plot_mesh(
    points,
    connectivity;
    elem_numbers=false,
    node_numbers=false,
    internal_order = false,
    elem_color=[0.8, 1.0, 0.8],
    vertex_score=[],
    figsize = (15,15)
)

    fig, ax = subplots(figsize=figsize)
    ax.axis("equal")
    ax.axis("off")
    plot_mesh!(
        ax,
        points,
        connectivity,
        elem_color=elem_color,
    )

    if elem_numbers
        plot_elem_numbers!(ax, points, connectivity)
    end

    if node_numbers
        plot_node_numbers!(ax, points)
    end

    if length(vertex_score) > 0
        plot_vertex_score!(ax, points, vertex_score)
    end

    if internal_order
        plot_internal_order!(ax, points, connectivity)
    end

    return fig, ax
end
