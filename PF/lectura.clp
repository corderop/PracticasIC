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
        (if (eq ?valor Porcentajes) then
            (bind ?v (read file))
            (bind ?v1 (read file))
            (assert (Porcentaje_Dificultad ?v1))
            (bind ?v (read file))
            (bind ?v1 (read file))
            (assert (Porcentaje_Orientacion ?v1))
            (bind ?v (read file))
            (bind ?v1 (read file))
            (assert (Porcentaje_Tipo ?v1))
            (bind ?v (read file))
            (bind ?v1 (read file))
            (assert (Porcentaje_Asignaturas ?v1))
            (bind ?v (read file))
            (bind ?v1 (read file))
            (assert (Porcentaje_Conceptos ?v1))
        )
        (if (eq ?valor Asignatura) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Asignatura ?v1 ?v2))
        )
        (assert (SeguirLeyendo))
    )
)

(defrule leer_asig
    ?a <- (Asignatura ?r ?na)
    =>
    (printout t ?na ": ")
    (assert (Asignatura ?r ?na (read)))
    (retract ?a)
)

(defrule closefile_read
    (declare (salience -5))
    ?f <- (leer)
    =>
    (close file)
    (retract ?f)
)
