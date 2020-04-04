(deftemplate FP
    (field Nombre)
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
        (Nombre Pedro))
    (FP
        (Nombre Juan))
)

(deffacts CreacionDiabolica
    (DE
        (Nombre Pedro)
        (Sintomas picor vesiculas))
    (DE
        (Nombre Juan)
        (Sintomas picor vesiculas))
)

(defrule DE
    (FP
        (Nombre ?Nombre))
    (DE
        (Nombre ?Nombre)
        (Sintomas picor vesiculas))
    =>
    (printout t "Oju que enfermo estas " ?Nombre crlf)
)