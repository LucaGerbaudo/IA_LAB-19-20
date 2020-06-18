% DEMO DEL PROGETTO DI ASP
% 26+2 corsi, 22 docenti e 24 settimane di cui la 7 e la 16 complete
% totale slot-ore calendario = 408
% totale ore di lezione da distribuire = 358 + 6

% 24 settimane
settimana(1..24).

% Giorni dal LUN al SAB = 6 giorni di lezioni
giorno(1..6).

% 8 ore al giorno massimo di lezione
ora(1..8).

% Lista insegnamenti
insegnamento(pm).               % Project Management
insegnamento(ict).              % Fondamenti di ICT e paradigmi di programazione
insegnamento(lm).               % Linguaggi di Markup
insegnamento(qual).             % Gestione della Qualiatà
insegnamento(lcs).              % Ambienti di sviluppo e Linguaggi Clien-side per il web
insegnamento(pgdi).             % Progettazione Grafica e Design Interfacce
insegnamento(pBD).              % Progettazione Basi di Dati
insegnamento(sm).               % Strumenti e Metodi di interazione nei social media
insegnamento(eis).              % Acquisizione ed Elaborazione di Immagine Statiche-grafica
insegnamento(progmulti).        % Accessibilità e usabilità nella progettazione multimediale
insegnamento(md).               % Marketing Digitale
insegnamento(ft).               % Elementi di Fotografia Digitale
insegnamento(dpp).              % Risorse digitali per il progetto collaborazione e documentazione
insegnamento(tss).              % Tecnologie Server_side per il web
insegnamento(tsmd).             % Tecniche e Strumenti di Marketing Digitale
insegnamento(smm).              % Introduzione al Social Media Management
insegnamento(aes).              % Acquisizione ed elaborazione del suono
insegnamento(aeid).             % Acquisizione ed elaborazione di sequenze di Immagini Digitali
insegnamento(cpub).             % Comunicazione pubblicitaria e comunicazione pubblica
insegnamento(semmult).          % Semiologia e multimedialità
insegnamento(crossmedia).       % Crossmedia articolazione delle scritture multimediali
insegnamento(grafica3D).        % Grafica 3D
insegnamento(psawdmI).          % Progettazione e sviluppo di applicazioni web su dispositivi mobili 1
insegnamento(psawmII).          % Progettazione e sviluppo di applicazioni web su dispositivi mobili 2
insegnamento(hr).               % Gestione delle Risorse Umane
insegnamento(vgp).              % Vincoli giuridici del progetto diritto dei media

insegnamento(presentazione_master).
insegnamento(recupero).

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

%------------------------- Suddivisione del calendario -------------------------------

% Il calendario è suddiviso in slot orari, cisacuno contrassegnato dalla tripla <settimana,giorno,ora>
% A ciascuno slot del calendario è eventualmente assegnato un insegamento
{ si_svolge(I, S, G, O) : insegnamento(I) } 1 :- settimana(S), giorno(G), ora(O).

% Definizione degli slot del calendario, lezioni, in base alla settimana
% Settimana 7, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-             
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S == 7, G < 6 , si_svolge(I,S,G,O).

% Settimana 7, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S == 7, G == 6, O < 6, si_svolge(I,S,G,O).

% Settimana 16, giorni lun-ven, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S == 16, G < 6,  si_svolge(I,S,G,O).

% Settimana 16, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S == 16, G == 6, O < 6, si_svolge(I,S,G,O).

% Settimana normale, venerdì, max 8h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 7, S!=16, G == 5, si_svolge(I,S,G,O).

% Settimana normale, sabato, max 5h di lezione
lezione(I,S,G,O) :-
    insegnamento(I), settimana(S), giorno(G), ora(O),
    S != 7, S!=16, G == 6, O < 6, si_svolge(I,S,G,O).

%------------------------- Assegnazione id a ciascuno slot del calendario -------------------
% Ogni ora, o slot, del calendario viene contrasseganata con un id progressivo nel soddisfacimento di alcuni vincoli
% gli idOra vanno da 1 per la prima ora del primo giorno della prima settimana ed aumentano progressivamente
% fino alla ultima ora del sesto giorno della ventiquattresima settimana

idOra(S, G, O, ID) :-
    settimana(S), giorno(G), ora(O),
    ID = (S - 1) * 48 + (G - 1) * 8 + O.

%------------------------- Lezioni con ore consecutive -------------------------------
% Le ore della stessa materia sono consecutive                                      DA RIVEDERE: RICHIEDE TEMPO DI ESECUZIONE TROPPO ELEVATO!
%vConsecutive :- lezione(I, S, G, O),insegnamento(I), O < O2, lezione(I, S, G, O2), O+1 != O2.

%------------------------- Definizione vincoli rigidi -------------------------------

%--- Vincolo 1 -- max 4 ore al giorno per docente ---                                                   
:- insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), 
   #count{I1: lezione(I1, S, G, O), insegnamento(I1), docente(D), insegna(I1,D)} > 4.

%--- Vincolo 2 -- ciascun insegnamento min 2 e max 4 ore al giorno ---
:- insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), #count{O1: lezione(I, S, G, O1), ora(O1)} < 2.
:- insegnamento(I),settimana(S), giorno(G),ora(O), lezione(I, S, G, O), #count{O1: lezione(I, S, G, O1), ora(O1)} > 4.

%--- Vincolo 3 -- 2 ore di presentazione master il primo giorno ---
v3 :- lezione(presentazione_master, 1, 5, 1), lezione(presentazione_master, 1, 5, 2).

%--- Vincolo 4 -- 2 blocchi da 2 ore per recuperi ---
%v4 :- lezione(recupero, S, G, O), ora(O), settimana(S), giorno(G), idOra(S,G,O,N), lezione(recupero, S, G, O1), ora(O1), idOra(S,G,O1,N1), O != O1, N1 == N+1.       
%v4 :-  lezione(recupero, S, G, O), lezione(recupero, S1, G1, O1), settimana(S), giorno(G), ora(O), settimana (S1), giorno(G1),ora(O1), S1==S,G1==G, O == O1 + 1.
%v4 :-  lezione(recupero, S, G, O), lezione(recupero, S, G, O1), settimana(S), giorno(G), ora(O), ora(O1), O == O1 + 1.
:- lezione(recupero, S, G, O), O < O2, lezione(recupero, S, G, O2), O+1 != O2.


%--- Vincolo 5 --  l’insegnamento “Project Management” deve concludersi non oltre la prima settimana full-time --
:- settimana(S), giorno(G), ora(O), S > 7, lezione(pm, S, G, O).

%--- Vincolo 6 --  la prima lezione di progmulti collocata prima del termine lezioni di lm --          
v6 :- settimana(S_ACC), giorno(G_ACC), ora(O_ACC), lezione(progmulti, S_ACC, G_ACC, O_ACC),
    settimana(S_LM), giorno(G_LM), ora(O_LM), lezione(lm, S_LM, G_LM, O_LM),
    idOra(S_ACC, G_ACC, O_ACC, N_ACC), idOra(S_LM, G_LM, O_LM, N_LM), N_LM < N_ACC.

%--- Vincolo 7 -- ogni insegnamento precedente deve concludersi prima della prima ora del successivo --
% Ovvero ogni idOra degli insegnamenti successivi non devono essere minori degli idOra degli insegnamenti precedenti    

% prima ora di lcs dopo ultima ora di ict
:-  settimana(S_LCS), giorno(G_LCS), ora(O_LCS), lezione(lcs, S_LCS, G_LCS, O_LCS), idOra(S_LCS, G_LCS, O_LCS, N_LCS), 
    settimana(S_ICT), giorno(G_ICT), ora(O_ICT), lezione(ict, S_ICT, G_ICT, O_ICT), idOra(S_ICT, G_ICT, O_ICT, N_ICT),
    N_LCS < N_ICT.

% prima ora di lcs dopo ultima ora di lm
:-  settimana(S_LCS), giorno(G_LCS), ora(O_LCS), lezione(lcs, S_LCS, G_LCS, O_LCS), idOra(S_LCS, G_LCS, O_LCS, N_LCS),
    settimana(S_LM), giorno(G_LM), ora(O_LM), lezione(lm, S_LM, G_LM, O_LM), idOra(S_LM, G_LM, O_LM, N_LM),
    N_LCS < N_LM.

% prima ora di psawdmI dopo ultima ora di lcs
:-  settimana(S_PSAWDMI), giorno(G_PSAWDMI), ora(O_PSAWDMI), lezione(psawdmI, S_PSAWDMI, G_PSAWDMI, O_PSAWDMI), idOra(S_PSAWDMI, G_PSAWDMI, O_PSAWDMI, N_PSAWDMI),
    settimana(S_LCS), giorno(G_LCS), ora(O_LCS), lezione(lcs, S_LCS, G_LCS, O_LCS), idOra(S_LCS, G_LCS, O_LCS, N_LCS), 
    N_PSAWDMI < N_LCS.

% prima ora di psawmII dopo ultima ora di psawdmI
:-  settimana(S_PSAWDMI), giorno(G_PSAWDMI), ora(O_PSAWDMI), lezione(psawdmI, S_PSAWDMI, G_PSAWDMI, O_PSAWDMI), idOra(S_PSAWDMI, G_PSAWDMI, O_PSAWDMI, N_PSAWDMI),
    settimana(S_PSAWMII), giorno(G_PSAWMII), ora(O_PSAWMII), lezione(psawmII, S_PSAWMII, G_PSAWMII, O_PSAWMII), idOra(S_PSAWMII, G_PSAWMII, O_PSAWMII, N_PSAWMII),
    N_PSAWMII < N_PSAWDMI.

% prima ora di tss dopo ultima ora di pBD
:-  settimana(S_PBD), giorno(G_PBD), ora(O_PBD), lezione(pBD, S_PBD, G_PBD, O_PBD), idOra(S_PBD, G_PBD, O_PBD, N_PBD),
    settimana(S_TSS), giorno(G_TSS), ora(O_TSS), lezione(tss, S_TSS, G_TSS, O_TSS), idOra(S_TSS, G_TSS, O_TSS, N_TSS),
    N_TSS < N_PBD.

% prima ora di md  dopo ultima ora di pm
:-  settimana(S_PM), giorno(G_PM), ora(O_PM), lezione(pm, S_PM, G_PM, O_PM), idOra(S_PM, G_PM, O_PM, N_PM),
    settimana(S_MD), giorno(G_MD), ora(O_MD), lezione(md, S_MD, G_MD, O_MD), idOra(S_MD, G_MD, O_MD, N_MD),
    N_MD < N_PM.

% prima ora di sm dopo ultima ora di pm
:-  settimana(S_SM), giorno(G_SM), ora(O_SM), lezione(sm, S_SM, G_SM, O_SM), idOra(S_SM, G_SM, O_SM, N_SM),
    settimana(S_PM), giorno(G_PM), ora(O_PM), lezione(pm, S_PM, G_PM, O_PM), idOra(S_PM, G_PM, O_PM, N_PM),
    N_SM < N_PM.

% prima ora di pgdi dopo ultima ora di pm
:-  settimana(S_PGDI), giorno(G_PGDI), ora(O_PGDI), lezione(pgdi, S_PGDI, G_PGDI, O_PGDI), idOra(S_PGDI, G_PGDI, O_PGDI, N_PGDI),
    settimana(S_PM), giorno(G_PM), ora(O_PM), lezione(pm, S_PM, G_PM, O_PM), idOra(S_PM, G_PM, O_PM, N_PM),
    N_PGDI < N_PM.

% prima ora di tsmd dopo ultima ora di md
:-  settimana(S_MD), giorno(G_MD), ora(O_MD), lezione(md, S_MD, G_MD, O_MD), idOra(S_MD, G_MD, O_MD, N_MD),
    settimana(S_TSMD), giorno(G_TSMD), ora(O_TSMD), lezione(tsmd, S_TSMD, G_TSMD, O_TSMD), idOra(S_TSMD, G_TSMD, O_TSMD, N_TSMD),
    N_TSMD < N_MD.

% prima ora di ft dopo ultima ora di eis
:-  settimana(S_EIS), giorno(G_EIS), ora(O_EIS), lezione(eis, S_EIS, G_EIS, O_EIS), idOra(S_EIS, G_EIS, O_EIS, N_EIS),
    settimana(S_FT), giorno(G_FT), ora(O_FT), lezione(ft, S_FT, G_FT, O_FT), idOra(S_FT, G_FT, O_FT, N_FT),
    N_FT < N_EIS.

% prima ora di aeid dopo ultima ora di ft
:-  settimana(S_AEID), giorno(G_AEID), ora(O_AEID), lezione(aeid, S_AEID, G__AEID, O_AEID), idOra(S_AEID, G__AEID, O_AEID, N_AEID),
    settimana(S_FT), giorno(G_FT), ora(O_FT), lezione(ft, S_FT, G_FT, O_FT), idOra(S_FT, G_FT, O_FT, N_FT),
    N_AEID < N_FT.

% prima ora di grafica3D dopo ultima ora di eis
:-  settimana(S_G3D), giorno(G_G3D), ora(O_G3D), lezione(grafica3D, S_G3D, G_G3D, O_G3D), idOra(S_G3D, G_G3D, O_G3D, N_G3D),
    settimana(S_EIS), giorno(G_EIS), ora(O_EIS), lezione(eis, S_EIS, G_EIS, O_EIS), idOra(S_EIS, G_EIS, O_EIS, N_EIS),
    N_G3D < N_EIS.


% ------------------------- Definizione Vincoli Auspicabili---------------------------

%--- Vincolo auspicabile 1 -- Distanza tra prima e ultima ora di lezione < 6 settimane --  

:- 
    settimana(S_1), giorno(G_1), ora(O_1), lezione(C_1, S_1, G_1, O_1),
    settimana(S_2), giorno(G_2), ora(O_2), lezione(C_2, S_2, G_2, O_2),
    C_1 == C_2, 
    S_2 - S_1 > 5.


%--- Vincolo auspicabile 2 -- Insegnamenti crossmedia e smm devono iniziare nella settimana 16 --  
% entrambe le lezioni si svolgono dalla settimana 16, ed entrambe hanno almeno 1 ora in quella settimana
% vincolo suddiviso in due sottoregole per ridurre il tempo di esecuzione.

:-  lezione(crossmedia, S, G, O), giorno(G), ora(O), settimana(S), S < 16.
:-  lezione(smm, S, G, O), giorno(G), ora(O), settimana(S), S < 16.
v2aa :- lezione(crossmedia, 16, G, O).
v2ab : lezione(smm, 16, G, O).


%--- Vincolo auspicabile 3 -- Ogni insegnamento successivo deve iniziare 4 ore dopo il precedente --  

propedeuticita(ict,pBD).
propedeuticita(tsmd,smm).
propedeuticita(cpub,vgp).
propedeuticita(tss,psawdmI).
:-
propedeuticita(P1,P2),
lezione(P2,S,G,O),
idOra(S,G,O,ID1),
#count{ID2:lezione(P1,S1,G1,O1),idOra(S1,G1,O1,ID2),ID2 < ID1} != 4.

%--- Vincolo auspicabile 4 -- la distanza fra ultima lezione di psawdmI  e la prima di psawmII non deve superare le due settimane --

1{ultima_settimana_psawdmI(S)} 1:-lezione(psawdmI,S,G,O), #max {SS:lezione(psawdmI,SS,GG,OO)} = S.
1{prima_settimana_psawmII(S)} 1:-lezione(psawmII,S,G,O), #min {SS:lezione(psawmII,SS,GG,OO)} = S.
:-ultima_settimana_psawdmI(S1),
    prima_settimana_psawmII(S2),
    S2 - S1 > 2.


% ------------------------ Definizione dei goal --------------------------
goal :- 

#count{S, G, O: lezione(presentazione_master, S, G, O), settimana(S), giorno(G),ora(O)} == 2,
#count{S, G, O: lezione(pm, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(ict, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(lm, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(qual, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(lcs, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(pgdi, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(pBD, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(sm, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(eis, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(progmulti, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(md, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(ft, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(dpp, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(tss, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(tsmd, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(smm, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(aes, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(aeid, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(cpub, S, G, O), settimana(S), giorno(G),ora(O)} == 14,
#count{S, G, O: lezione(semmult, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(crossmedia, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(grafica3D, S, G, O), settimana(S), giorno(G),ora(O)} == 20,
#count{S, G, O: lezione(psawdmI, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(psawmII, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(hr, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(vgp, S, G, O), settimana(S), giorno(G),ora(O)} == 10,
#count{S, G, O: lezione(recupero, S, G, O), settimana(S), giorno(G),ora(O)} == 4,

%not vConsecutive,

v3,
v6.

:- not goal.

goal_auspicabili:-
    v2aa,
    v2ab
    .

:- not goal_auspicabili.


#show lezione/4.
