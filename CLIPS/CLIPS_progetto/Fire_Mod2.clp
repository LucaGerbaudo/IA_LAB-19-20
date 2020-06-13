
;  --------------  MODULO FIRE -------------------------------
; Esegue operazione di fire prima sulla cella con più possibilità di avere contenuto nave
;	se già effettuata fire su tale cella esegue operazioni di fire su riga migliore (con n maggiore)


(defmodule VAL (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))


;----------------------------- FIRE -----------------------------------------

; Fire su cella con num col e num row massimo
(defrule fireOnCellBestRowAndCol (declare (salience 100))
	(status (step ?s) (currently running))
	(k-per-row (row ?x) (num ?numR &:(> ?numR 0)))
	(not (k-per-row (row ?x2) (num ?num-r2 &:(> ?num-r2 ?numR))))
	(k-per-col (col ?y) (num ?numC &:(> ?numC 0)))
	(not (k-per-col (col ?y2) (num ?numC2 &:(> ?numC2 ?numC)))  )
	(moves (fires ?nf &:(> ?nf 0)))
	(not (k-cell (x ?x) (y ?y)))
	(not (exec (action fire) (x ?x) (y ?y)))
	(not (exec (action guess) (x ?x) (y ?y)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE ON [" ?x ", " ?y "] based on best K-ROW and K-COL" crlf)
	(assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
	(focus MAIN)
)

; Fire lungo riga migliore
(defrule fireOnBestRow 
	(status (step ?s) (currently running))
	(k-per-row (row ?x) (num ?numR &:(> ?numR 0)))
	(not (k-per-row (row ?x2) (num ?num-r2 &:(> ?num-r2 ?numR))))
	(moves (fires ?nf &:(> ?nf 0)))
	?index <- (indexFire (i ?i))
	(not (k-cell (x ?x) (y ?i)))
	(not (exec (action fire) (x ?x) (y ?i)))
	(not (exec (action guess) (x ?x) (y ?i)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE ON [" ?x ", " ?i "] based on best K-ROW" crlf)
	(assert (exec (step ?s) (action fire) (x ?x) (y ?i)))
	(modify ?index (i (+ ?i 2))) ; Aumento indice di due: prossima fire stessa riga, ma due celle a dx
	(focus MAIN)
)

;(defrule decide_if_fire_random (declare (salience -200))
;	(status (step ?s)(currently running))
;	(moves (fires ?nf &:(> ?nf 0)))
;	; nel caso in cui nella cella 
;	(k-per-row (row ?r) (num ?nr &:(> ?nr 0)))
;	(k-per-col (col ?c) (num ?nc &:(> ?nc 0)))
;
;	(not (exec (action fire) (x ?r) (y ?c) )) ; se non eseguita fire 
;	(not (exec (action guess) (x ?r) (y ?c) )) ; se non eseguita guess 
;	(not (k-cell (x ?r) (y ?c) (content water)) )
;	(not  (cell_status (kx ?r) (ky ?c) (stat guessed) ))
;	(not  (cell_status (kx ?r) (ky ?c) (stat fired) ))
;=>
;	(printout t crlf)
;	(printout t "Step " ?s ":   RANDOM FIRE cell [" ?r  "," ?c "] "crlf)
;	(assert (exec (step ?s) (action fire) (x ?r ) (y ?c) ))
;	(focus MAIN)
;)