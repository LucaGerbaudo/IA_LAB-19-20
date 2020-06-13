
;  --------------  MODULO GUESS -------------------------------
; Esegue le operazioni di guess sulle celle che contengono sicuramente una parte di nave


(defmodule GUESS (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))


;  --------------------------- GUESS CELLE NOTE ------------------------------------------------------

; Controlla k-cell top e guess su di essa
(defrule guessKCellTop (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (guesses ?ng &:(> ?ng 0)))
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
	(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell bottom e guess su di essa
(defrule guessKCellBottom (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (guesses ?ng &:(> ?ng 0)))
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
	(moves (guesses ?ng &:(> ?ng 0)))
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
	(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell SUB e guess su di essa
(defrule guessKCellSub (declare (salience 100))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content sub))
	(not (exec (action guess) (x ?x) (y ?y)))
	?stf <- (submarine (to_find ?to_find_s &:(> ?to_find_s 0)) ) ; per contare num di sottomarini da trovare
	(moves (guesses ?ng &:(> ?ng 0)))
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
	(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell right e guess su di essa
(defrule guessKCellRight (declare (salience 100))
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (guesses ?ng &:(> ?ng 0)))
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
	(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell MIDDLE e guess su di essa
(defrule guessKCellMiddle (declare (salience 100))
	(status (step ?s)(currently running))
	(k-cell (x ?x) (y ?y) (content middle))
	(not (exec (action guess) (x ?x) (y ?Y)))
	(moves (guesses ?ng &:(> ?ng 0)))
=> 
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," ?y "] middle"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx

	(assert (cell_status (kx ?x) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" ?x "," ?y "]  guessed"crlf)
	(focus MAIN)
)

;  --------------------------- GUESS CELLE A FIANCO A QUELLE NOTE ---------------------------------------

; Controlla k-cell top e guess cella sottostante
(defrule guessCellUnderK-Top 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x-under &:(eq ?x-under(+ ?x 1))) (y ?y))) ; se non eseguita guess su cella sotto
	(moves (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sotto alla K-CELL con content=TOP
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (+ ?x 1) "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	(assert (k-cell (x (+ ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (+ ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx (+ ?x 1)) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" (+ ?x 1) "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell bottom e faccio guess cella soprastante
(defrule guessCellOnTopK-Bot ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action guess) (x ?x-top &:(eq ?x-top(- ?x 1))) (y ?y)))
	(moves (guesses ?ng &:(> ?ng 0)))
=>
	; GUESS sulla cella sopra alla K-CELL con content=BOT
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (- ?x 1) "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x (- ?x 1)) (y ?y)))
	(assert (k-cell (x (- ?x 2)) (y (- ?y 1)) (content water)))	;diag sotto sx
	(assert (k-cell (x (- ?x 2)) (y (+ ?y 1)) (content water)))	;diag sotto dx

	(assert (cell_status (kx (- ?x 1)) (ky ?y) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" (- ?x 1) "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; GUESS sulla cella a DX alla K-CELL con content=LEFT
(defrule guessCellOnRightK-Left ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1)))))
	(moves (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x "," (+ ?y 1) "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 2)) (content water)))	;diag sopra dx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 2)) (content water)))	;diag sotto dx

	(assert (cell_status (kx ?x) (ky (+ ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" ?x "," (+ ?y 1) "]  guessed"crlf)
	(focus MAIN)
)

; Controlla k-cell right e faccio guess cella a sinistra
(defrule guessCellOnRight-Left ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action guess) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1)))))
	(moves (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	; GUESS sulla cella sinistra alla K-CELL con content=RIGHT
	(printout t "Step " ?s ":    GUESS cell [" ?x "," (- ?y 1) "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1))))
	(assert (k-cell (x (- ?x 1)) (y (- ?y 2)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 2)) (content water))) ; sotto-sx

	(assert (cell_status (kx ?x) (ky (- ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" ?x "," (- ?y 1) "]  guessed"crlf)
	(focus MAIN)
)

; --------- GUESS DATO MIDDLE -------------

; Se k-cell middle ha water a dx o sx e non guess sopra -> guess top
(defrule guessOnTopKMiddle ;(declare (salience 30))
	(status (step ?s) (currently running))
	(moves (guesses ?ng &:(> ?ng 0)))
	(k-cell (x ?x) (y ?y) (content ?c &:(eq ?c middle)))
	(or 
		(k-cell (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1))) (content water))
		(k-cell (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1))) (content water))
	)
	(not (exec (action guess) (x ?x-up &:(eq ?x-up(- ?x 1))) (y ?y)))
	(not (exec (action fire) (x ?x-up &:(eq ?x-up(- ?x 1))) (y ?y)))
	;(not (exec (action guess) (x ?x-bot &:(eq ?x-up(+ ?x 1))) (y ?y)))
=>
	;(printout t "GUESS ON [" (- ?x 1) ", " ?y "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (- ?x 1) ", " ?y "] knowing [" ?x "," ?y "] middle"crlf)
	(assert (exec (step ?s) (action guess) (x (- ?x 1))(y ?y)))
	; ASSERISCO ACQUA ATTORNO
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
	(assert (k-cell (x (- ?x 2)) (y (+ ?y 1)) (content water) ) ) ; sopra-dx
	(assert (k-cell (x (- ?x 2)) (y (- ?y 1)) (content water) ) ) ; sopra-sx

	(assert (cell_status (kx (- ?x 1)) (ky  ?y ) (stat guessed)) ) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" (- ?x 1) "," ?y  "]  guessed"crlf)
	(focus MAIN)
)

; Se k-cell middle ha water a dx o sx e non guess sotto -> guess bot
(defrule guessOnBotKMiddle ;(declare (salience 30))
	(status (step ?s) (currently running))
	(moves (guesses ?ng &:(> ?ng 0)))
	(k-cell (x ?x) (y ?y) (content ?c &:(eq ?c middle)))
	(or 
		(k-cell (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1))) (content water))
		(k-cell (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1))) (content water))
	)
	(not (exec (action guess) (x ?x-bot &:(eq ?x-bot(+ ?x 1))) (y ?y)))
	(not (exec (action fire) (x ?x-bot &:(eq ?x-bot(+ ?x 1))) (y ?y)))
=>
	;(printout t "GUESS ON [" (+ ?x 1) ", " ?y "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" (+ ?x 1) ", " ?y "] knowing [" ?x "," ?y "] middle"crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	; ASSERISCO ACQUA
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
	(assert (k-cell (x (+ ?x 2)) (y (+ ?y 1)) (content water) ) ) ; sotto-dx
	(assert (k-cell (x (+ ?x 2)) (y (- ?y 1)) (content water) ) ) ; sotto-sx

	(assert (cell_status (kx (+ ?x 1)) (ky ?y ) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" (+ ?x 1) "," ?y "]  guessed"crlf)
	(focus MAIN)
)

; Se k-cell middle ha water top o bot e non guess sx -> guess LEFT
(defrule guessOnLeftKMiddle ;(declare (salience 30))
	(status (step ?s) (currently running))
	(moves (guesses ?ng &:(> ?ng 0)))
	(k-cell (x ?x) (y ?y) (content ?c &:(eq ?c middle)))
	(or 
		(k-cell (x ?x-top &:(eq ?x-top (- ?x 1))) (y ?y) (content water))
		(k-cell (x ?x-bot &:(eq ?x-bot (+ ?x 1))) (y ?y) (content water))
	)
	(not (exec (action guess) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1)))))
	(not (exec (action fire) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 1)))))
	;(not (exec (action guess) (x ?x-bot &:(eq ?x-up(+ ?x 1))) (y ?y)))
=>
	;(printout t "GUESS ON [" ?x ", " (- ?y 1) "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell [" ?x ", " (- ?y 1) "] knowing [" ?x "," ?y "] middle"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1)) ))
	; ASSERISCO ACQUA
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (- ?y 2)) (content water) ) ) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 2)) (content water) ) ) ; sotto-sx

	(assert (cell_status (kx ?x) (ky (- ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" ?x "," (- ?y 1) "]  guessed"crlf)
	(focus MAIN)
)

; Se k-cell middle ha water top o bot e non guess dx -> guess RIGHT
(defrule guessOnRightKMiddle ;(declare (salience 30))
	(status (step ?s) (currently running))
	(moves (guesses ?ng &:(> ?ng 0)))
	(k-cell (x ?x) (y ?y) (content ?c &:(eq ?c middle)))
	(or 
		(k-cell (x ?x-top &:(eq ?x-top (- ?x 1))) (y ?y) (content water))
		(k-cell (x ?x-bot &:(eq ?x-bot (+ ?x 1))) (y ?y) (content water))
	)
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1)))))
	(not (exec (action fire) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 1)))))
	;(not (exec (action guess) (x ?x-bot &:(eq ?x-up(+ ?x 1))) (y ?y)))
=>
	;(printout t "GUESS ON [" ?x ", " (+ ?y 1) "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(printout t crlf)
	(printout t "Step " ?s ":    GUESS cell[" ?x ", " (+ ?y 1) "] knowing [" ?x "," ?y "]  middle"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
	; ASSERISCO ACQUA
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 2)) (content water) ) ) ; sopra-dx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 2)) (content water) ) ) ; sotto-dx

	(assert (cell_status (kx ?x) (ky (+ ?y 1)) (stat guessed) )) ; tiene traccia che la cella è stata guessed
	(printout t "--------------- cell[" ?x "," (+ ?y 1) "]  guessed"crlf)
	(focus MAIN)
)
