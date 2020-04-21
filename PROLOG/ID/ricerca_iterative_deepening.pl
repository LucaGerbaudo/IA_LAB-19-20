% ITERATIVE DEEPENING

/* ricerca a profondità limitata con limite variabile:
inizialmente il limite è 1, 
viene utilizzata la ricerca in profondità limitata
se non ha successo il limite viene incrementato di 1 e la ricerca richiamata a partire dallo start,
il limite viene incrementato fino a un massimo pari al numero di celle nel labirinto
*/

% Profondità con limite che parte da 1 e aumenta (Iterative Deepening)
provaID(Soluzione):-
    iniziale(S),
    num_colonne(NC), num_righe(NR),
    LimiteMax is NC * NR, % limite massimo = num righe x num colonne 
    Limite is 1,
    contenitore(S,Limite,LimiteMax,Soluzione).

contenitore(S,Limite,LimiteMax,Soluzione):-
    Limite < LimiteMax,
    ricerca_prof_limitata(S,[],Limite,Soluzione),
    !. % nel caso in cui sia trovata la soluzione gli altri rami potati 

contenitore(S,Limite,LimiteMax,Soluzione):-
    Limite < LimiteMax,
    LimiteNew is Limite + 1,
    contenitore(S,LimiteNew,LimiteMax,Soluzione).

ricerca_prof_limitata(S,_,_,[]):-    %caso base in cui S è uno stato finale
    finale(S),
    !.  % raggiunto uno stato finale gli altri rami vengono potati
  
ricerca_prof_limitata(S,Visitati,Limite,[Az|SequenzaAzioni]):-
    Limite > 0,
    applicabile(Az,S), %controllo se l'azione è concessa
    trasforma(Az,S,SNuovo), % spostamento nel nuovo stato raggiunto
    \+member(SNuovo,Visitati), % controllo se lo stato nuovo non era ancora stato visitato
    NuovoLimite is Limite-1, % decremento il limite
    ricerca_prof_limitata(SNuovo,[S|Visitati],NuovoLimite,SequenzaAzioni). % chiamata ricorsiva in cui lo stato raggiunto viene aggiunto alla lista dei visitati
    