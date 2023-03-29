include("graph.jl")
using .myGraph
using DataStructures

filename = joinpath(@__DIR__, string(ARGS[1]))
graph = readGraphFromFile(filename)
println("Wczytano graf!")

result = topologicalSort(graph)
isSortable = result[1]
order = result[2]
if isSortable
  println("Graf jest sortowalny (brak skierowanego cyklu).")
  if graph.totalVertices <= 200
    println("Porządek topologiczny:")
    println(order)
  end
else
  println("Graf ma skierowany cykl.")
end
  