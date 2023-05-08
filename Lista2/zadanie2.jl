# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 2 Zadanie 2
using JuMP, Printf
import DelimitedFiles
import HiGHS

# drukować macierz dla ułmaków
function printPath(array, startVertice, endVertice)
  for i in 1:size(array)[1]
    if value(array[startVertice, i]) == 1
      print("->",i)
      if i != endVertice
        printPath(array, i, endVertice)
      end
      return
    end
  end  
end

function printVariables(array)
  for i in 1:size(array)[1]
    for j in 1:size(array)[2]
      print(lpad(round(value(array[i, j]), digits=3), 6, ' '))
    end
    print("\n")
  end
end


function solveCSP(costs, times, startVertice, endVertice, maxTime)
  model = Model(HiGHS.Optimizer)
  set_silent(model)
  n = size(costs)[1]
  # tablica zapotrzebowania węzłów (balance)
  b = zeros(n)
  b[startVertice] = 1 #wychodzi jeden ładunek
  b[endVertice] = -1 #wchodzi jeden ładunek

  # zmienne - czy bierzemy daną krawędź, czy nie
  @variable(model, x[1:n, 1:n] >= 0.0)

  #warunki na niewykorzystwanie nieistniejących krawędzi (zerowy koszt i czas)
  @constraint(model, [i = 1:n, j = 1:n; costs[i, j] == 0], x[i, j] == 0)
  @constraint(model, [i = 1:n, j = 1:n; times[i, j] == 0], x[i, j] == 0)

  # warunek na poprawność ścieżki
  @constraint(model, [i = 1:n], sum(x[i, :]) - sum(x[:, i]) == b[i])

  # warunek maksymalnego czasu
  @constraint(model, sum(times .* x) <= maxTime)

  # funkcja celu do minimalizacji
  @objective(model, Min, sum(costs .* x))
  optimize!(model)
  print("Koszt najtańszej ścieżki ", startVertice, "->...->", endVertice, " o jej czasie wynoszącym maksymalnie ", maxTime, ": ")
  println(objective_value(model))
  println("Czas ścieżki: ",  sum(value(times[c, a]) * value(x[c, a]) for c in 1:n, a in 1:n))
  # println("Przebieg ścieżki:")
  # print(startVertice)
  # printPath(x, startVertice, endVertice)
  println("Macierz zmiennych decyzyjnych: ")
  printVariables(x)
  print("\n")
end

filenameCosts = joinpath(@__DIR__, "zadanie2_costs.txt")
costs = DelimitedFiles.readdlm(filenameCosts, ';')
filenameTimes = joinpath(@__DIR__, "zadanie2_times.txt")
times = DelimitedFiles.readdlm(filenameTimes, ';')
solveCSP(costs, times, 9, 2, 23)
println("**********************")
solveCSP(costs, times, 9, 2, 22)


