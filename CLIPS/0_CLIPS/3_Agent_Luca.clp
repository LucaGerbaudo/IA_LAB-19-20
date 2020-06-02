;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;Stampa dati noti all'inizio
(defrule print-what-i-know-since-the-beginning (declare (salience 50))
	(k-cell (x ?x) (y ?y) (content ?t) )
	;(k-per-row (row ?r) (num ?n))
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)
;Stampa dati noti all'inizio
(defrule no-knoweledge-at-beginning (declare (salience 50))
	(not (k-cell (x ?x) (y ?y) (content ?t) ))
	(k-per-row (row ?r) (num ?n))
=>
	(printout t "k-per-row" ?r ": " ?n crlf)
	(printout t "No data available for any cell" crlf)
)

(defrule initialState (declare (salience 50))
	(status (step ?s)(currently running))
	(moves (fires 5) (guesses 20))
    (statistics (num_fire_ok 0) (num_fire_ko 0) (num_guess_ok 0) (num_guess_ko 0) (num_safe 0) (num_sink 0))
	;(k-per-row (row ?r) (num ?n))
	;(k-per-row (row ?r) (num ?n))
=>
	(assert (exec (step ?s) (action guess) (x 0) (y 0)))
	(printout t "Situa iniziale" crlf)
	;(printout t "k-per-row" ?r ": " ?n crlf)
    (pop-focus)
)

;(defrule checkGuessFirstCell
;	(status (step ?s)(currently running))
;	(exec  (step ?s-1) (action guess) (x 0) (y 0))
;=>
;	;(assert (exec (step ?s) (action fire) (x 1) (y 1)))
;	(printout t "FIRE ON FIRST CELL" crlf)
;	(pop-focus)
;)