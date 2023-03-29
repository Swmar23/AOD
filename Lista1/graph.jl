# Marek Świergoń 261750 Algorytmy Optymalizacji Dyskretnej Lista 1

module myGraph
export Graph, readGraphFromFile, newGraph, DFS, BFS, topologicalSort, getStronglyConnectedComponentsRecursive, getStronglyConnectedComponents, isGraphBipartite
using DataStructures
using AbstractTrees

# Struktura drzewa przesukiwań BFS/DFS
mutable struct SearchTreeNode
  verticeNo::Int
  childrenList::Vector{SearchTreeNode}
end

#definicje potrzebne do drukowania drzewa
AbstractTrees.children(node::SearchTreeNode) = something(node.childrenList)
AbstractTrees.nodevalue(node::SearchTreeNode) = node.verticeNo
AbstractTrees.printnode(io::IO, node::SearchTreeNode) = print(io, node.verticeNo)

"""
Proponowana struktura grafu.
Wierzchołki numerowane od 1 do totalVertices:
* totalVertices - liczba wierzchołków
* isDirected - czy graf jest skierowany (True jeśli jest)
* edgesNo - liczba krawędzi
* neighborsList - lista sąsiadów, np. graph.adjacencyList[3] to lista sąsiadów
                  wierzchołka 3
"""
mutable struct Graph
  totalVertices::Int
  isDirected::Bool
  edgesNo::UInt32
  neighborsList::Array{Vector{Int}}
end

function newGraph(totalVertices::Int, isDirected::Bool, edges::Vector{Tuple{Int, Int}})
  neighborsList = Array{Vector{Int}}(undef, totalVertices)
  fill!(neighborsList, nil(Int))
  for edge in edges
    push!(neighborsList[edge[1]], edge[2])
  end
  return Graph(totalVertices, isDirected, len(edges), neighborsList)
end

function readGraphFromFile(filename::String)
  open(filename) do file
    args = split(readline(file))
    flag = args[1]
    isDirected = false
    if (flag == "D")
      isDirected = true
    elseif (flag == "U")
      # isDirected = false
    else
      error("Nieznana flaga w pierwszej linii pliku!")
    end
    totalVertices = parse(Int, readline(file))
    neighborsList::Array{Vector{Int}} = [ [] for i in 1:totalVertices]
    edgesNo = parse(UInt32, readline(file))
    if(isDirected)
      while !eof(file)
        line = split(readline(file))
        u = parse(Int, line[1])
        v = parse(Int, line[2])
        push!(neighborsList[u], v)
        
      end
    else
      while !eof(file)
        line = split(readline(file))
        u = parse(Int, line[1])
        v = parse(Int, line[2])
        push!(neighborsList[u], v)
        push!(neighborsList[v], u)
      end
    end
    return Graph(totalVertices, isDirected, edgesNo, neighborsList)
  end
end

# ****************************************************************
# Zadanie 1 - metody, algorytmy

"""
Iteracyjne mplementacja algorytmu poszukiwania wszerz BFS.

Input:
* graph - analizowany graf (wierzchołki numerowane od 1 do n)
* startingVertice - wierzchołek startowy
* printTree - zmienna Bool decydująca o tym, czy algorytm ma drukować drzewo BFS
"""
function DFS(graph::Graph, printTree::Bool)::Vector{Int} #iteratywna wersja 
  DFSTraversal = Vector{Int}()
  if (printTree == false)
    visited = [false for i in 1:graph.totalVertices]
    for vertice in 1:graph.totalVertices
      if visited[vertice] == false
        s = Stack{Int}()
        push!(s, vertice)
        while(isempty(s) == false)
          currentVertice = pop!(s)
          if (visited[currentVertice] == false)
            push!(DFSTraversal, currentVertice)
            visited[currentVertice] = true
            for neighbor in graph.neighborsList[currentVertice]
              if visited[neighbor] == false
                push!(s, neighbor)
              end
            end
          end
        end
      end
    end
  else
    nodes = [SearchTreeNode(i,[]) for i in 1:graph.totalVertices]
    visited = [false for i in 1:graph.totalVertices]
    treeRoots = Vector{Int}()
    for vertice in 1:graph.totalVertices
      if visited[vertice] == false
        s = Stack{Tuple{Int, Int}}() # pierwszy int to wierzchołek, drugi to ojciec
        push!(s, (vertice, 0))
        while(isempty(s) == false)
          stackElement = pop!(s)
          currentVertice = stackElement[1]
          father = stackElement[2]
          if (visited[currentVertice] == false)
            if father != 0
              push!(nodes[father].childrenList, nodes[currentVertice])
            end
            push!(DFSTraversal, currentVertice)
            visited[currentVertice] = true
            for neighbor in graph.neighborsList[currentVertice]
              if visited[neighbor] == false
                push!(s, (neighbor, currentVertice))
              end
            end
          end
        end
        push!(treeRoots, vertice)
      end
    end
    println("Drzewo (las) DFS:")
    for vertNo in treeRoots
      print_tree(nodes[vertNo])
    end
  end
  return DFSTraversal
end

"""
Implementacja algorytmu poszukiwania wszerz BFS.

Input:
* graph - analizowany graf (wierzchołki numerowane od 1 do n)
* startingVertice - wierzchołek startowy
* printTree - zmienna Bool decydująca o tym, czy algorytm ma drukować drzewo BFS
"""
function BFS(graph::Graph, startingVertice::Int, printTree::Bool)::Vector{Int}
  BFSTraversal = Vector{Int}()
  if printTree == false
    distances = [typemax(Int) for i in 1:graph.totalVertices]
    distances[startingVertice] = 0
    queue = Queue{Int}()   
    enqueue!(queue, startingVertice)
    while isempty(queue) == false
      u = dequeue!(queue)
      push!(BFSTraversal, u)
      for neighbor in graph.neighborsList[u]
        if distances[neighbor] == typemax(Int)
          enqueue!(queue, neighbor)
          distances[neighbor] = distances[u] + 1
        end
      end
    end
  else
    nodes = [SearchTreeNode(i,[]) for i in 1:graph.totalVertices]
    # jest tylko jeden treeRoot, nie potrzeba więcej
    distances = [typemax(Int) for i in 1:graph.totalVertices]
    distances[startingVertice] = 0
    queue = Queue{Int}() # pierwszy int to wierzchołek, drugi to ojciec
    enqueue!(queue, startingVertice)
    while isempty(queue) == false
      u = dequeue!(queue)
      push!(BFSTraversal, u)
      for neighbor in graph.neighborsList[u]
        if distances[neighbor] == typemax(Int)
          enqueue!(queue, neighbor)
          distances[neighbor] = distances[u] + 1
          push!(nodes[u].childrenList, nodes[neighbor])
        end
      end
    end
    println("Drzewo BFS:")
    print_tree(nodes[startingVertice])
  end
  return BFSTraversal
end


#************************************************************************************
# Zadanie 2 - metody, algorytmy

# algorytm oparty na idei algorytmu Kahna, złożoność to O(|E|+|V|)
"""
Metoda zwracająca porządek topologiczny grafu oraz informację o tym, czy graf ma cykl.

Input:
* graph - graf do przeanalizowania (wierzchołki numerowane od 1 do n)

Output - para postaci (hasOrder, orderList):
* hasOrder - zmienna typu Bool informująca o tym czy graf można uporządkować 
             (gdy nie to znaczy, że ma skierowany cykl)
* orderList - porządek topologiczny grafu
              (gdy hasOrder = false to orderList = [])
"""
function topologicalSort(graph::Graph)::Tuple{Bool, Vector{Int}}
  inDegrees = [0 for i in 1:graph.totalVertices]
  orderList = [0 for i in 1:graph.totalVertices] # tu znajdzie się porządek topologiczny
  # pętle wyliczające inDeg dla każdego wierzchołka (O(|E|))
  for i in 1:graph.totalVertices
    for inVertice in graph.neighborsList[i]
      inDegrees[inVertice] += 1
    end
  end
  queue = Queue{Int}() # kolejka by sprawnie zachować kolejność (FIFO)
  next = 0
  # na listę umieszczamy wszystkie wierzchołki z inDeg = 0
  for i in 1:graph.totalVertices
    if inDegrees[i] == 0
      enqueue!(queue, i)
    end
  end
  while isempty(queue) == false
    currentVertice = dequeue!(queue)
    next += 1
    orderList[next] = currentVertice #umieszczamy wierzchołek z listy na pierwsze wolne miejsce
    for neighbor in graph.neighborsList[currentVertice]
      inDegrees[neighbor] -= 1
      if inDegrees[neighbor] == 0
        enqueue!(queue, neighbor)
      end
    end
  end
  if next < graph.totalVertices
    return (false, [])
  else
    return (true, orderList)
  end
end

#************************************************************************************
# Zadanie 3 - metody, algorytmy wersja rekurencyjna, słaba dla dużych danych!

function transposeGraph(graph::Graph)::Graph
  newNeighborsList::Array{Vector{Int}} = [ [] for i in 1:graph.totalVertices]
  for i in 1:graph.totalVertices
    for neighbor in graph.neighborsList[i]
      push!(newNeighborsList[neighbor], i)
    end
  end
  returnGraph = Graph(graph.totalVertices, graph.isDirected, graph.edgesNo, newNeighborsList)
  return returnGraph
end

function explore!(graph::Graph, vertice::Int, visited::Vector{Bool}, postValuesOrder::Vector{Int}) #zmianie ulega tablica visited oraz postValuesOrder
  visited[vertice] = true
  for neighbor in graph.neighborsList[vertice]
    if visited[neighbor] == false
      explore!(graph, neighbor, visited, postValuesOrder)
    end
  end
  push!(postValuesOrder, vertice)
end

function DFSRecursivePostValue(graph::Graph)::Vector{Int} #zwraca wierzchołki w kolejności malejącej wartości post
  visited = [false for i in 1:graph.totalVertices]
  postValuesOrder = Vector{Int}()
  for vertice in 1:graph.totalVertices
    if visited[vertice] == false
      explore!(graph, vertice, visited, postValuesOrder)
    end
  end
  reverse!(postValuesOrder)
  return postValuesOrder
end

function exploreForComponents!(graph::Graph, vertice::Int, visited::Vector{Bool}, currentComponent::Vector{Int}) #zmianie ulega tablica visited oraz postValuesOrder
  visited[vertice] = true
  for neighbor in graph.neighborsList[vertice]
    if visited[neighbor] == false
      explore!(graph, neighbor, visited, currentComponent)
    end
  end
  push!(currentComponent, vertice)
end

function DFSRecursiveForComponents(graph::Graph, postValuesOrder::Vector{Int})::Vector{Vector{Int}} #zwraca komponenty
  visited = [false for i in 1:graph.totalVertices]
  components = Vector{Vector{Int}}()
  for vertice in postValuesOrder
    currentComponent = Vector{Int}()
    if visited[vertice] == false
      exploreForComponents!(graph, vertice, visited, currentComponent)
    end
    if isempty(currentComponent) == false
      push!(components, currentComponent)
    end
  end
  return components
end

function getStronglyConnectedComponentsRecursive(graph::Graph)::Vector{Vector{Int}}
  # wykonuję DFS na grafie bazowym by dostać postValuesOrder, O(|V|+|E|)
  postValuesOrder = DFSRecursivePostValue(graph)
  transposedGraph = transposeGraph(graph) # transponowany graf, O(|E|)
  # DFS z wyszukiwaniem komponent, po porządku postValuesOrder, O(|V| + |E|)
  return DFSRecursiveForComponents(transposedGraph, postValuesOrder) 
end

#************************************************************************************
# Zadanie 3 - metody, algorytmy, iteracyjnie!

function DFSForComponents(graph::Graph, postOrder::Vector{Int})::Vector{Vector{Int}} #iteratywna wersja 
  components = Vector{Vector{Int}}()
  visited = [false for i in 1:graph.totalVertices]
  for vertice in postOrder
    currentComponent = Vector{Int}()
    if visited[vertice] == false
      s = Stack{Int}()
      push!(s, vertice)
      while(isempty(s) == false)
        currentVertice = pop!(s)
        if (visited[currentVertice] == false)
          push!(currentComponent, currentVertice)
          visited[currentVertice] = true
          for neighbor in graph.neighborsList[currentVertice]
            if visited[neighbor] == false
              push!(s, neighbor)
            end
          end
        end
      end
    end
    if isempty(currentComponent) == false
      push!(components, currentComponent)
    end
  end
  return components
end

function getDFSTrees(graph::Graph)
  DFSTraversal = Vector{Int}()
  nodes = [SearchTreeNode(i,[]) for i in 1:graph.totalVertices]
  visited = [false for i in 1:graph.totalVertices]
  treeRoots = Vector{Int}()
  for vertice in 1:graph.totalVertices
    if visited[vertice] == false
      s = Stack{Tuple{Int, Int}}() # pierwszy int to wierzchołek, drugi to ojciec
      push!(s, (vertice, 0))
      while(isempty(s) == false)
        stackElement = pop!(s)
        currentVertice = stackElement[1]
        father = stackElement[2]
        if (visited[currentVertice] == false)
          if father != 0
            push!(nodes[father].childrenList, nodes[currentVertice])
          end
          push!(DFSTraversal, currentVertice)
          visited[currentVertice] = true
          for neighbor in graph.neighborsList[currentVertice]
            if visited[neighbor] == false
              push!(s, (neighbor, currentVertice))
            end
          end
        end
      end
      push!(treeRoots, vertice)
    end
  end
  rootNodes = []
  for vert in treeRoots
    push!(rootNodes, nodes[vert])
  end

  return rootNodes
end

function DFSTreePostOrderTraversal(root::SearchTreeNode) 
  postOrder = Vector{Int}()
  stack1 = Stack{SearchTreeNode}()
  stack2 = Stack{SearchTreeNode}()
  push!(stack1, root)
  while isempty(stack1) == false
    current = pop!(stack1)
    push!(stack2, current)
    for child in current.childrenList
      push!(stack1,child)
    end
  end
  while isempty(stack2) == false
    current = pop!(stack2)
    push!(postOrder, current.verticeNo)
  end
  return postOrder
end

function getStronglyConnectedComponents(graph::Graph)::Vector{Vector{Int}}
  # wykonuję DFS na grafie bazowym by dostać postValuesOrder, O(|V|+|E|)
  DFSTrees = getDFSTrees(graph)
  postValuesOrder = Vector{Int}()
  for tree in DFSTrees
    append!(postValuesOrder, DFSTreePostOrderTraversal(tree))
  end
  reverse!(postValuesOrder)
  transposedGraph = transposeGraph(graph) # transponowany graf, O(|E|)
  # DFS z wyszukiwaniem komponent, po porządku postValuesOrder, O(|V| + |E|)
  return DFSForComponents(transposedGraph, postValuesOrder) 
end

#************************************************************************************
# Zadanie 4 - metody, algorytmy

function isGraphBipartite(graph::Graph)::Tuple{Bool, Vector{Int}}
  # zastosujemy 2-kolorowanie grafu
  verticesColor = [-1 for i in 1:graph.totalVertices] # na wstępie każdy wierzchołek niepokolorowany
  # 0 i 1 to kolory użyte w kolorowaniu
  for startVertice in 1:graph.totalVertices #pętla potrzebna dla grafów niespójnych
    if verticesColor[startVertice] == -1
      # uruchamiamy zmodyfikowanego BFSa kolorującego składową spójną
      verticesColor[startVertice] = 0 # bez utraty ogólności kolorujemy startowy wierzchołek jednym z kolorów
      queue = Queue{Int}()   
      enqueue!(queue, startVertice)
      while isempty(queue) == false
        u = dequeue!(queue)
        for neighbor in graph.neighborsList[u]
          if verticesColor[neighbor] == -1
            enqueue!(queue, neighbor)
            verticesColor[neighbor] = (verticesColor[u] + 1) % 2 # kolorujemy każdego sąsiada innym kolorem od koloru 'u'
          elseif verticesColor[neighbor] == verticesColor[u]
            return (false, []) # wykryliśmy ten sam kolor dla 'u' i dla sąsiada, sprzeczność
          end
        end
      end
    end
  end
  # przeszliśmy po wszystkich wierzchołkach i poprawnie nadaliśmy 2-kolorowanie, czyli graf jest dwudzielny
  return (true, verticesColor)
end

end