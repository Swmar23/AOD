# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 2 Zadanie 1
using JuMP, Printf
import DelimitedFiles
import HiGHS

function readFromFile(filename::String)
  data = DelimitedFiles.readdlm(filename, ';')
  rows = data[2:end, 1] # pierwsza kolumna ma opis rzędów
  columns = data[1, 2:end] # pierwszy wiersz ma opis kolumn
  return Containers.DenseAxisArray(data[2:end, 2:end], rows, columns)
end

function solveTransportationProblem(data::Containers.DenseAxisArray)
  companies, airports = axes(data)
  companies = setdiff(companies, ["DEMAND"]) # pozbywamy się pola DEMAND
  airports = setdiff(airports, ["SUPPLY"]) # pozbywamy się pola SUPPLY
  model = Model(HiGHS.Optimizer)
  set_silent(model)
  #zmienne - ile z danej firmy zostaje wysłane do danego lotniska (>= 0)
  @variable(model, x[c in companies, a in airports] >= 0) 
  #gdy dana firma nie może wysyłać do danego lotniska to wtedy w odpowiednim polu jest '.'
  for c in companies, a in airports
    if data[c, a] == "."
      fix(x[c, a], 0.0; force = true)
    end
  end
  #określenie funkcji celu oraz celu programu - minimalizacja tej funkcji
  @objective(
    model,
    Min,
    sum(data[c, a] * x[c, a] for c in companies, a in airports if data[c, a] != "."),
  )
  #ograniczenia: firmy nie mogą wysłać więcej niż ich podaż
  @constraint(model, [c in companies], sum(x[c, :]) <= data[c, "SUPPLY"])
  #ograniczenia: popyt lotnisk musi być zaspokojony
  @constraint(model, [a in airports], sum(x[:, a]) == data["DEMAND", a])
  optimize!(model)

  #drukowanie ładnie rozwiązania
  print("Minimalny łączny koszt dostaw: ")
  @printf("%.0f\n", sum(value(data[c, a]) * value(x[c, a]) for c in companies, a in airports if data[c, a] != "."))

  println("Macierz dostaw:")

  print("  ", join(lpad.(airports, 12, ' ')))
  for c in companies
    print("\n", c)
    for a in airports
      if isapprox(value(x[c, a]), 0.0; atol = 1e-6)
        print("           .")
      else
        print(" ", lpad(value(x[c, a]), 11, ' '))
      end
    end
  end
  print("\n")
  return
end

data = readFromFile(joinpath(@__DIR__, "zadanie1_data.txt"))
solveTransportationProblem(data)

