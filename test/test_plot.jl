using PyPlot
pygui(false)

using Random
using Revise
using RandomQuadMesh
using PlotQuadMesh
using QuadMeshGame

RQ = RandomQuadMesh
PQ = PlotQuadMesh
QM = QuadMeshGame

elem_color = [0.8, 1, 0.8]

Random.seed!(123)
mesh = RQ.random_quad_mesh(10)
mesh = QM.QuadMesh(mesh.p, mesh.t, mesh.t2t, mesh.t2n)

QM.left_flip!(mesh, 16, 2)
QM.right_flip!(mesh, 2, 3)
QM.split!(mesh, 13, 3)
QM.split!(mesh, 3, 3)
fig, ax = PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), elem_numbers=true, node_numbers=true)
fig