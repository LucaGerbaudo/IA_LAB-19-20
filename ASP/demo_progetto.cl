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
% gli idOra vanno da 1 per la prima ora del primo giorno della prima settimana
% fino alla ultima ora del sesto giorno della ventiquattresima settimana

idOra(S, G, O, ID) :-
    settimana(S), giorno(G), ora(O),
    ID = (S - 1) * 48 + (G - 1) * 8 + O.

%------------------------- Lezioni con ore consecutive -------------------------------
% Le ore della stessa materia sono consecutive                                      DA RIVEDERE: RICHIEDE TEMPO DI ESECUZIONE TROPPO ELEVATO!
% vConsecutive :- lezione(I, S, G, O),insegnamento(I), O < O2, lezione(I, S, G, O2), O+1 != O2.

%------------------------- Definizione vincoli rigidi -------------------------------

%--- Vincolo 1 -- max 4 ore al giorno per docente ---                                                   
%v1 :- insegnamento(I), ora(O), settimana(S), giorno(G), docente(D), insegna(I,D),
%    #count{O: lezione(I, S, G, O) } > 4.
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
:- lezione(recupero, S, G, O), O < O2, lezione(I, S, G, O2), O+1 != O2.


%--- Vincolo 5 -- ...
%--- Vincolo 6 -- ...
%--- Vincolo 7 -- ...


% ------------------------- Definizione Vincoli auspicabili---------------------------



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

v3.




:- not goal.

#show lezione/4.

