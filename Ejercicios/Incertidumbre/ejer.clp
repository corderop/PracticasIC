;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PABLO CORDERO ROMERO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;; Representación ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (ave ?x) representa “?x es un ave ”
; (animal ?x) representa “?x es un animal”
; (vuela ?x si|no seguro|por_defecto) representa
;“?x vuela si|no con esa certeza”

;;;;;;;;;;;;;;;;;; Hechos ;;;;;;;;;;;;;;;;;;
;Las aves y los mamíferos son animales
;Los gorriones, las palomas, las águilas y los pingüinos son aves
;La vaca, los perros y los caballos son mamíferos
;Los pingüinos no vuelan
(deffacts datos
    (ave gorrion) 
    (ave paloma) 
    (ave aguila) 
    (ave pinguino)
    (mamifero vaca) 
    (mamifero perro) 
    (mamifero caballo)
    (vuela pinguino no seguro))

;;;;;;;;;;;;;;;;;; Reglas seguras ;;;;;;;;;;;;;;;;;;

; Las aves son animales
(defrule aves_son_animales
    (ave ?x)
    =>
    (assert (animal ?x))
    (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque las aves son un tipo de animal"))
    (assert (explicacion animal ?x ?expl)) 
)
; añadimos un hecho que contiene la explicación de la deducción

; Los mamiferos son animales (A3)
(defrule mamiferos_son_animales
    (mamifero ?x)
    =>
    (assert (animal ?x))
    (bind ?expl (str-cat "sabemos que un " ?x " es un animal porque los mamiferos son un tipo de animal"))
    (assert (explicacion animal ?x ?expl)) 
)
; añadimos un hecho que contiene la explicación de la deducción

;;;;;;;;;;;;;;;;;; Reglas por defecto ;;;;;;;;;;;;;;;;;;

;;; Añade

;;; Casi todos las aves vuela --> puedo asumir por defecto que las aves vuelan
; Asumimos por defecto
(defrule ave_vuela_por_defecto
    (declare (salience -1)) ; para disminuir probabilidad de añadir erróneamente
    (ave ?x)
    =>
    (assert (vuela ?x si por_defecto))
    (bind ?expl (str-cat "asumo que un " ?x " vuela, porque casi todas las aves vuelan"))
    (assert (explicacion vuela ?x ?expl))
)

;;; Retracta

; Retractamos cuando hay algo en contra
(defrule retracta_vuela_por_defecto
    (declare (salience 1))
    ; para retractar antes de inferir cosas erroneamente
    ?f<- (vuela ?x ?r por_defecto)
    (vuela ?x ?s seguro)
    =>
    (retract ?f)
    (bind ?expl (str-cat "retractamos que un " ?x ?r " vuela por defecto, porque sabemos seguro que " ?x ?s " vuela"))
    (assert (explicacion retracta_vuela ?x ?expl)) 
)
;;; COMETARIO: esta regla también elimina los por defecto cuando ya esta seguro

; Regla por defecto para razonar con información incompleta

;;; La mayor parte de los animales no vuelan --> puede interesarme asumir por defecto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;que un animal no va a volar
(defrule mayor_parte_animales_no_vuelan
    (declare (salience -2)) ;;;; es mas arriesgado, mejor después de otros razonamientos
    (animal ?x)
    (not (vuela ?x ? ?))
    =>
    (assert (vuela ?x no por_defecto))
    (bind ?expl (str-cat "asumo que " ?x " no vuela, porque la mayor parte de los animales no vuelan"))
    (assert (explicacion vuela ?x ?expl))
)

;; Si es uno de los recogidos en el conocimiento indique si vuela o no

; Pregunta de que animal está interasado
(defrule seleccion
    (declare (salience -50))
    =>
    (printout t "¿De que animal esta interesado?: ")
    (assert (interes_en (read)))
)

; Si está recogido imprime la explicación
(defrule esta_recogido_animal
    ?f <- (interes_en ?a)
    (animal ?a)
    (explicacion vuela ?a ?expl)
    =>
    (retract ?f)
    (printout t ?expl crlf)
)

;; si no es uno de los recogidos pregunte si es un ave o un mamífero y según la respuesta indique si vuela o no.

; Detecta que no está recogido
(defrule no_esta_recogido_animal
    ?f <- (interes_en ?a)
    (not (or (or (animal ?a) (ave ?a)) (mamifero ?a)))
    =>
    (assert (preguntar_por_animal ?a))
    (retract ?f)
)

; Pregunta si es un ave o un mamífero
(defrule pregunta_por
    (preguntar_por_animal ?a)
    =>
    (printout t "¿" ?a " es un ave o un mamifero?: (Responda 'no' si no lo sabe) ")
    (assert (animal_clasificado ?a (read)))
)

; Si ha respondido mal se vuelve a preguntar
(defrule mala_respuesta
    (declare (salience 1))
    ?f <- (animal_clasificado ?a ?i)
    (not (test (or (or (eq ?i ave) (eq ?i mamifero)) (eq ?i no) )))
    =>
    (retract ?f)
    (printout t "No has introducido una opción correcta. (no poner tildes)" crlf)
    (printout t "¿" ?a " es un ave o un mamifero?: (Responda 'no' si no lo sabe) ")
    (assert (animal_clasificado ?a (read)))
)

; Crea el mamifero introducido y lanza el interes en este para obtener la explicación de si vuela o no
(defrule crea_mamifero
    ?f <- (animal_clasificado ?a ?b)
    (test (eq ?b mamifero) )
    =>
    (retract ?f)
    (assert (mamifero ?a))
    (assert (interes_en ?a))
)

; Crea el ave introducida y lanza el interes en esta para obtener la explicación de si vuela o no
(defrule crea_ave
    ?f <- (animal_clasificado ?a ?b)
    (test (eq ?b ave) )
    =>
    (retract ?f)
    (assert (ave ?a))
    (assert (interes_en ?a))
)

;; Si no se sabe si es un mamífero o un ave también responda según el razonamiento por defecto indicado
(defrule crea_animal
    ?f <- (animal_clasificado ?a ?b)
    (test (eq ?b no) )
    =>
    (retract ?f)
    (assert (animal ?a))
    (assert (interes_en ?a))
)