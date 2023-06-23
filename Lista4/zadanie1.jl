using DataStructures

mutable struct HyperCube
  k::Int
  totalVertices::Int
  edgesCapacities::Vector{Vector{Int}}
end

# w Julii LSB = 1 (indeksowanie tablic od 1)
# MSB = k

function getHyperCube(k::Int)::HyperCube
  totalVertices = 2^k
  edgesCapacities::Vector{Vector{Int}} = []
  for i in 0:totalVertices-1
    edgesForVertice::Vector{Int} = []
    for j in 0:(k-1)
      toggled = i ⊻ 2^j
      edgeCapacity = 0
      if (toggled > i)
        l = max(count_ones(i), (k-count_ones(i)), count_ones(toggled), (k-count_ones(toggled)))
        edgeCapacity = rand(1:(2^l))
      end
      push!(edgesForVertice, edgeCapacity)
    end
    push!(edgesCapacities, edgesForVertice)
  end
  # print(edgesCapacities, "\n")
  return HyperCube(k, totalVertices, edgesCapacities)
end      

function EdmondsKarpForHyperCube!(hyperCube::HyperCube)::Pair{Int, Int}
  flow = 0
  augmentingPathsCount = 0
  k = hyperCube.k
  while true
    pred = [-1 for i in 1:hyperCube.totalVertices]
    q = Queue{Int}()
    enqueue!(q, 0)
    while !isempty(q)
      currentNode = dequeue!(q)
      for i in 1:hyperCube.k
        neighborNode = currentNode ⊻ 2^(i-1) # gdyby graf był nieskierowany
        # print(currentNode, "|", neighborNode, "\n")
        if pred[neighborNode + 1] == -1 && neighborNode != 0 && hyperCube.edgesCapacities[currentNode+1][i] > 0
          pred[neighborNode + 1] = currentNode
          enqueue!(q, neighborNode)
        end
      end
    end

    # print(pred)
    if pred[2^k] == -1
      return Pair(flow, augmentingPathsCount)
    else
      augmentingPathsCount += 1
      flowToIncrease = typemax(Int) #maksymalna wartość przepływu jaką możemy puścić znalezioną ścieżką
      currentNode = 2^k-1
      while currentNode != 0
        previous = pred[currentNode+1]
        differingBit = round(Int, log2(previous ⊻ currentNode)) + 1
        flowToIncrease = min(flowToIncrease, hyperCube.edgesCapacities[previous+1][differingBit])
        currentNode = previous
      end
      currentNode = 2^k-1
      while currentNode != 0
        previous = pred[currentNode+1]
        differingBit = round(Int, log2(previous ⊻ currentNode)) + 1
        hyperCube.edgesCapacities[previous+1][differingBit] -= flowToIncrease
        hyperCube.edgesCapacities[currentNode+1][differingBit] += flowToIncrease
        currentNode = previous
      end
      flow += flowToIncrease
    end
  end
  return Pair(flow, augmentingPathsCount)
end


function getEdgesFlowFromResult(hyperCube::HyperCube)
  edges = []
  print("SZCZEGÓŁY PRZEPŁYWU: \n")
  for i in 0:(hyperCube.totalVertices)-1
    edgesForVertice::Vector{Int} = []
    for j in 0:(hyperCube.k)-1
      toggled = i ⊻ 2^j
      edgeCapacity = 0
      if (toggled > i)
        edgeCapacity = hyperCube.edgesCapacities[toggled+1][j+1]
        print(i, " -> ", toggled, " : ", edgeCapacity, "\n")
      end
      push!(edgesForVertice, edgeCapacity)
    end
    push!(edges, edgesForVertice)
  end
  return edges
end


if (length(ARGS) >= 2)
  if (string(ARGS[1]) == "--size")
    stats = @timed begin
      k = parse(Int, string(ARGS[2]))
      hyperCube = getHyperCube(k)
      println("Wygenerowano hiperkostkę o rozmiarze ", k)
      if (length(ARGS) >= 5)
        if (string(ARGS[3]) == "--printFlow" && string(ARGS[4]) == "--JuMP")
          filename = string(ARGS[5])
          open(filename, "w") do f
            write(f, "using JuMP\n")
            write(f, "import HiGHS\n")
            write(f, "G = zeros(Int,")
            write(f, string(hyperCube.totalVertices))
            write(f, ",")
            write(f, string(hyperCube.totalVertices))
            write(f, ")\n")
            write(f, "# Liczba x ma zapisane krawędzie w zmiennej f[x+1, :]\n")
            write(f, "# liczby z zakresu 0:n-1 -> macierz nxn\n")
            for i in 1:hyperCube.totalVertices
              write(f, "G[")
              write(f, string(i))
              write(f, ", :] = [")
              for j in 1:hyperCube.totalVertices
                if i != j && ceil(log2((i-1) ⊻ (j-1))) == floor(log2((i-1) ⊻ (j-1))) #wtedy liczby różnią się o jeden bit
                  write(f, string(hyperCube.edgesCapacities[i][round(Int, log2((i-1) ⊻ (j-1))) + 1]))
                else
                  write(f, "0")
                end
                  write(f, " ")
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
            write(f, "# warunek - nie przekraczamy ograniczeń górnych\n")
            write(f, "@constraint(max_flow, [i = 1:n, j = 1:n], f[i, j] <= G[i, j])\n")
            write(f, "# warunek zachowania balansu dla przepływu\n")
            write(f, "@constraint(max_flow, [i = 1:n; i != 1 && i != ")
            write(f, string(hyperCube.totalVertices))
            write(f, "], sum(f[i, :]) == sum(f[:, i]))\n")
            write(f, "# funkcja celu do maksymalizacji - przepływ wychodzący ze źródła\n")
            write(f, "@objective(max_flow, Max, sum(f[1, :]))\n")
            write(f, "optimize!(max_flow)\n")
            write(f, "print(\"Maksymalny przepływ: \")\n")
            write(f, "println(objective_value(max_flow))\n")
            write(f, "print(\"Czas działania samego solvera: \")\n")
            write(f, "println(solve_time(max_flow))\n")
            write(f, "#opcjonalne - drukuj szczegóły przepływu\n")
            write(f, "print(\"SZCZEGÓŁY PRZEPŁYWU: \\n\")\n")
            write(f, "for i in 1:n\n")
            write(f, "  for j in 1:")
            write(f, string(hyperCube.k))
            write(f, "\n")
            write(f, "    toggled = (i-1) ⊻ 2^(j-1)\n")
            write(f, "    edgeCapacity = 0\n")
            write(f, "    if (toggled > i-1)\n")
            write(f, "      edgeCapacity = value(f[i, toggled+1])\n")
            write(f, "      print(i-1, \" -> \", toggled, \" : \", edgeCapacity, \"\\n\")\n")
            write(f, "    end\n")
            write(f, "  end\n")
            write(f, "end\n")
          end
        end
      end
      flow, pathsCount = EdmondsKarpForHyperCube!(hyperCube)
      println("Maksymalny przepływ: ", flow)
      if (length(ARGS) >= 3)
        if (string(ARGS[3]) == "--printFlow")
          # getEdgesFlowFromResult(hyperCube)
        end
      end
    end
    print(stderr, stats.time)
    print(stderr, ";")
    print(stderr, pathsCount)
    print(stderr, "\n")
  
  elseif (string(ARGS[1]) == "--tests")
    for k in 15:16
      totalTime::Float64 = 0.0
      totalAugmentingPaths::Int128 = 0
      totalFlow::Int128 = 0
      for no in 1:100
        global stats = @timed begin
          global hyperCube = getHyperCube(k)
          global flow, pathsCount = EdmondsKarpForHyperCube!(hyperCube)
        end
        totalTime += stats.time
        totalAugmentingPaths += pathsCount
        totalFlow += flow
        println(no)
      end
      println(k, ";", (totalFlow / 1000.0), ";", (totalAugmentingPaths / 1000.0), ";", (totalTime / 1000.0))
    end
  end
else
  println("Błąd wywołania - niewystarczająca liczba argumentów")
end