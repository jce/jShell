ctc_addr    .equ    0x88

ctc_runtime:
    sfo 20
    ld de, ctc_u_counter
    push ix
    pop hl
    call uint32tostr_dec
    ld (hl), 0
    push ix
    pop hl
    call sio_prstr_nl
    sfc
    ret

ctc_uptime:
    sfo 20
    ld de, ctc_s_counter
    push ix
    pop hl
    call uint32tostr_dec
    ld (hl), 0
    push ix
    pop hl
    call sio_prstr_nl
    sfc
    ret

ctc_isr0:
    ei
    reti

ctc_isr1:
    push af
    push ix

    ld a, (ctc_ms_coun_ff)
    inc a
    ld (ctc_ms_coun_ff), a

    ld a, (ctc_ms_counter)
    inc a
    cp a, 100
    ld (ctc_ms_counter), a
    jp nz, ctc_isr1_end
    ld a, 0
    ld (ctc_ms_counter), a
    ld a, 1
    ld (ctc_s_flag), a    
    ld ix, ctc_s_counter
    call ctc_increment
    ld ix, ctc_u_counter
    call ctc_increment
ctc_isr1_end:
    pop ix
    pop af
    ei
    reti

; increments uint32 located at ix
ctc_increment
    ld a, (ix+0)
    inc a
    ld (ix+0), a
    jr nz, ctc_increment_end
    ld a, (ix+1)
    inc a
    ld (ix+1), a
    jr nz, ctc_increment_end
    ld a, (ix+2)
    inc a
    ld (ix+2), a
    jr nz, ctc_increment_end
    ld a, (ix+3)
    inc a
    ld (ix+3), a
ctc_increment_end:
    ret

ctc_isr2:
    ei
    reti

ctc_isr3:
    ei
    reti

ctc_init:
    ; Init ctc0
    ld a, 0x08   ; Vector offset is 0x08
    out (ctc_addr), a

    ld a, 0b00000011    ; ctc0 will be sw reset, control
    out (ctc_addr), a
    ld a, 0b00110101    ; ctc0 will be timer, 256 prescaler, rising edge, automatic, time follows, control
    out (ctc_addr), a
    ld a, 18            ; timer value of 18 -> 1600 Hz
    out (ctc_addr), a

    ; init ctc1
    ld a, 0b00000011    ; sw reset, control
    out (ctc_addr+1), a
    ld a, 0b11010101    ; Enable interrupts, counter mode, rising edge, time constant follows, control
    out (ctc_addr+1), a
    ld a, 16            ; timer value of 16 -> 100 Hz
    out (ctc_addr+1), a

    ld a, 0
    ld hl, 0
    ld (ctc_ms_counter), a
    ld (ctc_s_counter), hl
    ld (ctc_s_counter+2), hl
    ret

ctc_ms_counter: .db 0   ; Counts ms 0 to 99
ctc_ms_coun_ff: .db 0   ; Counts ms 0 to 0xff
ctc_s_counter:  .dw 0,0 ; Counts uptime [s]
ctc_u_counter:  .dw 0,0 ; Counts runtime [s]
ctc_s_flag:     .db 0   ; Set every second
