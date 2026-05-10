.data  
A:          .float  10.0
B:          .float  20.0
C:          .float  30.0
D:          .float  40.0
E:          .float  50.0
F:          .float  60.0
Resultado:  .float  0
cero:       .float  0.0

.text
.global main

main:
    ; --- INICIO AGRESIVO (Ciclo 1-3) ---
    LF f0, A            
    LF f5, F            
    DIVF f20, f0, f5    ; DIV 1 lanzada en ciclo 3. Termina en el 22.

    ; --- RELLENO 1 (Ocultamos cargas y primer chequeo) ---
    LF f1, B            
    LF f4, E            
    LF f30, cero        
    LF f2, C            
    LF f3, D            
    EQF f5, f30         ; F == 0?
    BFPT division_por_cero 

    ; --- PREPARACIÓN DENOMINADORES ---
    MULTF f10, f0, f1   ; A*B
    MULTF f11, f4, f5   ; E*F
    EQF f4, f30         ; E == 0?
    BFPT division_por_cero

    ; --- SEGUNDA DIVISIÓN (Debe entrar en el ciclo 23) ---
    DIVF f21, f1, f4    ; DIV 2 lanzada en ciclo 23. Termina en el 42.
    
    ; --- RELLENO 2 (Ocultamos sumas y más chequeos) ---
    ADDF f26, f0, f1    ; A+B
    MULTF f10, f10, f2  ; A*B*C
    ADDF f27, f3, f4    ; D+E
    EQF f3, f30         ; D == 0?
    BFPT division_por_cero

    ; --- TERCERA DIVISIÓN (Ciclo 43) ---
    DIVF f22, f2, f3    ; DIV 3 lanzada en ciclo 43. Termina en el 62.

    EQF f10, f30        ; A*B*C == 0?
    ADDF f26, f26, f2   ; A+B+C
    BFPT division_por_cero

    ; --- CUARTA DIVISIÓN (Ciclo 63) ---
    DIVF f23, f4, f10   ; DIV 4 lanzada en ciclo 63. Termina en el 82.

    EQF f11, f30        ; E*F == 0?
    ADDF f27, f27, f5   ; D+E+F
    BFPT division_por_cero

    ; --- QUINTA DIVISIÓN (Ciclo 83) ---
    DIVF f24, f3, f11   ; DIV 5 lanzada en ciclo 83. Termina en el 102.

    ; --- CÁLCULOS FINALES (Mientras DIV 5 termina) ---
    MULTF f28, f26, f27 ; (A+B+C)*(D+E+F) -> Ciclo 84-89 aprox.
    ADDF f25, f20, f21  ; Sumas de los primeros resultados ya listos
    ADDF f25, f25, f22  

    ; El procesador esperará aquí un poco a que DIV 4 y 5 terminen (Stalls inevitables)
    ADDF f29, f23, f24  
    ADDF f25, f25, f29  
    MULTF f31, f25, f28 ; Resultado final en f31

    SF Resultado, f31   ; Guardar
    TRAP 0              ; TERMINAR (Ruta normal)

division_por_cero:
    LF f31, cero
    SF Resultado, f31
    TRAP 0              ; TERMINAR (Ruta error)

