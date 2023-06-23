#!/bin/bash


echo "Long-C (dijkstra)"

for i in {0..15}
do
  echo "$i START"
	julia dijkstra.jl -d ch9-1.1/inputs/Long-C/Long-C.$i.0.gr -ss ch9-1.1/inputs/Long-C/Long-C.$i.0.ss -oss ch9-1.1/results/longc_$i.dijkstra
  echo "$i END"
done

echo "Long-C (dial)"

for i in {0..15}
do
  echo "$i START"
	julia dial.jl -d ch9-1.1/inputs/Long-C/Long-C.$i.0.gr -ss ch9-1.1/inputs/Long-C/Long-C.$i.0.ss -oss ch9-1.1/results/longc_$i.dial
  echo "$i END"
done

echo "Long-C (radixheap)"

for i in {0..15}
do
  echo "$i START"
	julia radixheap.jl -d ch9-1.1/inputs/Long-C/Long-C.$i.0.gr -ss ch9-1.1/inputs/Long-C/Long-C.$i.0.ss -oss ch9-1.1/results/longc_$i.radixheap
  echo "$i END"
done

echo "Long-n (dijkstra)"

for i in {10..21}
do
  echo "$i START"
	julia dijkstra.jl -d ch9-1.1/inputs/Long-n/Long-n.$i.0.gr -ss ch9-1.1/inputs/Long-n/Long-n.$i.0.ss -oss ch9-1.1/results/longn_$i.dijkstra
  echo "$i END"
done

echo "Long-n (dial)"

for i in {10..21}
do
  echo "$i START"
	julia dial.jl -d ch9-1.1/inputs/Long-n/Long-n.$i.0.gr -ss ch9-1.1/inputs/Long-n/Long-n.$i.0.ss -oss ch9-1.1/results/longn_$i.dial
  echo "$i END"
done

echo "Long-n (radixheap)"

for i in {10..21}
do
  echo "$i START"
	julia radixheap.jl -d ch9-1.1/inputs/Long-n/Long-n.$i.0.gr -ss ch9-1.1/inputs/Long-n/Long-n.$i.0.ss -oss ch9-1.1/results/longn_$i.radixheap
  echo "$i END"
done

echo "Random4-n (dijkstra)"

for i in {10..21}
do
  echo "$i START"
	julia dijkstra.jl -d ch9-1.1/inputs/Random4-n/Random4-n.$i.0.gr -ss ch9-1.1/inputs/Random4-n/Random4-n.$i.0.ss -oss ch9-1.1/results/random4n_$i.dijkstra
  echo "$i END"
done

echo "Random4-n (dial)"

for i in {10..21}
do
  echo "$i START"
	julia dial.jl -d ch9-1.1/inputs/Random4-n/Random4-n.$i.0.gr -ss ch9-1.1/inputs/Random4-n/Random4-n.$i.0.ss -oss ch9-1.1/results/random4n_$i.dial
  echo "$i END"
done

echo "Random4-n (radixheap)"

for i in {10..21}
do
  echo "$i START"
	julia radixheap.jl -d ch9-1.1/inputs/Random4-n/Random4-n.$i.0.gr -ss ch9-1.1/inputs/Random4-n/Random4-n.$i.0.ss -oss ch9-1.1/results/random4n_$i.radixheap
  echo "$i END"
done
echo "BAY start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.ss -oss ch9-1.1/results/USA-road-t.BAY.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.ss -oss ch9-1.1/results/USA-road-t.BAY.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.BAY.ss -oss ch9-1.1/results/USA-road-t.BAY.radixheap
echo "CAL start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.ss -oss ch9-1.1/results/USA-road-t.CAL.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.ss -oss ch9-1.1/results/USA-road-t.CAL.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CAL.ss -oss ch9-1.1/results/USA-road-t.CAL.radixheap
echo "COL start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.COL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.COL.ss -oss ch9-1.1/results/USA-road-t.COL.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.COL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.COL.ss -oss ch9-1.1/results/USA-road-t.COL.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.COL.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.COL.ss -oss ch9-1.1/results/USA-road-t.COL.radixheap
echo "CTR start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.ss -oss ch9-1.1/results/USA-road-t.CTR.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.ss -oss ch9-1.1/results/USA-road-t.CTR.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.CTR.ss -oss ch9-1.1/results/USA-road-t.CTR.radixheap
echo "E start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.E.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.E.ss -oss ch9-1.1/results/USA-road-t.E.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.E.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.E.ss -oss ch9-1.1/results/USA-road-t.E.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.E.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.E.ss -oss ch9-1.1/results/USA-road-t.E.radixheap
echo "FLA start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.ss -oss ch9-1.1/results/USA-road-t.FLA.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.ss -oss ch9-1.1/results/USA-road-t.FLA.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.FLA.ss -oss ch9-1.1/results/USA-road-t.FLA.radixheap
echo "LKS start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.ss -oss ch9-1.1/results/USA-road-t.LKS.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.ss -oss ch9-1.1/results/USA-road-t.LKS.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.LKS.ss -oss ch9-1.1/results/USA-road-t.LKS.radixheap
echo "NE start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NE.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NE.ss -oss ch9-1.1/results/USA-road-t.NE.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NE.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NE.ss -oss ch9-1.1/results/USA-road-t.NE.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NE.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NE.ss -oss ch9-1.1/results/USA-road-t.NE.radixheap
echo "NW start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NW.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NW.ss -oss ch9-1.1/results/USA-road-t.NW.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NW.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NW.ss -oss ch9-1.1/results/USA-road-t.NW.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NW.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NW.ss -oss ch9-1.1/results/USA-road-t.NW.radixheap
echo "NY start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NY.ss -oss ch9-1.1/results/USA-road-t.NY.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NY.ss -oss ch9-1.1/results/USA-road-t.NY.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.NY.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.NY.ss -oss ch9-1.1/results/USA-road-t.NY.radixheap
echo "W start"
julia dijkstra.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.W.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.W.ss -oss ch9-1.1/results/USA-road-t.W.dijkstra
julia dial.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.W.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.W.ss -oss ch9-1.1/results/USA-road-t.W.dial
julia radixheap.jl -d ch9-1.1/inputs/USA-road-t/USA-road-t.W.gr -ss ch9-1.1/inputs/USA-road-t/USA-road-t.W.ss -oss ch9-1.1/results/USA-road-t.W.radixheap