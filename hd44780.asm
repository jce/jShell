; LCD is at DA/DB

creg equ    218 ; control register
dreg equ    219 ; data register

lcd_init:
    ld hl, 15
    call delay_ms
    ld a, 0b00111000
    out(creg), a
    ld hl, 5
    call delay_ms
    out(creg), a
    ld hl, 1
    call delay_ms
    out(creg), a
    ld hl, 5
    call delay_ms
    ld a, 0b00111000    ; Function 8 bit, 2 lines, 5x8 dot
    out(creg), a
    ld hl, 5
    call delay_ms
    ld a, 0b00001100    ; Display on, cursor off, no blink
    out(creg), a
    ld hl, 5
    call delay_ms
    ld a, 0b00000001    ; Clear display
    out(creg), a
    ret    

; writes character b to lcd data register
lcd_wrd:
    in a, (creg)
    bit 7, a
    jr nz, lcd_wrd
    ld a, b
    out(dreg), a
    ret

; writes character b to lcd control register
lcd_wrc:
    in a, (creg)
    bit 7, a
    jr nz, lcd_wrc
    ld a, b
    out(creg), a
    ret

lcd_clear:
    ld b, 0b00000001    ; Clear display
    call lcd_wrc
    ret

; string given in hl
lcd_write_string:
    push hl
    push af
lcd_write_string_begin:
    ld a, (hl)
    or a
    jr z, lcd_write_string_done
    ld b, a
    call lcd_wrd
    inc hl
    jr lcd_write_string_begin
lcd_write_string_done:
    pop af
    pop hl
    ret



