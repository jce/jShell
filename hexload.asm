
; Hexload should receive a hexfile on serial port and write it to memory. All within
; a relocatable piece of memory.
; jce, 16-2-2026

;.org 0x9000

; Elaborate tree function, to keep it relocatable.
; a - scratchpad
; b - received character, hex value of 2 characters
; c - state
; d - value of bytepair
; e - crc sum
; hl - scratchpad
; ix - write pointer
; iyh - value of high nibble
; iyl - unused

hexload:
	ld c, 0
	ld e, 0                 ; reset crc sum
hexload_start:

; Blocking get character
hexload_getch:
    ld a, 0					;
    out (0x80), a			;
    in a, (0x80)			;
    bit 0, a                ; Test the SIO if there is a new character
    jr z, hexload_getch     ; No? Back to hexload_getch
    in a, (0x81)            ;
	ld b, a                 ; New character goes to live in b

	ld a, c                 ; test the state
	cp 1                    ; is it 1 or higher?
	jr nc, hexload_pass_1   ; continue to hexload_pass_1

	ld a, b                 ; compare the incoming character
	cp ':'                  ; look for ':'
	jr nz, hexload_start    ; ':' not found, jump back to hexload_start
	inc c                   ; increment state
	jr hexload_start        ; Jump back to hexload_start
	
hexload_pass_1:

	ld a, b					; Translate the character, b, to value
    cp ':'					;
    jr c, hexload_hstoui4_09;
    cp 'G'					;
    jr c, hexload_hstoui4_AF;
hexload_hstoui4_09:			;
    sub 48					;
    jr hexload_pass_1b		;
hexload_hstoui4_AF:			;
    sub 55					;
    jr hexload_pass_1b		;
hexload_pass_1b				;
	ld b, a					; the value goes to live in b, as did the character
	
	bit 0, c				; test state for being even.
	jr z, hexload_pass_1_even_continue	; If even, jump to hexload_pass_1_even_continue
	sla a					; Uneven, we are the high nibble
	sla a					; shift the value to the top nibble	
	sla a					;
	sla a					;
	ld iyh, a				; Store in the unofficial iyh register
	inc c					; Increment the state.
	jr hexload_start		; Jump back to hexload_start. Only even states have a complete byte and continue.

hexload_pass_1_even_continue:
	ld a, iyh				; Retrieve the high nibble from iyh
	or b					; Even state, we continue. Or the previous and this nibble together
	ld b, a					; Store result in b, b is now the full byte
	add a, e				; Add the value to the zero sum crc
	ld e, a					;
	ld a, c					;
	cp 3					; State is 3 or more
	jr nc, hexload_pass_3	; Jump to hexload_pass_3
							; c = 2, record length
	ld d, b					; Store record length
	inc c					; Increment state
	jr hexload_start		; Jump to hexload_start
	
hexload_pass_3:
	cp 5					; State is 5 or more
	jr nc, hexload_pass_5	; Continue to hexload_pass_5
							; c = 4, first byte of address
	ld ixh, b				; Store value in ixh
	inc c					; increment state
	jr hexload_start		; Jump to hexload_start

hexload_pass_5:
	cp 7					; State is 7 or more
	jr nc, hexload_pass_7	; Continue to hexload_pass_7
							; c = 6, second byte address
	ld ixl, b				; Store value in ixl
	inc c					; Increment state
	jr hexload_start		; Jump to hexload_start

hexload_start_2:			; Trampoline for jumping back
	jr hexload_start		; to hexload_start
	
hexload_pass_7:
	cp 9					; State is 9 or more
	jr nc, hexload_pass_9	; Continue to hexload_pass_9
							; c = 8, record type
	ld a, b                 ; Load value in a
	or b					; Test if record type is 00 (data)
    jr nz, hexload_pass_7_end; if not, finished
	inc c					; increment state
	jr hexload_start_2		; Jump to hexload_start

hexload_pass_7_end:
;-----------------------------------------------
	ld a, 'r' 
    out (0x81), a
;-----------------------------------------------
    rst 0

hexload_pass_9:
							; c = 10, 12, 14, ... data!
	ld a, d					;
	or d					; Are we still expecting data?
	jr z, hexload_crc		; If not, jump to hexload_crc

	dec d					;
	ld (ix), b				; Write the data to ram
	inc ix					; Increment write pointer
	inc c
	jr hexload_start_2
	
hexload_crc:
							; We do now expect the crc byte. The special property
	ld a, e					; of this crc is that the sum will be 0.
	or a
	ld e, 0					; The new sum starts out at zero
	ld c, 0					; The new state is zero
	jr z, hexload_ok
;-----------------------------------------------
	ld a, 'e' 
    out (0x81), a
;-----------------------------------------------
	jr hexload_start_2
hexload_ok:
;-----------------------------------------------
	ld a, '.' 
    out (0x81), a
;-----------------------------------------------
    jr hexload_start_2

hexload_end:
