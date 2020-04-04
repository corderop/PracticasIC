(deftemplate FP
    (field Nombre)
    (field Indice)
)

(deftemplate DE
    (field Nombre)
    (multifield Sintomas)
)

; (deftemplate Sintomas
;     ()
; )

(deffacts CreacionDivina
    (FP
        (Nombre Pedro)
        (Indice 1))
    (FP
        (Nombre Juan)
        (Indice 2))
)

(deffacts CreacionDiabolica
    (DE
        (Nombre Pedro)
        (Sintomas picor vesiculas))
    (DE
        (Nombre Juan)
        (Sintomas vesiculas))
)

(defrule DJ
    (FP
        (Nombre ?Nombre)
        (Indice ?i))
    (DE
        (Nombre ?Nombre)
        (Sintomas picor vesiculas))
    =>
    (printout t "Has muerto pringao " ?Nombre crlf)
    (retract ?i)
)