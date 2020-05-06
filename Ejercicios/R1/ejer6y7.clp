; Pablo Cordero Romero

; Ejercicio 6 y 7

(deftemplate Jugadores
    (slot Nombre)
    (slot Altura)
)

(deffacts intro_jugadores
    (Jugadores 
        (Nombre Manolo)
        (Altura 190))
    (Jugadores 
        (Nombre Juan)
        (Altura 170))
    (Jugadores 
        (Nombre Maria)
        (Altura 180))
    (Jugadores 
        (Nombre Paco)
        (Altura 160))
)

(defrule coger_mayor
    (Jugadores (Nombre ?n) (Altura ?a))
    (not (Jugadores (Altura ?a2&:(> ?a2 ?a))))
    =>
    (printout t "El Jugador mas alto es " ?n)
    (printout t " con una altura de " ?a crlf)
)