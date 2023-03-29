include("graph.jl")
using .myGraph
using DataStructures

open("tests_results.txt", "w") do file
  write(file, "Zadanie 1 (nazwa | rozmiar instancji (n+m) | tablica przejścia DFS | tablica przejścia BFS) \n")
  for name in ["g1d-1.txt", "g1d-2.txt", "g1d-3.txt", "g1d-4.txt", "g1u-1.txt", "g1u-2.txt", "g1u-3.txt", "g1u-4.txt"]
    graph = readGraphFromFile(name) 
    resultDFS = DFS(graph, false)
    resultBFS = BFS(graph, 1, false)
    instanceSize = graph.totalVertices + graph.edgesNo
    write(file, "$name | $instanceSize | $resultDFS | $resultBFS \n")
  end
  cd("aod_testy1/2")
  write(file, "\n\nZadanie 2 (nazwa | rozmiar instancji (n+m) | czy acykliczny (sortowalny) | dla n <= 200 porządek topologiczny) \n")
  for name in ["g2a-1.txt", "g2a-2.txt", "g2a-3.txt", "g2a-4.txt", "g2a-5.txt", "g2a-6.txt", "g2a-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = topologicalSort(graph)
    instanceSize = graph.totalVertices + graph.edgesNo
    isSortable = result[1]
    if graph.totalVertices <= 200 && isSortable
      orderList = result[2]
      write(file, "$name | $instanceSize | $isSortable | $orderList \n")
    else
      write(file, "$name | $instanceSize | $isSortable \n")
    end
  end
  for name in ["g2b-1.txt", "g2b-2.txt", "g2b-3.txt", "g2b-4.txt", "g2b-5.txt", "g2b-6.txt", "g2b-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = topologicalSort(graph)
    isSortable = result[1]
    instanceSize = graph.totalVertices + graph.edgesNo
    if graph.totalVertices <= 200 && isSortable
      orderList = result[2]
      write(file, "$name | $instanceSize | $isSortable | $orderList \n")
    else
      write(file, "$name | $instanceSize | $isSortable \n")
    end
  end
  cd("..")
  cd("3")
  write(file, "\n\nZadanie 3 (nazwa | rozmiar instancji (n+m) | liczba składowych spójnych | liczba wierzchołków w składowych | gdy n <= 200 wypisane składowe) \n")
  for name in ["g3-1.txt", "g3-2.txt", "g3-3.txt", "g3-4.txt", "g3-5.txt", "g3-6.txt", "g3-ss.txt", "g3-nss.txt"]
    graph = readGraphFromFile(name) 
    result = getStronglyConnectedComponents(graph)
    instanceSize = graph.totalVertices + graph.edgesNo
    componentsNo = length(result)
    componentsSizes = Vector{Int}()
    for component in result
      push!(componentsSizes, length(component))
    end
    if graph.totalVertices <= 200
      write(file, "$name | $instanceSize | $componentsNo | $componentsSizes | $result \n")
    else
      write(file, "$name | $instanceSize | $componentsNo | $componentsSizes \n")
    end
  end
  cd("..")
  cd("4")
  write(file, "\n\nZadanie 4 (nazwa | rozmiar instancji (n+m) | czy dwudzielny | dla n <= 200 v0 | v1) \n")
  for name in ["d4a-1.txt", "d4a-2.txt", "d4a-3.txt", "d4a-4.txt", "d4a-5.txt", "d4a-wlasny.txt", "d4a-6.txt", "u4a-1.txt", "u4a-2.txt", "u4a-3.txt", "u4a-4.txt", "u4a-5.txt", "u4a-6.txt", "u4a-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = isGraphBipartite(graph)
    instanceSize = graph.totalVertices + graph.edgesNo
    isBipartite = result[1]
    if graph.totalVertices <= 200 && isBipartite
      verticesColor = result[2]
      set1 = Vector{Int}()
      set2 = Vector{Int}()
      for i in 1:graph.totalVertices
        if verticesColor[i] == 0
          push!(set1, i)
        end
      end
      for i in 1:graph.totalVertices
        if verticesColor[i] == 1
          push!(set2, i)
        end
      end
      write(file, "$name | $instanceSize | $isBipartite | $set1 | $set2 \n")
    else
      write(file, "$name | $instanceSize | $isBipartite \n")
    end
  end
  for name in ["d4b-1.txt", "d4b-2.txt", "d4b-3.txt", "d4b-4.txt", "d4b-5.txt", "d4b-6.txt", "d4b-wlasny.txt", "u4b-1.txt", "u4b-2.txt", "u4b-3.txt", "u4b-4.txt", "u4b-5.txt", "u4b-6.txt", "u4b-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = isGraphBipartite(graph)
    instanceSize = graph.totalVertices + graph.edgesNo
    isBipartite = result[1]
    if graph.totalVertices <= 200 && isBipartite
      verticesColor = result[2]
      set1 = Vector{Int}()
      set2 = Vector{Int}()
      for i in 1:graph.totalVertices
        if verticesColor[i] == 0
          push!(set1, i)
        end
      end
      for i in 1:graph.totalVertices
        if verticesColor[i] == 1
          push!(set2, i)
        end
      end
      write(file, "$name | $instanceSize | $isBipartite | $set1 | $set2 \n")
    else
      write(file, "$name | $instanceSize | $isBipartite \n")
    end
  end
end