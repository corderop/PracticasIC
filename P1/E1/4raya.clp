;;;;;;; JUGADOR DE 4 en RAYA ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;; Version de 4 en raya clásico: Tablero de 7x7, donde se introducen fichas por arriba
;;;;;;;;;;;;;;;;;;;;;;; y caen hasta la posicion libre mas abajo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Hechos para representar un estado del juego

;;;;;;; (Turno M|J)   representa a quien corresponde el turno (M maquina, J jugador)
;;;;;;; (Tablero Juego ?i ?j _|M|J) representa que la posicion i,j del tablero esta vacia (_), o tiene una ficha propia (M) o tiene una ficha del jugador humano (J)

;;;;;;;;;;;;;;;; Hechos para representar estado del analisis
;;;;;;; (Tablero Analisis Posicion ?i ?j _|M|J) representa que en el analisis actual la posicion i,j del tablero esta vacia (_), o tiene una ficha propia (M) o tiene una ficha del jugador humano (J)
;;;;;;; (Sondeando ?n ?i ?c M|J)  ; representa que estamos analizando suponiendo que la ?n jugada h sido ?i ?c M|J
;;;

;;;;;;;;;;;;; Hechos para representar una jugadas

;;;;;;; (Juega M|J ?columna) representa que la jugada consiste en introducir la ficha en la columna ?columna 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INICIALIZAR ESTADO


(deffacts Estado_inicial
(Tablero Juego 1 1 _) (Tablero Juego 1 2 _) (Tablero Juego 1 3 _) (Tablero Juego  1 4 _) (Tablero Juego  1 5 _) (Tablero Juego  1 6 _) (Tablero Juego  1 7 _)
(Tablero Juego 2 1 _) (Tablero Juego 2 2 _) (Tablero Juego 2 3 _) (Tablero Juego 2 4 _) (Tablero Juego 2 5 _) (Tablero Juego 2 6 _) (Tablero Juego 2 7 _)
(Tablero Juego 3 1 _) (Tablero Juego 3 2 _) (Tablero Juego 3 3 _) (Tablero Juego 3 4 _) (Tablero Juego 3 5 _) (Tablero Juego 3 6 _) (Tablero Juego 3 7 _)
(Tablero Juego 4 1 _) (Tablero Juego 4 2 _) (Tablero Juego 4 3 _) (Tablero Juego 4 4 _) (Tablero Juego 4 5 _) (Tablero Juego 4 6 _) (Tablero Juego 4 7 _)
(Tablero Juego 5 1 _) (Tablero Juego 5 2 _) (Tablero Juego 5 3 _) (Tablero Juego 5 4 _) (Tablero Juego 5 5 _) (Tablero Juego 5 6 _) (Tablero Juego 5 7 _)
(Tablero Juego 6 1 _) (Tablero Juego 6 2 _) (Tablero Juego 6 3 _) (Tablero Juego 6 4 _) (Tablero Juego 6 5 _) (Tablero Juego 6 6 _) (Tablero Juego 6 7 _)
(Tablero Juego 7 1 _) (Tablero Juego 7 2 _) (Tablero Juego 7 3 _) (Tablero Juego 7 4 _) (Tablero Juego 7 5 _) (Tablero Juego 7 6 _) (Tablero Juego 7 7 _)
(Jugada 0)
)

(defrule Elige_quien_comienza
=>
(printout t "Quien quieres que empieze: (escribre M para la maquina o J para empezar tu) ")
(assert (Turno (read)))
)

;;;;;;;;;;;;;;;;;;;;;;; MUESTRA POSICION ;;;;;;;;;;;;;;;;;;;;;;;
(defrule muestra_posicion
(declare (salience 10))
(muestra_posicion)
(Tablero Juego 1 1 ?p11) (Tablero Juego 1 2 ?p12) (Tablero Juego 1 3 ?p13) (Tablero Juego 1 4 ?p14) (Tablero Juego 1 5 ?p15) (Tablero Juego 1 6 ?p16) (Tablero Juego 1 7 ?p17)
(Tablero Juego 2 1 ?p21) (Tablero Juego 2 2 ?p22) (Tablero Juego 2 3 ?p23) (Tablero Juego 2 4 ?p24) (Tablero Juego 2 5 ?p25) (Tablero Juego 2 6 ?p26) (Tablero Juego 2 7 ?p27)
(Tablero Juego 3 1 ?p31) (Tablero Juego 3 2 ?p32) (Tablero Juego 3 3 ?p33) (Tablero Juego 3 4 ?p34) (Tablero Juego 3 5 ?p35) (Tablero Juego 3 6 ?p36) (Tablero Juego 3 7 ?p37)
(Tablero Juego 4 1 ?p41) (Tablero Juego 4 2 ?p42) (Tablero Juego 4 3 ?p43) (Tablero Juego 4 4 ?p44) (Tablero Juego 4 5 ?p45) (Tablero Juego 4 6 ?p46) (Tablero Juego 4 7 ?p47)
(Tablero Juego 5 1 ?p51) (Tablero Juego 5 2 ?p52) (Tablero Juego 5 3 ?p53) (Tablero Juego 5 4 ?p54) (Tablero Juego 5 5 ?p55) (Tablero Juego 5 6 ?p56) (Tablero Juego 5 7 ?p57)
(Tablero Juego 6 1 ?p61) (Tablero Juego 6 2 ?p62) (Tablero Juego 6 3 ?p63) (Tablero Juego 6 4 ?p64) (Tablero Juego 6 5 ?p65) (Tablero Juego 6 6 ?p66) (Tablero Juego 6 7 ?p67)
(Tablero Juego 7 1 ?p71) (Tablero Juego 7 2 ?p72) (Tablero Juego 7 3 ?p73) (Tablero Juego 7 4 ?p74) (Tablero Juego 7 5 ?p75) (Tablero Juego 7 6 ?p76) (Tablero Juego 7 7 ?p77)
=>
(printout t crlf)
(printout t 1 " " 2 " " 3 " " 4 " " 5 " " 6 " " 7 crlf)
(printout t ?p11 " " ?p12 " " ?p13 " " ?p14 " " ?p15 " " ?p16 " " ?p17 crlf)
(printout t ?p21 " " ?p22 " " ?p23 " " ?p24 " " ?p25 " " ?p26 " " ?p27 crlf)
(printout t ?p31 " " ?p32 " " ?p33 " " ?p34 " " ?p35 " " ?p36 " " ?p37 crlf)
(printout t ?p41 " " ?p42 " " ?p43 " " ?p44 " " ?p45 " " ?p46 " " ?p47 crlf)
(printout t ?p51 " " ?p52 " " ?p53 " " ?p54 " " ?p55 " " ?p56 " " ?p57 crlf)
(printout t ?p61 " " ?p62 " " ?p63 " " ?p64 " " ?p65 " " ?p66 " " ?p67 crlf)
(printout t ?p71 " " ?p72 " " ?p73 " " ?p74 " " ?p75 " " ?p76 " " ?p77 crlf)
(printout t  crlf)
)


;;;;;;;;;;;;;;;;;;;;;;; RECOGER JUGADA DEL CONTRARIO ;;;;;;;;;;;;;;;;;;;;;;;
(defrule mostrar_posicion
(declare (salience 9999))
(Turno J)
=>
(assert (muestra_posicion))
)

(defrule jugada_contrario
?f <- (Turno J)
=>
(printout t "en que columna introduces la siguiente ficha? ")
(assert (Juega J (read)))
(retract ?f)
)

(defrule juega_contrario_check_entrada_correcta
(declare (salience 1))
?f <- (Juega J ?c)
(test (and (neq ?c 1) (and (neq ?c 2) (and (neq ?c 3) (and (neq ?c 4) (and (neq ?c 5) (and (neq ?c 6) (neq ?c 7))))))))
=>
(printout t "Tienes que indicar un numero de columna: 1,2,3,4,5,6 o 7" crlf)
(retract ?f)
(assert (Turno J))
)

(defrule juega_contrario_check_columna_libre
(declare (salience 1))
?f <- (Juega J ?c)
(Tablero Juego 1 ?c ?X) 
(test (neq ?X _))
=>
(printout t "Esa columna ya esta completa, tienes que jugar en otra" crlf)
(retract ?f)
(assert (Turno J))
)

(defrule juega_contrario_actualiza_estado
?f <- (Juega J ?c)
?g <- (Tablero Juego ?i ?c _)
(Tablero Juego ?j ?c ?X) 
(test (= (+ ?i 1) ?j))
(test (neq ?X _))
=>
(retract ?f ?g)
(assert (Turno M) (Tablero Juego ?i ?c J))
)

(defrule juega_contrario_actualiza_estado_columna_vacia
?f <- (Juega J ?c)
?g <- (Tablero Juego 7 ?c _)
=>
(retract ?f ?g)
(assert (Turno M) (Tablero Juego 7 ?c J))
)


;;;;;;;;;;; ACTUALIZAR  ESTADO TRAS JUGADA DE CLISP ;;;;;;;;;;;;;;;;;;

(defrule juega_clisp_actualiza_estado
?f <- (Juega M ?c)
?g <- (Tablero Juego ?i ?c _)
(Tablero Juego ?j ?c ?X) 
(test (= (+ ?i 1) ?j))
(test (neq ?X _))
=>
(retract ?f ?g)
(assert (Turno J) (Tablero Juego ?i ?c M))
)

(defrule juega_clisp_actualiza_estado_columna_vacia
?f <- (Juega M ?c)
?g <- (Tablero Juego 7 ?c _)
=>
(retract ?f ?g)
(assert (Turno J) (Tablero Juego 7 ?c M))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;  Comprobar si hay 4 en linea ;;;;;;;;;;;;;;;;;;;;;

(defrule cuatro_en_linea_horizontal
(declare (salience 9999))
(Tablero ?t ?i ?c1 ?jugador)
(Tablero ?t ?i ?c2 ?jugador) 
(test (= (+ ?c1 1) ?c2))
(Tablero ?t ?i ?c3 ?jugador)
(test (= (+ ?c1 2) ?c3))
(Tablero ?t ?i ?c4 ?jugador)
(test (= (+ ?c1 3) ?c4))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador horizontal ?i ?c1))
)

(defrule cuatro_en_linea_vertical
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i1 ?c ?jugador)
(Tablero ?t ?i2 ?c ?jugador)
(test (= (+ ?i1 1) ?i2))
(Tablero ?t ?i3 ?c  ?jugador)
(test (= (+ ?i1 2) ?i3))
(Tablero ?t ?i4 ?c  ?jugador)
(test (= (+ ?i1 3) ?i4))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador vertical ?i1 ?c))
)

(defrule cuatro_en_linea_diagonal_directa
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i ?c ?jugador)
(Tablero ?t ?i1 ?c1 ?jugador)
(test (= (+ ?i 1) ?i1))
(test (= (+ ?c 1) ?c1))
(Tablero ?t ?i2 ?c2  ?jugador)
(test (= (+ ?i 2) ?i2))
(test (= (+ ?c 2) ?c2))
(Tablero ?t ?i3 ?c3  ?jugador)
(test (= (+ ?i 3) ?i3))
(test (= (+ ?c 3) ?c3))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador diagonal_directa ?i ?c))
)

(defrule cuatro_en_linea_diagonal_inversa
(declare (salience 9999))
?f <- (Turno ?X)
(Tablero ?t ?i ?c ?jugador)
(Tablero ?t ?i1 ?c1 ?jugador)
(test (= (+ ?i 1) ?i1))
(test (= (- ?c 1) ?c1))
(Tablero ?t ?i2 ?c2  ?jugador)
(test (= (+ ?i 2) ?i2))
(test (= (- ?c 2) ?c2))
(Tablero ?t ?i3 ?c3  ?jugador)
(test (= (+ ?i 3) ?i3))
(test (= (- ?c 3) ?c3))
(test (or (eq ?jugador M) (eq ?jugador J) ))
=>
(assert (Cuatro_en_linea ?t ?jugador diagonal_inversa ?i ?c))
)

;;;;;;;;;;;;;;;;;;;; DESCUBRE GANADOR
(defrule gana_fila
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador horizontal ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la fila " ?i crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_columna
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador vertical ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la columna " ?c crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_diagonal_directa
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador diagonal_directa ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la diagonal que empieza la posicion " ?i " " ?c   crlf)
(retract ?f)
(assert (muestra_posicion))
) 

(defrule gana_diagonal_inversa
(declare (salience 9999))
?f <- (Turno ?X)
(Cuatro_en_linea Juego ?jugador diagonal_inversa ?i ?c)
=>
(printout t ?jugador " ha ganado pues tiene cuatro en linea en la diagonal hacia arriba que empieza la posicin " ?i " " ?c   crlf)
(retract ?f)
(assert (muestra_posicion))
) 


;;;;;;;;;;;;;;;;;;;;;;;  DETECTAR EMPATE

(defrule empate
(declare (salience -9999))
(Turno ?X)
(Tablero Juego 1 1 M|J)
(Tablero Juego 1 2 M|J)
(Tablero Juego 1 3 M|J)
(Tablero Juego 1 4 M|J)
(Tablero Juego 1 5 M|J)
(Tablero Juego 1 6 M|J)
(Tablero Juego 1 7 M|J)
=>
(printout t "EMPATE! Se ha llegado al final del juego sin que nadie gane" crlf)
)

;;;;;;;;;;;;;;;;;;;;;; CONOCIMIENTO EXPERTO ;;;;;;;;;;

;;;;;;;;;;; CLISP JUEGA SIN CRITERIO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule clisp_juega_sin_criterio
(declare (salience -9999))
?f<- (Turno M)
(Tablero Juego ?i ?c _)
=>
(printout t "JUEGO en la columna (sin criterio) " ?c crlf)
(retract ?f)
(assert (Juega M ?c))
)

;;;;; ¡¡¡¡¡¡¡¡¡¡ Añadir codigo para que juege como vosotros jugariais !!!!!!!!!!!!
; No puede jugarse en c
(defrule no_puede_jugarse_c
    (declare (salience 9998))
    (Tablero Juego 1 ?c M|J)
    =>
    (assert (no_puede_jugarse ?c))
)

; Detectar donde caeria
    (defrule inicializar_caeria
    (declare (salience 9998))
    (Tablero Juego 7 ?c _)
    (not (caeria 7 ?c))
    =>
    (assert (caeria 7 ?c))
)

(defrule caeria_f_c
    (declare (salience 9997))
    ?a <- (caeria ?f ?c)
    (Tablero Juego ?f ?c M|J)
    (not (no_puede_jugarse ?c))
    =>
    (retract ?a)
    (assert (caeria (- ?f 1) ?c))
)

(defrule actualiza_caeria_f_c
    (declare (salience 9997))
    (no_puede_jugarse ?c)
    ?a <- (caeria 1 ?c)
    =>
    (retract ?a)
)

; Detecta si hay dos fichas en un mismo lugar
(defrule dos_fichas_horizontal
    (declare (salience 9997))
    (Tablero ?t ?i ?c1 ?jugador)
    (Tablero ?t ?i ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (test (neq ?jugador _))
    =>
    (assert (conectado Juego h ?i ?c1 ?i ?c2 ?jugador))
)

(defrule dos_fichas_vertical
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c ?jugador)
    (Tablero ?t ?i2 ?c ?jugador)
    (test (= (+ ?i1 1) ?i2))
    (test (neq ?jugador _))
    =>
    (assert (conectado Juego v ?i1 ?c ?i2 ?c ?jugador))
)

(defrule dos_fichas_diagonal_derecha_abajo
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c1 ?jugador)
    (Tablero ?t ?i2 ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (test (= (+ ?i1 1) ?i2))
    (test (neq ?jugador _))
    =>
    (assert (conectado Juego d1 ?i1 ?c1 ?i2 ?c2 ?jugador))
)

(defrule dos_fichas_diagonal_derecha_arriba
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c1 ?jugador)
    (Tablero ?t ?i2 ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (test (= (- ?i1 1) ?i2))
    (test (neq ?jugador _))
    =>
    (assert (conectado Juego d2 ?i1 ?c1 ?i2 ?c2 ?jugador))
)

; Tres en línea
(defrule tres_fichas_horizontal
    (declare (salience 9997))
    (Tablero ?t ?i ?c1 ?jugador)
    (Tablero ?t ?i ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (Tablero ?t ?i ?c3 ?jugador)
    (test (= (+ ?c2 1) ?c3))
    (test (neq ?jugador _))
    =>
    (assert (3_en_linea Juego h ?i ?c1 ?i ?c3 ?jugador))
)

(defrule tres_fichas_vertical
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c ?jugador)
    (Tablero ?t ?i2 ?c ?jugador)
    (test (= (+ ?i1 1) ?i2))
    (Tablero ?t ?i3 ?c ?jugador)
    (test (= (+ ?i2 1) ?i3))
    (test (neq ?jugador _))
    =>
    (assert (3_en_linea Juego v ?i1 ?c ?i3 ?c ?jugador))
)


(defrule tres_fichas_diagonal_derecha_abajo
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c1 ?jugador)
    (Tablero ?t ?i2 ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (test (= (+ ?i1 1) ?i2))
    (Tablero ?t ?i3 ?c3 ?jugador)
    (test (= (+ ?c2 1) ?c3))
    (test (= (+ ?i2 1) ?i3))
    (test (neq ?jugador _))
    =>
    (assert (3_en_linea Juego d1 ?i1 ?c1 ?i3 ?c3 ?jugador))
)

(defrule tres_fichas_diagonal_derecha_arriba
    (declare (salience 9997))
    (Tablero ?t ?i1 ?c1 ?jugador)
    (Tablero ?t ?i2 ?c2 ?jugador)
    (test (= (+ ?c1 1) ?c2))
    (test (= (- ?i1 1) ?i2))
    (Tablero ?t ?i3 ?c3 ?jugador)
    (test (= (+ ?c2 1) ?c3))
    (test (= (- ?i2 1) ?i3))
    (test (neq ?jugador _))
    =>
    (assert (3_en_linea Juego d2 ?i1 ?c1 ?i3 ?c3 ?jugador))
)

; Reglas para deducir si ganaría

; Calcula cuando está a una accion de ganar alguien cuando la forma de las
; fichas es la siguiente:
; X X X _ ó _ X X X
(defrule ganaria_horizontal
    (declare (salience 9996))
    (3_en_linea Juego h ?i ?c1 ?i ?c2 ?jugador)
    (Tablero Juego ?i ?c3 _)
    (test (or (= (+ ?c2 1) ?c3) (= (- ?c1 1) ?c3) ))
    (caeria ?i ?c3)
    =>
    (assert (ganaria ?jugador ?c3))
)

; Calcula cuando está a una accion de ganar alguien cuando la forma de las
; fichas es en vertical
(defrule ganaria_vertical
    (declare (salience 9996))
    (3_en_linea Juego v ?i1 ?c ?i2 ?c ?jugador)
    (Tablero Juego ?i3 ?c _)
    (test (= (- ?i1 1) ?i3))
    (caeria ?i3 ?c)
    =>
    (assert (ganaria ?jugador ?c))
)

; Calcula cuando está a una accion de ganar alguien cuando la forma de las
; fichas es la siguiente:
; X X _ X
(defrule gana_2_horizontal_derecha
    (declare (salience 9996))
    ; Busca dos conectadas X X
    (conectado Juego h ?i ?c1 ?i ?c2 ?jugador)
    ; Busca X X Y X, es decir una X a la derecha
    (Tablero Juego ?i ?c3 ?jugador)
    (test (= (+ ?c2 2) ?c3))
    ; Busca X X _ X, un espacio en medio
    (Tablero Juego ?i ?c4 _)
    (test (= (+ ?c2 1) ?c4))
    ; Busca que la pieza caiga en ese sitio
    (caeria ?i ?c4)
    =>
    (assert (ganaria ?jugador ?c4))
)

; Calcula cuando está a una accion de ganar alguien cuando la forma de las
; fichas es la siguiente:
; X _ X X
(defrule gana_2_horizontal_izquierda
    (declare (salience 9996))
    ; Busca dos conectadas X X
    (conectado Juego h ?i ?c1 ?i ?c2 ?jugador)
    ; Busca X Y X X, es decir una X a la izquierda
    (Tablero Juego ?i ?c3 ?jugador)
    (test (= (- ?c1 2) ?c3))
    ; Busca X _ X X, es decir un espacio en medio
    (Tablero Juego ?i ?c4 _)
    (test (= (- ?c1 1) ?c4))
    ; Busca que la pieza caiga en ese sitio
    (caeria ?i ?c4)
    =>
    (assert (ganaria ?jugador ?c4))
)

; Calcula cuando está a una accion de ganar en diagonal hacia abajo
; _ · · · | X · · ·
; · X · · | · X · ·
; · · X · | · · X ·
; · · · X | · · · _
(defrule ganaria_diagonal_abajo
    (declare (salience 9996))
    (3_en_linea Juego d1 ?i1 ?c1 ?i2 ?c2 ?jugador)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
            (and (= (+ ?c2 1) ?c3) (= (+ ?i2 1) ?i3))
            (and (= (- ?c1 1) ?c3) (= (- ?i1 1) ?i3))))
    (caeria ?i3 ?c3)
    =>
    (assert (ganaria ?jugador ?c3))
)

; Calcula cuando está a una accion de ganar en diagonal hacia arriba
; · · · X | · · · _
; · · X · | · · X ·
; · X · · | · X · ·
; _ · · · | X · · ·
(defrule ganaria_diagonal_arriba
    (declare (salience 9996))
    (3_en_linea Juego d2 ?i1 ?c1 ?i2 ?c2 ?jugador)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
            ; Arriba
            (and (= (+ ?c2 1) ?c3) (= (- ?i2 1) ?i3))
            ; Abajo
            (and (= (- ?c1 1) ?c3) (= (+ ?i1 1) ?i3))))
    (caeria ?i3 ?c3)
    =>
    (assert (ganaria ?jugador ?c3))
)

; Cuando se introduce una nueva ficha en una columna,
; se elimina la posibilidad de ganar al introducir
; una ficha en esa columna. Si la ha introducido el rival
; seguirá el juego, si no ganaría el que tenía ya esta posibilidad.
(defrule elimina_ganaria
    (declare (salience 9998))
    (Juega ? ?c)
    ?j <- (ganaria ? ?c)
    =>
    (retract ?j)
)

; Jugadas de la máquina

; Inicia en el centro
(defrule clisp_inicia_centro
    (declare (salience 1000))
    ?f<- (Turno M)
    (Tablero Juego 7 4 _)
    =>
    (printout t "JUEGO en la columna central para iniciar " 4 crlf)
    (retract ?f)
    (assert (Juega M 4))
)

; Tapa si ganaría rival
(defrule tapa_victoria_rival
    (declare (salience 1050))
    ?f<- (Turno M)
    (ganaria J ?i)
    =>
    (printout t "JUEGO en la columna " ?i " para tapar victoria" crlf)
    (retract ?f)
    (assert (Juega M ?i))
)

; Introduce si esto lo hace ganar
(defrule busca_victoria
    (declare (salience 1051))
    ?f<- (Turno M)
    (ganaria M ?i)
    =>
    (printout t "JUEGO en la columna " ?i " para ganar" crlf)
    (retract ?f)
    (assert (Juega M ?i))
)

; Evita que el rival tenga 3 en raya y se acerque a ganar
(defrule tapo_2_horizontal
    (declare (salience 1030))
    ?f<- (Turno M)
    (conectado Juego h ?i ?c1 ?i ?c2 J)
    (Tablero Juego ?i ?c3 _)
    (test (or 
        (= (+ ?c2 1) ?c3) 
        (= (- ?c1 1) ?c3) ))
    (caeria ?i ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para evitar que el rival tenga 3 en raya (h)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule tapo_2_diagonal_abajo
    (declare (salience 1030))
    ?f<- (Turno M)
    (conectado Juego d1 ?i1 ?c1 ?i2 ?c2 J)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
        (and (= (+ ?c2 1) ?c3) (= (+ ?i2 1) ?i3))
        (and (= (- ?c1 1) ?c3) (= (- ?i1 1) ?i3)) ))
    (caeria ?i3 ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para evitar que el rival tenga 3 en raya (dab)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule tapo_2_diagonal_arriba
    (declare (salience 1030))
    ?f<- (Turno M)
    (conectado Juego d2 ?i1 ?c1 ?i2 ?c2 J)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
        ; Arriba
        (and (= (+ ?c2 1) ?c3) (= (- ?i2 1) ?i3))
        ; Abajo
        (and (= (- ?c1 1) ?c3) (= (+ ?i1 1) ?i3))))
    (caeria ?i3 ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para evitar que el rival tenga 3 en raya (dar)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule tapo_2_vertical
    (declare (salience 1030))
    ?f<- (Turno M)
    (conectado Juego v ?i ?c ? ? J)
    (Tablero Juego ?i3 ?c _)
    (test (= (- ?i 1) ?i3))
    =>
    (printout t "JUEGO en la columna " ?c " para evitar que el rival tenga 3 en raya (v)" crlf)
    (retract ?f)
    (assert (Juega M ?c))
)

; Busco tener 3 en raya
(defrule busco_3_horizontal
    (declare (salience 1025))
    ?f<- (Turno M)
    (conectado Juego h ?i ?c1 ?i ?c2 M)
    (Tablero Juego ?i ?c3 _)
    (test (or 
        (= (+ ?c2 1) ?c3) 
        (= (- ?c1 1) ?c3) ))
    (caeria ?i ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para buscar 3 en raya (h)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule busco_3_diagonal_abajo
    (declare (salience 1025))
    ?f<- (Turno M)
    (conectado Juego d1 ?i1 ?c1 ?i2 ?c2 M)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
        (and (= (+ ?c2 1) ?c3) (= (+ ?i2 1) ?i3))
        (and (= (- ?c1 1) ?c3) (= (- ?i1 1) ?i3)) ))
    (caeria ?i3 ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para buscar 3 en raya (dab)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule bsuco_3_diagonal_arriba
    (declare (salience 1025))
    ?f<- (Turno M)
    (conectado Juego d2 ?i1 ?c1 ?i2 ?c2 M)
    (Tablero Juego ?i3 ?c3 _)
    (test (or 
        ; Arriba
        (and (= (+ ?c2 1) ?c3) (= (- ?i2 1) ?i3))
        ; Abajo
        (and (= (- ?c1 1) ?c3) (= (+ ?i1 1) ?i3))))
    (caeria ?i3 ?c3)
    =>
    (printout t "JUEGO en la columna " ?c3 " para tener 3 en raya (dar)" crlf)
    (retract ?f)
    (assert (Juega M ?c3))
)

(defrule bsuco_3_vertical
    (declare (salience 1025))
    ?f<- (Turno M)
    (conectado Juego v ?i ?c ? ? M)
    (Tablero Juego ?i3 ?c _)
    (test (= (- ?i 1) ?i3))
    =>
    (printout t "JUEGO en la columna " ?c " para tener 3 en raya (v)" crlf)
    (retract ?f)
    (assert (Juega M ?c))
)