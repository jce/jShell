ctc_addr    .equ    0x88

ctc_uptime:
    sfo 20
    ld de, ctc_s_counter
    push ix
    pop hl
    ;ld (hl), 'h' \ inc hl
    ;ld (hl), '0' \ inc hl
    ;ld (hl), 'i' \ inc hl
    ;ld (hl), 'z' \ inc hl
    ;ld (hl), 'd' \ inc hl
    ;ld (hl), 'c' \ inc hl
    ;ld (hl), '3' \ inc hl
    ;ld (hl), '4' \ inc hl
    push ix
    call uint32tostr_dec
    pop ix
    ld (hl), 0
    push ix
    pop hl
    call sio_prstr

    ;ld hl, (ctc_s_counter+2)
    ;call sio_uint16_hex
    ;ld hl, (ctc_s_counter+0)
    ;call sio_uint16_hex
    ld b, '.'
    call sio_prchr
    ld a, (ctc_ms_counter)
    call sio_uint8_hex_nl
    sfc
    ret

ctc_isr0:
    reti


ctc_isr1:
    dbg 0
    push af
    dbg 1
    ld a, (ctc_ms_counter)
    dbg 2
    inc a
    dbg 3
    cp a, 100
    dbg 4
    ld (ctc_ms_counter), a
    dbg 5
    jp nz, ctc_isr1_end
    dbg 6
    ld a, 0
    dbg 7
    ld (ctc_ms_counter), a
    dbg 8
    ld a, 1
    dbg 9
    ld (ctc_s_flag), a    
    dbg 10

    ld a, (ctc_s_counter+0)
    dbg 11
    inc a
    dbg 12
    ld (ctc_s_counter+0), a
    dbg 13
    jr nz, ctc_isr1_end
    dbg 14

    ld a, (ctc_s_counter+1)
    dbg 15
    inc a
    dbg 16
    ld (ctc_s_counter+1), a
    dbg 17
    jr nz, ctc_isr1_end
    dbg 18

    ld a, (ctc_s_counter+2)
    dbg 19
    inc a
    dbg 20
    ld (ctc_s_counter+2), a
    dbg 21
    jr nz, ctc_isr1_end
    dbg 22

    ld a, (ctc_s_counter+3)
    dbg 23
    inc a
    dbg 24
    ld (ctc_s_counter+3), a
    dbg 25
ctc_isr1_end:
    dbg 26
    pop af
    dbg 27
    ei
    dbg 28
    reti

ctc_isr2:
    reti

ctc_isr3:
    reti

ctc_init:
    ; Init ctc0
    ld a, 0x08   ; Vector offset is 0x08
    out (ctc_addr), a

    ld a, 0b00110101    ; ctc0 will be timer, 256 prescaler, rising edge, automatic, time follows, sw reset, control
    out (ctc_addr), a
    ;ld a, 18            ; timer value of 18 -> 1600 Hz
    ld a, 1            ; timer value of 18 -> 1600 Hz
    out (ctc_addr), a

    ; init ctc1
    ld a, 0b11010111    ; Enable interrupts, counter mode, rising edge, time constant follows, sw reset, control
    out (ctc_addr+1), a
    ;ld a, 16            ; timer value of 16 -> 100 Hz
    ld a, 1            ; timer value of 16 -> 100 Hz
    out (ctc_addr+1), a

    ld a, 0
    ld hl, 0
    ld (ctc_ms_counter), a
    ld (ctc_s_counter), hl
    ld (ctc_s_counter+2), hl
    ret

ctc_ms_counter: .db 0   ; Counts ms
ctc_s_counter:  .dw 0,0 ; Counts s
ctc_s_flag:     .db 0   ; Set every second
