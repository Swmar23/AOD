# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 2 Zadanie 3
using JuMP, Printf
import DelimitedFiles
import HiGHS

function readFromFile(filename::String)
  data = DelimitedFiles.readdlm(filename, ';')
  rows = data[2:end, 1] # pierwsza kolumna ma opis rzędów
  columns = data[1, 2:end] # pierwszy wiersz ma opis kolumn
  return Containers.DenseAxisArray(data[2:end, 2:end], rows, columns)
end

function solveCirculationProblem(minData::Containers.DenseAxisArray, maxData::Containers.DenseAxisArray)
  precints, shifts = axes(minData)
  precints = setdiff(precints, ["MIN_SHIFT"]) # pozbywamy się pola DEMAND
  shifts = setdiff(shifts, ["MIN_PRECINT"]) # pozbywamy się pola SUPPLY
  model = Model(HiGHS.Optimizer)
  set_silent(model)

  #zmienne - ile dla danej dzielnicy jest przydzielonych radiowozów na danej zmianie
  #dziedzina zmiennych zgodna z tabelami minimalnych i maksymalnych liczb radiowozów
  @variable(model, minData[p, s] <= x[p in precints, s in shifts] <= maxData[p, s]) 

  #zmienne pomocnicze, które określają liczbę radiowozów użytą na danej zmianie
  @variable(model, helpers[s in shifts] >= 0)

  #zmienna, którą chcemy minimalizować, będąca maksimum z liczby radiowozów użytych na zmianach
  @variable(model, target >= 0)

  #określenie funkcji celu oraz celu programu - minimalizacja tej funkcji
  @objective(
    model,
    Min,
    target,
  )

  #ograniczenia: łączna liczba radiowozów dla danej zmiany nie mniejsza niż MIN_SHIFT
  @constraint(model, [s in shifts], sum(x[:, s]) >= minData["MIN_SHIFT", s])
  #ograniczenia: łączna liczba radiowozów dla danej dzielnice nie mniejsza niż MIN_PRECINT
  @constraint(model, [p in precints], sum(x[p, :]) >= minData[p, "MIN_PRECINT"]) 

  #ograniczenie definiujące działąnie zmiennych pomocniczych - są one co najmniej sumą liczby radiowozów na danej zmianie
  @constraint(model, [s in shifts], sum(x[:, s]) <= helpers[s])

  #ograniczenie definiujące działania zmiennej docelowo minimalizowanej - jest ona większa od każdej ze zmiennych pomocniczych
  #ponieważ ją chcemy minimalizować, to ostatecznie będzie po prostu równa maksimum ze zmienny pomocniczych określających sumę
  #radiowozów na danej zmianie
  @constraint(model, [s in shifts], target >= helpers[s])

  optimize!(model)

  #drukowanie ładnie rozwiązania
  print("Minimalna całkowita liczba radiowozów: ")
  println(objective_value(model))
  println("Macierz radiowozów:")

  print("  ", join(lpad.(shifts, 12, ' ')))
  for p in precints
      print("\n", p)
      for s in shifts
          if isapprox(value(x[p, s]), 0.0; atol = 1e-6)
              print("           .")
          else
              print(" ", lpad(value(x[p, s]), 11, ' '))
          end
      end
  end
  print("\n")
  return
end

minData = readFromFile(joinpath(@__DIR__, "zadanie3_min.txt"))
maxData = readFromFile(joinpath(@__DIR__, "zadanie3_max.txt"))
solveCirculationProblem(minData, maxData)

