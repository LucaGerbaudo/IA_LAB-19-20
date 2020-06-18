% Progetto

% 24 settimane
settimana(1..24).

% Giorni dal LUN al SAB
%giorno(lun; mar; mer; gio; ven; sab).
giorno(1..6).

% 8 ore al giorno massimo di lezione
ora(1..8).

% Lista insegnamenti
insegnamento(pm; ict; lm; qual; slc; design; acc).

insegnamento(presentazione_master).
insegnamento(buco_libero).

% Lista Docenti
docente(muzzetto; pozzato; gena; tomatis; micalizio; terranova).

% Relazioni Docente-Insegnamento
insegna(pm, muzzetto).
insegna(ict, pozzato).
insegna(lm, gena).
insegna(qual, tomatis).
insegna(slc, micalizio).
insegna(design, terranova).
insegna(acc, gena).

% 1 insegnamento ha almeno una lezione
%1 { si_svolge(I, S, G, O) : settimana(S), giorno(G), ora(O) } :- insegnamento(I).

% Una tripla <settimana,giorno,ora> ha al massimo 1 insegnamento assegnato per evitare sovrapposizione
{ si_svolge(I, S, G, O) : insegnamento(I) } 1 :- settimana(S), giorno(G), ora(O). %sovrapposto(X,Y) :- insegnamento(X), insegnamento(Y), si_svolge(X, S, G, O), si_svolge(Y, S, G, O), X!=Y.

% Definizione di lezione normale solo ven-sab eccetto le settimane intere 7 e 16
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 7,
    si_svolge(I,S,G,O).

lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 7, G=6, O<6,
    si_svolge(I,S,G,O).

lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 16,
    si_svolge(I,S,G,O).

lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 16, G=6, O<6,
    si_svolge(I,S,G,O).

lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 7, S!=16, G = 5,
    si_svolge(I,S,G,O).

lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 7, S!=16, G = 6, O < 6,
    si_svolge(I,S,G,O).

% Conteggio ore di lezione per ogni materia
countOreInsegnamento(I, K) :- K = #count{S, G, O: lezione(I, S, G, O), settimana(S), giorno(G),ora(O)}, insegnamento(I).

%------------------------- Vincoli rigidi -------------------------------

% lo stesso docente non può svolgere più di 4 ore di lezione in un giorno
v1 :- docente(D), insegnamento(I), insegna(I,D),
    K = #count{O: lezione(I, S, G, O),ora(O)},settimana(S), giorno(G),
    K < 5.
%

%V1
%{ si_svolge(I, S, G, O) : insegnamento(I), ora(O) } 4 :- settimana(S), giorno(G),docente(D), insegna(I,D).

slotTempo(S,G,O,N) :- 
    settimana(S), giorno(G), ora(O),
    N = (G-1 * 8 + O) * S.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S < 7,
    COUNT = (S - 1) * 12 + (G - 5) * 8 + O.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S == 7,
    COUNT = (S - 1) * 12 + (G - 1) * 8 + O.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S > 7,
    COUNT = (S - 2) * 12 + (G - 5) * 8 + O + 44.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S == 16,
    COUNT = (S - 2) * 12 + (G - 1) * 8 + O + 44.

idOra(S, G, O, COUNT) :-
    settimana(S), giorno(G), ora(O),
    S > 16,
    COUNT = (S - 3) * 12 + (G - 5) * 8 + O + 44 + 44.

%V2 - va solo con 2 consecutive
%v2 :- insegnamento(I), settimana(S), giorno(G), ora(O), O2 = O+1, ora(O2), lezione(I,S,G,O), not lezione(I,S,G,O2).
%v2 :- insegnamento(I), settimana(S), giorno(G), ora(O), O2 = O+1, O3 = O2+1, ora(O2),ora(O3), lezione(I,S,G,O), lezione(I,S,G,O2),not lezione(I,S,G,O3).
%v2 :- insegnamento(I), settimana(S), giorno(G), ora(O), O2 = O+1, O3 = O2+1, O4 = O3+1, ora(O2),ora(O3),ora(O4), lezione(I,S,G,O), lezione(I,S,G,O2), lezione(I,S,G,O3),not lezione(I,S,G,O4).
%2 { si_svolge(I, S, G, O) : ora(O) } 4 :- settimana(S), giorno(G), insegnamento(I).

v2 :-  insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), K = #count{O2: lezione(I, S, G, O2), ora(O2)}, K<2.
v2 :-  insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), K = #count{O2: lezione(I, S, G, O2), ora(O2)}, K>4.
%v2 :- insegnamento(I), K = #count{O: lezione(I, S, G, O),ora(O)},settimana(S), giorno(G), K<2.
%v2 :- insegnamento(I), K = #count{O: lezione(I, S, G, O),ora(O)},settimana(S), giorno(G), K>4.

%V3 il primo giorno di lezione prevede che, nelle prime due ore, vi sia la presentazione del master
v3 :- lezione(presentazione_master, 1, 5, 1), lezione(presentazione_master, 1, 5, 2).

v4 :- lezione(buco_libero, S, G, O),ora(O), settimana(S), giorno(G), 
    lezione(buco_libero, S1, G1, O1), settimana(S1), giorno(G1), ora(O1), 
    idOra(S,G,O,N1), idOra(S1,G1,O1,N2), N1 != N2, N1 > N2 + 2.

%V5 l’insegnamento “Project Management” deve concludersi non oltre la prima settimana full-time
v5 :- settimana(S), giorno(G), ora(O), S > 7, lezione(pm, S, G, O).

v6 :- settimana(S_ACC), giorno(G_ACC), ora(O_ACC), lezione(acc, S_ACC, G_ACC, O_ACC),
    settimana(S_LM), giorno(G_LM), ora(O_LM), lezione(lm, S_LM, G_LM, O_LM),
    idOra(S_ACC, G_ACC, O_ACC, N_ACC), idOra(S_LM, G_LM, O_LM, N_LM), N_LM < N_ACC.

v7 :- settimana(S_SLC), giorno(G_SLC), ora(O_SLC), lezione(slc, S_SLC, G_SLC, O_SLC), 
    settimana(S_ICT), giorno(G_ICT), ora(O_ICT), lezione(ict, S_ICT, G_ICT, O_ICT), 
    idOra(S_SLC, G_SLC, O_SLC, N_SLC), idOra(S_ICT, G_ICT, O_ICT, N_ICT),
    N_SLC > N_ICT.

%ore consecutive
vConsecutive :- lezione(I, S, G, O), O < O2, lezione(I, S, G, O2), O+1 != O2.
% ----------------------------------------------------------------------

goal :- 
    countOreInsegnamento(presentazione_master, PRES_O), PRES_O=2,
    countOreInsegnamento(buco_libero, BUCO_O), BUCO_O=4,
    countOreInsegnamento(pm, PM_O), PM_O=14,
    countOreInsegnamento(ict, ICT_O), ICT_O=14,
    countOreInsegnamento(lm, LM_O), LM_O=20,
    countOreInsegnamento(qual, QUAL_O), QUAL_O=10,
    countOreInsegnamento(slc, SLC_O), SLC_O=20,
    countOreInsegnamento(design, DESIGN_O), DESIGN_O=10,
    countOreInsegnamento(acc, ACC_O), ACC_O=14,
    % Vincoli rigidi
    %not v2, 
    v1,
    not v2,
    v3,
    v4,
    not v5,
    v6,
    not v7.
    not vConsecutive.
:- not goal.

#show lezione/4.