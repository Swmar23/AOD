include("graph.jl")
using .myGraph
using DataStructures


function dijkstraForAll(graph::Graph, source::Int)::Pair{Array{Int}, Array{Int}}
  d = [typemax(Int) for i in 1:graph.totalVertices]
  pred = [0 for i in 1:graph.totalVertices]

  d[source] = 0
  pq = PriorityQueue{Int, Int}()
  enqueue!(pq, source, 0)
  while !isempty(pq)
    node = dequeue!(pq)
    for neighborEdge in graph.neighborsList[node]
      value = d[node] + neighborEdge.second
      if d[neighborEdge.first] > value
        if d[neighborEdge.first] == typemax(Int)
          d[neighborEdge.first] = value
          pred[neighborEdge.first] = node
          enqueue!(pq, neighborEdge.first, d[neighborEdge.first])
        else
          d[neighborEdge.first] = value
          pred[neighborEdge.first] = node
          pq[neighborEdge.first] = value
        end
      end
    end
  end

  return Pair(d, pred)
end



function dijkstraForPair(graph::Graph, source::Int, target::Int)::Int
  d = [typemax(Int) for i in 1:graph.totalVertices]
  pred = [0 for i in 1:graph.totalVertices]

  d[source] = 0
  pq = PriorityQueue{Int, Int}()
  enqueue!(pq, source, 0)
  while !isempty(pq)
    node = dequeue!(pq)
    if (node == target)
      return d[node]
    end
    for neighborEdge in graph.neighborsList[node]
      value = d[node] + neighborEdge.second
      if d[neighborEdge.first] > value
        if d[neighborEdge.first] == typemax(Int)
          d[neighborEdge.first] = value
          pred[neighborEdge.first] = node
          enqueue!(pq, neighborEdge.first, d[neighborEdge.first])
        else
          d[neighborEdge.first] = value
          pred[neighborEdge.first] = node
          pq[neighborEdge.first] = value
        end
      end
    end
  end
  return d[target]
end



# MAIN CODE BELOW ************************************


pathGraph = ""
pathSources = ""
pathPairs = ""
pathOutput = ""
pathLength = 0

if (length(ARGS) == 6)
  if (string(ARGS[1]) == "-d")
    if (string(ARGS[3]) == "-ss")
      # wersja ze źródłami
      if (string(ARGS[5]) == "-oss")
        # tu już możemy pracować
        pathGraph = joinpath(@__DIR__, string(ARGS[2]))
        pathSources = joinpath(@__DIR__, string(ARGS[4]))
        pathOutput = joinpath(@__DIR__, string(ARGS[6]))
        graph = readGraphFromFile(pathGraph)
        # println(graph.totalVertices)
        # println(graph.edgesNo)
        # println(length(graph.neighborsList))

        sources = readSources(pathSources)
        # println(sources)
        local timeTotal::Float64 = 0.0
        avgTime::Float64 = 0.0

        for source in sources
          stats = @timed dijkstraForAll(graph, source)
          timeTotal += stats.time
        end

        avgTime = timeTotal / length(sources)

        writeResultSources(pathOutput, pathGraph, pathSources, "dijkstra", graph, graph.minEdgeCost, graph.maxEdgeCost, avgTime)

      else
        println("Błąd wywołania - nieznana flaga ", string(ARGS[5]))
      end
    elseif (string(ARGS[3]) == "-p2p")
      # wersja z parami punktów
      if (string(ARGS[5]) == "-op2p")
        # tu już możemy pracować
        pathGraph = joinpath(@__DIR__, string(ARGS[2]))
        pathPairs = joinpath(@__DIR__, string(ARGS[4]))
        pathOutput = joinpath(@__DIR__, string(ARGS[6]))
        graph = readGraphFromFile(pathGraph)
        # println(graph.totalVertices)
        # println(graph.edgesNo)
        # println(length(graph.neighborsList))

        pairsToSolve::Array{Pair{Int, Int}} = readPairs(pathPairs)
        # println(pairsToSolve)

        pairsWithResults::Vector{Tuple{Int, Int, Int}} = []

        for pair in pairsToSolve
          i = pair.first
          j = pair.second
          global pathLength = dijkstraForPair(graph, i, j)
          push!(pairsWithResults, (i, j, pathLength))
        end

        writeResultPairs(pathOutput, pathGraph, pathPairs, "dijkstra", graph, graph.minEdgeCost, graph.maxEdgeCost, pairsWithResults)

      else
        println("Bład wywołania - nieznana flaga ", string(ARGS[5]))
      end
    else
      println("Błąd wywołania - nieznana flaga ", string(ARGS[3]))
    end

  else 
    println("Błąd wywołania - nieznana flaga ", string(ARGS[1]))
  end

else
  println("Błąd wywołania - niepoprawna liczba argumentów")
end


