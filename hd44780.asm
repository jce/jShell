; LCD is at DA/DB

creg equ    218 ; control register
dreg equ    219 ; data register

; string given in hl
; to line a
; Writes at the position of the cursor
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

; Clears line a
lcd_clear_line:
    push af
    call lcd_goto_line
    ld c, 20
    ld b, ' '
lcd_clear_line_loop:
    call lcd_wrd        
    dec c
    jr nz, lcd_clear_line_loop    
    pop af
    ret

; goto function in LCD line number
; a - line number
lcd_goto_line:
    cp 0 \ jr z, lcd_goto_line_0
    cp 1 \ jr z, lcd_goto_line_1
    cp 2 \ jr z, lcd_goto_line_2
    ld a, 0x54
    call lcd_goto_ddram
    ret
lcd_goto_line_0:
    ld a, 0x00
    call lcd_goto_ddram
    ret
lcd_goto_line_1:
    ld a, 0x40
    call lcd_goto_ddram
    ret
lcd_goto_line_2:
    ld a, 0x14
    call lcd_goto_ddram
    ret
    
; goto function in LCD DDRAM address
; a - DDRAM address
lcd_goto_ddram:
    or 0b10000000
    ld b, a
    call lcd_wrc
    ret

lcd_clear:
    ld b, 0b00000001    ; Clear display
    call lcd_wrc
    ret

lcd_home:
    ld b, 0b00000010    ; Return home
    call lcd_wrc
    ret

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


