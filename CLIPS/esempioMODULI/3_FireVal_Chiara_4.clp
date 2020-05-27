
;  --------------  MODULO VALUTAZIONE FIRE -------------------------------
; OBIETTIVO: valutare quale tipo di FIRE fare in base alla situazione

(defmodule VAL (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))


; Decide di richiamare il modulo con Fire su 2 celle dopo se ci sono ancora incrociatori 
(defrule decide_if_fire
	(status (step ?s)(currently running))
	(cruiser (to_find ?to_find_c &:(> ?to_find_c 0)))
	;(battleship (to_find ?to_find_b &:(> ?to_find_b 0)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	;(printout t crlf)
	;(printout t "---------------MODULO VAL------------ "crlf)
	;(printout t ?to_find_c " cruisers left      ")
	;(printout t ?to_find_b " battleships left"crlf)
	;(printout t "Fires left: " ?nf "   Guess left: " ?ng " "crlf)
	;(printout t "=> faccio FIRE " crlf)
	;(printout t crlf)
	(focus FIRE_FWD)
)

; Decide di richiamare il modulo con Fire su 2 celle dopo se ci sono ancora corazzate 
(defrule decide_if_fire1
	(status (step ?s)(currently running))
	(battleship (to_find ?to_find_b &:(> ?to_find_b 0)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	;(printout t crlf)
	;(printout t "---------------MODULO VAL------------ "crlf)
	;(printout t ?to_find_b " battleships left"crlf)
	;(printout t "Fires left: " ?nf "   Guess left: " ?ng " "crlf)
	;(printout t "=> faccio FIRE " crlf)
	;(printout t crlf)
	(focus FIRE_FWD)
)

; Trova incrociatori    DA VEDEREEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEe

;(defrule find_cruisers_orizz (declare (salience 100))
;	(status (step ?s)(currently running))
;	(cruiser (to_find ?to_find_c &:(> ?to_find_c 0)))
	;(not (k-cell (x (- ?x 2)) (y ?y) (content water)) )
	;(cell_status (kx (- ?x 1)) (ky ?y) (stat guessed) ) ; top/bot guessed
	;(cell_status (kx ?x) (ky ?y) (stat guessed) ) 		; middle guessed
	;(cell_status (kx (+ ?x 1)) (ky ?y) (stat guessed) ) ; top/bot guessed
	;(not (k-cell (x (+ ?x 2)) (y ?y) (content water)) )

;	(k-cell (x (- ?x 1)) (y ?y) (content top))
;	(k-cell (x ?x ) (y ?y) (content middle))
;	(k-cell (x (+ ?x 1)) (y ?y) (content bot))
;=>	
;	(modify ?mvs (fires (- ?nf 1)))
;	(modify (cruiser (to_find (- ?to_find_c 1)) ))
;	(printout t crlf)
;	(printout t ?to_find_c "----------- cruisers left"crlf)
;)

