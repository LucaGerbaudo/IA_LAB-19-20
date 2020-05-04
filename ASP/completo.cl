% Progetto

% 24 settimane
settimana(1..24).

% Giorni dal LUN al SAB
%giorno(lun; mar; mer; gio; ven; sab).
giorno(1..6).

% 8 ore al giorno massimo di lezione
ora(1..8).

% Lista insegnamenti
insegnamento(pm).
insegnamento(ict).
insegnamento(lm).
insegnamento(qual).
insegnamento(lcs).
insegnamento(gdi).
insegnamento(pgdi).
insegnamento(pBD).
insegnamento(sm).
insegnamento(eis).
insegnamento(progmulti).
insegnamento(md).
insegnamento(ft).
insegnamento(dpp).
insegnamento(tss).
insegnamento(tsmd).
insegnamento(smm).
insegnamento(aes).
insegnamento(aeid).
insegnamento(cpub).
insegnamento(semmult).
insegnamento(crossmedia).
insegnamento(grafica3D).
insegnamento(psawdmI).
insegnamento(psawmII).
insegnamento(hr).
insegnamento(vgp).

insegnamento(presentazione_master).
insegnamento(buco_libero).

% Lista Docenti
docente(muzzetto).
docente(pozzato).
docente(gena).
docente(tomatis).
docente(micalizio).
docente(terranova).
docente(mazzei).
docente(giordani).
docente(zanchetta).
docente(vargiu).
docente(boniolo).
docente(damiano).
docente(suppini).
docente(valle).
docente(ghidelli).
docente(gabardi).
docente(santangelo).
docente(taddeo).
docente(girbaudo).
docente(schifanella).
docente(lombardo).
docente(travostino).

% Relazioni Docente-Insegnamento
insegna(pm, muzzetto).
insegna(ict, pozzato).
insegna(lm, gena).
insegna(qual, tomatis).
insegna(lcs, micalizio).
insegna(pgdi, terranova).
insegna(pBD, mazzei).
insegna(sm, giordani).
insegna(eis, zanchetta).
insegna(progmulti, gena).
insegna(md, muzzetto).
insegna(ft, vargiu).
insegna(dpp, boniolo).
insegna(tss, damiano).
insegna(tsmd, zanchetta).
insegna(smm, suppini).
insegna(aes, valle).
insegna(aeid, ghidelli).
insegna(cpub, gabardi).
insegna(semmult, santangelo).
insegna(crossmedia, taddeo).
insegna(grafica3D, girbaudo).
insegna(psawdmI, pozzato).
insegna(psawmII, schifanella).
insegna(hr, lombardo).
insegna(vgp, travostino).

% 1 insegnamento ha almeno una lezione
%1 { si_svolge(I, S, G, O) : settimana(S), giorno(G), ora(O) } :- insegnamento(I).

% Una tripla <settimana,giorno,ora> ha al massimo 1 insegnamento assegnato per evitare sovrapposizione
{ si_svolge(I, S, G, O) : insegnamento(I) } 1 :- settimana(S), giorno(G), ora(O). %sovrapposto(X,Y) :- insegnamento(X), insegnamento(Y), si_svolge(X, S, G, O), si_svolge(Y, S, G, O), X!=Y.

% Definizione delle lezioni
% Settimana 7, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-             
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 7,
    si_svolge(I,S,G,O).
% Settimana 7, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 7, G=6, O<6,
    si_svolge(I,S,G,O).
% Settimana 16, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 16,
    si_svolge(I,S,G,O).
% Settimana 16, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S = 16, G=6, O<6,
    si_svolge(I,S,G,O).
% Settimana normale, venerdì, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 7, S!=16, G = 5,
    si_svolge(I,S,G,O).
% Settimana normale, sabato, max 5h di lezione
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

% idOra assegna ad ogni ora un numero unico sequanziale che la contraddistingue nel calendario
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

%v2 :- insegnamento(I), K = #count{O: lezione(I, S, G, O),ora(O)},settimana(S), giorno(G), K>=2, K<=4.
v2 :-  insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), K = #count{O2: lezione(I, S, G, O2), ora(O2)}, K<2.
v2 :-  insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), K = #count{O2: lezione(I, S, G, O2), ora(O2)}, K>4.

%V3 il primo giorno di lezione prevede che, nelle prime due ore, vi sia la presentazione del master
v3 :- lezione(presentazione_master, 1, 5, 1), lezione(presentazione_master, 1, 5, 2).

v4 :- lezione(buco_libero, S, G, O),ora(O), settimana(S), giorno(G), 
    lezione(buco_libero, S1, G1, O1), settimana(S1), giorno(G1), ora(O1), 
    slotTempo(S,G,O,N1), slotTempo(S1,G1,O1,N2), N1 != N2, N1 > N2 + 2.

%V5 l’insegnamento “Project Management” deve concludersi non oltre la prima settimana full-time
v5 :- settimana(S), giorno(G), ora(O), S > 7, lezione(pm, S, G, O).

%v6 la prima lezione di progmulti collocata prima del termine lezioni di lm
v6 :- settimana(S_ACC), giorno(G_ACC), ora(O_ACC), lezione(progmulti, S_ACC, G_ACC, O_ACC),
    settimana(S_LM), giorno(G_LM), ora(O_LM), lezione(lm, S_LM, G_LM, O_LM),
    slotTempo(S_ACC, G_ACC, O_ACC, N_ACC), slotTempo(S_LM, G_LM, O_LM, N_LM), N_LM < N_ACC.

% v7 la prima lezione di insegnamento_successivo deve avvenire dopo ultima di insegnamento_precedente
%   slotTempo(insegnamento_successivo) > slotTempo(insegnamento_precedente)
v7 :- settimana(S_SLC), giorno(G_SLC), ora(O_SLC), lezione(lcs, S_SLC, G_SLC, O_SLC), slotTempo(S_SLC, G_SLC, O_SLC, N_SLC), 
    settimana(S_ICT), giorno(G_ICT), ora(O_ICT), lezione(ict, S_ICT, G_ICT, O_ICT), slotTempo(S_ICT, G_ICT, O_ICT, N_ICT),
    settimana(S_PSAWDMI), giorno(G_PSAWDMI), ora(O_PSAWDMI), lezione(psawdmI, S_PSAWDMI, G_PSAWDMI, O_PSAWDMI), slotTempo(S_PSAWDMI, G_PSAWDMI, O_PSAWDMI, N_PSAWDMI),
    settimana(S_PSAWMII), giorno(G_PSAWMII), ora(O_PSAWMII), lezione(psawmII, S_PSAWMII, G_PSAWMII, O_PSAWMII), slotTempo(S_PSAWMII, G_PSAWMII, O_PSAWMII, N_PSAWMII),
    settimana(S_PBD), giorno(G_PBD), ora(O_PBD), lezione(pBD, S_PBD, G_PBD, O_PBD), slotTempo(S_PBD, G_PBD, O_PBD, N_PBD),
    settimana(S_TSS), giorno(G_TSS), ora(O_TSS), lezione(tss, S_TSS, G_TSS, O_TSS), slotTempo(S_TSS, G_TSS, O_TSS, N_TSS),
    settimana(S_LM), giorno(G_LM), ora(O_LM), lezione(lm, S_LM, G_LM, O_LM), slotTempo(S_LM, G_LM, O_LM, N_LM),
    settimana(S_PM), giorno(G_PM), ora(O_PM), lezione(pm, S_PM, G_PM, O_PM), slotTempo(S_PM, G_PM, O_PM, N_PM),
    settimana(S_MD), giorno(G_MD), ora(O_MD), lezione(md, S_MD, G_MD, O_MD), slotTempo(S_MD, G_MD, O_MD, N_MD),
    settimana(S_TSMD), giorno(G_TSMD), ora(O_TSMD), lezione(tsmd, S_TSMD, G_TSMD, O_TSMD), slotTempo(S_TSMD, G_TSMD, O_TSMD, N_TSMD),
    settimana(S_SM), giorno(G_SM), ora(O_SM), lezione(sm, S_SM, G_SM, O_SM), slotTempo(S_SM, G_SM, O_SM, N_SM),
    settimana(S_PGDI), giorno(G_PGDI), ora(O_PGDI), lezione(pgdi, S_PGDI, G_PGDI, O_PGDI), slotTempo(S_PGDI, G_PGDI, O_PGDI, N_PGDI),
    settimana(S_EIS), giorno(G_EIS), ora(O_EIS), lezione(eis, S_EIS, G_EIS, O_EIS), slotTempo(S_EIS, G_EIS, O_EIS, N_EIS),
    settimana(S_FT), giorno(G_FT), ora(O_FT), lezione(ft, S_FT, G_FT, O_FT), slotTempo(S_FT, G_FT, O_FT, N_FT),
    settimana(S_AEID), giorno(G_AEID), ora(O_AEID), lezione(aeid, S_AEID, G__AEID, O_AEID), slotTempo(S_AEID, G__AEID, O_AEID, N_AEID),
    settimana(S_G3D), giorno(G_G3D), ora(O_G3D), lezione(grafica3D, S_G3D, G_G3D, O_G3D), slotTempo(S_G3D, G_G3D, O_G3D, N_G3D),
    N_SLC > N_ICT,          % prima ora di lcs dopo ultima ora di ict
    N_PSAWDMI > N_SLC,      % prima ora di psawdmI dopo ultima ora di lcs
    N_PSAWMII > N_PSAWDMI,  % prima ora di psawmII dopo ultima ora di psawdmI
    N_TSS > N_PBD,          % prima ora di tss dopo ultima ora di pBD
    N_SLC > N_LM,           % prima ora di lcs dopo ultima ora di lm
    N_MD > N_PM,            % prima ora di md  dopo ultima ora di pm
    N_TSMD > N_MD,          % prima ora di tsmd dopo ultima ora di md
    N_SM > N_PM,            % prima ora di sm dopo ultima ora di sm
    N_PGDI > N_PM,          % prima ora di pgdi dopo ultima ora di sm
    N_FT > N_EIS,           % prima ora di ft dopo ultima ora di eis
    N_AEID > N_FT,          % prima ora di aeid dopo ultima ora di ft
    N_G3D > N_EIS.          % prima ora di grafica3D dopo ultima ora di eis

%ore consecutive
vConsecutive :- lezione(I, S, G, O), O < O2, lezione(I, S, G, O2), O+1 != O2.
% ----------------------------------------------------------------------

goal :- 
    countOreInsegnamento(presentazione_master, PRES_O), PRES_O=2,
    countOreInsegnamento(pm, PM_O), PM_O=14,
    countOreInsegnamento(ict, ICT_O), ICT_O=14,
    countOreInsegnamento(lm, LM_O), LM_O=20,
    countOreInsegnamento(qual, QUAL_O), QUAL_O=10,
    countOreInsegnamento(lcs, LCS_O), LCS_O=20,
    countOreInsegnamento(pgdi, PGDI_O), PGDI_O=10,  
    countOreInsegnamento(pBD, PBD_O), PBD_O=20,
    countOreInsegnamento(sm, SM_O), SM_O=14,
    countOreInsegnamento(eis, EIS_O), EIS_O=14,
    countOreInsegnamento(progmulti, PROGMULTI_O), PROGMULTI_O=14,
    countOreInsegnamento(md, MD_O), MD_O=10,
    countOreInsegnamento(ft, FT_O), FT_O=10,
    countOreInsegnamento(dpp, DPP_O), DPP_O=10,
    countOreInsegnamento(tss, TSS_O), TSS_O=20,
    countOreInsegnamento(tsmd, TSMD_O), TSMD_O=10,
    countOreInsegnamento(smm, SMM_O), SMM_O=14,
    countOreInsegnamento(aes, AES_O), AES_O=10,
    countOreInsegnamento(aeid, AEID_O), AEID_O=20,
    countOreInsegnamento(cpub, CPUB_O), CPUB_O=14,
    countOreInsegnamento(semmult, SEMMULT_O), SEMMULT_O=10,
    countOreInsegnamento(crossmedia, CROSSMEDIA_O), CROSSMEDIA_O=20,
    countOreInsegnamento(grafica3D, GRAFICA3D_O), GRAFICA3D_O=20,
    countOreInsegnamento(psawdmI, PSAWDMI_O), PSAWDMI_O=10,
    countOreInsegnamento(psawmII, PSAWDMII_O), PSAWDMII_O=10,
    countOreInsegnamento(hr, HR_O), HR_O=10,
    countOreInsegnamento(vgp, VGP_O), VGP_O=10,
    % Vincoli rigidi
    %not v2, 
    v1,
    not v2,
    v3,
    v4,
    not v5,
    v6,
    not v7,
    not vConsecutive.
:- not goal.

#show lezione/4.