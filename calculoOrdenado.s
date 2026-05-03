.data  
;; INICIO VARIABLES DE ENTRADA Y SALIDA: NO MODIFICAR ORDEN 
A:				.float		10.0
B:				.float		20.0
C:				.float		30.0
D:				.float		40.0
E:				.float		50.0
F:				.float		60.0

Resultado:		.float		0

;; FIN VARIABLES DE E/S 


cero:			.float 		0.0

.text
.global main

main:

	;; CARGAMOS LOS VALORES EN LOS REGISTROS FLOTANTES
	LF f0, A 	; f0 = A
	LF f1, B 	; f1 = B
	LF f2, C 	; f2 = C
	LF f3, D 	; f3 = D
	LF f4, E 	; f4 = E
	LF f5, F 	; f5 = F


	; COMPROBAMOS DIVISIONES POR 0 (EN CASO DE QUE SEA VERDADERA, SALTAMOS A DIVISION POR 0)
	LF f30, cero

	EQF f5, f30		; comprueba si F == 0
	BFPT division_por_cero

	EQF f4, f30		; comprueba si E == 0
	BFPT division_por_cero

	EQF f3, f30		; comprueba si D == 0
	BFPT division_por_cero



	;A*B*C PARA EL DENOMINADOR DE E/(A*B*C)
	MULTF f10, f0, f1	; f10 = A*B
	MULTF f10, f10, f2	; f10 = A*B*C

	EQF f10, f30		; comprueba si A*B*C == 0
	BFPT division_por_cero


	;E*F PARA EL DENOMINADOR DE D/(E*F)
	MULTF f11, f4, f5	; f11 = E*F

	EQF f11, f30		; comprueba si E*F == 0
	BFPT division_por_cero

	; A/F
	DIVF f20,f0,f5		; f20 = A/F

	;MIENTRAS SE CALCULA A/F, HACEMOS LAS SUMAS INDEPENDIENTES
	; CALCULAMOS (A+B+C)
	ADDF f26,f0,f1		; f26 = A + B
	ADDF f26,f26,f2		; f26 = A + B + C

	; CALCULAMOS (D+E+F)
	ADDF f27,f3,f4		; f27 = D + E
	ADDF f27,f27,f5		; f27 = D + E + F

	; CALCULAMOS (A+B+C) * (D+E+F)
	MULTF f28,f26,f27	; f28 = (A+B+C) * (D+E+F)


	; TRAS HACER TODO LO ANTERIOR, LA DIVISION YA ESTARÁ LIBRE
	; B/E
	DIVF f21,f1,f4		; f21 = B/E


	; C/D
	DIVF f22,f2,f3		; f22 = C/D

	; CALCULAMOS E/(A*B*C)
	DIVF f23,f4,f10		; f23 = E/(A*B*C)

	; CALCULAMOS D/(E*F)
	DIVF f24,f3,f11		; f24 = D/(E*F)


	;SUMAMOS LOS 5 TERMINOS ANTERIORES
	ADDF f25,f20,f21	; f25 = A/F + B/E
	ADDF f25,f25,f22	; f25 = + C/D
	ADDF f25,f25,f23	; f25 = + E/(A*B*C)
	ADDF f25,f25,f24	; f25 = + D/(E*F)


	; CALCULAMOS RESULTADO FINAL
	MULTF f31,f25,f28	

	; GUARDAMOS RESULTADO
	SF Resultado, f31


	J fin


division_por_cero:
	; EN CASO DE DIVISION POR 0, RESULTADO = 0
	LF f31, cero
	SF Resultado, f31


fin:
	TRAP 0