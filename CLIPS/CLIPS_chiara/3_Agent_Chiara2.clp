;  -------------- AGENTE 2 DI CHIARA -------------------------------
; OBIETTIVO:

(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
;(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
;(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
;(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
;(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water) ) ) ; sopra-dx
;(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water) ) ) ; sopra-sx
;(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water) ) ) ; sotto-dx
;(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water) ) ) ; sotto-sx

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

;  --------------------------- INIZIALIZZAZIONE ------------------------------------------------------

; Stampa delle celle note all'inizio del gioco
(defrule print-what-i-know-since-the-beginning (declare (salience 100))
	(k-cell (x ?x) (y ?y) (content ?t) )
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)

; Caso in cui nessuna cella nota all' inizio del gioco
(defrule no-knoweledge-at-beginning (declare (salience 50))
	(not (k-cell (x ?x) (y ?y) (content ?t) ))
	;(k-per-row (row ?r) (num ?n))
=>
	;(printout t "k-per-row" ?r ": " ?n crlf)
	(printout t "No data available for any cell" crlf)
)

;  --------------------------- GUESS CELLE NOTE ------------------------------------------------------

; Controlla k-cell top e guess su di essa
(defrule guessKCellTop ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "K-CELL: TOP in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL TOP
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell top e guess cella sottostante
(defrule guessCellUnderK-Top ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x-under &:(eq ?x-under(+ ?x 1))) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sotto alla K-CELL con content=TOP
	(printout t crlf)
	(printout t "GUESS cell under K-TOP [" (+ ?x 1) "," ?y "]" crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	(assert (k-cell (x (+ ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell bottom e guess su di essa
(defrule guessKCellBottom ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "K-CELL: BOT in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL BOT
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell top e faccio guess cella sottostante
(defrule guessCellOnTopK-Bot ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x-top &:(eq ?x-top(- ?x 1))) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sopra alla K-CELL con content=BOT
	(printout t crlf)
	(printout t "GUESS cell on top of K-BOT [" (- ?x 1) "," ?y "]" crlf)
	(assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
	(assert (k-cell (x (- ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (- ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell LEFT e guess su di essa
(defrule guessKCellLeft ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "K-CELL: LEFT in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL LEFT
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell LEFT e guess cella a destra
(defrule guessCellOnRightK-Left ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1)))))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella a DX alla K-CELL con content=LEFT
	(printout t crlf)
	(printout t "GUESS cell on the right of K-LEFT [" ?x "," (+ ?y 1) "]" crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 2)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 2)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell SUB e guess su di essa
(defrule guessKCellSub ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content sub))
	(not (exec (action guess) (x ?x) (y ?y)))
	(submarine (to_find ?to_find &:(> ?to_find 0)) ) ; per contare num di sottomarini da trovare
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "K-CELL: SUB in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL sub
    (assert (submarine (to_find (- ?to_find 1))))  ; decremento numero sottomarini da trovare
	; Asserisco WATER attorno a K-CELL SUB
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water))) 	;sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	(pop-focus)
)

; Controlla k-cell right e guess su di essa
(defrule guessKCellRight
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action guess) (x ?x) (y ?Y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=> 
	(printout t crlf)
	(printout t "K-CELL: RIGHT in "[ ?x "," ?y "]"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))       ; dx
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water)))       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water)))       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx
	(pop-focus)
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
	(printout t "GUESS cell on left of K-RIGHT [" ?x "," (- ?y 1) "]" crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (- ?y 2)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 2)) (content water))) ; sotto-sx
	(pop-focus)
)

; Controlla k-cell MIDDLE e guess su di essa
(defrule guessKCellMiddle
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content middle))
	(not (exec (action guess) (x ?x) (y ?Y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=> 
	(printout t crlf)
	(printout t "K-CELL: MIDDLE in "[ ?x "," ?y "]"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx
	(pop-focus)
)

;  --------------------------- FIRE PER SCOPRIRE NAVI ------------------------------------------------------

;  --------------------------- FINE ------------------------------------------------------
; Stampa numero di navi non trovate
(defrule print_left_boats (declare (salience -100))
	(status (step ?s)(currently running))
	(submarine (to_find ?to_find_s))
	(destroyer (to_find ?to_find_d))
	(cruiser (to_find ?to_find_c))
	(battleship (to_find ?to_find_b))
=>
	(printout t ""crlf)
	(printout t "Boats not found: "crlf)
	(printout t ?to_find_s " submarines left"crlf)
	(printout t ?to_find_d " destroyers left"crlf)
	(printout t ?to_find_c " cruisers left"crlf)
	(printout t ?to_find_b " battleships left"crlf)
	(pop-focus)
)
; Non si sa più dove colpire
(defrule solve (declare (salience -300))
	(status (step ?s)(currently running))
=>
	(assert (exec (step ?s) (action solve)))
	(printout t crlf)
	(printout t "I don't know what to do anymore: let's solve." crlf)
	(printout t crlf)
	(pop-focus)
)
