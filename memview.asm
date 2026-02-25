; Simple memory viewer, i hope to make the same format as SCM.
; Only wider. JCE, 24-2-2026

; View function. hl is the start address, de the length.
view:
    push hl
    add hl, de
    ld de, hl
    pop hl          ; now de is the end address instead of the length

    ; Align to 5 bits (32)
    ld a, l
    and 0b11100000
    ld l, a
    ld a, e
    and 0b11100000
    ld e, a

view_loop:
    call view_line
    ld bc, 0x0020
    add hl, bc
    ld a, l
    cp e
    jr nz, view_loop
    ld a, h
    cp d
    jr nz, view_loop
    ret

; Routine to draw one line
; hl contains the line start address
view_line: 
    push hl
    push de
    push hl

    call sio_uint16_hex
    ld b, ':'
    call sio_prchr

    ld d, 0x20
view_line_loop:
    ld a, l
    and 0b00000111
    jr nz, view_line_pass
    ld b, ' '
    call sio_prchr
view_line_pass:
    ld b, ' '
    call sio_prchr
    ld a, (hl)
    inc hl
    call sio_uint8_hex
    dec d
    jr nz, view_line_loop
    pop hl

    ld b, ' '
    call sio_prchr

    ld d, 0x20
view_line_loop_char:
    ld a, (hl)
    inc hl
    call view_char
    dec d
    jr nz, view_line_loop_char
    ld b, 13
    call sio_prchr
    ld b, 10
    call sio_prchr

    pop de
    pop hl
    ret

; a contains the byte. Display as ascii or '.' if not displayable.
view_char:
    cp 0x20
    jr c, view_char_nonascii
    cp 0x7f
    jr c, view_char_ascii
view_char_nonascii:
    ld a, '.'
view_char_ascii:
    ld b, a
    call sio_prchr
    ret
