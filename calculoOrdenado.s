.data
;; INICIO VARIABLES DE ENTRADA Y SALIDA: NO MODIFICAR ORDEN
A:          .float  10.0
B:          .float  20.0
C:          .float  30.0
D:          .float  40.0
E:          .float  50.0
F:          .float  60.0
Resultado:  .float  0
;; FIN VARIABLES DE E/S
cero:       .float  0.0

.text
.global main

main:
    LF f30, cero
    LF f0, A
    LF f1, B
    LF f2, C
    LF f3, D
    LF f4, E
    LF f5, F

    ; Chequeo F!=0 para DIV1
    EQF f5, f30
    BFPT division_por_cero

    DIVF f20, f0, f5    ; --- DIV 1 (A/F) ---

    ; Adelantamos chequeos D!=0, E!=0 para aprovechar el tiempo
    EQF f4, f30
    BFPT division_por_cero
    EQF f3, f30
    BFPT division_por_cero

    ; Aprovechamos los ciclos de espera de la unidad DIV para trabajo independiente
    MULTF f10, f0, f1   ; A*B
    MULTF f11, f4, f5   ; E*F
    ADDF f26, f0, f1    ; A+B
    ADDF f27, f3, f4    ; D+E

    DIVF f21, f1, f4    ; --- DIV 2 (B/E) ---

    ; Continuamos rellenando los huecos mientras arranca DIV2
    ADDF f26, f26, f2   ; (A+B)+C
    ADDF f27, f27, f5   ; (D+E)+F

    DIVF f22, f2, f3    ; --- DIV 3 (C/D) ---

    MULTF f10, f10, f2  ; f10 = A*B*C
    MULTF f28, f26, f27 ; f28 = (A+B+C)*(D+E+F)

    ; Comprobamos E*F != 0 para DIV5
    EQF f11, f30
    BFPT division_por_cero

    ; Comprobamos A*B*C != 0 para DIV4
    EQF f10, f30
    BFPT division_por_cero

    DIVF f23, f4, f10   ; --- DIV 4 (E / A*B*C) ---

    DIVF f24, f3, f11   ; --- DIV 5 (D / E*F) ---

    ; --- Reagrupación final ---
    ; Al llegar aquí, DIV1 y DIV2 se lanzaron hace más de 40 ciclos, ya han terminado.
    ADDF f25, f20, f21  ; Div1 + Div2
    ADDF f25, f25, f22  ; (Div1+Div2) + Div3

    ; Estas últimas sufrirán un RAW stall (dependencia de datos) esperando a que DIV4/DIV5 acaben,
    ; lo cual es matemáticamente inevitable al tener el cuello de botella de 1 sola unidad DIV.
    ADDF f29, f23, f24  ; Div4 + Div5
    ADDF f25, f25, f29  ; Suma total de las 5 fracciones

    MULTF f31, f25, f28 ; Total * Multiplicador final

    SF Resultado, f31
    J fin

division_por_cero:
    LF f31, cero
    SF Resultado, f31
fin:
    TRAP 0