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

function plot_node_numbers!(ax, points, fontsize, size)
    tpars = Dict(
        :color => "white",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontfamily => "sans-serif",
        :fontsize => fontsize,
    )
    ax.scatter(
        points[1, :],
        points[2, :],
        s=size,
        facecolors="black",
        alpha = 1.0,
    )
    for (idx, point) in enumerate(eachcol(points))
        ax.text(point[1], point[2], "$idx"; tpars...)
    end
end

function plot_elem_numbers!(ax, points, connectivity, element_numbers, fontsize)
    @assert size(connectivity, 2) == length(element_numbers)
    
    tpars = Dict(
        :color => "k",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontfamily => "sans-serif",
        :fontsize => fontsize,
    )
    for (idx, nodes) in enumerate(eachcol(connectivity))
        elem_id = element_numbers[idx]
        pc = sum(points[:, nodes], dims=2) / 4
        ax.text(pc[1], pc[2], "$elem_id"; tpars...)
    end
end

function plot_vertex_score!(ax, points, vertex_score, fontsize, vertex_size)
    @assert length(vertex_score) == size(points, 2) "Dimension mismatch between vertex scores and points"

    tpars = Dict(
        :color => "w",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontsize => fontsize,
        :fontweight => "bold",
    )

    ax.scatter(points[1, vertex_score.<0], points[2, vertex_score.<0], s=vertex_size, color="r")
    ax.scatter(points[1, vertex_score.>0], points[2, vertex_score.>0], s=vertex_size, color="m")

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

function plot_internal_order!(ax, points, connectivity, fontsize)
    tpars = Dict(
        :color => "r",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontsize => fontsize,
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
    number_elements=false,
    number_vertices=false,
    internal_order = false,
    elem_color=[0.8, 1.0, 0.8],
    vertex_score=[],
    figsize = (15,15),
    fontsize = 20,
    vertex_size = 20
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

    if number_elements isa Bool && number_elements
        element_numbers = 1:size(connectivity, 2)
        plot_elem_numbers!(ax, points, connectivity, element_numbers, fontsize)
    elseif number_elements isa Vector
        plot_elem_numbers!(ax, points, connectivity, number_elements, fontsize)
    end

    if number_vertices
        plot_node_numbers!(ax, points, fontsize, vertex_size^2)
    end

    if length(vertex_score) > 0
        plot_vertex_score!(ax, points, vertex_score, fontsize, vertex_size^2)
    end

    if internal_order
        plot_internal_order!(ax, points, connectivity, fontsize)
    end

    fig.tight_layout()

    return fig, ax
end
