include("graph.jl")
using .myGraph
using DataStructures

mutable struct Bucket
  minRange::Int
  maxRange::Int
  bucketWidth::Int
  container::PriorityQueue{Int, Int}
end


function radixHeapForAll(graph::Graph, source::Int)::Pair{Array{Int}, Array{Int}}
  buckets::Vector{Bucket} = []
  d::Array{Int} = [typemax(Int) for i in 1:graph.totalVertices]
  pred::Array{Int} = [0 for i in 1:graph.totalVertices]
  d[source] = 0

  # przygotowanie kubełków
  currentMaxRange::Int = 0
  currentMinRange::Int = 0
  currentWidth::Int = 1
  k::Int = 0
  push!(buckets, Bucket(currentMinRange, currentMaxRange, currentWidth, PriorityQueue{Int, Int}()))
  k += 1
  currentMaxRange = 2^k - 1
  currentMinRange = 2^(k-1)
  currentWidth = 2^(k-1)
  while (currentMaxRange < graph.totalVertices * graph.maxEdgeCost)
    push!(buckets, Bucket(currentMinRange, currentMaxRange, currentWidth, PriorityQueue{Int, Int}()))
    k += 1
    currentMaxRange = 2^k - 1
    currentMinRange = 2^(k-1)
    currentWidth = 2^(k-1)
  end

  enqueue!(buckets[1].container, source, 0)
  currentNonEmptyBucketIndex::Int = 1

  while currentNonEmptyBucketIndex < length(buckets)
    if (currentNonEmptyBucketIndex == 1 || currentNonEmptyBucketIndex == 2)
      #opróżnianie bez przenosin
      while (!isempty(buckets[currentNonEmptyBucketIndex].container))
        node::Int = dequeue!(buckets[currentNonEmptyBucketIndex].container)
        for neighborEdge in graph.neighborsList[node]
          value = d[node] + neighborEdge.second
          if d[neighborEdge.first] > value
            if d[neighborEdge.first] == typemax(Int)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = node
              # wstawienie sąsiada do kubełka - znalezienie mu odpowiedniego kubełka
              for i in currentNonEmptyBucketIndex:length(buckets)     
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  enqueue!(buckets[i].container, neighborEdge.first, d[neighborEdge.first])
                  break
                end
              end
              # gdy wcześniej etykieta sąsiada była inf to nie muszę się przejmować usuwaniem go (nie było go nigdzie)
            else
              # tu ten sąsiad gdzieś jest! zadbajmy o jego usunięcie
              previousNeighborBucketIndex = 0
              # usunięcie sąsiada 
              for i in currentNonEmptyBucketIndex:length(buckets)
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  delete!(buckets[i].container, neighborEdge.first)
                  previousNeighborBucketIndex = i
                  break
                end
              end
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = node
              # wstawienie sąsiada do kubełka bliższego niż tego, gdzie jest obecnie
              for i in previousNeighborBucketIndex:-1:1
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  enqueue!(buckets[i].container, neighborEdge.first, d[neighborEdge.first])
                  break
                end
              end
            end
          end
        end
      end
    else
      # przenosiny
      if (!isempty(buckets[currentNonEmptyBucketIndex].container))
        closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
        i = 1
        # zakresy nowych kubełków
        buckets[i].minRange = d[closestNode]
        buckets[i].maxRange = d[closestNode]
        enqueue!(buckets[i].container, closestNode, d[closestNode])
        currentMinRange = d[closestNode] + 1
        while (!isempty(buckets[currentNonEmptyBucketIndex].container))
          closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
          if (d[closestNode] == buckets[i].maxRange)
            enqueue!(buckets[i].container, closestNode, d[closestNode])
          else
            break
          end
        end
        i += 1
        while (currentMinRange <= buckets[currentNonEmptyBucketIndex].maxRange)
          buckets[i].minRange = currentMinRange
          buckets[i].maxRange = ((currentMinRange + buckets[i].bucketWidth - 1 < buckets[currentNonEmptyBucketIndex].maxRange) ? currentMinRange + buckets[i].bucketWidth - 1 : buckets[currentNonEmptyBucketIndex].maxRange)
          currentMinRange = buckets[i].maxRange + 1
          # przenosiny do kubełka
          if (d[closestNode] >= buckets[i].minRange && d[closestNode] <= buckets[i].maxRange)
            enqueue!(buckets[i].container, closestNode, d[closestNode])
          else
            i += 1
            continue
          end
          while (!isempty(buckets[currentNonEmptyBucketIndex].container))
            closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
            if (d[closestNode] >= buckets[i].minRange && d[closestNode] <= buckets[i].maxRange)
              enqueue!(buckets[i].container, closestNode, d[closestNode])
            else
              break
            end
          end
          i += 1
        end
        buckets[currentNonEmptyBucketIndex].maxRange = typemax(Int)
        buckets[currentNonEmptyBucketIndex].minRange = typemax(Int)
        currentNonEmptyBucketIndex = 0 # bo zostanie zinkrementowany
      end
    end
    currentNonEmptyBucketIndex += 1
  end

  return Pair(d, pred)
end

function radixHeapForPair(graph::Graph, source::Int, target::Int)::Int
  buckets::Vector{Bucket} = []
  d = [typemax(Int) for i in 1:graph.totalVertices]
  pred = [0 for i in 1:graph.totalVertices]
  d[source] = 0

  # przygotowanie kubełków
  currentMaxRange = 0
  currentMinRange = 0
  currentWidth = 1
  k = 0
  push!(buckets, Bucket(currentMinRange, currentMaxRange, currentWidth, PriorityQueue{Int, Int}()))
  k += 1
  currentMaxRange = 2^k - 1
  currentMinRange = 2^(k-1)
  currentWidth = 2^(k-1)
  while (currentMaxRange < graph.totalVertices * graph.maxEdgeCost)
    push!(buckets, Bucket(currentMinRange, currentMaxRange, currentWidth, PriorityQueue{Int, Int}()))
    k += 1
    currentMaxRange = 2^k - 1
    currentMinRange = 2^(k-1)
    currentWidth = 2^(k-1)
  end

  enqueue!(buckets[1].container, source, 0)
  currentNonEmptyBucketIndex = 1

  while currentNonEmptyBucketIndex < length(buckets)
    if (currentNonEmptyBucketIndex == 1 || currentNonEmptyBucketIndex == 2)
      #opróżnianie bez przenosin
      while (!isempty(buckets[currentNonEmptyBucketIndex].container))
        node = dequeue!(buckets[currentNonEmptyBucketIndex].container)
        if node == target
          return d[node]
        end
        for neighborEdge in graph.neighborsList[node]
          value = d[node] + neighborEdge.second
          if d[neighborEdge.first] > value
            if d[neighborEdge.first] == typemax(Int)
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = node
              # wstawienie sąsiada do kubełka - znalezienie mu odpowiedniego kubełka
              for i in currentNonEmptyBucketIndex:length(buckets)     
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  enqueue!(buckets[i].container, neighborEdge.first, d[neighborEdge.first])
                  break
                end
              end
              # gdy wcześniej etykieta sąsiada była inf to nie muszę się przejmować usuwaniem go (nie było go nigdzie)
            else
              # tu ten sąsiad gdzieś jest! zadbajmy o jego usunięcie
              previousNeighborBucketIndex = 0
              # usunięcie sąsiada 
              for i in currentNonEmptyBucketIndex:length(buckets)
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  delete!(buckets[i].container, neighborEdge.first)
                end
              end
              d[neighborEdge.first] = value
              pred[neighborEdge.first] = node
              # wstawienie sąsiada do kubełka bliższego niż tego, gdzie jest obecnie
              for i in previousNeighborBucketIndex;1:1
                if (d[neighborEdge.first] >= buckets[i].minRange && d[neighborEdge.first] <= buckets[i].maxRange)
                  enqueue!(buckets[i].container, neighborEdge.first, d[neighborEdge.first])
                  break
                end
              end
            end
          end
        end
      end
    else
      # przenosiny
      if (!isempty(buckets[currentNonEmptyBucketIndex].container))
        closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
        i = 1
        # zakresy nowych kubełków
        buckets[i].minRange = d[closestNode]
        buckets[i].maxRange = d[closestNode]
        enqueue!(buckets[i].container, closestNode, d[closestNode])
        currentMinRange = d[closestNode] + 1
        while (!isempty(buckets[currentNonEmptyBucketIndex].container))
          closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
          if (d[closestNode] == buckets[i].maxRange)
            enqueue!(buckets[i].container, closestNode, d[closestNode])
          else
            break
          end
        end
        i += 1
        while (currentMinRange <= buckets[currentNonEmptyBucketIndex].maxRange)
          buckets[i].minRange = currentMinRange
          buckets[i].maxRange = ((currentMinRange + buckets[i].bucketWidth - 1 < buckets[currentNonEmptyBucketIndex].maxRange) ? currentMinRange + buckets[i].bucketWidth - 1 : buckets[currentNonEmptyBucketIndex].maxRange)
          currentMinRange = buckets[i].maxRange + 1
          # przenosiny do kubełka
          if (d[closestNode] >= buckets[i].minRange && d[closestNode] <= buckets[i].maxRange)
            enqueue!(buckets[i].container, closestNode, d[closestNode])
          else
            i += 1
            continue
          end
          while (!isempty(buckets[currentNonEmptyBucketIndex].container))
            closestNode = dequeue!(buckets[currentNonEmptyBucketIndex].container)
            if (d[closestNode] >= buckets[i].minRange && d[closestNode] <= buckets[i].maxRange)
              enqueue!(buckets[i].container, closestNode, d[closestNode])
            else
              break
            end
          end
          i += 1
        end
        buckets[currentNonEmptyBucketIndex].maxRange = typemax(Int)
        buckets[currentNonEmptyBucketIndex].minRange = typemax(Int)
        currentNonEmptyBucketIndex = 0 # bo zostanie zinkrementowany
      end
    end
    currentNonEmptyBucketIndex += 1
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

        local timeTotal::Float64 = 0.0
        avgTime::Float64 = 0.0

        for source in sources
          stats = @timed radixHeapForAll(graph, source)
          timeTotal += stats.time
        end

        avgTime = timeTotal / length(sources)

        writeResultSources(pathOutput, pathGraph, pathSources, "radixheap", graph, graph.minEdgeCost, graph.maxEdgeCost, avgTime)

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

        pairsWithResults::Vector{Tuple{Int, Int, Int}} = []

        for pair in pairsToSolve
          i = pair.first
          j = pair.second
          global pathLength = radixHeapForPair(graph, i ,j)
          push!(pairsWithResults, (i, j, pathLength))
        end

        writeResultPairs(pathOutput, pathGraph, pathPairs, "radixheap", graph, graph.minEdgeCost, graph.maxEdgeCost, pairsWithResults)
        
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
