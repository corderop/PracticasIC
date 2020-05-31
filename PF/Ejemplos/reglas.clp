(deffacts VariosHechosVectores
    (Persona Pedro 45 V SI)
    (Persona Maria 34 M NO)
    (Persona Paquillo 65 M NO)
)

(defrule ECivilPedro_Soltero
    (Persona Pedro 45 V NO)
    =>
    (printout t crlf "Pedro está soltero")
)

(defrule ECivilPedro_Casado
    (Persona Pedro 45 V SI)
    =>
    (printout t crlf "Pedro está casado")
)

(defrule ECivilMaria_Soltera
    (Persona Maria 34 M NO)
    =>
    (printout t crlf "Maria está soltera")
)

(defrule ImprimeSolteros
    (Persona ?Nombre ? ? NO)
    =>
    (printout t crlf ?Nombre "está soltero")
)