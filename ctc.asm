ctc_addr    .equ    0x88

ctc_uptime:
    ld hl, (ctc_s_counter+2)
    call sio_uint16_hex
    ld hl, (ctc_s_counter+0)
    call sio_uint16_hex
    ld b, '.'
    call sio_prchr
    ld a, (ctc_ms_counter)
    call sio_uint8_hex_nl
    ret

ctc_isr0:
    reti

ctc_isr1:
    push af
    ld a, (ctc_ms_counter)
    inc a
    cp a, 100
    ld (ctc_ms_counter), a
    jr nz, ctc_isr1_end
    ld a, 0
    ld (ctc_ms_counter), a
    ld a, 1
    ld (ctc_s_flag), a    

    ld a, (ctc_s_counter+0)
    inc a
    ld (ctc_s_counter+0), a
    jr nz, ctc_isr1_end

    ld a, (ctc_s_counter+1)
    inc a
    ld (ctc_s_counter+1), a
    jr nz, ctc_isr1_end

    ld a, (ctc_s_counter+2)
    inc a
    ld (ctc_s_counter+2), a
    jr nz, ctc_isr1_end

    ld a, (ctc_s_counter+3)
    inc a
    ld (ctc_s_counter+3), a
ctc_isr1_end:
    pop af
    ei
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
    ld a, 18            ; timer value of 18 -> 1600 Hz
    out (ctc_addr), a

    ; init ctc1
    ld a, 0b11010111    ; Enable interrupts, counter mode, rising edge, time constant follows, sw reset, control
    out (ctc_addr+1), a
    ld a, 16            ; timer value of 16 -> 100 Hz
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
