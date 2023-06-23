using DataStructures
using StatsBase

mutable struct BipartiteGraphForMaxFlow
  k::Int
  totalVertices::Int # source + 2^k v1 + 2^k v2 + target
  edgesCapacities::Vector{Dict{Int, Int}}  # kluczem jest wierzchołek, wartością pojemność z przedziału 0-1
end

# w Julii LSB = 1 (indeksowanie tablic od 1)
# MSB = k

function getBipartiteGraphForMaxFlow(k::Int, i::Int)::BipartiteGraphForMaxFlow
  totalVertices = 2^k + 2^k + 2
  edgesCapacities::Vector{Dict{Int, Int}} = [Dict{Int, Int}() for i in 1:totalVertices]
  # źródło
  for i in 2:2^k+1
    edgesCapacities[1][i] = 1
  end

  # v1 plus residualna
  for iter in 2:2^k+1
    edgesCapacities[iter][1] = 0   # bo tu tworzymy sieć residualną!
    possibleNeighbors = [j for j in (2^k+2):(2^(k+1)+1)]
    neighborsSelected = sample(possibleNeighbors, i, replace=false)
    for neighbor in neighborsSelected
      edgesCapacities[iter][neighbor] = 1
      edgesCapacities[neighbor][iter] = 0
    end
  end

  # v2 plus residualna
  for iter in 2^k+2:2^(k+1)+1
    edgesCapacities[iter][totalVertices] = 1
    edgesCapacities[totalVertices][iter] = 0
  end

  # print(edgesCapacities)
  return BipartiteGraphForMaxFlow(k, totalVertices, edgesCapacities)
end      

function EdmondsKarpForBipartiteMatching!(graph::BipartiteGraphForMaxFlow)::Int
  flow = 0
  while true
    pred = [-1 for i in 1:graph.totalVertices]
    q = Queue{Int}()
    enqueue!(q, 1)
    while !isempty(q)
      currentNode = dequeue!(q)
      for (neighbor, edgeCapacity) in graph.edgesCapacities[currentNode]
        if pred[neighbor] == -1 && neighbor != 1 && edgeCapacity > 0
          pred[neighbor] = currentNode
          enqueue!(q, neighbor)
        end
      end
    end

    # print(pred)
    if pred[graph.totalVertices] == -1
      return flow
    else
      flowToIncrease = typemax(Int) #maksymalna wartość przepływu jaką możemy puścić znalezioną ścieżką
      currentNode = graph.totalVertices
      while pred[currentNode] != -1
        previous = pred[currentNode]
        flowToIncrease = min(flowToIncrease, graph.edgesCapacities[previous][currentNode])
        currentNode = previous
      end
      currentNode = graph.totalVertices
      while pred[currentNode] != -1
        previous = pred[currentNode]
        graph.edgesCapacities[previous][currentNode] -= flowToIncrease
        graph.edgesCapacities[currentNode][previous] += flowToIncrease
        currentNode = previous
      end
      flow += flowToIncrease
    end
  end
  return flow
end


function getMatchingFromResult(graph::BipartiteGraphForMaxFlow)
  edges = []
  println("Wierzchołki ze zbioru V1 mają indeksy ze zbioru {2,...,", 2^(graph.k)+1, "}")
  println("Wierzchołki ze zbioru V2 mają indeksy ze zbioru {",2^(graph.k)+2, ",...,", 2^(graph.k+1)+1, "}")
  println("Dorobione źródło ma indeks 1, zaś dorobione ujście indeks ", graph.totalVertices)
  print("SZCZEGÓŁY SKOJARZENIA (krawędzie skojarzenia): \n")
  for i in 2:2^graph.k+1
    for (neighbor, capacityLeft) in graph.edgesCapacities[i]
      if (neighbor >= 2^graph.k+2 && neighbor < graph.totalVertices && capacityLeft == 0)
        println(i, " -> ", neighbor)
        push!(edges, Pair(i, neighbor))
      end
    end
  end
  return edges
end


if (length(ARGS) >= 4)
  if (string(ARGS[1]) == "--size")
    k = parse(Int, string(ARGS[2]))
    if (string(ARGS[3]) == "--degree")
      i = parse(Int, string(ARGS[4]))
      stats = @timed begin
        graph = getBipartiteGraphForMaxFlow(k, i)
        println("Wygenerowano graf dwudzielny o rozmiarze |V1| = ", k, ", |V2| = ", k, ", deg(v) = ", i)
        if (length(ARGS) >= 7)
          if (string(ARGS[5]) == "--printMatching" && string(ARGS[6]) == "--JuMP")
            filename = string(ARGS[7])
            open(filename, "w") do f
              write(f, "using JuMP\n")
              write(f, "import HiGHS\n")
              write(f, "G = zeros(Int,")
              write(f, string(graph.totalVertices))
              write(f, ",")
              write(f, string(graph.totalVertices))
              write(f, ")\n")
              for i in 1:graph.totalVertices
                write(f, "G[")
                write(f, string(i))
                write(f, ", :] = [")
                for j in 1:graph.totalVertices
                  if haskey(graph.edgesCapacities[i], j)
                    write(f, string(graph.edgesCapacities[i][j]))
                    write(f, " ")
                  else
                    write(f, "0 ")
                  end
                end
                write(f,"]\n")
              end
              write(f, "n = size(G)[1]\n")
              write(f, "max_flow = Model(HiGHS.Optimizer)\n")
              write(f, "set_silent(max_flow)\n")
              write(f, "@variable(max_flow, f[1:n, 1:n] >= 0)\n\n")

              write(f, "# wymuszenie zer tam, gdzie nie ma krawędzi\n")
              write(f, "for i in 1:n, j in 1:n\n")
              write(f, "  if G[i,j] == 0\n")
              write(f, "    fix(f[i,j], 0.0; force = true)\n")
              write(f, "  end\n")
              write(f, "end\n")
              write(f, "# warunek - nie przekraczamy ograniczeń górnych (tu po prostu każda krawędź użyta max raz)\n")
              write(f, "@constraint(max_flow, [i = 1:n, j = 1:n], f[i, j] <= G[i, j])\n")
              write(f, "# warunek zachowania balansu dla przepływu\n")
              write(f, "@constraint(max_flow, [i = 1:n; i != 1 && i != ")
              write(f, string(graph.totalVertices))
              write(f, "], sum(f[i, :]) == sum(f[:, i]))\n")
              write(f, "# funkcja celu do maksymalizacji - przepływ wychodzący ze źródła\n")
              write(f, "@objective(max_flow, Max, sum(f[1, :]))\n")
              write(f, "optimize!(max_flow)\n")
              write(f, "print(\"Maksymalne skojarzenie: \")\n")
              write(f, "println(objective_value(max_flow))\n")
              write(f, "print(\"Czas działania samego solvera: \")\n")
              write(f, "println(solve_time(max_flow))\n")
              write(f, "#opcjonalne - drukuj szczegóły skojarzenia\n")
              write(f, "println(\"SZCZEGÓŁY SKOJARZENIA\")\n")
              write(f, "for i in 2:n-1, j in 2:n-1\n")
              write(f, "  if value(f[i,j]) > 0\n")
              write(f, "    println(i, \" -> \", j)\n")
              write(f, "  end\n")
              write(f, "end\n")
            end
          end
        end
        flow = EdmondsKarpForBipartiteMatching!(graph)
        println("Maksymalny przepływ: ", flow)
        if (length(ARGS) >= 5)
          if (string(ARGS[5]) == "--printMatching")
            getMatchingFromResult(graph)
          end
        end
      end
      print(stderr, stats.time)
      print(stderr, "\n")
    end
  elseif (string(ARGS[1]) == "--tests")
    for k in 3:10
      for i in 1:k
        totalTime::Float64 = 0.0
        totalMatching::Int128 = 0
        for no in 1:1000
          global stats = @timed begin
            global graph = getBipartiteGraphForMaxFlow(k, i)
            global flow = EdmondsKarpForBipartiteMatching!(graph)
          end
          totalTime += stats.time
          totalMatching += flow
        end
        println(k, ";", i, ";", (totalMatching / 1000.0), ";", (totalTime / 1000.0))
      end
    end
  end
else
  println("Błąd wywołania - niewystarczająca liczba argumentów")
end