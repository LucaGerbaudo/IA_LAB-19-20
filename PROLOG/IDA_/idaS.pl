% IDA*

:- dynamic(nuovoLimite/1).

%funzione iniziale 
idaStar(Soluzione) :- 
  iniziale(S), 
  f(S, 0, F_S), % G = 0, F_S = H_S
  provaPL(Soluzione, F_S).


%inizializza g(s) a 0 in quanto la prima iterazione ha g(s) = 0 poi richiama la ricerca in profondità
provaPL(Soluzione, Limite) :-
  iniziale(S),
  G is 0,
  retractall(nuovoLimite(_)),
  assert(nuovoLimite(inf)),
  ricerca_depth_limitata(S, [], Limite, Soluzione, G),
  !. % Se si vuole trovare alternative occorre toglierlo

  provaPL(Soluzione, _) :-
    nuovoLimite(NuovoLimite),
    provaPL(Soluzione, NuovoLimite).


%controlla se lo stato è finale
ricerca_depth_limitata(S, _, _, [], _) :- 
  finale(S), 
  !.

%effettua la ricerca in profondità controllando il limite con l'euristica
ricerca_depth_limitata(S, Visitati, Limite, [Az | SequenzaAzioni], G) :-
  f(S, G, F_S),
  F_S =< Limite,
  !,
  % f(s) <= limite, continuo l'esplorazione
  applicabile(Az, S),
  trasforma(Az, S, SNuovo),
  \+member(SNuovo, Visitati),
  NuovoG is G + 1, % Ogni passo è considerato a costo unitario
  ricerca_depth_limitata(SNuovo, [S | Visitati], Limite, SequenzaAzioni, NuovoG).

%calcola il nuovo limite
ricerca_depth_limitata(S, _, _, _, G) :-
  %f(s) > limite, devo eventualmente aggiornare nuovoLimite
  f(S, G, F_S),
  nuovoLimite(NuovoLimite),
  F_S < NuovoLimite,
  retractall(nuovoLimite(_)),
  assert(nuovoLimite(F_S)),
  false.

% funzione di valutazione 
f(S, G, F) :- 
  heuristic(S, H), 
  F is G + H. 

%euristica che definisce h(n)
heuristic(pos(Riga, Colonna), H) :- 
  finale(pos(RigaFinale, ColonnaFinale)),
  H is abs(Riga - RigaFinale) + abs(Colonna - ColonnaFinale). 