include("graph.jl")
using .myGraph
using DataStructures
using Test

cd("aod_testy1/2")
@testset "$(rpad("Zadanie 2", 30))" begin
  for name in ["g2a-1.txt", "g2a-2.txt", "g2a-3.txt", "g2a-4.txt", "g2a-5.txt", "g2a-6.txt", "g2a-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = topologicalSort(graph)
    @test result[1] == true
  end
  for name in ["g2b-1.txt", "g2b-2.txt", "g2b-3.txt", "g2b-4.txt", "g2b-5.txt", "g2b-6.txt", "g2b-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = topologicalSort(graph)
    @test result[1] == false
  end
end
cd("..")
cd("3")
@testset "$(rpad("Zadanie 3", 30))" begin
  for name in ["g3-1.txt", "g3-2.txt", "g3-3.txt", "g3-4.txt", "g3-5.txt", "g3-6.txt"]
    graph = readGraphFromFile(name) 
    result = getStronglyConnectedComponents(graph)
    @test length(result) == 5
  end
  graph = readGraphFromFile("g3-ss.txt")
  result = getStronglyConnectedComponents(graph)
  @test length(result) == 1
  graph = readGraphFromFile("g3-nss.txt")
  result = getStronglyConnectedComponents(graph)
  @test length(result) == 8
end
cd("..")
cd("4")
@testset "$(rpad("Zadanie 4", 30))" begin
  for name in ["d4a-1.txt", "d4a-2.txt", "d4a-3.txt", "d4a-4.txt", "d4a-5.txt", "d4a-6.txt", "d4a-wlasny.txt", "u4a-1.txt", "u4a-2.txt", "u4a-3.txt", "u4a-4.txt", "u4a-5.txt", "u4a-6.txt", "u4a-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = isGraphBipartite(graph)
    @test result[1] == true
  end
  for name in ["d4b-1.txt", "d4b-2.txt", "d4b-3.txt", "d4b-4.txt", "d4b-5.txt", "d4b-6.txt", "d4b-wlasny.txt", "u4b-1.txt", "u4b-2.txt", "u4b-3.txt", "u4b-4.txt", "u4b-5.txt", "u4b-6.txt", "u4b-wlasny.txt"]
    graph = readGraphFromFile(name) 
    result = isGraphBipartite(graph)
    @test result[1] == false
  end
end