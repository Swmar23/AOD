# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 1

module myGraph
export Graph, readGraphFromFile, newGraph, readSources, readPairs, writeResultSources, writeResultPairs
using DataStructures
using Printf

"""
Proponowana struktura grafu.
Wierzchołki numerowane od 1 do totalVertices:
* totalVertices - liczba wierzchołków
* isDirected - czy graf jest skierowany (True jeśli jest)
* edgesNo - liczba krawędzi
* neighborsList - lista sąsiadów, np. graph.adjacencyList[3] to lista sąsiadów
                  wierzchołka 3
"""
mutable struct Graph
  totalVertices::Int
  edgesNo::Int
  neighborsList::Array{Vector{Pair{Int,Int}}}
  minEdgeCost::Int
  maxEdgeCost::Int
end

# function newGraph(totalVertices::Int, isDirected::Bool, edges::Vector{Tuple{Int, Int}})
#   neighborsList = Array{Vector{Int}}(undef, totalVertices)
#   fill!(neighborsList, nil(Int))
#   for edge in edges
#     push!(neighborsList[edge[1]], edge[2])
#   end
#   return Graph(totalVertices, isDirected, len(edges), neighborsList)
# end

function readGraphFromFile(filename::String)
  totalVertices = 0
  edgesNo = 0
  neighborsList::Array{Vector{Pair{Int, Int}}} = [[]]
  minEdgeCost = typemax(Int)
  maxEdgeCost = 0
  open(filename) do file
    while !eof(file)
      args = split(readline(file))
      lineTypeFlag = args[1]
      if (lineTypeFlag == "c")
        continue
      end
      if (lineTypeFlag == "p")
        totalVertices = parse(Int, args[3])
        edgesNo = parse(Int, args[4])
        neighborsList = [ [] for i in 1:totalVertices]
      end
      if (lineTypeFlag == "a")
        u = parse(Int, args[2])
        v = parse(Int, args[3])
        c = parse(Int, args[4])
        if (c > maxEdgeCost)
          maxEdgeCost = c
        end
        if (c < minEdgeCost)
          minEdgeCost = c
        end
        push!(neighborsList[u], Pair(v, c))
      end
      if (lineTypeFlag != "a" && lineTypeFlag != "p" && lineTypeFlag != "c")
        error("Nieznana flaga w pliku!")
      end
    end
    return Graph(totalVertices, edgesNo, neighborsList, minEdgeCost, maxEdgeCost)
  end
end

function readSources(filename::String)::Array{Int}
  sourceNumber = 0
  sourceVector::Vector{Int} = []
  open(filename) do file
    while !eof(file)
      args = split(readline(file))
      lineTypeFlag = args[1]
      if (lineTypeFlag == "c")
        continue
      end
      if (lineTypeFlag == "p")
        sourceNumber = parse(Int, args[5])
      end
      if (lineTypeFlag == "s")
        u = parse(Int, args[2])
        push!(sourceVector, u)
      end
      if (lineTypeFlag != "s" && lineTypeFlag != "p" && lineTypeFlag != "c")
        error("Nieznana flaga w pliku!")
      end
    end
  end
  return sourceVector
end

function readPairs(filename::String)::Array{Pair{Int, Int}}
  pairsNumber = 0
  pairsVector::Vector{Pair{Int, Int}} = []
  open(filename) do file
    while !eof(file)
      args = split(readline(file))
      lineTypeFlag = args[1]
      if (lineTypeFlag == "c")
        continue
      end
      if (lineTypeFlag == "p")
        pairsNumber = parse(Int, args[5])
      end
      if (lineTypeFlag == "q")
        u = parse(Int, args[2])
        v = parse(Int, args[3])
        push!(pairsVector, Pair(u, v))
      end
      if (lineTypeFlag != "q" && lineTypeFlag != "p" && lineTypeFlag != "c")
        error("Nieznana flaga w pliku!")
      end
    end
  end
  return pairsVector
end

function writeResultSources(outputFilename::String, graphFilename::String, sourcesFilename::String, algorithmType::String, graph::Graph, minCost::Int, maxCost::Int, avgTime::Float64)
  file = open(outputFilename, "w")
  @printf(file, "p res sp ss %s\n", algorithmType)
  @printf(file, "-------------------------------\n")
  @printf(file, "f %s %s\n", graphFilename, sourcesFilename)
  @printf(file, "g %d %d %d %d\n", graph.totalVertices, graph.edgesNo, minCost, maxCost)
  @printf(file, "t %f", avgTime)
  close(file)
end

function writeResultPairs(outputFilename::String, graphFilename::String, pairsFilename::String, algorithmType::String, graph::Graph, minCost::Int, maxCost::Int, pairsWithResults::Array{Tuple{Int, Int, Int}})
  file = open(outputFilename, "w")
  @printf(file, "p res sp p2p %s\n", algorithmType)
  @printf(file, "c -------------------------------\n")
  @printf(file, "f %s %s\n", graphFilename, pairsFilename)
  @printf(file, "g %d %d %d %d\n", graph.totalVertices, graph.edgesNo, minCost, maxCost)
  for element in pairsWithResults
    if (element[3] == typemax(Int))
      @printf(file, "d %d %d INFINITY\n", element[1], element[2])
    else
      @printf(file, "d %d %d %d\n", element[1], element[2], element[3])
    end
  end
  close(file)
end

end