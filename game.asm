;==============================================================================
; Definitions of registers, etc. ("constants")
;==============================================================================
.EQU RESET        = 0x0000
.EQU PM_START     = 0x0056
.EQU NO_KEY       = 0x0F
.EQU CONVERT      = 0x30
.DEF TEMP         = R16
.DEF RVAL         = R24
.DEF LVAL         = R17
.DEF CHOICE       = R20
.DEF counter      = R18
.DEF randomNumber = R19

.INCLUDE "delay.inc"
.INCLUDE "lcd.inc"

;==============================================================================
; Start of program
;==============================================================================
.CSEG
.ORG RESET
    RJMP init
.ORG PM_START

;==============================================================================
; Basic initializations of stack pointer, I/O pins, etc.
;==============================================================================
init:
    ; Initialize stack pointer
    LDI TEMP, LOW(RAMEND)
    OUT SPL, TEMP
    LDI TEMP, HIGH(RAMEND)
    OUT SPH, TEMP
    ; Initialize pins
    CALL init_pins
    ; Initialize LCD
    CALL lcd_init
    ; Initialize random number generator
    CALL init_random
    ; Jump to main program
    RJMP main

;==============================================================================
; Initialize I/O pins
;==============================================================================
init_pins:
  SBI DDRD, 6
	SBI DDRD, 7
	CBI DDRE, 6

	LDI TEMP, 0xFF
	OUT DDRF, TEMP
	OUT DDRB, TEMP

	RET

	LDI TEMP, 0x80	 		
	OUT DDRC, TEMP	 		
		
	LDI TEMP, 0xf0	 		
	OUT DDRF, TEMP	 		

	
	SBI DDRD, 6			; Utgångar för port 6 i med att vi vill reglera rs signaaler
 	SBI DDRD, 7			; utgångar f ör port 7 i med att vi vill reglera enable signlar
	RET		 

;==============================================================================
; Initialize "random" number generator
;==============================================================================
init_random:
    LDI counter, 0x00  ; Reset counter
    RET

;==============================================================================
; Main program loop
;==============================================================================
main:
    CALL lcd_init          ; Initialize LCD for each round
    LDI R24, 'G'
    CALL lcd_write_chr
    RJMP keyboard_main

keyboard_main:
    CALL scan_keyboard    
    CPI RVAL, randomNumber  
    BREQ correct_guess
    RJMP wrong_guess

;==============================================================================
; Generate a new "random" number based on counter
;==============================================================================
update_random:
    INC counter          ; Increment counter on each key press
    ANDI counter, 0x0F   ; Keep counter within 0-9
    MOV randomNumber, counter  ; Use counter as the new "random" number
    RET

;==============================================================================
; Actions on correct guess
;==============================================================================
correct_guess:
    CALL lcd_clear
    LDI msg_pos, 0x00  ; starting position of message on LCD
    LDI R24, 'C'
    CALL lcd_write_chr
    LDI R24, 'o'
    CALL lcd_write_chr
    LDI R24, 'r'
    CALL lcd_write_chr
    LDI R24, 'r'
    CALL lcd_write_chr
    LDI R24, 'e'
    CALL lcd_write_chr
    LDI R24, 'c'
    CALL lcd_write_chr
    LDI R24, 't'
    CALL lcd_write_chr
    LDI R24, '!'
    CALL lcd_write_chr
   
    CALL init_random
    CALL delay_long
    RJMP main

;==============================================================================
; Actions on wrong guess
;==============================================================================
wrong_guess:
    CALL lcd_clear
    LDI msg_pos, 0x00  ; Starting position of message on LCD
    LDI R24, 'W'
    CALL lcd_write_chr
    LDI R24, 'r'
    CALL lcd_write_chr
    LDI R24, 'o'
    CALL lcd_write_chr
    LDI R24, 'n'
    CALL lcd_write_chr
    LDI R24, 'g'
    CALL lcd_write_chr
    LDI R24, '!'
    CALL lcd_write_chr
    CALL delay_long
    RJMP keyboard_main

;==============================================================================
; Keyboard scan routine
;==============================================================================
scan_keyboard:
    ; Keyboard scanning code here
    RET

;==============================================================================
; Delay routine for longer waits
;==============================================================================
delay_long:
    LDI R16, 8      
    LDI R17, 250   
delay_loop:
    PUSH R16        
    MOV R18, R17    
    CALL delay_ms   
    POP R16         
    DEC R16         
    BRNE delay_loop 
    RET             
