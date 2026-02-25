; delay that takes hl milliseconds
; overwrites a
delay_ms:
    ld a, h
    or l
    ret z
    call delay
    dec hl
    jr delay_ms

; delay that takes 1 ms to run
; overwrites a
delay:
    push hl

    ld hl, 220
delay_1_ms_loop:
    ld a, h
    or l
    jr z, delay_1_ms_loop_end
    dec hl
    jr delay_1_ms_loop
delay_1_ms_loop_end:

    pop hl
    ret

