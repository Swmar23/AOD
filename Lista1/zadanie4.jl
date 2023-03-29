include("graph.jl")
using .myGraph
using DataStructures

filename = joinpath(@__DIR__, string(ARGS[1]))
graph = readGraphFromFile(filename)
println("Wczytano graf!")

result = isGraphBipartite(graph)
isBipartite = result[1]
if isBipartite
  println("Graf jest dwudzielny")
  if graph.totalVertices <= 200
    verticesColor = result[2]
    print("\nZbiór V0: ")
    for i in 1:graph.totalVertices
      if verticesColor[i] == 0
        print(i, ", ")
      end
    end
    print("\n\nZbiór V1: ")
    for i in 1:graph.totalVertices
      if verticesColor[i] == 1
        print(i, ", ")
      end
    end
    print("\n")
  end
else
  println("Graf nie jest dwudzielny.")
end