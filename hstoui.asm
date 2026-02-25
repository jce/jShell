; Hexadecimal string of hexadecimal number to uint8
; hl - pointer to first character of null terminated input string

; Convert four characters in a string to uint16
; hl contains the string pointer
; de contains the result value
hstoui16:
    ld de, 0            ; Result registers
    push af
    push hl
    push bc
hstoui16_loop:
    ld a, (hl)          ; Read character
    inc hl              ; Increment character pointer
    call hstoui4        ; Translate character to [0-16], result in a
    ld b, a
    and 16              ; If 16
    jr nz, hstoui16_end ; Go to end. Finished conversion.
    sla e \ rl d        ; Shift result value 4 bits left
    sla e \ rl d
    sla e \ rl d
    sla e \ rl d        
    ld a, b
    add e               ; Add the new value at the right
    ld e, a
    jr hstoui16_loop
hstoui16_end:
    pop bc
    pop hl
    pop af
    ret

; Half byte version
; a - input character
; a - output value [0-16], 16 signals invalid character
hstoui4:
    cp '0'
    jp c, hstoui4_end
    cp ':'
    jp c, hstoui4_09
    cp 'A'
    jp c, hstoui4_end
    cp 'G'
    jp c, hstoui4_AF
    cp 'a'
    jp c, hstoui4_end
    cp 'g'
    jp c, hstoui4_af
hstoui4_end:
    ld a, 16            ; value of 16 signals invalid character
    ret
hstoui4_09:
    sub 48
    ret
hstoui4_AF:
    sub 55
    ret
hstoui4_af:
    sub 87
    ret 

  
; Convert two characters in a string to uint8
; hl contains the string pointer
; a contains the hexadecimal value
;hstoui8:
;    push bc
;    ld a, (hl)
;    or a
;    jr z, hstoui8_end; end line encountered, return 0
;    call hstoui4    ; convert first character
;    ld b, a
;    inc hl
;    ld a, (hl)
;    or a
;    jr z, hstoui8_2_end; end of line encountered, return a
;    call hstoui4    ; convert the second character
;    sla b
;    sla b
;    sla b
;    sla b
;    add b           ; add the first digit <4
;hstoui8_end:
;    pop bc
;    ret             ; return a
;hstoui8_2_end:      ; a was overwritten
;    ld a, b
;    jp hstoui8_end
