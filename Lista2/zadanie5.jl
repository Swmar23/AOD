# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 2 Zadanie 5
using JuMP, Printf
import DelimitedFiles
import HiGHS

function readFromFile(filename::String)
  data = DelimitedFiles.readdlm(filename, ';')
  rows = data[2:end, 1] # pierwsza kolumna ma opis rzędów
  columns = data[1, 2:end] # pierwszy wiersz ma opis kolumn
  return Containers.DenseAxisArray(data[2:end, 2:end], rows, columns)
end

function scheduleProduction(productsData::Containers.DenseAxisArray, machinesData::Containers.DenseAxisArray)
  products, machines = axes(productsData)
  machines = setdiff(machines, ["MAX_DEMAND", "PRICE", "MATERIAL_COSTS"])
  model = Model(HiGHS.Optimizer)
  set_silent(model)

  @variable(model, x[p in products] >= 0)

  @objective(
    model,
    Max,
    sum((productsData[p, "PRICE"] - sum((machinesData[m, "MACHINE_COST"] / 60.0) * productsData[p, m] for m in machines) - productsData[p, "MATERIAL_COSTS"]) * x[p] for p in products)
  )

  # warunek 1 - ilość wyprodukowanych produktów nie przekracza ich popyt
  @constraint(model, [p in products], x[p] <= productsData[p, "MAX_DEMAND"])

  # warunek 2 - maszyny nie pracują ponad normę
  @constraint(model, [m in machines], sum(x[p] * productsData[p, m] for p in products) <= machinesData[m, "UPTIME"])

  optimize!(model)

  println("Największy zysk: ", objective_value(model))

  println("Macierz produkcji:")

  print(join(lpad.(products, 12, ' ')))
  print("\n")
  for p in products
    print(" ", lpad(value(x[p]), 11, ' '))
  end
  print("\n")
  return
end

productsData = readFromFile(joinpath(@__DIR__, "zadanie5_productinfo.txt"))
machinesData = readFromFile(joinpath(@__DIR__, "zadanie5_machineinfo.txt"))

scheduleProduction(productsData, machinesData)
