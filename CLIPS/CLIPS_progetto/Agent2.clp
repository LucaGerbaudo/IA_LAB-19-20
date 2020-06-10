
;  -------------- AGENTE -------------------------------
; Modulo che si occupa di controlli e valutazioni, contiene i template ausiliari
; Valutazioni iniziali sulle celle contenenti acqua

(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;  --------------------------- DEFINIZIONE TEMPLATE AUSLIARI ------------------------------------------

; Numero di navi ancora da scoprire per tipo 

(deftemplate submarine	; 4 sottomarini (1 casella)
	(slot to_find)
)
(deftemplate destroyer	; 3 cacciatorpediniere (2 caselle)
	(slot to_find)
)
(deftemplate cruiser	; 2 incrociatori (3 caselle)
	(slot to_find)
)
(deftemplate battleship	; 1 corazzata (4 caselle)
	(slot to_find)
)

(deffacts boat_to_find
	(submarine (to_find 4))
	(destroyer (to_find 3))
	(cruiser (to_find 2))
	(battleship (to_find 1))
)

;Template per controlli sulla cella
(deftemplate cell_status
	(slot kx)
	(slot ky)
	(slot stat (allowed-values none guessed fired) )
)

; Template per controlli su righe/colonne
(deftemplate k-row-water
	(slot row)
)
(deftemplate k-col-water
	(slot col)
)

; Template per tenere traccia degli incrociatori trovati
(deftemplate cruiser_vert_found
	(slot xtop)
	(slot xmid)
	(slot xbot)
	(slot y)
)
(deftemplate cruiser_orizz_found
	(slot x)
	(slot ysx)
	(slot ymid)
	(slot ydx)
)

; Template per tenere traccia dei cacciatorpedinieri trovati
(deftemplate destroyer_vert_found
	(slot xtop)
	(slot xbot)
	(slot y)
)
(deftemplate destroyer_orizz_found
	(slot x)
	(slot ysx)
	(slot ydx)
)

; Template per tenere traccia delle corazzate trovate
(deftemplate battleship_vert_found
	(slot xtop)
	(slot xmid)
	(slot xmid1)
	(slot xbot)
	(slot y)
)
(deftemplate battleship_orizz_found
	(slot x)
	(slot ysx)
	(slot ymid)
	(slot ymid1)
	(slot ydx)
)

;  --------------------------- INIZIALIZZAZIONE ------------------------------------------------------

; Caso in cui nessuna cella nota all' inizio del gioco
(defrule no-knoweledge-at-beginning (declare (salience 500))
	(not (k-cell (x ?x) (y ?y) (content ?t) ))
	;(k-per-row (row ?r) (num ?n))
=>
	;(printout t "k-per-row" ?r ": " ?n crlf)
	(printout t "No data available for any cell" crlf)
)

; Asserisce acqua nelle righe con k-per-row = 0
(defrule setWaterKRow (declare (salience 500))
	(status (step ?s)(currently running))
	(k-per-row (row ?r) (num 0))
	(not (k-row-water (row ?r)))
=>
	(printout t "WATER on ROW " ?r crlf)
	(assert (k-cell (x ?r) (y 0) (content water)))
	(assert (k-cell (x ?r) (y 1) (content water)))
	(assert (k-cell (x ?r) (y 2) (content water)))
	(assert (k-cell (x ?r) (y 3) (content water)))
	(assert (k-cell (x ?r) (y 4) (content water)))
	(assert (k-cell (x ?r) (y 5) (content water)))
	(assert (k-cell (x ?r) (y 6) (content water)))
	(assert (k-cell (x ?r) (y 7) (content water)))
	(assert (k-cell (x ?r) (y 8) (content water)))
	(assert (k-cell (x ?r) (y 9) (content water)))
	(assert (k-row-water (row ?r)))
	(printout t crlf)
)

; Asserisce acqua nelle colonne con k-per-col = 0
(defrule setWaterKCol (declare (salience 500))
	(status (step ?s)(currently running))
	(k-per-col (col ?c) (num 0))
	(not (k-col-water (col ?c)))
=>
	(printout t "WATER on COL " ?c crlf)
	(assert (k-cell (x 0) (y ?c) (content water)))
	(assert (k-cell (x 1) (y ?c) (content water)))
	(assert (k-cell (x 2) (y ?c) (content water)))
	(assert (k-cell (x 3) (y ?c) (content water)))
	(assert (k-cell (x 4) (y ?c) (content water)))
	(assert (k-cell (x 5) (y ?c) (content water)))
	(assert (k-cell (x 6) (y ?c) (content water)))
	(assert (k-cell (x 7) (y ?c) (content water)))
	(assert (k-cell (x 8) (y ?c) (content water)))
	(assert (k-cell (x 9) (y ?c) (content water)))
	(assert (k-col-water (col ?c)))
	(printout t crlf)
)

; Asserisce acqua tutte le celle che contornano la tabella di gioco 

(defrule setLimitsAsWater (declare (salience 500))
	(status (step ?s)(currently running))
=>
	; bordo superiore
	(assert (k-cell (x -1) (y 0)))	(assert (k-cell (x -1) (y 1)))	(assert (k-cell (x -1) (y 2)))
	(assert (k-cell (x -1) (y 3)))	(assert (k-cell (x -1) (y 4)))	(assert (k-cell (x -1) (y 5)))
	(assert (k-cell (x -1) (y 6)))	(assert (k-cell (x -1) (y 7)))	(assert (k-cell (x -1) (y 8)))
	(assert (k-cell (x -1) (y 9)))
	;bordo sinistro
	(assert (k-cell (x 0) (y -1)))	(assert (k-cell (x 1) (y -1)))	(assert (k-cell (x 2) (y -1)))
	(assert (k-cell (x 3) (y -1)))	(assert (k-cell (x 4) (y -1)))	(assert (k-cell (x 5) (y -1)))
	(assert (k-cell (x 6) (y -1)))	(assert (k-cell (x 7) (y -1)))	(assert (k-cell (x 8) (y -1)))
	(assert (k-cell (x 9) (y -1)))
	;bordo destro
	(assert (k-cell (x 0) (y 10)))	(assert (k-cell (x 1) (y 10)))	(assert (k-cell (x 2) (y 10)))
	(assert (k-cell (x 3) (y 10)))	(assert (k-cell (x 4) (y 10)))	(assert (k-cell (x 5) (y 10)))
	(assert (k-cell (x 6) (y 10)))	(assert (k-cell (x 7) (y 10)))	(assert (k-cell (x 8) (y 10)))
	(assert (k-cell (x 9) (y 10)))
	; bordo inferiore
	(assert (k-cell (x 10) (y 0)))	(assert (k-cell (x 10) (y 1)))	(assert (k-cell (x 10) (y 2)))
	(assert (k-cell (x 10) (y 3)))	(assert (k-cell (x 10) (y 4)))	(assert (k-cell (x 10) (y 5)))
	(assert (k-cell (x 10) (y 6)))	(assert (k-cell (x 10) (y 7)))	(assert (k-cell (x 10) (y 8)))
	(assert (k-cell (x 10) (y 9)))
)


;  --------------------------- GESTIONE NAVI TROVATE ------------------------------------------------

; Cerca incrociatori  verticali
(defrule find_cruisers_vert 
	(status (step ?s)(currently running))
	?ctf <- (cruiser (to_find ?to_find_c ))
	(cruiser (to_find ?to_find_c &:(> ?to_find_c 0)))
	
	(or			; middle guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; top guessed or fired
		(cell_status (kx ?x_top &:(eq ?x_top (- ?x 1))) (ky ?y) (stat guessed) )
		(cell_status (kx ?x_top &:(eq ?x_top (- ?x 1))) (ky ?y) (stat fired) )
	)	
	(or			; bot guessed or fired
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 1))) (ky ?y) (stat guessed) )	
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 1))) (ky ?y) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x_top2 &:(eq ?x_top2 (- ?x 2))) (y ?y) (content water)) 
	(k-cell (x ?x_bot2 &:(eq ?x_bot2 (+ ?x 2))) (y ?y) (content water)) 
	; se non già trovata quella nave
	(not (cruiser_vert_found 
		(xtop ?xtop &:(eq ?xtop (- ?x 1)))
		(xmid ?x)
		(xbot ?xbot &:(eq ?xbot (+ ?x 1))) 
		(y ?y)
		))
=>	
	(modify ?ctf (to_find (- ?to_find_c 1)))
	(assert (cruiser_vert_found (xtop (- ?x 1))	(xmid ?x) (xbot (+ ?x 1)) (y ?y) ))
	(printout t crlf)
	(printout t "VERTICAL CRUISER FOUND!!")
	(printout t crlf)
)

; Cerca incrociatori  orizzontali
(defrule find_cruisers_orizz 
	(status (step ?s)(currently running))
	?ctf <- (cruiser (to_find ?to_find_c ))
	(cruiser (to_find ?to_find_c &:(> ?to_find_c 0)))
	(or			; middle guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; top guessed or fired
		(cell_status (kx ?x) (ky ?y_left &:(eq ?y_left (- ?y 1))) (stat guessed) )
		(cell_status (kx ?x) (ky ?y_left &:(eq ?y_left (- ?y 1))) (stat fired) )
	)	
	(or			; right guessed or fired
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 1))) (stat guessed) )	
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 1))) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x) (y ?y_left2 &:(eq ?y_left2 (- ?y 2))) (content water)) 
	(k-cell (x ?x) (y ?y_right2 &:(eq ?y_right2 (+ ?y 2))) (content water)) 
	; se non già trovata quella nave
	(not (cruiser_orizz_found 
		 (x ?x) (ysx ?yleft &:(eq ?yleft (- ?y 1))) 
		 (ymid ?y) 
		 (ydx ?yright &:(eq ?yright (+ ?y 1))) 
	)) 
=>	
	(modify ?ctf (to_find (- ?to_find_c 1)))
	(assert (cruiser_orizz_found (x ?x) (ysx (- ?y 1)) (ymid ?y) (ydx (+ ?y 1)) )) 
	(printout t crlf)
	(printout t "HORIZONTAL CRUISER FOUND!!")
	(printout t crlf)
)

; Cerca cacciatorpedinieri  verticali
(defrule find_destroyer_vert 
	(status (step ?s)(currently running))
	?ctf <- (destroyer (to_find ?to_find_c ))
	(destroyer (to_find ?to_find_c &:(> ?to_find_c 0)))
	
	(or			; top guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; bot guessed or fired
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 1))) (ky ?y) (stat guessed) )	
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 1))) (ky ?y) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x_top2 &:(eq ?x_top2 (- ?x 1))) (y ?y) (content water)) 
	(k-cell (x ?x_bot2 &:(eq ?x_bot2 (+ ?x 2))) (y ?y) (content water)) 
	; se non già trovata quella nave
	(not (destroyer_vert_found (xtop ?x) (xbot ?xbot &:(eq ?xbot (+ ?x 1))) (y ?y) ))
=>	
	(modify ?ctf (to_find (- ?to_find_c 1)))
	(assert (destroyer_vert_found (xtop  ?x ) (xbot (+ ?x 1)) (y ?y)))
	(printout t crlf)
	(printout t "VERTICAL DESTROYER FOUND!!")
	(printout t crlf)
)

; Cerca cacciatorpedinieri orizzontali
(defrule find_destroyer_orizz 
	(status (step ?s)(currently running))
	?ctf <- (destroyer (to_find ?to_find_c ))
	(destroyer (to_find ?to_find_c &:(> ?to_find_c 0)))
	(or			; sx guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; right guessed or fired
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 1))) (stat guessed) )	
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 1))) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x) (y ?y_left2 &:(eq ?y_left2 (- ?y 1))) (content water)) 
	(k-cell (x ?x) (y ?y_right2 &:(eq ?y_right2 (+ ?y 2))) (content water)) 
	; se non già trovata quella nave
	(not (destroyer_orizz_found (x ?x) (ysx ?y) (ydx ?yright &:(eq ?yright (+ ?y 1))) )) 
=>	
	(modify ?ctf (to_find (- ?to_find_c 1)))
	(assert (destroyer_orizz_found (x ?x) (ysx  ?y ) (ydx (+ ?y 1)) )) 
	(printout t crlf)
	(printout t "HORIZONTAL DESTROYER FOUND!!")
	(printout t crlf)
)

; Cerca corazzate  verticali
(defrule find_battleship_vert 
	(status (step ?s)(currently running))
	?btf <- (battleship (to_find ?to_find_b ))
	(battleship (to_find ?to_find_b &:(> ?to_find_b 0)))
	
	(or			; middle guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; top guessed or fired
		(cell_status (kx ?x_top &:(eq ?x_top (- ?x 1))) (ky ?y) (stat guessed) )
		(cell_status (kx ?x_top &:(eq ?x_top (- ?x 1))) (ky ?y) (stat fired) )
	)	
	(or			; middle1 guessed or fired
		(cell_status (kx ?x_mid &:(eq ?x_mid (+ ?x 1))) (ky ?y) (stat guessed) )	
		(cell_status (kx ?x_mid &:(eq ?x_mid (+ ?x 1))) (ky ?y) (stat fired) )
	)
	(or			; bot guessed or fired
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 2))) (ky ?y) (stat guessed) )	
		(cell_status (kx ?x_bot &:(eq ?x_bot (+ ?x 2))) (ky ?y) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x_top2 &:(eq ?x_top2 (- ?x 2))) (y ?y) (content water)) 
	(k-cell (x ?x_bot2 &:(eq ?x_bot2 (+ ?x 3))) (y ?y) (content water)) 
	; se non già trovata quella nave
	(not (battleship_vert_found 
		(xtop ?xtop &:(eq ?xtop (- ?x 1)))
		(xmid ?x)
		(xmid1 ?xmid &:(eq ?xmid (+ ?x 1))) 
		(xbot ?xbot &:(eq ?xbot (+ ?x 2))) 
		))
=>	
	(modify ?btf (to_find (- ?to_find_b 1)))
	(assert (battleship_vert_found (xtop (- ?x 1))	(xmid ?x) (xmid1 (+ ?x 1)) (xbot (+ ?x 2)) ))
	(printout t crlf)
	(printout t "VERTICAL BATTLESHIP FOUND!!")
	(printout t crlf)
)

; Cerca corazzate  orizzontali
(defrule find_battleship_orizz 
	(status (step ?s)(currently running))
	?btf <- (battleship (to_find ?to_find_b ))
	(battleship (to_find ?to_find_b &:(> ?to_find_b 0)))
	(or			; middle guessed or fired
		(cell_status (kx ?x) (ky ?y) (stat guessed) ) 
		(cell_status (kx ?x) (ky ?y) (stat fired) ) 
	)
	(or			; top guessed or fired
		(cell_status (kx ?x) (ky ?y_left &:(eq ?y_left (- ?y 1))) (stat guessed) )
		(cell_status (kx ?x) (ky ?y_left &:(eq ?y_left (- ?y 1))) (stat fired) )
	)	
	(or			; middle1 guessed or fired
		(cell_status (kx ?x) (ky ?y_mid &:(eq ?y_mid (+ ?y 1))) (stat guessed) )	
		(cell_status (kx ?x) (ky ?y_mid &:(eq ?y_mid (+ ?y 1))) (stat fired) )
	)
	(or			; right guessed or fired
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 2))) (stat guessed) )	
		(cell_status (kx ?x) (ky ?y_right &:(eq ?y_right (+ ?y 2))) (stat fired) )
	)
	;water alle estremità
	(k-cell (x ?x) (y ?y_left2 &:(eq ?y_left2 (- ?y 2))) (content water)) 
	(k-cell (x ?x) (y ?y_right2 &:(eq ?y_right2 (+ ?y 3))) (content water)) 
	; se non già trovata quella nave
	(not (battleship_orizz_found 
		 (x ?x) (ysx ?yleft &:(eq ?yleft (- ?y 1))) 
		 (ymid ?y) 
		 (ymid1 ?ymid &:(eq ?ymid (+ ?y 1)))
		 (ydx ?yright &:(eq ?yright (+ ?y 2))) 
	)) 
=>	
	(modify ?btf (to_find (- ?to_find_b 1)))
	(assert (battleship_orizz_found (x ?x) (ysx (- ?y 1)) (ymid ?y) (ymid1 (+ ?y 1)) (ydx (+ ?y 2)) )) 
	(printout t crlf)
	(printout t "HORIZONTAL BATTLESHIP FOUND!!")
	(printout t crlf)
)


;  --------------------------- CAMBIO MODULO ------------------------------------------------------

; Non è più possibile fare Guess -> focus al modulo valutazione dei fires
(defrule go_to_guess ;(declare (salience -200))
	(status (step ?s)(currently running))
	(moves (guesses ?ng &:(> ?ng 0)))
	=>
	(printout t crlf)
	;(printout t "I know something let's guess: FOCUS to GUESS." crlf)
	(focus GUESS)
)

; Non è più possibile fare Guess -> focus al modulo valutazione dei fires
(defrule go_to_fire (declare (salience -300))
	(status (step ?s)(currently running))
	(moves (fires ?nf &:(> ?nf 0)))
	=>
	(printout t crlf)
	;(printout t "I don't know what to do anymore: FOCUS to VAL." crlf)
	(focus VAL)
)

;  --------------------------- FINE ------------------------------------------------------

(defrule solve (declare (salience -500))
	(status (step ?s)(currently running))
	;(not (cell_status (kx ?x) (ky ?y) (stat fired) ))
	(submarine (to_find ?to_find_s))
	(destroyer (to_find ?to_find_d))
	(cruiser (to_find ?to_find_c))
	(battleship (to_find ?to_find_b))
	(moves (fires ?nf) (guesses ?ng) )
=>
	(assert (exec (step ?s) (action solve)))

	(printout t crlf)
	(printout t "I don't know what to do anymore: let's SOLVE!" crlf)
	(printout t crlf)
	(printout t "Boats not found: "crlf)
	(printout t ?to_find_s " submarines left"crlf)
	(printout t ?to_find_d " destroyers left"crlf)
	(printout t ?to_find_c " cruisers left"crlf)
	(printout t ?to_find_b " battleships left"crlf)
	(printout t crlf)
	(printout t "Fires left: " ?nf "   Guess left: " ?ng " "crlf)
	(printout t crlf)
	(pop-focus)
)

