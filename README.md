# AOD - Algorytmy Optymalizacji Dyskretnej
Zbiorcze repozytorium rozwiązań zadań z przedmiotu Algorytmy Optymalizacji Dyskretnej, rok akademicki 2022/2023. Kurs prowadzony przez dra inż. Karola Gotfryda na kierunku Informatyka Algorytmiczna, Wydział Informatyki i Telekomunikacji Politechniki Wrocławskiej.

### Lista 1 

#### Zadanie 1
Algorytmy BFS, DFS (DFS w wersji iteratywnej, lepszej dla ogromnych grafów). 

Wywołanie: `julia zadanie1.jl [in] [flag]`, gdzie `[in]` - ścieżka relatywna do pliku z grafem w formacie zgodnym z wytycznymi na liście, `[flag]` - flaga: `--tree` drukuje drzewo BFS / las DFS (domyślnie program zwraca BFS/DFS Traversal)

#### Zadanie 2
Sortowanie topologiczne z wykrywaniem skierowanego cyklu. 

Wywołanie: `julia zadanie2.jl [in]`, gdzie `[in]` - ścieżka relatywna do pliku z grafem w formacie zgodnym z wytycznymi na liście. 

Program zwraca porządek topologiczny grafu (gdy liczba wierzchołków <= 200) i informuje o tym, czy graf jest topologicznie sortowalny, czy też ma skierowany cykl.

#### Zadanie 3
Algorytm wyznaczający silnie spójne składowe grafu.

Wywołanie: `julia zadanie3.jl [in]`, gdzie `[in]` - ścieżka relatywna do pliku z grafem w formacie zgodnym z wytycznymi na liście. 

Program zwraca liczbę silnie spójnych składowych oraz szczegółowo drukuje każdą z nich, gdy liczba wierzchołków grafu <= 200.

#### Zadanie 4
Algorytm określający czy graf jest dwudzielny (dwukolorowalny).

Wywołanie: `julia zadanie4.jl [in]`, gdzie `[in]` - ścieżka relatywna do pliku z grafem w formacie zgodnym z wytycznymi na liście. 

Program zwraca informację o tym, czy graf jest dwudzielny, oraz drukuje szczegóły rozbicia grafu na dwa rozłączne zbiory, gdy liczba wierzchołków grafu <= 200 i graf jest dwudzielny.

### Lista 2

Programowanie liniowe z wykorzystaniem JuMP i solverów (np. HiGHS). Tworzenie modeli do rozwiązywania problemów optymalizacyjnych i oddzielanie ich od konkretnych danych, pozwalając na większą uniwersalność.

Aby uruchomić programy należy mieć zainstalowane moduły JuMP i HiGHS. Informacje na temat instalacji modułów można znaleźć [tutaj](https://jump.dev/JuMP.jl/stable/tutorials/getting_started/getting_started_with_JuMP/).

Lista składa się z 5 zadań, każde z nich jest opisane szczegółowo w sprawozdaniu (plik `l2_sprawozdanie_261750.pdf`).

### Lista 3

Implementacja i analiza złożoności obliczeniowej trzech algorytmów znajdowania najkrótszych ścieżek:

* algorytm Dijkstry (z kolejką priorytetową na kopcu binarnym),
* algorytm Diala (jako kubełek struktura Set bazująca na słownikach),
* algorytm radixheap (kubełki to kolejki priorytetowe na kopcu binarnym).

Testy przeprowadzone zostały na danych testowych z [9th DIMACS Implementation Challenge - Shortest Paths](http://www.diag.uniroma1.it/challenge9/download.shtml). Wyniki testów oraz opis idei algorytmów i teoretycznej złożoności został przedstawiony w sprawozdaniu (plik `l3_sprawodzanie_261750.pdf`).