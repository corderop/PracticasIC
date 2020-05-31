(deftemplate Persona
    (field Nombre)
    (field MiembroMasGrandeQuePierna)
    (field Tos)
)

(deftemplate Enfermedad
    (field Nombre)
    (field MiembroMasGrandeQuePierna)
    (field Tos)
)

(deffacts PersonasYEnfermedades
    (Persona
        (Nombre "Paquillo Martinez")
        (MiembroMasGrandeQuePierna SI)
        (Tos NO)
    )
    (Persona
        (Nombre "La novia paquillo")
        (MiembroMasGrandeQuePierna NO)
        (Tos NO)
    )
    (Enfermedad
        (Nombre Dierna)
        (MiembroMasGrandeQuePierna SI)
        (Tos NO)
    )
    (Enfermedad
        (Nombre Resfriado)
        (MiembroMasGrandeQuePierna NO)
        (Tos SI)
    )
)

(defrule QueEnfermedad
    (Persona 
        (Nombre ?Nombre)
        (MiembroMasGrandeQuePierna ?S1)
        (Tos ?S2)
    )
    (Enfermedad
        (Nombre ?Enfermedad)
        (MiembroMasGrandeQuePierna ?S1)
        (Tos ?S2)
    )
    =>
    (printout t ?Nombre " tiene " ?Enfermedad crlf)
)