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
            (bind ?v3 (read file))
            (assert (Tipo ?v1 ?v2 ?v3))
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
    ; (declare (salience 995))
    ?f <- (leer)
    =>
    (close file)
    (retract ?f)
    (assert (preguntar_modulo))
)

; --------------------------------------------------------------
;   PREGUNTAS
; --------------------------------------------------------------

; Pregunta por qué asesoramiento se quiere
(defrule pregunta_modulo
    (declare (salience 960))
    ?m <- (preguntar_modulo)
    (not (modulo ramas))
    (not (modulo asignaturas))
    =>
    (retract ?m)
    (printout t crlf "¿Qué quieres que te recomiende?" crlf "A) Que rama coger" crlf "B) Que asignaturas coger" crlf "Elige A o B: ")
    (assert (eleccion_modulo (read)))
)

; Módulo mal elegido
(defrule mal_eleccion_modulo
    (declare (salience 950))
    ?m <- (eleccion_modulo ?i)
    (test (and (neq ?i A) (neq ?i B) ))
    =>
    (printout t crlf "Modulo mal introducido. Introduce uno válido: ")
    (assert (eleccion_modulo (read)))
)

; Lo crea según lo elegido
(defrule creacion_modulo
    (declare (salience 940))
    ?m <- (eleccion_modulo ?i)
    =>
    (retract ?m)
    (if ( eq ?i A)
        then
            (assert (modulo ramas))
        else
            (assert (modulo asignaturas))
            (assert (preguntar_curso))
            (assert (preguntar_creditos))
    )
    (assert (preguntar_dificultad))
)

(defrule pregunta_creditos
    (declare (salience 930))
    ?m <- (preguntar_creditos)
    (not (Creditos ?))
    =>
    (retract ?m)
    (printout t crlf "¿Cuantos creditos quieres cursar?: ")
    (assert (Creditos (read)))
)

(defrule mal_eleccion_creditos
    (declare (salience 920))
    ?m <- (Creditos ?i)
    (test (or (< ?i 0) (> ?i 60)))
    =>
    (printout t crlf "Los créditos deben estar entre 0 y 60. Introducelos de nuevo: ")
    (assert (Creditos (read)))
)

(defrule pregunta_curso
    (declare (salience 930))
    ?m <- (preguntar_curso)
    (not (curso ?))
    =>
    (retract ?m)
    (printout t crlf "¿De qué curso quieres las asignaturas?" crlf "3) Tercero" crlf "4) Cuarto" crlf "0) Ambos" crlf "Introduce 3, 4 o 0: ")
    (assert (eleccion_curso (read)))
)

(defrule mal_eleccion_curso
    (declare (salience 920))
    ?m <- (eleccion_curso ?i)
    (test (and (neq ?i 3) (neq ?i 4) (neq ?i 0) ))
    =>
    (printout t crlf "Curso mal introducido. Introduce uno válido: ")
    (assert (eleccion_curso (read)))
)

; -------------------------------------------------------------
; PREGUNTAS
; -------------------------------------------------------------

; Pregunta y chequea por la primera caracteristica (Dificultad)
(defrule introduce_dificultad
    (declare (salience 890))
    ; ?i<-(inicio)
    ?m <- (preguntar_dificultad)
    (not (Dificultad ?))
    =>
    (printout t "Del 1 al 5, introduce la dificultad que estas dispuesto a asumir" crlf "Si no te importa la dificultad, introduce un 0: ")
    (assert (Dificultad (read)))
    (assert (preguntar_orientacion))
    (retract ?m)
)

; Comprueba que la dificultad introducida sea correcta
(defrule check_dificultad
    (declare (salience 890))
    ?d <- (Dificultad ?i)
    (test (and (or (< ?i 1) (> ?i 5) ) (neq ?i 0)))
    ; (not (Dificultad ?))
    =>
    (printout t "La dificultad introducida no esta en el rango correcto (1...5 o 0)" crlf)
    (retract ?d)
    (assert (Dificultad (read)))
)
; ---------------------

; Pregunta al usuario si se prefiere una orientacion mas teorica o practica de la materia
(defrule introduce_orientacion
    (declare (salience 880))
    ; Ha introducido el punto previo
    ?m <- (preguntar_orientacion)
    (not (Orientacion ?))
    =>
    (printout t crlf "En la mayoria de asignaturas hay una parte teorica y otra practica." crlf "Algunos alumnos prefieren estudiar mas contenidos teoricos y algunos otros contenidos mas practicos." crlf "Introduce 'T' para teoria o 'P' para practicas segun tu preferencia." crlf "Si no es algo que te importe, introduce 'ns': ")
    (assert (Orientacion (read)))
    (retract ?m)
    (assert (preguntar_tipo))
)

; Comprueba que la orientacion introducida es correcta
(defrule check_orientacion
    (declare (salience 880))
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
    (declare (salience 870))
    ?m <- (preguntar_tipo)
    (not (Tipo ?))
    =>
    (printout t crlf "Aunque algunas de las ramas estudien ambos campos complementados, es facil diferencias algunas asignaturas" crlf "segun si estan mas orientadas al software o al hardware" crlf "Introduce 'H' si te gusta mas estudiar sobre hardware y 'S' si prefieres hacerlo sobre software." crlf "Si no es algo que te importe, introduce 'ns': ")
    (assert (Tipo (read)))
    (retract ?m)
)

; Comprueba que el tipo introducido sea correcto
(defrule check_tipo
    (declare (salience 870))
    ; Ha introducido el punto previo
    ?d <- (Tipo ?i)
    (test (not (or (eq ?i S) (eq ?i H) (eq ?i ns) )))
    =>
    (printout t crlf "Solo puedes introducir como opciones 'S' para software o 'H' para hardware." crlf "Si te da igual introduce ns: ")
    (retract ?d)
    (assert (Tipo (read)))
)

(defrule introduce_tipo_de_software
    (declare (salience 869))
    ?m <- (Tipo S)
    =>
    (printout t crlf "Dentro de las asignaturas de software existen dos ramas: " crlf "D) Desarrollo de software" crlf "A) Desarrollo de algoritmos para resolución de problemas" crlf "Introduce 'D' o 'S' según prefieras." crlf "Si no es algo que te importe, introduce 'ns': "  )
    (assert (Tipo S (read)))
    (retract ?m)
    (assert (preguntar_asignaturas))
)

(defrule check_tipo_de_software
    (declare (salience 869))
    (Tipo S ?a)
    (test (and (neq ?a D) (neq ?a A) (neq ?a ns)))
    =>
    (printout t crlf "Tipo de software mal introducido, introduzcalo de nuevo: ")
    (assert (Tipo S (read)))
)

(defrule introduce_tipo_de_hardware
    (declare (salience 869))
    ?m <- (Tipo H)
    =>
    (printout t crlf "Dentro de las asignaturas de hardware existen dos ramas: " crlf "E) Electronica" crlf "T) Telecomunicaciones" crlf "Introduce 'E' o 'T' según prefieras." crlf "Si no es algo que te importe, introduce 'ns': "  )
    (assert (Tipo H (read)))
    (retract ?m)
    (assert (preguntar_asignaturas))
)

(defrule check_tipo_de_hardware
    (declare (salience 869))
    (Tipo H ?a)
    (test (and (neq ?a T) (neq ?a E) (neq ?a ns)))
    =>
    (printout t crlf "Tipo de hardware mal introducido, introduzcalo de nuevo: ")
    (assert (Tipo H (read)))
)

; -----------------------------------------------------------
; SOLO MODULO RAMAS

; ---------------------
; Ahora le presento las asignaturas que ya ha cursado el estudiante.
; Cada asignatura normalmente esta orientada o es mas parecida a las de 
; una rama u otra.
; 
(defrule previo_asignaturas
    (declare (salience 850))
    (modulo ramas)
    ?m <- (preguntar_asignaturas)
    ; Ha introducido el punto previo
    ; (preguntar_asignaturas)
    =>
    (printout t crlf "Ahora te voy a presentar una serie de asignaturas. Te voy a pedir que las puntues de 0 al 100 segun" crlf "te hayan gustado" crlf "Si no quieres realizar este test introduce 'no'." crlf "Si quieres realizarlo introduce 'si' o cualquier otra cosa: ")
    (assert (comienzo_asignaturas (read)))
    (retract ?m)
    (assert (preguntar_conceptos))
)

; Lee 1 por 1 el valor de la asignatura
(defrule leer_asig
    (declare (salience 850))
    (modulo ramas)
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
    (declare (salience 851))
    (modulo ramas)
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
    (declare (salience 840))
    ?m <- (preguntar_conceptos)
    (modulo ramas)
    =>
    (printout t crlf "Por ultimo te voy a presentar una serie de conceptos relacionados con las ramas." crlf " Te voy a pedir que las puntues de 0 al 100 segun tu preferencia" crlf "Si no quieres realizar este test introduce 'no'." crlf "Si quieres realizarlo introduce 'si' o cualquier otra cosa: ")
    (assert (comienzo_conceptos (read))) 
    (retract ?m)
)

; Lee 1 por 1 el valor de los conceptos
(defrule leer_concepto
    (declare (salience 840))
    (modulo ramas)
    ?a <- (Concepto ?r ?nc)
    (comienzo_conceptos ?i)
    (test (neq ?i no))
    =>
    (printout t ?nc ": ")
    (assert (Concepto ?r ?nc (read)))
    (retract ?a)
)

(defrule chequea_conceptos_mal
    (declare (salience 841))
    (modulo ramas)
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

; ----------------------------------------
; Incentidumbre

(deffacts ince
    (modulo incertidumbre)
)

; Reglas seguras
; Las características de la asignatura son las mismas que le gustan
(defrule asume_orientacion
    (declare (salience 799))
    (modulo incertidumbre)
    ?a <- (asumir_orientacion)
    (Orientacion ?o)
    (test (neq ?o ns))
    =>
    (if (eq ?o P) 
        then
            (bind ?exp (str-cat "Te gustan las asignaturas mas practicas"))
        else
            (bind ?exp (str-cat "Te gustan las asignaturas mas teoricas"))
    )
    (assert (explicacion Orientacion ?exp))
    (retract ?a)
)

(defrule asume_tipo
    (declare (salience 799))
    ?a <- (asumir_tipo)
    (modulo incertidumbre)
    (Tipo ?o ?i)
    (test (neq ?o ns))
    (test (neq ?i ns))
    =>
    (if (eq ?o S) 
        then
            (if (eq ?i D) 
                then
                    (bind ?exp (str-cat "Te gustan las asignaturas mas orientadas al desarrollo de software"))
                else
                    (bind ?exp (str-cat "Te gustan las asignaturas mas orientadas al desarrollo de algoritmos"))
            )
        else
            (if (eq ?i T)
                then
                    (bind ?exp (str-cat "Te gustan las asignaturas mas orientadas a las redes y hardware de telecomunicaciones"))
                else
                    (bind ?exp (str-cat "Te gustan las asignaturas mas orientadas a electronica"))
            )
    )
    (assert (explicacion Tipo ?exp))
    (retract ?a)
)

; Reglas por defecto
(defrule orientacion_por_defecto
    (declare (salience 750))
    (modulo incertidumbre)
    ?a <- (asumir_orientacion)
    (Orientacion ?o)
    (test (eq ?o ns))
    =>
    (bind ?exp (str-cat "La mayoría de alumnos prefieren asignaturas prácticas."))
    (assert (explicacion Orientacion ?exp))
    (assert (Orientacion P))
    (retract ?a)
)

(defrule tipo_por_defecto
    (declare (salience 750))
    (modulo incertidumbre)
    ?a <- (asumir_tipo)
    (Tipo ?o)
    (test (eq ?o ns))
    =>
    (bind ?exp (str-cat "La mayoría de alumnos prefieren asignaturas relacionadas con el desarrollo de software."))
    (assert (explicacion Tipo ?exp))
    (assert (Tipo S D))
    (retract ?a)
)

(defrule tipo_de_software_por_defecto
    (declare (salience 750))
    (modulo incertidumbre)
    ?a <- (asumir_tipo)
    (Tipo S ?o)
    (test (eq ?o ns))
    =>
    (bind ?exp (str-cat "La mayoría de los alumnos a los que le gusta el software prefieren asignaturas relacionadas con el desarrollo de software."))
    (assert (explicacion Tipo ?exp))
    (assert (Tipo S D))
    (retract ?a)
)

(defrule tipo_de_hardware_por_defecto
    (declare (salience 750))
    (modulo incertidumbre)
    ?a <- (asumir_tipo)
    (Tipo H ?o)
    (test (eq ?o ns))
    =>
    (bind ?exp (str-cat "La mayoría de los alumnos a los que le gusta el hardware prefieren asignaturas relacionadas con la electronica"))
    (assert (explicacion Tipo ?exp))
    (assert (Tipo H E))
    (retract ?a)
)

; ----------------------------------------
; Solo cuando Ramas: 

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
    (modulo ramas)
    (Porcentaje_Dificultad ?per)
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
    ; Si el usuario asume mas dificultad que la de la rama -> suma todo el porcentaje
    ; Si asume menos sera el porcentaje segun la cercania a la dificultad mediante la formula porcentaje*(1 - (dificultad_rama-dificultad_asumida)/4)
    (if(neq ?i 0)
        then
        (if(<= ?a ?i)
            then
                (bind ?csi (+ ?csi ?per) )
            else
                (bind ?csi (+ ?csi (* ?per (- 1 (/ (- ?a ?i) 4)))))
        )
        (if(<= ?b ?i)
            then
                (bind ?is (+ ?is ?per) )
            else
                (bind ?is (+ ?is (* ?per (- 1 (/ (- ?b ?i) 4)))))
        )
        (if(<= ?c ?i)
            then
                (bind ?ic (+ ?ic ?per) )
            else
                (bind ?ic (+ ?ic (* ?per (- 1 (/ (- ?c ?i) 4)))))
        )
        (if(<= ?d ?i)
            then
                (bind ?si (+ ?si ?per) )
            else
                (bind ?si (+ ?si (* ?per (- 1 (/ (- ?d ?i) 4)))))
        )
        (if(<= ?e ?i)
            then
                (bind ?ti (+ ?ti ?per) )
            else
                (bind ?ti (+ ?ti (* ?per (- 1 (/ (- ?e ?i) 4)))))
        )
    else
        (bind ?csi (+ ?csi ?per))
        (bind ?is (+ ?is ?per))
        (bind ?ic (+ ?ic ?per))
        (bind ?si (+ ?si ?per))
        (bind ?ti (+ ?ti ?per))
    )
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (dificultad_check))
)

; Si la orientacion del usuario es la misma que la de la rama se suma el %
; Si no 0%
(defrule porcentaje_orientacion
    (modulo ramas)
    (not (orientacion_check))
    (Porcentaje_Orientacion ?per)
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
                (bind ?csi (+ ?csi ?per) )
        )
        (if(eq ?b ?i)
            then
                (bind ?is (+ ?is ?per) )
        )
        (if(eq ?c ?i)
            then
                (bind ?ic (+ ?ic ?per) )
        )
        (if(eq ?d ?i)
            then
                (bind ?si (+ ?si ?per) )
        )
        (if(eq ?e ?i)
            then
                (bind ?ti (+ ?ti ?per) )
        )
    else
        (bind ?csi (+ ?csi ?per))
        (bind ?is (+ ?is ?per))
        (bind ?ic (+ ?ic ?per))
        (bind ?si (+ ?si ?per))
        (bind ?ti (+ ?ti ?per))
    )
    (retract ?r1 ?r2 ?r3 ?r4 ?r5)
    (assert (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi))
    (assert (Rama Ingenieria_del_Software IS ?is))
    (assert (Rama Ingenieria_de_Computadores IC ?ic))
    (assert (Rama Sistemas_de_Informacion SI ?si))
    (assert (Rama Tecnologias_de_la_Informacion TI ?ti))
    (assert (orientacion_check))
)

; Si el tipo del usuario es el mismo que la de la rama se suma el %
; Si no 0%
(defrule porcentaje_tipo
    (modulo ramas)
    (not (tipo_check))
    (Porcentaje_Tipo ?per)
    (Tipo ?i1 ?i2)
    (Tipo CSI ?a1 ?a2)
    (Tipo IS ?b1 ?b2) 
    (Tipo IC ?c1 ?c2)
    (Tipo SI ?d1 ?d2)
    (Tipo TI ?e1 ?e2)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (if (and (eq ?a1 ?i1) (eq ?a2 ?i2))
        then
            (bind ?csi (+ ?csi ?per) )
    )
    (if (and (eq ?b1 ?i1) (eq ?b2 ?i2))
        then
            (bind ?is (+ ?is ?per) )
    )
    (if (and (eq ?c1 ?i1) (eq ?c2 ?i2))
        then
            (bind ?ic (+ ?ic ?per) )
    )
    (if (and (eq ?d1 ?i1) (eq ?d2 ?i2))
        then
            (bind ?si (+ ?si ?per) )
    )
    (if (and (eq ?e1 ?i1) (eq ?e2 ?i2))
        then
            (bind ?ti (+ ?ti ?per) )
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
    (modulo ramas)
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
    (modulo ramas)
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
    (modulo ramas)
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
    (modulo ramas)
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
    (modulo ramas)
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
    (modulo ramas)
    (not (asignaturas_check))
    (comienzo_asignaturas ?a)
    (Porcentaje_Asignaturas ?per)
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
    (bind ?csi (+ ?csi (* ?csi1 (/ ?per 100))))
    (bind ?is (+ ?is (* ?is1 (/ ?per 100))))
    (bind ?ic (+ ?ic (* ?ic1 (/ ?per 100))))
    (bind ?si (+ ?si (* ?si1 (/ ?per 100))))
    (bind ?ti (+ ?ti (* ?ti1 (/ ?per 100))))
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
    (modulo ramas)
    (Porcentaje_Conceptos ?per)
    (Concepto CSI Resolucion_de_problemas ?csi1)
    (Concepto IS Programacion ?is1)
    (Concepto IC Cloud_computing ?ic1)
    (Concepto SI Tratamiento_de_la_informacion ?si1)
    (Concepto TI Redes ?ti1)
    ?r1 <- (Rama Computacion_y_Sistemas_Inteligentes CSI ?csi)
    ?r2 <- (Rama Ingenieria_del_Software IS ?is)
    ?r3 <- (Rama Ingenieria_de_Computadores IC ?ic)
    ?r4 <- (Rama Sistemas_de_Informacion SI ?si)
    ?r5 <- (Rama Tecnologias_de_la_Informacion TI ?ti)
    =>
    (bind ?csi (+ ?csi (* ?csi1 (/ ?per 100))))
    (bind ?is (+ ?is (* ?is1 (/ ?per 100))))
    (bind ?ic (+ ?ic (* ?ic1 (/ ?per 100))))
    (bind ?si (+ ?si (* ?si1 (/ ?per 100))))
    (bind ?ti (+ ?ti (* ?ti1 (/ ?per 100))))
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
    (modulo ramas)
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
    (modulo ramas)
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
    (modulo ramas)
    ; Si se ha tomado nota de ka orientacion
    (orientacion_check)
    (explicacion Orientacion ?e)
    (Rama_mayor ?R)
    (Orientacion ?R ?dr)
    ?a <- (Orientacion ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(eq ?d ?dr) then
        (bind ?texto (str-cat ?texto ?e ". "))
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Produce el consejo segun el tipo elegido por el usuario
(defrule consejo_tipo
    (declare (salience -53))
    (modulo ramas)
    ; Si se ha tomado nota del tipo
    (tipo_check)
    (explicacion Tipo ?e)
    (Rama_mayor ?R)
    (Tipo ?R ?dr1 ?dr2)
    ?a <- (Tipo ?i1 ?i2)
    ?b <- (Razonamiento ?texto)
    =>
    (if (and (eq ?dr1 ?i1) (eq ?dr2 ?i2)) then
        (bind ?texto (str-cat ?texto ?e ". "))
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

; Produce el consejo segun las asignaturas elegidas por el usuario
(defrule consejo_asignaturas
    (declare (salience -54))
    (modulo ramas)
    ; Si se ha tomado nota de la asignaturas
    (asignaturas_check)
    (Rama_mayor ?R)
    ?a <- (Asignaturas ?R ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(> ?d 50) then
        (bind ?texto (str-cat ?texto "Asignaturas que te han gustado me hacen decantarme por esta eleccion."))
    else
        (bind ?texto (str-cat ?texto "Algunas asignaturas similares no han sido de preferencia, pero algunas otras si"))
    )
    (retract ?a ?b)
    (assert (Razonamiento ?texto))
)

(defrule consejo_conceptos
    (declare (salience -55))
    (modulo ramas)
    ; Si se ha tomado nota de los conceptos
    (concepto_check)
    (Rama_mayor ?R)
    ?a <- (Concepto ?R ?nombre ?d)
    ?b <- (Razonamiento ?texto)
    =>
    (if(> ?d 50) then
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
    (modulo ramas)
    ?b <- (Rama_consejo ?R)
    ?a <- (Razonamiento ?texto)
    =>
    (assert (Consejo ?R ?texto "Pablo Cordero Romero"))
    (retract ?a ?b)
)

; Cuando se obtienen un consejo se imprime con el lenguaje apropiadoS
(defrule imprimir_consejo
    (modulo ramas)
    ?f <- (Consejo ?rama ?texto ?apodo)
    =>
    (retract ?f)
    (printout t crlf crlf "El experto " ?apodo " te aconseja escoger la rama:" crlf ?rama crlf "Ha sido por el siguiente motivo: " crlf ?texto crlf crlf)
    (assert (asignaturas_posibles))
    (assert (recomendar_asignaturas))
)

; -----------------------------------------------------------
;   Razonamiento asignaturas (MODULO ASIGNATURAS)
; -----------------------------------------------------------

(deffacts incertidumbre
    ; Tercero
    (AS 3 Aprendizaje_automatico 5 T S A)
    (AS 3 Metaheuristicas 3 P S A)
    (AS 3 Modelos_Avanzados_de_Computacion 4 T S A)
    (AS 3 Tecnicas_de_sistemas_Inteligentes 3 P S A)
    (AS 3 Ingenieria_del_conocimiento 3 T S A)

    (AS 3 Desarrollo_de_sistemas_distribuidos 4 T S D)
    (AS 3 Desarrollo_de_software 4 P S D)
    (AS 3 Diseno_de_interfaces_de_usuario 2 T S D)
    (AS 3 Sistemas_de_informacion_basados_en_web 3 P S D)
    (AS 3 Sistemas_graficos 4 P S D)
    
    (AS 3 Arquitectura_de_Sistemas 4 T S D)
    (AS 3 Arquitectura_y_Computacion_de_altas_prestaciones 4 T H E)
    (AS 3 Desarrollo_de_hardware_digital 3 P H E)
    (AS 3 Diseno_de_sistemas_electronicos 3 P H E)
    (AS 3 Sistemas_con_microprocesadores 5 T H E)

    (AS 3 Computacion_ubicua_e_inteligencia_ambiental 3 T H T)
    (AS 3 Servidores_web_de_altas_prestaciones 3 P H T)
    (AS 3 Sistemas_multimedia 3 P S D)
    (AS 3 Tecnologias_web 2 P S D)
    (AS 3 Transmision_de_datos_y_redes_de_computadores 4 T H T)

    (AS 3 Administracion_de_bases_de_datos 4 T S D)
    (AS 3 Ingenieria_de_sistemas_de_informacion 4 T S D)
    (AS 3 Programacion_web 2 P S D)
    (AS 3 Sistemas_de_informacion_para_empresas 3 T S D)
    (AS 3 Sistemas_multidimensionales 4 T H T)

    ; Cuarto

    (AS 4 Nuevos_paradigmas_de_Interaccion 4 P S A)
    (AS 4 Procesadores_de_lenguajes 4 T S A)
    (AS 4 Vision_por_computador 5 T S A)
    
    (AS 4 Direccion_y_gestion_de_proyectos 3 P S D)
    (AS 4 Metodologias_de_desarrollo_agiles 3 P S D)
    (AS 4 Desarrollo_basado_en_agentes 4 P S A)

    (AS 4 Centro_de_procesamiento_de_datos 4 T H T)
    (AS 4 Sistemas_empotrados 3 P H E)
    (AS 4 Tecnologias_de_red 5 T H T)

    (AS 4 Desarrollo_de_aplicaciones_para_internet 4 P S D)
    (AS 4 Infraestructura_virtual 3 P S D)
    (AS 4 Seguridad_y_proteccion_de_sistemas_informaticos 5 P S A)

    (AS 4 Bases_de_datos_distribuidas 4 P S D)
    (AS 4 Inteligencia_de_negocio 3 P S A)
    (AS 4 Recuperacion_de_la_informacion 4 T H E)

    (asumir_orientacion)
    (asumir_tipo)
)

(defrule asume_asignatura
    (declare (salience 5))
    (modulo asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (or (<= ?d ?dc) (= ?d 0)))
    (test (eq ?o ?oc))
    (test (and (eq ?t1 ?tc1) (eq ?t2 ?tc2)))
    (explicacion Orientacion ?expO)
    (explicacion Tipo ?expT)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t "Estas dispuesto a asumir la dificultad" crlf )
    (printout t ?expO crlf)
    (printout t ?expT crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_con_diferente_orientacion
    (declare (salience 4))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (or (<= ?d ?dc) (= ?d 0)))
    (test (neq ?o ?oc))
    (test (and (eq ?t1 ?tc1) (eq ?t2 ?tc2)))
    (explicacion Tipo ?expT)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t "Estas dispuesto a asumir la dificultad" crlf )
    (printout t ?expT crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_con_diferente_tipo
    (declare (salience 4))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (or (<= ?d ?dc) (= ?d 0)))
    (test (eq ?o ?oc))
    (test (neq ?t2 ?tc2))
    (explicacion Orientacion ?expO)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t "Estas dispuesto a asumir la dificultad" crlf )
    (printout t ?expO crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_con_diferente_orientacion_y_tipo
    (declare (salience 3))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (or (<= ?d ?dc) (= ?d 0)))
    (test (neq ?o ?oc))
    (test (neq ?t2 ?tc2))
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ")crlf)
    (printout t "Estas dispuesto a asumir la dificultad" crlf )
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_mas_dificil
    (declare (salience 2))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (> ?d ?dc))
    (test (eq ?o ?oc))
    (test (and (eq ?t1 ?tc1) (eq ?t2 ?tc2)))
    (explicacion Orientacion ?expO)
    (explicacion Tipo ?expT)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t ?expO crlf)
    (printout t ?expT crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_mayor_dificultad_diferente_orientacion
    (declare (salience 1))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (> ?d ?dc))
    (test (neq ?o ?oc))
    (test (and (eq ?t1 ?tc1) (eq ?t2 ?tc2)))
    (explicacion Tipo ?expT)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t ?expT crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_mayor_dificultad_diferente_tipo
    (declare (salience 1))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (> ?d ?dc))
    (test (eq ?o ?oc))
    (test (neq ?t2 ?tc2))
    (explicacion Orientacion ?expO)
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    (printout t ?expO crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)

(defrule asume_asignatura_mayor_dificultad_diferente_orientacion_y_tipo
    (declare (salience 0))
    (modulo asignaturas)
    ; ?rc <- (recomendar_asignaturas)
    ; Para completar creditos
    ?cr <- (Creditos ?c)
    (test (> ?c 0))
    ; Si todo concuerda con lo elegido por el usuario
    ?a <- (AS ?cs ?n ?d ?o ?t1 ?t2)
    (eleccion_curso ?ic)
    (test (or (= ?ic 0) (= ?ic ?cs)))
    (Dificultad ?dc)
    (Orientacion ?oc)
    (Tipo ?tc1 ?tc2)
    (test (> ?d ?dc))
    (test (neq ?o ?oc))
    (test (neq ?t2 ?tc2))
    =>
    (printout t crlf (str-cat "He elegido la asignatura " ?n " por las siguientes razones: ") crlf)
    ; (retract ?rc)
    (retract ?cr)
    ; (assert (recomendar_asignaturas))
    (assert (Creditos (- ?c 6)))
    (retract ?a)
)
