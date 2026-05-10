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
    ;; --- ESTRATEGIA 113 CICLOS: DISPARO INMEDIATO ---
    LF f0, A            ; Ciclo 1
    LF f5, F            ; Ciclo 2
    DIVF f20, f0, f5    ; Ciclo 3: LANZAMOS DIV 1 (A/F) INMEDIATAMENTE

    ;; --- RELLENO MIENTRAS DIV1 TRABAJA (19 ciclos de margen) ---
    LF f1, B            
    LF f4, E            
    LF f30, cero        
    
    EQF f5, f30         ; Comprobamos F mientras f20 se calcula
    LF f2, C            
    LF f3, D            
    BFPT division_por_cero ; Salto si F es 0

    EQF f4, f30         ; Comprobamos E
    MULTF f10, f0, f1   ; f10 = A*B (Adelantamos cálculo del denominador 4)
    BFPT division_por_cero ; Salto si E es 0

    EQF f3, f30         ; Comprobamos D
    MULTF f11, f4, f5   ; f11 = E*F (Adelantamos denominador 5)
    BFPT division_por_cero ; Salto si D es 0

    ;; --- SEGUNDA OLEADA DE DIVISIONES ---
    ; Para este punto, la unidad DIV debería estar a punto de liberarse
    DIVF f21, f1, f4    ; DIV 2 (B/E)
    
    ADDF f26, f0, f1    ; f26 = A+B (Parte del multiplicador final)
    MULTF f10, f10, f2  ; f10 = A*B*C (Terminamos denominador 4)
    ADDF f27, f3, f4    ; f27 = D+E (Parte del multiplicador final)

    EQF f10, f30        ; Comprobamos A*B*C
    BFPT division_por_cero
    
    DIVF f22, f2, f3    ; DIV 3 (C/D)

    EQF f11, f30        ; Comprobamos E*F
    ADDF f26, f26, f2   ; f26 = A+B+C
    BFPT division_por_cero

    DIVF f23, f4, f10   ; DIV 4 (E / A*B*C)

    ADDF f27, f27, f5   ; f27 = D+E+F
    MULTF f28, f26, f27 ; f28 = (A+B+C)*(D+E+F) <--- Multiplicador listo

    DIVF f24, f3, f11   ; DIV 5 (D / E*F)

    ;; --- REAGRUPACIÓN FINAL (Aprovechando latencias de DIV4 y DIV5) ---
    ADDF f25, f20, f21  ; Sumamos las que ya terminaron (DIV1+DIV2)
    ADDF f25, f25, f22  ; + DIV3
    
    ; Aquí el pipeline esperará lo mínimo por DIV4 y DIV5
    ADDF f29, f23, f24  ; f29 = DIV4 + DIV5
    ADDF f25, f25, f29  ; Suma total de las 5 fracciones

    MULTF f31, f25, f28 ; f31 = (Suma total) * (Multiplicador)

    SF Resultado, f31
    J fin

division_por_cero:
    LF f31, cero
    SF Resultado, f31

fin:
    TRAP 0