using PyPlot

using Random
using Revise
using RandomQuadMesh
using PlotQuadMesh
using QuadMeshGame

RQ = RandomQuadMesh
PQ = PlotQuadMesh
QM = QuadMeshGame

elem_color = [0.8, 1, 0.8]


mesh = QM.square_mesh(2)
QM.split!(mesh, 3, 3)
vs = [0,-1,0,1,2,1,0,-1,1,-1]
fig, ax = PQ.plot_mesh(
    QM.active_vertex_coordinates(mesh),
    QM.active_quad_connectivity(mesh);
    elem_numbers = true,
    internal_order=true,
    vertex_score = vs
)
fig

# Random.seed!(123)
# mesh = RQ.random_quad_mesh(10)
# mesh = QM.QuadMesh(mesh.p, mesh.t, mesh.t2t, mesh.t2n)
