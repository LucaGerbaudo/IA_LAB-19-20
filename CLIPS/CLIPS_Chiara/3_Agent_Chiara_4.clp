
;  -------------- AGENTE DI CHIARA -------------------------------
; OBIETTIVO: guess su celle note in partenza e su prima cella nota come acqua 
;			conoscendo il contenuto delle celle note
;			Quando l'agente si trova "a corto di idee" passe il controllo ad un modulo di valutazione
;			se non vi sono più azioni possibili termina

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

; Template per tenere traccia dei cacciatorpedinieri
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

;  --------------------------- GUESS CELLE NOTE ------------------------------------------------------

; Controlla k-cell top e guess su di essa
(defrule guessKCellTop (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] top"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL TOP
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	
	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell bottom e guess su di essa
(defrule guessKCellBottom (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] bot"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL BOT
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(focus MAIN)
)

; Controlla k-cell LEFT e guess su di essa
(defrule guessKCellLeft (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] left"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL LEFT
	; Asserisco WATER attorno a K-CELL LEFT
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell SUB e guess su di essa
(defrule guessKCellSub (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content sub))
	(not (exec (action guess) (x ?x) (y ?y)))
	?stf <- (submarine (to_find ?to_find_s &:(> ?to_find_s 0)) ) ; per contare num di sottomarini da trovare
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] sub"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL sub
    (modify ?stf (to_find (- ?to_find_s 1))) ; decremento numero sottomarini da trovare
	(printout t crlf)
	(printout t "SUBMARINE FOUND!!")
	(printout t crlf)
	; Asserisco WATER attorno a K-CELL SUB
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell right e guess su di essa
(defrule guessKCellRight (declare (salience 100))
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action guess) (x ?x) (y ?Y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=> 
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] right"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))       ; dx
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water)))       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water)))       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell MIDDLE e guess su di essa
(defrule guessKCellMiddle (declare (salience 100))
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content middle))
	(not (exec (action guess) (x ?x) (y ?Y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=> 
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] middle"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

;  --------------------------- GUESS CELLE A FIANCO A QUELLE NOTE ---------------------------------------

; Controlla k-cell top e guess cella sottostante
(defrule guessCellUnderK-Top 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x-under &:(eq ?x-under(+ ?x 1))) (y ?y))) ; se non eseguita guess su cella sotto
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sotto alla K-CELL con content=TOP
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (+ ?x 1) "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	(assert (k-cell (x (+ ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx (+ ?x 1)) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" (+ ?x 1) "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell bottom e faccio guess cella soprastante
(defrule guessCellOnTopK-Bot ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x-top &:(eq ?x-top(- ?x 1))) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sopra alla K-CELL con content=BOT
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (- ?x 1) "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
	(assert (k-cell (x (- ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (- ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx (- ?x 1)) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" (- ?x 1) "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; GUESS sulla cella a DX alla K-CELL con content=LEFT
(defrule guessCellOnRightK-Left ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1)))))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," (+ ?y 1) "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 2)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 2)) (content water)))	;diag sotto dx

	(assert (cell_status (kx ?x) (ky (+ ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," (+ ?y 1) "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell right e faccio guess cella a sinistra
(defrule guessCellOnRight-Left ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action guess) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1)))))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	; GUESS sulla cella sinistra alla K-CELL con content=RIGHT
	(printout t "Step " ?s ":    GUESS cell [" ?x "," (- ?y 1) "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (- ?y 2)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 2)) (content water))) ; sotto-sx

	(assert (cell_status (kx ?x) (ky (- ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	;(printout t "--------------- cell[" ?x "," (- ?y 1) "]  guessed"crlf)
	(focus MAIN)
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
		))
=>	
	(modify ?ctf (to_find (- ?to_find_c 1)))
	(assert (cruiser_vert_found (xtop (- ?x 1))	(xmid ?x) (xbot (+ ?x 1)) ))
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

;  --------------------------- GUESS CELLE FIRED ------------------------------------------------------
;(defrule guess_cells_fired
;	(status (step ?s) (currently running))
;	(not (k-cell (x ?x) (y ?y) (content water) ) )
;	(cell_status (kx ?x) (ky ?y) (stat fired) )
;	(not (exec (action guess) (x ?x) (y ?y)))
;	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
;	=>
;	(assert (exec (action guess) (x ?x) (y ?y)) )
;	(printout t "Step " ?s ":    GUESS after fire cell [" ?x "," ?y "]"crlf)
;	(focus MAIN)
;)

;  --------------------------- FOCUS MODULO VAL ------------------------------------------------------

; Non si sa più dove colpire -> focus al modulo valutazione dei fires
(defrule go_to_fire (declare (salience -100))
	(status (step ?s)(currently running))
	;(not (cell_status (kx ?x) (ky ?y) (stat fired) ))
	=>
	;(printout t crlf)
	;(printout t "I don't know what to do anymore: FOCUS to VAL." crlf)
	(focus VAL)
)

;  --------------------------- FINE ------------------------------------------------------

(defrule solve (declare (salience -300))
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
	(focus MAIN)
)
