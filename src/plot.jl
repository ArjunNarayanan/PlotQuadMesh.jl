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

    tpars = Dict(
        :color => "k",
        :horizontalalignment => "center",
        :verticalalignment => "center",
        :fontfamily => "sans-serif",
        :fontsize => 10,
    )

    if elem_numbers
        for (idx, nodes) in enumerate(eachcol(connectivity))
            pc = sum(points[:, nodes], dims = 2) / 4
            ax.text(pc[1], pc[2], "$idx"; tpars...)
        end
    end

    if node_numbers
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
end

function plot_mesh(
    points,
    connectivity;
    elem_numbers = false,
    node_numbers = false,
    elem_color = [0.8, 1.0, 0.8],
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
    )
    return fig, ax
end
