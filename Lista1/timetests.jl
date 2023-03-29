include("graph.jl")
using .myGraph
using DataStructures

avgTime = Vector{Float64}()
names = ["g2a-1.txt", "g2a-2.txt", "g2a-3.txt", "g2a-4.txt", "g2a-5.txt", "g2a-6.txt", "g2b-1.txt", "g2b-2.txt", "g2b-3.txt", "g2b-4.txt", "g2b-5.txt", "g2b-6.txt", 
"g3-1.txt", "g3-2.txt", "g3-3.txt", "g3-4.txt", "g3-5.txt", "g3-6.txt", 
"d4a-1.txt", "d4a-2.txt", "d4a-3.txt", "d4a-4.txt", "d4a-5.txt", "d4a-6.txt", "d4b-1.txt", "d4b-2.txt", "d4b-3.txt", "d4b-4.txt", "d4b-5.txt", "d4b-6.txt",
"u4a-1.txt", "u4a-2.txt", "u4a-3.txt", "u4a-4.txt", "u4a-5.txt", "u4a-6.txt", "u4b-1.txt", "u4b-2.txt", "u4b-3.txt", "u4b-4.txt", "u4b-5.txt", "u4b-6.txt"]


cd("aod_testy1/2")
# rozruch
startGraph = readGraphFromFile("g2a-1.txt")
  for i in 1:100
    stats = @timed topologicalSort(startGraph)
  end


for name in names[1:12]
  graph = readGraphFromFile(name)
  sumTime = Float64(0.0)
  for i in 1:100
    stats = @timed topologicalSort(graph)
    sumTime += stats.time
  end
  println(name)
  push!(avgTime, sumTime/100.0)
end
cd("..")
cd("3")
for name in names[13:18]
  graph = readGraphFromFile(name)
  sumTime = Float64(0.0)
  for i in 1:100
    stats = @timed getStronglyConnectedComponents(graph)
    sumTime += stats.time
  end
  println(name)
  push!(avgTime, sumTime/100.0)
end
cd("..")
cd("4")
for name in names[19:42]
  graph = readGraphFromFile(name)
  sumTime = Float64(0.0)
  for i in 1:100
    stats = @timed isGraphBipartite(graph)
    sumTime += stats.time
  end
  println(name)
  push!(avgTime, sumTime/100.0)
end

open("time_results.txt", "w") do file
  for i in 1:length(avgTime)
    x = avgTime[i]
    y = names[i]
    write(file, "$y & $x \\\\\\hline \n")
  end
end