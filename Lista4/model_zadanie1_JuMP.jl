using JuMP
import HiGHS
G = zeros(Int,16,16)
# Liczba x ma zapisane krawędzie w zmiennej f[x+1, :]
# liczby z zakresu 0:n-1 -> macierz nxn
G[1, :] = [0 8 7 0 12 0 0 0 15 0 0 0 0 0 0 0 ]
G[2, :] = [0 0 0 2 0 4 0 0 0 7 0 0 0 0 0 0 ]
G[3, :] = [0 0 0 1 0 0 8 0 0 0 7 0 0 0 0 0 ]
G[4, :] = [0 0 0 0 0 0 0 5 0 0 0 7 0 0 0 0 ]
G[5, :] = [0 0 0 0 0 6 3 0 0 0 0 0 2 0 0 0 ]
G[6, :] = [0 0 0 0 0 0 0 1 0 0 0 0 0 7 0 0 ]
G[7, :] = [0 0 0 0 0 0 0 8 0 0 0 0 0 0 7 0 ]
G[8, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 ]
G[9, :] = [0 0 0 0 0 0 0 0 0 5 1 0 1 0 0 0 ]
G[10, :] = [0 0 0 0 0 0 0 0 0 0 0 6 0 2 0 0 ]
G[11, :] = [0 0 0 0 0 0 0 0 0 0 0 4 0 0 1 0 ]
G[12, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9 ]
G[13, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 6 8 0 ]
G[14, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9 ]
G[15, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6 ]
G[16, :] = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
n = size(G)[1]
max_flow = Model(HiGHS.Optimizer)
set_silent(max_flow)
@variable(max_flow, f[1:n, 1:n] >= 0)

# wymuszenie zer tam, gdzie nie ma krawędzi
for i in 1:n, j in 1:n
  if G[i,j] == 0
    fix(f[i,j], 0.0; force = true)
  end
end
# warunek - nie przekraczamy ograniczeń górnych
@constraint(max_flow, [i = 1:n, j = 1:n], f[i, j] <= G[i, j])
# warunek zachowania balansu dla przepływu
@constraint(max_flow, [i = 1:n; i != 1 && i != 16], sum(f[i, :]) == sum(f[:, i]))
# funkcja celu do maksymalizacji - przepływ wychodzący ze źródła
@objective(max_flow, Max, sum(f[1, :]))
optimize!(max_flow)
print("Maksymalny przepływ: ")
println(objective_value(max_flow))
print("Czas działania samego solvera: ")
println(solve_time(max_flow))
#opcjonalne - drukuj szczegóły przepływu
print("SZCZEGÓŁY PRZEPŁYWU: \n")
for i in 1:n
  for j in 1:4
    toggled = (i-1) ⊻ 2^(j-1)
    edgeCapacity = 0
    if (toggled > i-1)
      edgeCapacity = value(f[i, toggled+1])
      print(i-1, " -> ", toggled, " : ", edgeCapacity, "\n")
    end
  end
end
