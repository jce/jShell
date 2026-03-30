; ==========================================================================
; Paint function fills the grb buffer
;Draw a stargate: 10 rotating lobes of altering color and rotation direction
neo_paint_sg:
    call calc_dt
    call neo_sg_calc_shift
    call neo_sg_calc_pos

    ld a, (sg_pos) \ add 256/6*0 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 0 \ call neo_grb_pixel
    ld a, (sg_pos) \ add 256/6*1 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 1 \ call neo_grb_pixel
    ld a, (sg_pos) \ add 256/6*2 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 2 \ call neo_grb_pixel
    ld a, (sg_pos) \ add 256/6*3 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 3 \ call neo_grb_pixel
    ld a, (sg_pos) \ add 256/6*4 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 4 \ call neo_grb_pixel
    ld a, (sg_pos) \ add 256/6*5 \ call sin \ call dim \ ld c, a \ ld b, 0 \ ld a, 5 \ call neo_grb_pixel

    ld ix, neo_grb
    ld iy, neo_grb+6*3
    ld b, 54*3
grb_copy_loop:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop     
    ret

; Calculate the dimming of the led. 
; in: a = undimmed intensity
; out a = dimmed intensity
dim:
    push de
    push hl
    ld d, 0
    ld e, a
    ld a, (neo_bright)
    call Mul8       ; HL=A*DE
    ld a, h
    pop hl
    pop de
    ret

neo_sg_calc_pos:
    ld a, (sg_shift) \ ld b, a
    ld a, (sg_pos)
    add b
    ld (sg_pos), a
    ret
sg_pos: .db 0   ; position 0-0xff

neo_sg_calc_shift:
    ld a, (dt)
    ld d, 0
    ld e, a
    ld a, (sg_speed)
    call Mul8   ; HL=DE*A
    ld (sg_shift), hl
    ret
sg_shift:   .dw 0       ; Shift to do in the next animation step
sg_speed:   .db 0x04    ; Speed of movement

calc_dt:
    push bc
    ld a, (prev_ms) \ ld b, a
    ld a, (ctc_ms_coun_ff)
    ld (prev_ms), a
    sub b
    ld (dt), a
    pop bc
    ret
dt: .db 0       ; dt, time difference [10 ms]
prev_ms: .db 0  ; ms coun ff at the previous consult
