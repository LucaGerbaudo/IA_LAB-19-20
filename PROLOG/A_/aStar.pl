% A*
/*
    f(n) = g(n) + h(n)
    g(n) = costo minimo di tutti i percorsi visitati per raggiungere n da si (stato iniziale)
    h(n) = stima del costo minimo del proseguimento di percorso che consente di raggiungere un goal preferito di n
    f(n) = stima del costo minimo per raggiungere un goal preferito di n partendo da s

    Bisogna tenere traccia dei costi f(n) precedenti: se si trova f(n) maggiore di quello appena analizzato, si torna ai genitori e si sceglie il min(f(n))

    Valori euristica
    g(n) = costo cammino da nodo iniziale e n -> costo di ciascun ramo = 1 -> g(n) = length(AzioniPerS)
    h(n) = abs(RigaNodo -  RigaGoal) + abs(ColonnaNodo - ColonnaGoal) --> abs = valore assoluto

    Aggiunto elemento F (= euristica f(n)) al nodo -> lo si sfrutta quando si riordina la coda dalla quale si andrà ad estrarre sempre il primo elemento,
    ovvero quello con F minore, grazie a insertion sort.
*/

a*(Soluzione):-
    iniziale(S),
    bfs([nodo(S,[],0)],[],Soluzione). % Acronimo che indica visita in ampiezza

bfs([nodo(S,AzioniPerS,_)|_],_,AzioniPerSInvertita):- 
    finale(S), 
    !,
    invertiOpt(AzioniPerS,AzioniPerSInvertita). % Inversione lista del cammino perchè le AZ vengono messe in testa e non in ocoda
 
bfs([nodo(S,AzioniPerS,F)|CodaStati],Visitati,Soluzione):-
   findall(Az, applicabile(Az,S), ListaAzApplicabili), % trova tutti i nodi figli
   generaStatiFigli(nodo(S,AzioniPerS,F),[S|Visitati],ListaAzApplicabili,StatiFigli),
   insert_sort(CodaStati,StatiOrdered),
   append(StatiOrdered,StatiFigli,NuovaCoda),
   bfs(NuovaCoda,[S|Visitati],Soluzione).

generaStatiFigli(_,_,[], []).

generaStatiFigli(nodo(S,AzioniPerS,F),Visitati,[Az|AltreAzioni],[nodo(SNuovo,[Az|AzioniPerS],F)|AltriFigli]):-  
    trasforma(Az,S,SNuovo),
    % Calcolo dell'euristica per il nodo corrente
    heuristic(S,H),
    length(AzioniPerS,LenAzioniPerS),
    NF is H + LenAzioniPerS,
    \+member(SNuovo,Visitati),
    !,
    generaStatiFigli(nodo(S,AzioniPerS,NF),Visitati,AltreAzioni,AltriFigli).

generaStatiFigli(nodo(S,AzioniPerS,_),Visitati,[_|AltreAzioni],AltriFigli):-
    heuristic(S,H),
    length(AzioniPerS,LenAzioniPerS),
    NF is H + LenAzioniPerS,  
    generaStatiFigli(nodo(S,AzioniPerS,NF),Visitati,AltreAzioni,AltriFigli).

% Euristica
heuristic(pos(Riga,Col),H):-
    finale(pos(RFin,ColFin)),
    H is abs(Riga - RFin) + abs(Col - ColFin).

% Insert sort fatto sul valore F del nodo
insert_sort(List,Sorted) :- i_sort(List,[],Sorted).
i_sort([],Acc,Acc).
i_sort([Head|Tail],Acc,Sorted):-
    insert(Head,Acc,NAcc),
    i_sort(Tail,NAcc,Sorted).
insert(nodo(S,AzioniPerS, F_X),[nodo(S2,AzioniPerS2, F_Y)|T],[nodo(S2,AzioniPerS2, F_Y)|NT]) :- 
    F_X>F_Y,
    insert(nodo(S,AzioniPerS, F_X),T,NT).
insert(nodo(S,AzioniPerS, F_X),[nodo(S2,AzioniPerS2, F_Y)|T],[nodo(S,AzioniPerS, F_X),nodo(S2,AzioniPerS2, F_Y)|T]) :-
    F_X=<F_Y.
insert(nodo(S,AzioniPerS, F_X),[],[nodo(S,AzioniPerS, F_X)]).