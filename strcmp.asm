; compare two strings.
; de - string 1
; hl - string 2
; a - destroyed
; zero flag is set if equal
strcmp:
    push de
    push hl
strcmp_loop:
    ld a, (de)          ; Find out if the first character of string de
    or a                ; is 0
    jr z, strcmp_onenull;
    cp (hl)             ; Compare the first character of de to the first of hl
    jr nz, strcmp_return_not_equal ; Return if not equal. Zero flag is cleared
    inc de              ; Increment the de pointer
    inc hl              ; Increment the hl pointer
    jr strcmp_loop      ; Restart the routine.                  

strcmp_onenull:         ; The first character of de was 0 Still compare to
    ld a, (hl)          ; the first character of hl.
    or a                ; Zero flag is set if they are equal.
    pop hl
    pop de
    ret

strcmp_return_not_equal:
    pop hl
    pop de
    ret
