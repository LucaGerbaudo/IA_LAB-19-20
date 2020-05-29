;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

;(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
;(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
;(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
;(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
;(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water) ) ) ; sopra-dx
;(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water) ) ) ; sopra-sx
;(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water) ) ) ; sotto-dx
;(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water) ) ) ; sotto-sx

(deftemplate k-row-water
	(slot row)
)

(deftemplate k-col-water
	(slot col)
)

;Stampa dati noti all'inizio
(defrule print-what-i-know-since-the-beginning (declare (salience 50))
	(k-cell (x ?x &:(> ?x -1) &:(< ?x 10)) (y ?y &:(> ?y -1) &:(< ?y 10)) (content ?t) )
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

; Asserisce acqua nelle righe con k-per-row = 0
(defrule setWaterKRow (declare (salience 50))
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
)

; Asserisce acqua nelle colonne con k-per-col = 0
(defrule setWaterKCol (declare (salience 50))
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
)

; Controlla k-cell top e guess su di essa
(defrule guessKCellTop ;(declare (salience 50))
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action guess) (x ?x) (y ?y)))
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step "?s " GUESS ON K-CELL: TOP in "[ ?x "," ?y "]"crlf)
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
	(printout t "Step " ?s " GUESS cell under K-TOP [" (+ ?x 1) "," ?y "]" crlf)
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
	(printout t "Step " ?s " GUESS ON K-CELL: BOT in "[ ?x "," ?y "]"crlf)
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
	(printout t "Step " ?s " GUESS cell on top of K-BOT [" (- ?x 1) "," ?y "]" crlf)
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
	(printout t "Step " ?s" GUESS ON K-CELL: LEFT in "[ ?x "," ?y "]"crlf)
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
	(printout t "Step " ?s " GUESS cell on the right of K-LEFT [" ?x "," (+ ?y 1) "]" crlf)
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
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(printout t crlf)
	(printout t "Step " ?s " GUESS ON K-CELL: SUB in "[ ?x "," ?y "]"crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))	;guess K-CELL sub
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
	(printout t "Step " ?s " GUESS ON K-CELL: RIGHT in "[ ?x "," ?y "]"crlf)
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
	(printout t "Step " ?s " GUESS cell on left of K-RIGHT [" ?x "," (- ?y 1) "]" crlf)
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
	(printout t "Step " ?s " GUESS ON K-CELL: MIDDLE in "[ ?x "," ?y "]"crlf)
	(assert (exec(step ?s) (action guess) (x ?x) (y ?y)))		; questa cella
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water))) ; sopra-dx
	(assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water))) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water))) ; sotto-dx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water))) ; sotto-sx
	(pop-focus)
)

; FIRE su 2 celle sotto alla K-CELL con content=TOP
(defrule fire_2CellUnderK_Top 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content top))
	(not (exec (action fire) (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) )) ; se non guessed
	(not (k-cell (x ?x-2under &:(eq ?x-2under(+ ?x 2))) (y ?y) (content water))) ; controllo se cella da sparare non è nota come acqua
	;(battleship (to_find ?to_find &:(> ?to_find 0)) ) ; controllo se ci sono ancora incrociatori da affondare		DA VEDERE!!!!
	;(cruiser (to_find ?to_find &:(> ?to_find 0)) ); controllo se ci sono ancora corazzate da affondare 		DA VEDERE!!!!
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x (+ ?x 2)) (y ?y)))
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" (+ ?x 2) "," ?y "] knowing [" ?x "," ?y "] top" crlf)
	(pop-focus)
)

; FIRE su 2 celle sopra alla K-CELL con content=BOT
(defrule fire_2CellUp_K-Bot 
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content bot))
	(not (exec (action fire) (x ?x-2up &:(eq ?x-2up(- ?x 2))) (y ?y) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x-2up &:(eq ?x-2up(- ?x 2))) (y ?y) ))  ; se non guessed
	(not (k-cell (x ?x-2under &:(eq ?x-2under(- ?x 2))) (y ?y) (content water))) ; controllo se cella da sparare non è nota come acqua
	;(battleship (to_find ?to_find &:(> ?to_find 0)) ) ; controllo se ci sono ancora incrociatori da affondare 		DA VEDERE!!!!
	;(cruiser (to_find ?to_find &:(> ?to_find 0)) ); controllo se ci sono ancora corazzate da affondare 		DA VEDERE!!!!
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x (- ?x 2)) (y ?y)))
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" (- ?x 2) "," ?y "] knowing [" ?x "," ?y "] bot" crlf)
	(pop-focus)
)

; FIRE su 2 celle a dx alla K-CELL con content=LEFT
(defrule fire_2CellDx_K-Left
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content left))
	(not (exec (action fire) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) )) ; se non guessed
	(not (k-cell (x ?x) (y ?y-right &:(eq ?y-right(+ ?y 2))) (content water))) ; controllo se cella da sparare non è nota come acqua
	;(battleship (to_find ?to_find &:(> ?to_find 0)) ) ; controllo se ci sono ancora incrociatori da affondare 		DA VEDERE!!!!
	;(cruiser (to_find ?to_find &:(> ?to_find 0)) ); controllo se ci sono ancora corazzate da affondare 		DA VEDERE!!!!
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x ?x)(y (+ ?y 2)) ))       
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" ?x "," (+ ?y 2) "] knowing [" ?x "," ?y "] left" crlf)
	(pop-focus)
)

; FIRE e GUESS su 2 celle a sx alla K-CELL con content=RIGHT
(defrule fire_2CellSx_K-Right
	(status (step ?s) (currently running))
	(k-cell (x ?x) (y ?y) (content right))
	(not (exec (action fire) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) )) ; se non eseguita fire 
	(not (exec (action guess) (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) )) ; se non guessed
	(not (k-cell (x ?x) (y ?y-left &:(eq ?y-left(- ?y 2))) (content water))) ; controllo se cella da sparare non è nota come acqua
	;(battleship (to_find ?to_find &:(> ?to_find 0)) ) ; controllo se ci sono ancora incrociatori da affondare 		DA VEDERE!!!!
	;(cruiser (to_find ?to_find &:(> ?to_find 0)) ); controllo se ci sono ancora corazzate da affondare 		DA VEDERE!!!!
	(moves (fires ?nf &:(> ?nf 0)) (guesses ?ng &:(> ?ng 0)))
=>
	(assert (exec (step ?s) (action fire) (x ?x)(y (- ?y 2)) ))       
	(printout t crlf)
	(printout t "Step " ?s ":    FIRE cell [" ?x "," (- ?y 2) "] knowing [" ?x "," ?y "] right" crlf)
	(pop-focus)
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
	(printout t "GUESS ON [" (- ?x 1) ", " ?y "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(assert (exec (step ?s) (action guess) (x (- ?x 1))(y ?y)))
	; ASSERISCO ACQUA ATTORNO
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
	(assert (k-cell (x (- ?x 2)) (y (+ ?y 1)) (content water) ) ) ; sopra-dx
	(assert (k-cell (x (- ?x 2)) (y (- ?y 1)) (content water) ) ) ; sopra-sx
	(pop-focus)
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
	(printout t "GUESS ON [" (+ ?x 1) ", " ?y "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(assert (exec (step ?s) (action guess) (x (+ ?x 1)) (y ?y)))
	; ASSERISCO ACQUA
	(assert (k-cell (x ?x) (y (+ ?y 1)) (content water) ) )       ; dx
	(assert (k-cell (x ?x) (y (- ?y 1)) (content water) ) )       ; sx
	(assert (k-cell (x (+ ?x 2)) (y (+ ?y 1)) (content water) ) ) ; sotto-dx
	(assert (k-cell (x (+ ?x 2)) (y (- ?y 1)) (content water) ) ) ; sotto-sx
	(pop-focus)
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
	(printout t "GUESS ON [" ?x ", " (- ?y 1) "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (- ?y 1)) ))
	; ASSERISCO ACQUA
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (- ?y 2)) (content water) ) ) ; sopra-sx
	(assert (k-cell (x (+ ?x 1)) (y (- ?y 2)) (content water) ) ) ; sotto-sx
	(pop-focus)
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
	(printout t "GUESS ON [" ?x ", " (+ ?y 1) "] knowing [" ?x "," ?y "] MIDDLE" crlf)
	(assert (exec (step ?s) (action guess) (x ?x) (y (+ ?y 1))))
	; ASSERISCO ACQUA
	(assert (k-cell (x (+ ?x 1)) (y ?y) (content water) ) )       ; sotto
	(assert (k-cell (x (- ?x 1)) (y ?y) (content water) ) )       ; sopra
	(assert (k-cell (x (- ?x 1)) (y (+ ?y 2)) (content water) ) ) ; sopra-dx
	(assert (k-cell (x (+ ?x 1)) (y (+ ?y 2)) (content water) ) ) ; sotto-dx
	(pop-focus)
)

; -------------- GUESS SULLE CELLE IN BASE A K-ROW e K-COL ----------------
;(defrule fireOnBestCol
;	(status (step ?s) (currently running))
;	;(k-per-row (row ?x) (num ?num))
;	;(not (k-per-row (row ?x2) (num ?num-row2 &:(> ?num-row2 ?num)))  )
;	;(not (k-per-col (col ?y) (num ?num-col &:(> ?num-col ?num)))  )
;	;(k-per-col (col ?y) (num ?num-col &:(> ?num-col 0)))
;	(moves (fires ?nf &:(> ?nf 0)))
;	(not (k-cell (x ?x) (y ?y)))
;	;(not (k-per-row (row ?x2) (num ?num-row2 &:(> ?num-row2 ?num))))
;	;(not (k-per-col (col ?y2) (num ?num-col &:(> ?num-col ?num))))
;=>
;	(printout t "FIRE ON [" ?x2 ", " ?y2 "] based on best K-ROW and K-COL" crlf)
;	(assert (exec (action fire) (x ?x2) (y ?y2)))
;)

; Non si sa più dove colpire
(defrule solve (declare (salience -300))
	(status (step ?s)(currently running))
	(moves (fires ?nf) (guesses ?ng) )
=>
	(assert (exec (step ?s) (action solve)))
	(printout t crlf)
	(printout t "I don't know what to do anymore: let's solve." crlf)
	(printout t "Fires left: " ?nf " - Guesses left: " ?ng crlf)
	(printout t crlf)
	(pop-focus)
)