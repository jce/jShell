
; SIOA_D 0x81 SIOA_C 0x80

; print string with newline over serial
; hl - pointer to character string
sio_prstr_nl:
    call sio_prstr
    push hl
    ld hl, sio_newline
    call sio_prstr
    pop hl
    ret
sio_newline:
    .db 13, 10, 0


; print string over serial
; hl - pointer to character string
sio_prstr:
    push af
    push bc
    push de
    push hl
sio_prstr_begin:
    ld a, (hl)
    or a
    jr z, sio_prstr_end
    ld b, (hl)
    call sio_prchr
    inc hl
    jr sio_prstr_begin
sio_prstr_end:
    pop hl
    pop de
    pop bc
    pop af
    ret

; Transmit character on newline over serial
; a - character to transmit
sio_prchr_nl:
    push af
    push bc
    push hl
    ld b, a
    call sio_prchr
    ld hl, sio_newline
    call sio_prstr
    pop hl
    pop bc
    pop af
    ret

; Transmit character over serial
; b - character to transmit
sio_prchr:
    ld a, 0         ; test if transmit buffer is empty
    out(0x80), a
    in a, (0x80)
    bit 2, a
    jr z, sio_prchr

    ld a, b
    out (0x81), a
    ret

; Getchar.
; a - returned char. 0x00 when no char available
; f - zero is set if no char available
sio_getch:
    ld a, 0
    out (0x80), a
    in a, (0x80)
    bit 0, a
    ld a, 0
    ret z    
    in a, (0x81)
    ret

SIO_A_RESET:
    
    ld a, 00110000b     ; Error reset
    out (0x80), a

    ld a, 00011000b     ; Channel reset
    out (0x80), a

    ld a, 4
    out (0x80), a
    ;ld a, 11110101b     ; X64, 1 stop bit, odd parity
    ld a, 11110100b     ; X64, 1 stop bit, no parity. Somehow this works better? No clue what is going on...
    out (0x80), a

    ld a, 1
    out (0x80), a
    ;ld a, 00000000b     ; No interrupts
    ld a, 00011000b     ; Interrupt on all Rx Characters
    out (0x80), a

    ld a, 2
    out (0x82), a
    ld a, 0x02     ; vector: 2      (0x8002)
    out (0x82), a

    ld a, 3
    out (0x80), a
    ld a, 11000001b     ; Rx enable, Rx 8 bits long
    out (0x80), a

    ld a, 5
    out (0x80), a
    ld a, 01101000b     ; Tx enable, Tx 8 bits long
    out (0x80), a
    
    ret

sio_isr:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    call jshell
    ld a, (run_enabled)
    or a
    jr z, sio_isr_disable
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ei
    reti
sio_isr_disable:
    ;di
    reti

; Print hexadecimal uint16_t and newline
sio_uint16_hex_nl:
    push hl
    call sio_uint16_hex
    ld hl, sio_newline
    call sio_prstr
    pop hl
    ret

; print hexadecimal uint16_t
; hl - value to print
sio_uint16_hex:
    push af
    ld a, h
    call sio_uint8_hex
    ld a, l
    call sio_uint8_hex
    pop af
    ret

sio_uint8_hex_nl:
    push af
    push hl
    call sio_uint8_hex
    ld hl, sio_newline
    call sio_prstr
    pop hl
    pop af
    ret

; print hexadecimal uint8_t
; a - value to print
sio_uint8_hex:
    push af
    push de
    push bc
    ld b, a
    srl a
    srl a
    srl a
    srl a
    call sio_uint4_hex
    ld a, b
    and 0x0F
    call sio_uint4_hex
    pop bc
    pop de
    pop af
    ret

; print hexadecimal uint4_t
; a - value [0-15]
; outputs a single char to the sio
sio_uint4_hex:
    push bc
    cp 10
    jp nc, sio_uint4_hex_over10
    add '0'
    ld b, a
    call sio_prchr
    pop bc
    ret
sio_uint4_hex_over10:
    sub 10
    add 'A'
    ld b, a
    call sio_prchr
    pop bc
    ret
