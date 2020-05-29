
;  --------------  MODULO FIRE FORWARD -------------------------------

; OBIETTIVO: Fare FIRE sulle celle che si presumano avere contenuto = boat
;			ovvero due celle dopo una nota 

(defmodule FIRE_FWD (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (import VAL ?ALL) (export ?ALL))

;(defrule ciao
;=>
;	(printout t crlf)
;	(printout t "Ciao ho cambiato modulo" crlf)
;	(pop-focus)
;)

; FIRE su 2 celle sotto alla K-CELL con content=TOP
(defrule fire_2CellUnderK_Top 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action fire) (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) )) ; se non guessed
	(not (k-cell (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) (content water))) ; controllo se cella da sparare non è nota come acqua
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x (+ ?x 2)) (y ?y)))
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" (+ ?x 2) "," ?y "] knowing [" ?x "," ?y "] top" crlf)
	(assert (cell_status  (stat fired) (kx (+ ?x 2)) (ky ?y) )) ; tiene traccia che la cella è stata fired
	(printout t "--------------- cell[" (+ ?x 2) "," ?y "]  fired"crlf)
	(focus MAIN)
)

; FIRE su 2 celle sopra alla K-CELL con content=BOT
(defrule fire_2CellUp_K-Bot 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action fire) (x ?x-2up &:(eq ?x-2up(- ?x 2))) (y ?y) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x-2up &:(eq ?x-2up(- ?x 2))) (y ?y) ))  ; se non guessed
	(not (k-cell (x ?x-2under &:(eq ?x-2under(- ?x 2))) (y ?y) (content water))) ; controllo se cella da sparare non è nota come acqua
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x (- ?x 2)) (y ?y) ))
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" (- ?x 2) "," ?y "] knowing [" ?x "," ?y "] bot" crlf)
	(assert (cell_status  (stat fired) (kx (- ?x 2)) (ky ?y) )) ; tiene traccia che la cella è stata fired
	(printout t "--------------- cell[" (- ?x 2) "," ?y "]  fired"crlf)
	(focus MAIN)
)

; FIRE su 2 celle a dx alla K-CELL con content=LEFT
(defrule fire_2CellDx_K-Left
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action fire) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) )) ; se non guessed
	(not (k-cell (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) (content water))) ; controllo se cella da sparare non è nota come acqua
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x ?x)(y (+ ?y 2)) ))       
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" ?x "," (+ ?y 2) "] knowing [" ?x "," ?y "] left" crlf)
	(assert (cell_status  (stat fired) (kx ?x)(ky (+ ?y 2)) )) ; tiene traccia che la cella è stata fired
	(printout t "--------------- cell[" ?x "," (+ ?y 2) "]  fired"crlf)
	(focus MAIN)
)

; FIRE e GUESS su 2 celle a sx alla K-CELL con content=RIGHT
(defrule fire_2CellSx_K-Right
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action fire) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) )) ; se non guessed
	(not (k-cell (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) (content water))) ; controllo se cella da sparare non è nota come acqua
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x ?x)(y (- ?y 2)) ))       
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" ?x "," (- ?y 2) "] knowing [" ?x "," ?y "] right" crlf)
	(assert (cell_status  (stat fired) (kx ?x)(ky (- ?y 2)) )) ; tiene traccia che la cella è stata fired
	(printout t "--------------- cell[" ?x "," (- ?y 2) "]  fired"crlf)
	(focus MAIN)
)