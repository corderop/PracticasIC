; Alumno:   Pablo Cordero Romero
;           77035152X

; Propiedades a usar que emplearia el experto para realizar el consejo:
; 
; - (Dificultad 0|1|2|3|4|5), 0 sera cuando no le importe
; - (Orientacion T|P|ns), ns sera cuando no le importe
; - (Tipo S|H|ns), ns cuando no le importe
; - (Asignaturas Rama %)

; --------------------------------------------------------------
;   LECTURA DE LA BASE DE CONOCIMIENTO
; --------------------------------------------------------------
; Indica que se inicie la lectura
(deffacts Leer
    (leer))

; Abre el archivo 
(defrule openfile_read
    (declare (salience 1000))
    (leer)
    =>
    (open "/home/pcordero/Software/PracticasUGR/PracticasIC/PF/data/conocimiento.txt" file)
    (assert (SeguirLeyendo))
)

; Realiza la lectura de cada una de las lineas
(defrule readfile
    (declare (salience 1000))
    ?f <- (SeguirLeyendo)
    =>
    (bind ?valor (read file))
    (retract ?f)
    ; Realizado para detectar el final del archivo
    (if (neq ?valor EOF) then
        ; Si encuentra una linea comenzada por dificultad
        ; significará que esa linea contiene la dificultad
        ; de cada rama
        (if (eq ?valor Dificultad) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Dificultad ?v1 ?v2))
        )
        ; Si encuentra una linea comenzada por orientación
        ; significará que esa linea contiene la orientación
        ; de cada rama
        (if (eq ?valor Orientacion) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Orientacion ?v1 ?v2))
        )
        ; Si encuentra una linea comenzada por tipo
        ; significará que esa linea contiene la tipo
        ; de cada rama
        (if (eq ?valor Tipo) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Tipo ?v1 ?v2))
        )
        ; Aquí se obtendrá el porcentaje que se le dará a cada apartado
        ; según tenga más o menos importacia
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
        ; Se recoge la asociación de ramas con asignaturas
        (if (eq ?valor Asignatura) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Asignatura ?v1 ?v2))
        )
        ; Se recoge la asociación de ramas con conceptos
        (if (eq ?valor Concepto) then
            (bind ?v1 (read file))
            (bind ?v2 (read file))
            (assert (Concepto ?v1 ?v2))
        )
        (assert (SeguirLeyendo))
    )
)

(defrule closefile_read
    (declare (salience 995))
    ?f <- (leer)
    =>
    (close file)
    (retract ?f)
)

; --------------------------------------------------------------
;   PREGUNTAS
; --------------------------------------------------------------

; Indica que se inicie la obtencion de informacion
(deffacts Inicio
    (inicio))

; Pregunta y chequea por la primera caracteristica (Dificultad)
(defrule introduce_dificultad
    ?i<-(inicio)
    =>
    (printout t "Del 1 al 5, introduce la dificultad que estas dispuesto a asumir" crlf "Si no te importa la dificultad, introduce un 0: ")
    (assert (Dificultad (read)))
    (retract ?i)
)

; Comprueba que la dificultad introducida sea correcta
(defrule check_dificultad
    ?d <- (Dificultad ?i)
    (test (and (or (< ?i 1) (> ?i 5) ) (neq ?i 0)))
    =>
    (printout t "La dificultad introducida no esta en el rango correcto (1...5 o 0)" crlf)
    (retract ?d)
    (assert (Dificultad (read)))
)
; ---------------------

; Pregunta al usuario si se prefiere una orientacion mas teorica o practica de la materia
(defrule introduce_orientacion
    ; Ha introducido el punto previo
    (Dificultad ?i)
    (test (or (and (>= ?i 1) (<= ?i 5) ) (eq ?i 0)))
    =>
    (printout t crlf "En la mayoria de asignaturas hay una parte teorica y otra practica." crlf "Algunos alumnos prefieren estudiar mas contenidos teoricos y algunos otros contenidos mas practicos." crlf "Introduce 'T' para teoria o 'P' para practicas segun tu preferencia." crlf "Si no es algo que te importe, introduce 'ns': ")
    (assert (Orientacion (read)))
)

; Comprueba que la orientacion introducida es correcta
(defrule check_orientacion
    ; Ha introducido el punto previo
    ?d <- (Orientacion ?i)
    (test (not (or (eq ?i T) (eq ?i P) (eq ?i ns) )))
    =>
    (printout t crlf "Solo puedes introducir como opciones 'T' para teoria o 'P' para practicas." crlf "Si te da igual introduce ns: ")
    (retract ?d)
    (assert (Orientacion (read)))
)

; ---------------------

; Pregunta si prefiere lo relacionado con software o hardware
(defrule introduce_tipo
    ; Ha introducido el punto previo
    (Orientacion ?i)
    (test (or (eq ?i T) (eq ?i P) (eq ?i ns) ))
    =>
    (printout t crlf "Aunque algunas de las ramas estudien ambos campos complementados, es facil diferencias algunas asignaturas" crlf "segun si estan mas orientadas al software o al hardware" crlf "Introduce 'H' si te gusta mas estudiar sobre hardware y 'S' si prefieres hacerlo sobre software." crlf "Si no es algo que te importe, introduce 'ns': ")
    (assert (Tipo (read)))
)

; Comprueba que el tipo introducido sea correcto
(defrule check_tipo
    ; Ha introducido el punto previo
    ?d <- (Tipo ?i)
    (test (not (or (eq ?i S) (eq ?i H) (eq ?i ns) )))
    =>
    (printout t crlf "Solo puedes introducir como opciones 'S' para software o 'H' para hardware." crlf "Si te da igual introduce ns: ")
    (retract ?d)
    (assert (Tipo (read)))
)

; ---------------------
; Ahora le presento las asignaturas que ya ha cursado el estudiante.
; Cada asignatura normalmente esta orientada o es mas parecida a las de 
; una rama u otra.
; 
(defrule previo_asignaturas
    ; Ha introducido el punto previo
    (Tipo ?i)
    (test (or (eq ?i S) (eq ?i H) (eq ?i ns) ))
    =>
    (printout t crlf "Ahora te voy a presentar una serie de asignaturas. Te voy a pedir que las puntues de 0 al 100 segun" crlf "te hayan gustado" crlf "Si no quieres realizar este test introduce 'no'." crlf "Si quieres realizarlo introduce 'si' o cualquier otra cosa: ")
    (assert (comienzo_asignaturas (read))) 
    (assert (conceptos))
)

; Lee 1 por 1 el valor de la asignatura
(defrule leer_asig
    (declare (salience 9))
    ?a <- (Asignatura ?r ?na)
    (comienzo_asignaturas ?i)
    (test (neq ?i no))
    =>
    (printout t ?na ": ")
    (assert (Asignatura ?r ?na (read)))
    (retract ?a)
)


; Chequea si el valor de alguna asignatura no se ha introducido de forma valida
(defrule chequea_asig_mal
    (declare (salience 10))
    ?d <- (Asignatura ?r ?a ?b)
    (test (not (and (>= ?b 0) (<= ?b 100))))
    =>
    (printout t "Has introducido mal el valor de :" ?a ". Introducelo de nuevo: ")
    (retract ?d)
    (assert (Asignatura ?r ?a (read)))
)

; ---------------------
; Por ultimo le presento una serie de conceptos relacionados con las diferentes ramas
; El usuarios los puntuara 
; 

(defrule previo_conceptos
    ; Ha introducido el punto previo
    ?c <- (conceptos)
    =>
    (printout t crlf "Por ultimo te voy a presentar una serie de conceptos relacionados con las ramas." crlf " Te voy a pedir que las puntues de 0 al 100 segun tu preferencia" crlf "Si no quieres realizar este test introduce 'no'." crlf "Si quieres realizarlo introduce 'si' o cualquier otra cosa: ")
    (assert (comienzo_conceptos (read))) 
    (retract ?c)
)

; Lee 1 por 1 el valor de los conceptos
(defrule leer_concepto
    (declare (salience 9))
    ?a <- (Concepto ?r ?nc)
    (comienzo_conceptos ?i)
    (test (neq ?i no))
    =>
    (printout t ?nc ": ")
    (assert (Concepto ?r ?nc (read)))
    (retract ?a)
)

(defrule chequea_conceptos_mal
    (declare (salience 10))
    ?d <- (Concepto ?r ?a ?b)
    (test (not (and (>= ?b 0) (<= ?b 100))))
    =>
    (printout t "Has introducido mal el valor de :" ?a ". Introducelo de nuevo: ")
    (retract ?d)
    (assert (Concepto ?r ?a (read)))
)

; --------------------------------------------------------------
;   RAZONAMIENTO
; --------------------------------------------------------------
; El razonamiento segun las caracteristicas vendra por una puntuacion 
; de semejanza con cada rama segun los valores de la base de conocimiento

; Segun lo escogido calculo los porcentajes de similitud, teniendo en cuenta
; Una cosas mas que otras.
; El reparto de porcentajes segun la importancia sera el siguiente:
; Dificultad    - 5%
; Orientacion   - 10%
; Tipo          - 10%
; Asignaturas   - 60%
; Conceptos     - 15%
; El porcentaje de preferencia a cada rama se va a almacenar en vectores con la forma
; (Rama Siglas_de_la_rama %)
(deffacts PuntuacionRamas
    (Rama Computacion_y_Sistemas_Inteligentes CSI 0)
    (Rama Ingenieria_del_Software IS 0)
    (Rama Ingenieria_de_Computadores IC 0)
    (Rama Sistemas_de_Informacion SI 0)
    (Rama Tecnologias_de_la_Informacion TI 0)
)

; Calcula el porcentaje de la dificultad
(defrule porcentaje_dificultad
    (not (dificultad_check))
    (Dificultad ?i)
    (Dificultad CSI ?a)
    (Dificultad IS ?b)
    (Dificultad IC ?c)
    (Dificultad SI ?d)
    (Dificultad TI ?e)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    ; Si el usuario asume mas dificultad que la de la rama -> 5%
    ; Si asume menos sera el porcentaje segun la cercania a la dificultad mediante la formula 5*(1 - (dificultad_rama-dificultad_asumida)/4)
    (if(neq ?i 0)
        then
        (if(<= ?a ?i)
            then
                (bind ?csi (+ ?csi 5) )
            else
                (bind ?csi (+ ?csi (* 5 (- 1 (/ (- ?a ?i) 4)))))
        )
        (if(<= ?b ?i)
            then
                (bind ?is (+ ?is 5) )
            else
                (bind ?is (+ ?is (* 5 (- 1 (/ (- ?b ?i) 4)))))
        )
        (if(<= ?c ?i)
            then
                (bind ?ic (+ ?ic 5) )
            else
                (bind ?ic (+ ?ic (* 5 (- 1 (/ (- ?c ?i) 4)))))
        )
        (if(<= ?d ?i)
            then
                (bind ?si (+ ?si 5) )
            else
                (bind ?si (+ ?si (* 5 (- 1 (/ (- ?d ?i) 4)))))
        )
        (if(<= ?e ?i)
            then
                (bind ?ti (+ ?ti 5) )
            else
                (bind ?ti (+ ?ti (* 5 (- 1 (/ (- ?e ?i) 4)))))
        )
    else
        (bind ?csi (+ ?csi 5))
        (bind ?is (+ ?is 5))
        (bind ?ic (+ ?ic 5))
        (bind ?si (+ ?si 5))
        (bind ?ti (+ ?ti 5))
    )
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (dificultad_check))
)

; Si la orientacion del usuario es la misma que la de la rama 10%
; Si no 0%
(defrule porcentaje_orientacion
    (not (orientacion_check))
    (Orientacion ?i)
    (Orientacion CSI ?a)
    (Orientacion IS ?b) 
    (Orientacion IC ?c) 
    (Orientacion SI ?d) 
    (Orientacion TI ?e)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (if(neq ?i ns)
        then
        (if(eq ?a ?i)
            then
                (bind ?csi (+ ?csi 10) )
        )
        (if(eq ?b ?i)
            then
                (bind ?is (+ ?is 10) )
        )
        (if(eq ?c ?i)
            then
                (bind ?ic (+ ?ic 10) )
        )
        (if(eq ?d ?i)
            then
                (bind ?si (+ ?si 10) )
        )
        (if(eq ?e ?i)
            then
                (bind ?ti (+ ?ti 10) )
        )
    else
        (bind ?csi (+ ?csi 10))
        (bind ?is (+ ?is 10))
        (bind ?ic (+ ?ic 10))
        (bind ?si (+ ?si 10))
        (bind ?ti (+ ?ti 10))
    )
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (orientacion_check))
)

; Si el tipo del usuario es el mismo que la de la rama 10%
; Si no 0%
(defrule porcentaje_tipo
    (not (tipo_check))
    (Tipo ?i)
    (Tipo CSI ?a)
    (Tipo IS ?b) 
    (Tipo IC ?c)
    (Tipo SI ?d)
    (Tipo TI ?e)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (if(neq ?i ns)
        then
        (if(eq ?a ?i)
            then
                (bind ?csi (+ ?csi 10) )
        )
        (if(eq ?b ?i)
            then
                (bind ?is (+ ?is 10) )
        )
        (if(eq ?c ?i)
            then
                (bind ?ic (+ ?ic 10) )
        )
        (if(eq ?d ?i)
            then
                (bind ?si (+ ?si 10) )
        )
        (if(eq ?e ?i)
            then
                (bind ?ti (+ ?ti 10) )
        )
    else
        (bind ?csi (+ ?csi 10))
        (bind ?is (+ ?is 10))
        (bind ?ic (+ ?ic 10))
        (bind ?si (+ ?si 10))
        (bind ?ti (+ ?ti 10))
    )
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (tipo_check))
)

(deffacts por_asig
    (Asignaturas CSI 0)
    (Asignaturas IS 0)
    (Asignaturas IC 0)
    (Asignaturas SI 0)
    (Asignaturas TI 0)
)

; Calcula los porcentajes de las asignatura segun la media de asignaturas parecedas por las que se le ha preguntado
(defrule porcentaje_asignaturas_IS
    (declare (salience 1))
    ?f <- (Asignatura IS ?asig ?i)
    ?f2 <- (Asignaturas IS ?p)
    =>
    (bind ?p (+ ?p (/ ?i 4)))
    (retract ?f2)
    (assert (Asignaturas IS ?p))
    (retract ?f)
)

(defrule porcentaje_asignaturas_CSI
    (declare (salience 1))
    ?f <- (Asignatura CSI ?asig ?i)
    ?f2 <- (Asignaturas CSI ?p)
    =>
    (bind ?p (+ ?p (/ ?i 4)))
    (retract ?f2)
    (assert (Asignaturas CSI ?p))
    (retract ?f)
)

(defrule porcentaje_asignaturas_IC
    (declare (salience 1))
    ?f <- (Asignatura IC ?asig ?i)
    ?f2 <- (Asignaturas IC ?p)
    =>
    (bind ?p (+ ?p (/ ?i 4)))
    (retract ?f2)
    (assert (Asignaturas IC ?p))
    (retract ?f)
)

(defrule porcentaje_asignaturas_TI
    (declare (salience 1))
    ?f <- (Asignatura TI ?asig ?i)
    ?f2 <- (Asignaturas TI ?p)
    =>
    (bind ?p (+ ?p ?i))
    (retract ?f2)
    (assert (Asignaturas TI ?p))
    (retract ?f)
)

(defrule porcentaje_asignaturas_SI
    (declare (salience 1))
    ?f <- (Asignatura SI ?asig ?i)
    ?f2 <- (Asignaturas SI ?p)
    =>
    (bind ?p (+ ?p (/ ?i 2)))
    (retract ?f2)
    (assert (Asignaturas SI ?p))
    (retract ?f)
)

; Añade al total el porcentaje de la asignaturas
(defrule aniado_por_asig
    (declare (salience -1))
    (not (asignaturas_check))
    (comienzo_asignaturas ?a)
    (test (neq ?a no))
    (Asignaturas CSI ?csi1)
    (Asignaturas IS ?is1)
    (Asignaturas IC ?ic1)
    (Asignaturas SI ?si1)
    (Asignaturas TI ?ti1)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (bind ?csi (+ ?csi (* ?csi1 0.6)))
    (bind ?is (+ ?is (* ?is1 0.6)))
    (bind ?ic (+ ?ic (* ?ic1 0.6)))
    (bind ?si (+ ?si (* ?si1 0.6)))
    (bind ?ti (+ ?ti (* ?ti1 0.6)))
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (asignaturas_check))
)

; Añade al global segun lo seleccionado en los conceptos
(defrule aniado_por_concepto
    (not (concepto_check))
    (Concepto CSI Problemas ?csi1)
    (Concepto IS Programacion ?is1)
    (Concepto IC Cloud ?ic1)
    (Concepto SI Informacion ?si1)
    (Concepto TI Redes ?ti1)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (bind ?csi (+ ?csi (* ?csi1 0.15)))
    (bind ?is (+ ?is (* ?is1 0.15)))
    (bind ?ic (+ ?ic (* ?ic1 0.15)))
    (bind ?si (+ ?si (* ?si1 0.15)))
    (bind ?ti (+ ?ti (* ?ti1 0.15)))
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (concepto_check))
)

; En funcion de los calculo toma la decision de una rama
(defrule coger_mayor
    (declare (salience -50))
    ?f1 <- (Rama ?R1 ?r1 ?v1)
    ?f2 <- (Rama ?R2 ?r2 ?v2)
    ?f3 <- (Rama ?R3 ?r3 ?v3)
    ?f4 <- (Rama ?R4 ?r4 ?v4)
    ?f5 <- (Rama ?R5 ?r5 ?v5)
    (test (and (neq ?r1 ?r2) (neq ?r1 ?r3) (neq ?r1 ?r4) (neq ?r1 ?r5)))
    (test (and (neq ?r2 ?r1) (neq ?r2 ?r3) (neq ?r2 ?r4) (neq ?r2 ?r5)))
    (test (and (neq ?r3 ?r1) (neq ?r3 ?r2) (neq ?r3 ?r4) (neq ?r3 ?r5)))
    (test (and (neq ?r4 ?r1) (neq ?r4 ?r2) (neq ?r4 ?r3) (neq ?r4 ?r5)))
    (test (and (neq ?r5 ?r1) (neq ?r5 ?r2) (neq ?r5 ?r3) (neq ?r5 ?r4)))
    =>
    (if (and (> ?v1 ?v2) (> ?v1 ?v3) (> ?v1 ?v4) (> ?v1 ?v5)) then
        (assert (Rama_mayor ?r1))
        (assert (Rama_consejo ?R1))
    else
        (if (and (> ?v2 ?v1) (> ?v2 ?v3) (> ?v2 ?v4) (> ?v2 ?v5)) then
            (assert (Rama_mayor ?r2))
            (assert (Rama_consejo ?R2))
        else
            (if (and (> ?v3 ?v1) (> ?v3 ?v2) (> ?v3 ?v4) (> ?v3 ?v5)) then
                (assert (Rama_mayor ?r3))
                (assert (Rama_consejo ?R3))
            else
                (if (and (> ?v4 ?v1) (> ?v4 ?v2) (> ?v4 ?v3) (> ?v4 ?v5)) then
                    (assert (Rama_mayor ?r4))
                    (assert (Rama_consejo ?R4))
                else
                    (if (and (> ?v5 ?v1) (> ?v5 ?v2) (> ?v5 ?v3) (> ?v5 ?v4)) then
                        (assert (Rama_mayor ?r5))
                        (assert (Rama_consejo ?R5))
                    else
                        (assert (Consejo "" "No me has aportado suficiente informacion como para decantarme por una." "Pablo Cordero"))
    )))))
    (assert (Razonamiento ""))
    (retract ?f1 ?f2 ?f3 ?f4 ?f5)
)

; Produce el consejo segun la dificultad elegida por el usuario
(defrule consejo_dificultad
    (declare (salience -51))
    ; Si se ha tomado nota de la dificultad
    (dificultad_check)
    (Rama_mayor ?R)
    (Dificultad ?R ?dr)
    ?a <- (Dificultad ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(or (= ?d 0) (>= ?d ?dr) ) then
        (bind ?texto (str-cat ?texto "La dificultad para ti es correcta. ") )
    else
        (bind ?texto (str-cat ?texto "Requerira un poco mas de dificultad en ti. "))
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Produce el consejo segun la orientacion elegida por el usuario
(defrule consejo_orientacion
    (declare (salience -52))
    ; Si se ha tomado nota de ka orientacion
    (orientacion_check)
    (Rama_mayor ?R)
    (Orientacion ?R ?dr)
    ?a <- (Orientacion ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(eq ?d ?dr) then
        (if (eq ?dr T) then
            (bind ?texto (str-cat ?texto "La orientacion es mas teorica. "))
        else
            (bind ?texto (str-cat ?texto "La orientacion es mas practica. "))
        )
    else
        (if (eq ?dr T) then
            (bind ?texto (str-cat ?texto "Tendra un contenido mas teorico pero facilmente sobrellevable segun tus gustos. "))
        else
            (bind ?texto (str-cat ?texto "Tendra un contenido mas practico pero facilmente sobrellevable segun tus gustos. "))
        )
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Produce el consejo segun el tipo elegido por el usuario
(defrule consejo_tipo
    (declare (salience -53))
    ; Si se ha tomado nota del tipo
    (tipo_check)
    (Rama_mayor ?R)
    (Tipo ?R ?dr)
    ?a <- (Tipo ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(eq ?d ?dr) then
        (if (eq ?dr S) then 
            (bind ?texto (str-cat ?texto "Tratara mas el software como es de tu preferencia. "))
        else
            (bind ?texto (str-cat ?texto "Tratara mas el hardware como es de tu preferencia. "))
        )
    else
        (if (eq ?dr S) then
            (bind ?texto (str-cat ?texto "Tratara mas el software pero seguramente de una forma diferente a la que piensas."))
        else
            (bind ?texto (str-cat ?texto "Tratara mas el hard pero seguramente de una forma diferente a la que piensas."))
        )
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Produce el consejo segun las asignaturas elegidas por el usuario
(defrule consejo_asignaturas
    (declare (salience -54))
    ; Si se ha tomado nota de la asignaturas
    (asignaturas_check)
    (Rama_mayor ?R)
    ?a <- (Asignaturas ?R ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(> ?d 60) then
        (bind ?texto (str-cat ?texto "Asignaturas que te han gustado me hacen decantarme por esta eleccion."))
    else
        (bind ?texto (str-cat ?texto "Algunas asignaturas similares no han sido de preferencia, pero algunas otras si"))
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

(defrule consejo_conceptos
    (declare (salience -55))
    ; Si se ha tomado nota de los conceptos
    (concepto_check)
    (Rama_mayor ?R)
    ?a <- (Concepto ?R ?nombre ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(> ?d 60) then
        (if(eq ?nombre Redes) then
            (bind ?texto (str-cat ?texto "Las redes es algo interesante para ti y esta relacionado con esta rama."))
        )
        (if(eq ?nombre Programacion) then
            (bind ?texto (str-cat ?texto "La programacion es algo interesante para ti y esta relacionado con esta rama."))
        )
        (if(eq ?nombre Informacion) then
            (bind ?texto (str-cat ?texto "La gestion de la informacion es algo interesante para ti y esta relacionado con esta rama."))
        )
        (if(eq ?nombre Problemas) then
            (bind ?texto (str-cat ?texto "La solucion de problemas es algo interesante para ti y esta relacionado con esta rama."))
        )
        (if(eq ?nombre Cloud) then
            (bind ?texto (str-cat ?texto "El Cloud Computing es algo interesante para ti y esta relacionado con esta rama."))
        )
    else
        (if(eq ?nombre Redes) then
            (bind ?texto (str-cat ?texto "Las redes no es una de tus preferencias, pero aun asi esta rama abarcara mas cosas"))
        )
        (if(eq ?nombre Programacion) then
            (bind ?texto (str-cat ?texto "La programacion no es una de tus preferencias, pero aun asi esta rama abarcara mas cosas"))
        )
        (if(eq ?nombre Informacion) then
            (bind ?texto (str-cat ?texto "La gestion de informacion no es una de tus preferencias, pero aun asi esta rama abarcara mas cosas"))
        )
        (if(eq ?nombre Problemas) then
            (bind ?texto (str-cat ?texto "La resolucion de problemas no es una de tus preferencias, pero aun asi esta rama abarcara mas cosas"))
        )
        (if(eq ?nombre Cloud) then
            (bind ?texto (str-cat ?texto "El Cloud Computacion no es una de tus preferencias, pero aun asi esta rama abarcara mas cosas"))
        )
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Recopilados todos los consejos lo pone en un vector para imprimirlo añadiendo la rama y el experto
(defrule hacer_consejo
    (declare (salience -56))
    ?b <- (Rama_consejo ?R)
    ?a <- (Razonamiento ?texto)
    =>
    (assert (Consejo ?R ?texto "Pablo Cordero Romero"))
    (retract ?a ?b)
)

; Cuando se obtienen un consejo se imprime con el lenguaje apropiadoS
(defrule imprimir_consejo
    ?f <- (Consejo ?rama ?texto ?apodo)
    =>
    (retract ?f)
    (printout t crlf crlf "El experto " ?apodo " te aconseja escoger la rama:" crlf ?rama crlf "Ha sido por el siguiente motivo: " crlf ?texto crlf crlf)
)
