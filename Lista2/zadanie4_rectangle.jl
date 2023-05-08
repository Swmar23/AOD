# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 2 Zadanie 4
using JuMP, Printf
import DelimitedFiles
import HiGHS

function getCameraPlacement(data, k)
  model = Model(HiGHS.Optimizer)
  set_silent(model)
  n = size(data)[1]
  m = size(data)[2]

  #zmienne - czy w danym miejscu znajdzie się kontener
  @variable(model, x[1:n, 1:m], Bin)

  # nie możemy postawić kamery tam, gdzie już jest kontener
  for i in 1:n
    for j in 1:m
      if data[i, j] == 1
        fix(x[i, j], 0.0; force = true)
      end
    end
  end

  # warunek: każdy kontener jest obserwowany
  @constraint(model, [i = 1:n, j = 1:m; data[i, j] == 1], sum(x[l, o] for l in ((i-k) < 1 ? 1 : (i-k)):((i+k) > n ? n : (i+k)), o in ((j-k) < 1 ? 1 : (j-k)):((j+k) > m ? m : (j+k))) >= 1)
  @objective(model, Min, sum(x[i, j] for i in 1:n, j in 1:m))
  optimize!(model)
  println("Liczba potrzebnych kamer: ",  objective_value(model), ". Macierz kamer: ")
  for i in 1:n
      for j in 1:m
        if value(data[i, j]) == 1
          @printf("k ")
        else
          @printf("%.0f ", value(x[i, j]))
        end
      end
      print("\n")
  end
end


filenameData = joinpath(@__DIR__, "zadanie4_data2.txt")
data = DelimitedFiles.readdlm(filenameData, ';')
for k in 1:9
  println("*************[k = ", k, "]****************")
  getCameraPlacement(data, k)
end