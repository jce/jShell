; Rotating tape reel animation. Divides the circle in 240 points, each 4 points are for one LED.
; Deposits some activation in some points, logic is per point instead of per LED.
neo_paint_dtape2:
    ld a, (alarm)
    or a
    jp nz, neo_paint_d_alarm

    call calc_dt
    call neo_drodo_calc_shift
    call neo_drodo_calc_pos
    call neo_drodo_calc_color
    call neo_drodo_scale_brightness

    ; Calculate the limits for q1
    ; d = start/high/on
    ; e = end/low/off
    ld a, (neo_drodo_pos)   ; a is [0-239]
    cp 120                  ; while a > 120
    jr c, drodo_pos_60_continue
    sub a, 120;             ; a -= 120
drodo_pos_60_continue:      ; a is [0-119]
    ld d, a                 ; d is the start
    add a, 60               ; add 60 to a
    ld e, a                   ; e is the end
    cp 120                  ; a >= 120 ?
    jr nc, drodo_inverted   ; e < d 
    jr drodo_straight       ; e >= d

drodo_straight:
    ld a, d
    ld b, e
    call dtape_linesec
    jr dtape2_end

drodo_inverted:
    ld a, e
    sub 120
    ld e, a

    ld a, 0
    ld b, e

    call dtape_linesec
    ld a, 120
    ld b, a
    ld a, d
    call dtape_linesec
    jr dtape2_end

dtape2_end:
    ld hl, neo_grb
    ld de, neo_grb + 3 * 60 / 2;
    ld bc, 3 * 60 / 2
    ldir
    ret

neo_paint_dtape3:
    call neo_paint_dtape2

neo_paint_dtape4:
    call neo_paint_dtape2

neo_paint_dtape5:
    call neo_paint_dtape2

neo_paint_dtape6:
    call neo_paint_dtape2

 




dtape_linesec:
; Draws a line section on the 240 virtual pixels.
; Input a - Start pixel (included) (trashed)
; Input b - End pixel (omitted) (preserved)
    push bc
dtape_linesec_loop:
    cp b                    ; compare a with b
    jr nz, dtape_linesec_continue ; a == b?
    pop bc
    ret                     ; return
dtape_linesec_continue:
    ld c, a                 ; Store a
    srl a \ srl a           ; a / 4
    call neo_grb_pixel3     ; paint pixel a
    ld a, c                 ; Remember a
    inc a                   ; increment a
    jr dtape_linesec_loop   ; continue
