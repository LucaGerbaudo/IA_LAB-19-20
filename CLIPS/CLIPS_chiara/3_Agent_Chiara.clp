;  -------------- Agente 1 di Chiara -------------------------------

(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

; stampa delle celle note all'inizio del gioco
(defrule print-what-i-know-since-the-beginning
	(k-cell (x ?x) (y ?y) (content ?t) )
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)

; guess delle celle note con navi
(defrule first_step 
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content ?t) )
	(not (exec  (action guess) (x ?x) (y ?y)))
	(not (k-cell (x ?x) (y ?y) (content water) ))
=>
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
	(printout t "Step " ?s ", guessed [" ?x " , " ?y "]" crlf)
    (pop-focus)

)

