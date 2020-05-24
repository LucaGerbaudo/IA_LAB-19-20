;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

(deftemplate new-k-cell 
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot sub))
)

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
	;(k-per-row (row ?r) (num ?n))
=>
	;(printout t "k-per-row" ?r ": " ?n crlf)
	(printout t "No data available for any cell" crlf)
)

; Controlla e fa guess su tutte le celle note
;(defrule checkKCells ;(declare (salience 50))
;	(status (step ?s) (currently running))
;	(k-cell (x ?x) (y ?y) (content ?c))
;	(not (exec (action guess) (x ?x) (y ?y)))
;=>
;	(printout t "K-CELL: " ?c " in "[ ?x "," ?y "]"crlf)
;	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
;	(pop-focus)
;)

(deffunction addOne (?n)
	(+ ?n 1)
)

; Controlla k-cell top e faccio guess cella sottostante
(defrule guessKCellTop ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x) (y ?y)))
	;?newX <- (addOne ?x)
	;(not (exec (action guess) (x ?x) (y ?y)))
=>
	;(printout t "K-CELL: TOP in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))		;guess K-CELL top
	;(assert (exec (step (+ ?s 1)) (action guess) (x (+ ?x 1)) (y ?y)))	;guess cella sotto
	;(facts)
	; Asserisco WATER attorno a K-CELL TOP
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water))) 	;sopra
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water)))	;sx
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water)))	;dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))	;diag sopra sx
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))	;diag sotto dx
	;(facts)
	;(printout t "NewX " ?newX crlf)
	(pop-focus)
	;(assert (exec (step ?s) (action solve)))
)

; Controlla k-cell top e faccio guess cella sottostante
(defrule guessCellUnderK-Top ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (new-k-cell (x ?x) (y ?y) (content middle)))
=>
	;(printout t "K-CELL: TOP in "[ ?x "," ?y "]"crlf)
	;(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))		;guess K-CELL top
	;(printout t "AAA")
	;(printout t "NewX: " ?newX)
	(printout t "Guess cell under K-TOP" crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	(assert (new-k-cell (x (+ ?x 1)) (y ?y)) (content middle))
	(pop-focus)
	;(assert (exec (step ?s) (action solve)))
)


;Stato iniziale
;(defrule initialState
;	(status (step ?s)(currently running))
;	;(moves (fires ?f&:(> ?f 0)) (guesses ?ng&:(> ?ng 0)))
;    (statistics (num_fire_ok 0) (num_fire_ko 0) (num_guess_ok 0) (num_guess_ko 0) (num_safe 0) (num_sink 0))
;	;(k-per-row (row ?r) (num ?n))
;	;(k-per-row (row ?r) (num ?n))
;=>
;	;(assert (exec (step ?s) (action guess) (x 0) (y 0)))
;	;(assert (status (step 100) (currently running)))
;	;(assert (exec (step ?s) (action fire) (x 0) (y 0)))
;	(printout t "Situazione iniziale" crlf)
;	;(assert (pallino 0 0))
;	;(assert (solve))
;	;(printout t "Solve assert" crlf)
;	;(printout t "k-per-row" ?r ": " ?n crlf)
;    (pop-focus)
;)

;
;(defrule setGuessAroundKCell (declare (salience 50))
;	(status (step ?s) (currently running))
;	(k-cell (x ?x) (y 4) (content ?t))
;=>
;	(printout t "AAAAAAA" crlf)
;	(assert (status (step 100) (currently running)))
;	(assert (exec (step ?s) (action fire) (x (- ?x 1)) (y 4)))
;	(assert (exec (step ?s) (action fire) (x (- ?x 1)) (y 4)))
;	(assert (exec (step ?s) (action fire) (x (- ?x 1)) (y 4)))
;	(assert (status (step 100) (currently running)))
;)

;(defrule checkGuessFirstCell
;	(status (step ?s)(currently running))
;	(exec  (step ?s-1) (action guess) (x 0) (y 0))
;=>
;	;(assert (exec (step ?s) (action fire) (x 1) (y 1)))
;	(printout t "FIRE ON FIRST CELL" crlf)
;	(pop-focus)
;)