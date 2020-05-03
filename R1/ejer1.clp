; Pablo Cordero Romero

; Ejercicio 1

(defrule seleccion
=>
    (printout t "Elije entre las siguientes opciones: A, B, C o D: ")
    (assert (OpcionElegida (read)))
)

(defrule seleccion_mal
    ?f <- (OpcionElegida ?i)
    (not (test (or (or (eq ?i A) (eq ?i B)) (or (eq ?i C) (eq ?i D)) )))
=>
    (retract ?f)
    (printout t "No has introducido una opción correcta." crlf)
    (printout t "Elije entre las siguientes opciones: A, B, C o D: ")
    (assert (OpcionElegida (read)))
)