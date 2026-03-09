
; ===================================================
; divide 224 over 32 bins around given value (7 per bin)
; around: from bin -16 to + 15
; b - bin/item in the center [16-240]
rain_in_bins:
    push bc
    ld a, b
    sub 16
    ld b, a
    ld c, 32
rain_loop:
    ld a, 7
    call pwm_bin_to_value
    inc b
    dec c
    jp nz, rain_loop
    pop bc
    ret    

; ============== divides 256 bins over leds ===========
; a - value to add
; b - binitem [0-255], a pwmvalue [0-255]
pwm_bin_to_value:
    push bc
    srl b
    srl b
    srl b
    srl b
    srl b
    call pwm_item_to_value
    pop bc
    ret

; ===============add pwm data item b to a ============
; a - value to add
; b - led to add the value to
pwm_item_to_value:
    push ix
    push bc
    ld c, a
    ld a, b
    and a
    ld ix, pwmdata
pwm_item_next_index:
    jr z, pwm_item_found_index
    inc ix
    dec a
    jr pwm_item_next_index    

pwm_item_found_index:
    ld a, (ix)
    add c
    ld (ix), a
    pop bc
    pop ix
    ret

; ============ zero all pwm data =====================
zero_pwm_data:
    push af
    push bc
    push ix
    ld b, 8
    ld a, 0
    ld ix, pwmdata
zero_pwm_data_loop:
    ld (ix), a
    inc ix
    djnz zero_pwm_data_loop
    pop ix
    pop bc
    pop af
    ret


; =================== PWM Routine =====================
pwmdata:
    db 1,1,1,1,1,1,1,1

f_pwm:
    push af
    push bc
    push de
    push hl
    ld c, 0     ; PWM counter
loop_pwm:
    ld d, 8     ; led counter
    ld e, 0     ; output byte
    ld hl, pwmdata
loop_led:
    ld b, (hl)  ; b = pwm value for this led
    inc hl
    ld a, c
    cp b        ; e.bit[led] = b < c
    jp nc, pwm_pass
    set 0, e
pwm_pass:
    rrc e
    dec d
    jp nz, loop_led
    ld a, e
    out (00), a
    inc c
    jp nz, loop_pwm

    pop hl
    pop de
    pop bc
    pop af
    ret
; =================== PWM Routine =====================

