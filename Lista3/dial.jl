include("graph.jl")
using .myGraph
using DataStructures

function dialForAll(graph::Graph, source::Int)::Pair{Array{Int}, Array{Int}}
  d = [typemax(Int) for i in 1:graph.totalVertices]
  pred = [0 for i in 1:graph.totalVertices]

  d[source] = 0

  buckets::Array{Set{Int}} = [Set{Int}() for i in 0:graph.maxEdgeCost]
  currentBucket = 1
  emptyBucketsInRow = 0

  push!(buckets[currentBucket], source)

  while emptyBucketsInRow < graph.maxEdgeCost + 1
    if isempty(buckets[currentBucket])
      currentBucket += 1
      if currentBucket > graph.maxEdgeCost + 1
        currentBucket = 1
      end
      emptyBucketsInRow += 1
    else
      emptyBucketsInRow = 0
      while !isempty(buckets[currentBucket])
        node = pop!(buckets[currentBucket])
        for neighborEdge in graph.neighborsList[node]
          value = d[node] + neighborEdge.second
          if d[neighborEdge.first] > value
            if d[neighborEdge.first] == typemax(Int)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = value
              push!(buckets[value % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
            else
              delete!(buckets[d[neighborEdge.first] % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = value
              push!(buckets[value % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
            end
          end
        end  
      end
    end
  end
  return Pair(d, pred)
end

function dialForPair(graph::Graph, source::Int, target::Int)::Int
  d = [typemax(Int) for i in 1:graph.totalVertices]
  pred = [0 for i in 1:graph.totalVertices]

  d[source] = 0

  buckets::Array{Set{Int}} = [Set{Int}() for i in 0:graph.maxEdgeCost]
  currentBucket = 1
  emptyBucketsInRow = 0

  push!(buckets[currentBucket], source)

  while emptyBucketsInRow < graph.maxEdgeCost + 1
    if isempty(buckets[currentBucket])
      currentBucket += 1
      if currentBucket > graph.maxEdgeCost + 1
        currentBucket = 1
      end
      emptyBucketsInRow += 1
    else
      emptyBucketsInRow = 0
      while !isempty(buckets[currentBucket])
        node = pop!(buckets[currentBucket])
        if node == target
          return d[node]
        end
        for neighborEdge in graph.neighborsList[node]
          value = d[node] + neighborEdge.second
          if d[neighborEdge.first] > value
            if d[neighborEdge.first] == typemax(Int)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = value
              push!(buckets[value % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
            else
              delete!(buckets[d[neighborEdge.first] % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = value
              push!(buckets[value % (graph.maxEdgeCost + 1) + 1], neighborEdge.first)
            end
          end
        end  
      end
    end
  end
  return d[target]
end


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
          stats = @timed dialForAll(graph, source)
          timeTotal += stats.time
        end

        avgTime = timeTotal / length(sources)

        writeResultSources(pathOutput, pathGraph, pathSources, "dial", graph, graph.minEdgeCost, graph.maxEdgeCost, avgTime)

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
          global pathLength = dialForPair(graph, i, j)
          push!(pairsWithResults, (i, j, pathLength))
        end

        writeResultPairs(pathOutput, pathGraph, pathPairs, "dial", graph, graph.minEdgeCost, graph.maxEdgeCost, pairsWithResults)
        
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


