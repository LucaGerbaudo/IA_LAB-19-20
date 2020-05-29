
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

;----------------------------- RANDOM FIRE -----------------------------------------




