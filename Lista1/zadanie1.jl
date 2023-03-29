include("graph.jl")
using .myGraph
using DataStructures


filename = joinpath(@__DIR__, string(ARGS[1]))
printTree = false
if length(ARGS) > 1
  if string(ARGS[2]) == "--tree"
    printTree = true
  end
end
graph = readGraphFromFile(filename)
println("Wczytano graf!")
DFSTraversal = DFS(graph, printTree)
println("Kolejność przechodzenia wierzchołków w DFS: ")
println(DFSTraversal)
println("***********************************************")
BFSTraversal = BFS(graph, 1, printTree)
println("Kolejność przechodzenia wierzchołków w BFS: ")
println(BFSTraversal)
