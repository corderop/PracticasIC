;;; lectura
(deffacts datos
    (leer)
)

(defrule openfile_read
    (leer)
    =>
    (open "/home/pcordero/Software/PracticasUGR/PracticasIC/PF/data/conocimiento.txt" file)
    (assert (SeguirLeyendo))
)

(defrule readfile
    ?f <- (SeguirLeyendo)
    =>
    (bind ?valor (read file))
    (retract ?f)
    (if (neq ?valor EOF) then
        (if (eq ?valor Dificultad) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Dificultad ?v1 ?v2))
        )
        (if (eq ?valor Orientacion) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Orientacion ?v1 ?v2))
        )
        (if (eq ?valor Tipo) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Tipo ?v1 ?v2))
        )
        (assert (SeguirLeyendo))
    )
)

(defrule closefile_read
    (declare (salience -5))
    ?f <- (leer)
    =>
    (close file)
    (retract ?f)
)
