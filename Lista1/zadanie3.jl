include("graph.jl")
using .myGraph
using DataStructures

filename = joinpath(@__DIR__, string(ARGS[1]))
graph = readGraphFromFile(filename)
println("Wczytano graf!")

stronglyConectedComponents = getStronglyConnectedComponents(graph)

println("Liczba silnie spójnych składowych: ", length(stronglyConectedComponents))
i = 1
for component in stronglyConectedComponents
  println("Składowa silnie spójna numer ", i, " (liczba wierzchołków: ", length(component), ")")
  if graph.totalVertices <= 200
    println(component)
  end
  global i += 1
end

