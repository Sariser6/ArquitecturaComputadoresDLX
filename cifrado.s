.data  
;; INICIO VARIABLES DE ENTRADA Y SALIDA: NO MODIFICAR ORDEN 

MENSAJE:  .asciiz "HOLA MUNDO." 
    .align  4 

MENSAJE_LEN:  .word  0

CLAVE:   .asciiz "GATO" 
    .align  4

CLAVE_LEN:  .word  0

MENSAJE_CIFRADO: .asciiz "***********" 
    .align  4

MENSAJE_DESCIFRADO: .asciiz "***********" 
     .align  4

;; FIN VARIABLES DE E/S 




;MENSAJES POR PANTALLA
STR_CALCULANDO:	.asciiz	"CALCULANDO LONGITUDES:"
.align 4

STR_CIFRANDO:	.asciiz	"CIFRANDO ......"
.align 4

STR_DESCIFRANDO:	.asciiz	"DESCIFRANDO ......"
.align 4

STR_CIFRADO:	.asciiz	"MENSAJE CIFRADO ......"
.align 4

STR_DESCIFRADO:	.asciiz	"MENSAJE DESCIFRADO ......"
.align 4

;;VARIABLES PARA LAS FUNCIONES DE IMRPIMIR POR PANTALLA
PrintFormatLINEA:     .asciiz "%c -> %02x" 
                      .align  4  
PrintPtroFormatLINEA: .word   PrintFormatLINEA 
PrintValueLINEA:      .space  8 

PrintFormatLINEA2:     .asciiz "%02x %c -> %02x %c -> %02x" 
PrintPtroFormatLINEA2: .word   PrintFormatLINEA2
PrintValueLINEA2:      .space  8 

PrintFormatLN:         .asciiz "\n" 
   .align  4 
PrintFormatESPACIO: .asciiz " " 
   .align  4 
PrintPtroCADENA:  .word  0 
PrintPtroLN:  .word  PrintFormatLN 
PrintPtroESPACIO: .word  PrintFormatESPACIO 

PrintFormatCHAR: .asciiz  "%c" 
  .align 4 
PrintPtroCHAR: .word PrintFormatCHAR 
PrintValueCHAR: .space 4 

PrintFormatDEC: .asciiz  "%d" 
  .align 4 
PrintPtroDEC: .word PrintFormatDEC 
PrintValueDEC: .space 4 

PrintFormatHEX: .asciiz   "%02x" 
  .align   4 
PrintPtroHEX: .word     PrintFormatHEX 
PrintValueHEX: .space   4 


.text
.global main

main:

;;A ==> Obtener la longitud de las cadenas MENSAJE y CLAVE y almacenarla en MENSAJE_LEN y CLAVE_LEN. 
  
	ADDI r30,r0,STR_CALCULANDO		
	JAL printCADENA
	JAL print_LN

	ADDI r1,r0,0		; indice = 0

loop_mensaje:
	ADDI r10,r0, MENSAJE	; Cargamos la direccion base
	ADD r10,r10,r1			; suma el indice
	LB r2,0(r10)			; Cargamos el byte
	BEQZ r2,fin_mensaje		;si es \0, terminamos
	ADDI r1,r1,1			; indice + 1
	J loop_mensaje

fin_mensaje:
	SW MENSAJE_LEN,r1	;guardamos la longitud en MENSAJE_LEN

	;;MOSTRAMOS: "HOLA MUNDO. 11"
	ADDI r30,r0,MENSAJE		
	JAL printCADENA
	JAL print_ESPACIO

	LW r30, MENSAJE_LEN

	JAL printDEC
	JAL print_LN


	;;CALCULAR LONGITUD DE LA CLAVE
	ADDI r1,r0,0		; indice = 0

loop_clave:
	LB r2, CLAVE(r1)	;cargarmos el byte en la posicion indice
	BEQZ r2,fin_clave	;si es \0, terminamos
	ADDI r1,r1,1		; indice + 1
	J loop_clave

fin_clave:
	SW CLAVE_LEN,r1		;guardamos la longitud en CLAVE_LEN


	;;MOSTRAMOS: "GATO. 4"
	ADDI r30,r0,CLAVE		
	JAL printCADENA
	JAL print_ESPACIO

	LW r30, CLAVE_LEN

	JAL printDEC
	JAL print_LN



;;B ==>  Cifrar la cadena MENSAJE con la CLAVE empleando el cifrado xor carácter a carácter 
;;y almacenar el resultado en MENSAJE_CIFRADO. 
	ADDI r30,r0,STR_CIFRANDO	
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0		; indice mensaje = 0
	ADDI r17,r0,0		; indice clave = 0
	
	LW r18, CLAVE_LEN	; cargamos la longitud de clave en el registro 7
	LW r19, MENSAJE_LEN	; r9 = contador de caracteres restantes


loop_cifrado:
	BEQZ r19,fin_cifrado	;si es \0, terminamos

	ADDI r10,r0, MENSAJE	
	ADD r10,r10,r16
	LB r4, 0(r10) 
	
	ADDI r11,r0, CLAVE	
	ADD r11,r11,r17	
	LB r5, 0(r11) 

	XOR r6,r4,r5		;XOR entre ambos caracteres

	;Guardamos en MENSAJE_CIFRADO
	ADDI r12,r0, MENSAJE_CIFRADO	;guardamos en MENSAJE_CIFRADO
	ADD r12,r12,r16
	SB 0(r12), r6

	
	;;MOSTRAMOS: "H -> 48 G -> 48 0f"
	ADDI r30,r4,0		
	JAL printLINEA		;imprime "H -> 48"
	JAL print_ESPACIO

	ADDI r30,r5,0		
	JAL printLINEA		;imprime "G -> 47"
	JAL print_ESPACIO

	ADDI r30,r6,0		
	JAL printHEX		;imprime "0f"
	JAL print_LN

	ADDI r16,r16,1		; indice mensaje + 1
	ADDI r17,r17,1		; indice clave + 1
	SUBI r19,r19,1		; decrementamos contador

	;resetear indice de clave si llegamos al fin_clave	
	SUB r8,r17,r18			; r8 = indice_clave - longitud_clave
	BNEZ r8, loop_cifrado	; si no es 0, seguimos
	ADDI r17,r0,0			;si es 0, reseteamos el indice de la clave

	J loop_cifrado


fin_cifrado:

	;Escribimos el \0 al final para que printCADENA FUNCIONES
	;;MOSTRAMOS MENSAJE CIFRADO COMPLETO
	ADDI r30,r0,STR_CIFRADO		
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0
	LW r19,MENSAJE_LEN

loop_print_cifrado:
	BEQZ r19,fin_print_cifrado
	ADDI r10,r0, MENSAJE_CIFRADO
	ADD r10,r10,r16

	LB r30,0(r10)	

	JAL printHEX
	JAL print_ESPACIO

	ADDI r16,r16,1
	SUBI r19,r19,1

	J loop_print_cifrado

fin_print_cifrado:
	JAL print_LN

	ADDI r30,r0,MENSAJE
	JAL printCADENA
	JAL print_LN


;;C ==>  Cifrar la cadena MENSAJE_CIFRADO con la CLAVE empleando el cifrado xor carácter a carácter y 
;;almacenar el resultado en MENSAJE_DESCIFRADO. 
	ADDI r30,r0,STR_DESCIFRANDO	
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0		; indice mensaje = 0
	ADDI r17,r0,0		; indice clave = 0
	
	LW r18, CLAVE_LEN	; cargamos la longitud de clave en el registro 7
	LW r19, MENSAJE_LEN	; r9 = contador de caracteres restantes

loop_descifrado:
	BEQZ r19,fin_descifrado	;si es \0, terminamos


	;CARGAR DEL MENSAJE_CIFRADO
	ADDI r10,r0, MENSAJE_CIFRADO	;cargamos de MENSAJE_CIFRADO
	ADD r10,r10,r16	
	LB r4, 0(r10)

	;CARGAR DE LA CLAVE
	ADDI r11,r0, CLAVE	;cargamos de CLAVE
	ADD r11,r11,r17	
	LB r5, 0(r11)	
	
	XOR r6,r4,r5		;XOR entre ambos caracteres

	;GUARDAR EN MENSAJE_DESCIFRADO
	ADDI r12,r0, MENSAJE_DESCIFRADO	;guardamos en CLAVE
	ADD r12,r12,r16	
	SB 0(r12),r6
	
	;;MOSTRAMOS: "H -> 48 G -> 48 0f"
	ADDI r30,r4,0		
	JAL printHEX		;imprime byte cifrado
	JAL print_ESPACIO

	ADDI r30,r5,0		
	JAL printLINEA		;imprime "G -> 47"
	JAL print_ESPACIO

	ADDI r30,r6,0		
	JAL printLINEA		;imprime "H -> 48"
	JAL print_LN

	ADDI r16,r16,1		; indice mensaje + 1
	ADDI r17,r17,1		; indice clave + 1
	SUBI r19,r19,1		;decrementamos contador

	;resetear indice de clave si llegamos al fin_clave	
	SUB r8,r17,r18			; r8 = indice_clave - longitud_clave
	BNEZ r8, loop_descifrado	; si no es 0, seguimos
	ADDI r17,r0,0			;si es 0, reseteamos el indice de la clave

	J loop_descifrado

fin_descifrado:

	;Escribimos el \0 al final para que printCADENA FUNCIONES
	ADDI r12,r0, MENSAJE_DESCIFRADO
	ADD r12,r12,r16
	SB 0(r12),r0		;Escribimos byte 0


	;;MOSTRAMOS MENSAJE DESCIFRADO COMPLETO
	ADDI r30,r0,STR_DESCIFRADO		
	JAL printCADENA
	JAL print_LN

	ADDI r30,r0,MENSAJE_DESCIFRADO	
	JAL printCADENA
	JAL print_LN

	TRAP 0 ; Finaliza la ejecución 




;; ===============================================
;;		FUNCIONES AUXILIARES DE TRAP 5
;; ===============================================
; printLINEA: R30 el valor para sacar en ASCII y HEX 
;Modifica R14 

printLINEA: 
	SW  PrintValueLINEA,r30 
	SW  PrintValueLINEA+4,r30 
	ADDI  r14,r0,PrintPtroFormatLINEA 
	TRAP  5 
	JR  r31 

; printCADENA: En R30 la dir de la cadena a imprimir
printCADENA: 
	SW PrintPtroCADENA,r30 
	ADDI  r14,r0,PrintPtroCADENA 
	TRAP  5 
	JR  r31 
 
print_LN:  
	ADDI  r14,r0,PrintPtroLN 
	TRAP  5  
	JR  r31 
 
print_ESPACIO:  
	ADDI  r14,r0,PrintPtroESPACIO 
	TRAP  5  
	JR  r31 

; printCHAR: En R30 el caracter a imprimir 
printCHAR: 
	SW  PrintValueCHAR,r30 
	ADDI  r14,r0,PrintPtroCHAR 
	TRAP  5 
	JR  r31 

;printDEC: En R30 el caracter a imprimir 
printDEC: 
	SW PrintValueDEC,r30 
	ADDI  r14,r0,PrintPtroDEC 
	TRAP  5 
	JR  r31 

; printHEX: En R30 el caracter a imprimir 
printHEX: 
	SW PrintValueHEX,r30 
	ADDI  r14,r0,PrintPtroHEX 
	TRAP  5 
	JR  r31 























