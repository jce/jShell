; Rotating tape reel animation. Divides the circle in 240 points, each 4 points are for one LED.
; Deposits some activation in some points, logic is per point instead of per LED.
neo_paint_dtape .macro &n
    ld a, (alarm)
    or a
    jp nz, neo_paint_d_alarm
    call dtape_common

    ; Calculate the limits for q1
    ; d = start/high/on
    ; e = end/low/off
    ld a, (neo_drodo_pos)   ; a is [0-239]
    ld b, a
    ld a, 240
    sub b                   ; Reverse the rotation direction

dtape_sub_start&n:
    cp 240/&n               ; while a > (240/n) [120, 80, 60, 48, 40]
    jr c, dtape_pos_q1_continue&n
    sub 240/&n;          ; a -= (240/n)
    jr dtape_sub_start&n

dtape_pos_q1_continue&n:    ; a is in q1, 0 - [119, 79, 59, 47, 39]
    ld d, a                 ; d is the start of the line section
    add a, 240/(&n*2)       ; add line section length to a
    ld e, a                 ; e is the end of the line section
    cp 240/&n               ; if a (end) >= q1_end
    jr nc, dtape_inverted&n ; yes: e (end) < d (start) (after wrapping)
    jr dtape_straight&n     ; no: e > d

dtape_straight&n:
    ld a, d
    ld b, e
    call dtape_linesec
    jr dtape_end&n

dtape_inverted&n:
    ld a, e
    sub 240 / &n
    ld e, a
    ld a, 0
    ld b, e
    call dtape_linesec
    ld a, 240 / &n
    ld b, a
    ld a, d
    call dtape_linesec
    jr dtape_end&n

dtape_end&n:
    ld hl, neo_grb
    ld de, neo_grb + 3 * 60 / &n;
    ld bc, 3 * 60 * (&n-1) / &n
    ldir
    ret
    .endm

neo_paint_dtape2:
    neo_paint_dtape 2

neo_paint_dtape3:
    neo_paint_dtape 3

neo_paint_dtape4:
    neo_paint_dtape 4

neo_paint_dtape5:
    neo_paint_dtape 5

neo_paint_dtape6:
    neo_paint_dtape 6

dtape_common:
; Common calls for tape animations.
    call calc_dt
    call neo_drodo_calc_shift
    call neo_drodo_calc_pos
    call neo_drodo_calc_color
    call neo_drodo_scale_brightness
    ret

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
