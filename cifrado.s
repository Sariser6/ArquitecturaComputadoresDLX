.data  
;; Inicio variables de entrada y salida

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

;; Fin variables de E/S


;; Mensajes por pantalla
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

;; Variables para las funciones de salida por pantalla
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

;; A ==> Obtener la longitud de las cadenas MENSAJE y CLAVE y almacenarla en MENSAJE_LEN y CLAVE_LEN. 
  
	ADDI r30,r0,STR_CALCULANDO		
	JAL printCADENA
	JAL print_LN

	; Calculamos la longitud del mensaje
	ADDI r1,r0,0		; Indice = 0

loop_mensaje:
	LB r2, MENSAJE(r1) 		; Cargamos el byte en la posicion del indice 
	BEQZ r2, fin_mensaje 	; Si es \0, terminamos
	ADDI r1,r1,1			; Indice + 1
	J loop_mensaje

fin_mensaje:
	SW MENSAJE_LEN,r1	; Guardamos la longitud en MENSAJE_LEN

	; Mostramos: "HOLA MUNDO. 11"
	ADDI r30,r0,MENSAJE		
	JAL printCADENA
	JAL print_ESPACIO

	LW r30, MENSAJE_LEN

	JAL printDEC
	JAL print_LN


	; Calculamos la longitud de la clave
	ADDI r1,r0,0		; Indice = 0

loop_clave:
	LB r2, CLAVE(r1)	; Cargarmos el byte en la posicion indice
	BEQZ r2,fin_clave	; Si es \0, terminamos
	ADDI r1,r1,1		; Indice + 1
	J loop_clave

fin_clave:
	SW CLAVE_LEN,r1		; Guardamos la longitud en CLAVE_LEN


	; Mostramos: "GATO. 4"
	ADDI r30,r0,CLAVE		
	JAL printCADENA
	JAL print_ESPACIO

	LW r30, CLAVE_LEN

	JAL printDEC
	JAL print_LN



;; B ==>  Cifrar la cadena MENSAJE con la CLAVE empleando el cifrado xor carácter a carácter 
;;			y almacenar el resultado en MENSAJE_CIFRADO. 
	ADDI r30,r0,STR_CIFRANDO	
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0		; Indice mensaje = 0
	ADDI r17,r0,0		; Indice clave = 0
	
	LW r18, CLAVE_LEN	; Cargamos la longitud de clave en el registro 7
	LW r19, MENSAJE_LEN	; r19 = contador de caracteres restantes


loop_cifrado:
	BEQZ r19,fin_cifrado	; Si es 0, terminamos

	LB r4, MENSAJE(r16)
	
	LB r5, CLAVE(r17) 

	XOR r6,r4,r5		; XOR entre ambos caracteres

	; Guardamos en MENSAJE_CIFRADO
	SB MENSAJE_CIFRADO(r16), r6
	
	; Mostramos: "H -> 48 G -> 48 0f"
	ADDI r30,r4,0		
	JAL printLINEA		; Imprime "H -> 48"
	JAL print_ESPACIO

	ADDI r30,r5,0		
	JAL printLINEA		; Imprime "G -> 47"
	JAL print_ESPACIO 

	ADDI r30,r6,0		
	JAL printHEX		; Imprime "0f"
	JAL print_LN

	ADDI r16,r16,1		; Indice mensaje + 1
	ADDI r17,r17,1		; Indice clave + 1
	SUBI r19,r19,1		; Decrementamos contador

	; Reseteamos el indice de la clave si llegamos al fin_clave	
	SUB r8,r17,r18			; r8 = indice_clave - longitud_clave
	BNEZ r8, loop_cifrado	; Si no es 0, seguimos
	ADDI r17,r0,0			; Si es 0, reseteamos el indice de la clave

	J loop_cifrado


fin_cifrado:
	; Añadimos el \0 al final del mensaje cifrado
    SB MENSAJE_CIFRADO(r16), r0
	; Mostramos el mensaje cifrado completo
	ADDI r30,r0,STR_CIFRADO		
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0
	LW r19,MENSAJE_LEN

loop_print_cifrado:
	BEQZ r19,fin_print_cifrado

	LB r30, MENSAJE_CIFRADO(r16)	
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


;; C ==>  Cifrar la cadena MENSAJE_CIFRADO con la CLAVE empleando el cifrado xor carácter a carácter y 
;;			almacenar el resultado en MENSAJE_DESCIFRADO. 
	ADDI r30,r0,STR_DESCIFRANDO	
	JAL printCADENA
	JAL print_LN

	ADDI r16,r0,0		; Indice mensaje = 0
	ADDI r17,r0,0		; Indice clave = 0
	
	LW r18, CLAVE_LEN	; Cargamos la longitud de clave en el registro 7
	LW r19, MENSAJE_LEN	; r19 = contador de caracteres restantes

loop_descifrado:
	BEQZ r19,fin_descifrado	; Si es \0, terminamos

	; Cargar el MENSAJE_CIFRADO 
	LB r4, MENSAJE_CIFRADO(r16)

	; Cargar la CLAVE
	LB r5, CLAVE(r17)	
	
	XOR r6,r4,r5		; XOR entre ambos caracteres

	; Guardar en MENSAJE_DESCIFRADO
	SB MENSAJE_DESCIFRADO(r16),r6
	
	; Mostramos: "H -> 48 G -> 48 0f"
	ADDI r30,r4,0		
	JAL printHEX		; Imprime byte cifrado
	JAL print_ESPACIO

	ADDI r30,r5,0		
	JAL printLINEA		; Imprime "G -> 47"
	JAL print_ESPACIO

	ADDI r30,r6,0		
	JAL printLINEA		; Imprime "H -> 48"
	JAL print_LN

	ADDI r16,r16,1		; Indice mensaje + 1
	ADDI r17,r17,1		; Indice clave + 1
	SUBI r19,r19,1		; Decrementamos contador

	; Resetear indice de clave si llegamos al fin_clave	
	SUB r8,r17,r18			; r8 = indice_clave - longitud_clave
	BNEZ r8, loop_descifrado	; Si no es 0, seguimos
	ADDI r17,r0,0			; Si es 0, reseteamos el indice de la clave

	J loop_descifrado

fin_descifrado:
	; Añadimos el \0 al final del mensaje cifrado
    SB MENSAJE_CIFRADO(r16), r0

	; Mostramos el mensaje descifrado completo
	ADDI r30,r0,STR_DESCIFRADO		
	JAL printCADENA
	JAL print_LN

	ADDI r30,r0,MENSAJE_DESCIFRADO	
	JAL printCADENA
	JAL print_LN

	TRAP 0 ; Finaliza la ejecución 


;; Funciones auxiliares de Trap 5
; printLINEA: R30 el valor para sacar en ASCII y HEX 
; Modifica R14 

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


