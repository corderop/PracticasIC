(deffacts datos
    (escribir)
    (WRITE sdfa ffgsd wertn gd uytu ikj 123 rtw)
)

; Toma el primero si n>1
(defrule write
    (declare (salience 5))
    ?f <- (escribir)
    (WRITE ?i ? $?)
    =>
    (open "/home/pcordero/Software/PracticasUGR/PracticasIC/R1/datos.txt" file "w")
    (retract ?f)
    (printout file ?i " ")
)

; Toma el primero si n=1
(defrule write_1
    (declare (salience 5))
    ?f <- (escribir)
    (WRITE ?i)
    =>
    (open "/home/pcordero/Software/PracticasUGR/PracticasIC/R1/datos.txt" file "w")
    (retract ?f)
    (printout file ?i " ")
    (close file)
)

; Tomo los valores intermedios
(defrule write_2
    (declare (salience 0))
    (WRITE ? $? ?i $? ?)
    =>
    (printout file ?i " ")
)

; Solo se lanza cuando n>1
; Tomo el último valor y cierro la lectura del archivo
(defrule write_final
    (declare (salience -5))
    (WRITE ? $? ?i)
    =>
    (printout file ?i)
    (close file)
)
