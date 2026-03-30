neo_paint_star:
    call xrnd
    ld a, h
    call dim
    ld c, a
    call xrnd
    ld a, h
neo_paint_star_loop:
    cp 7
    jr c, neo_paint_star_continue
    sub 7
    jr neo_paint_star_loop
neo_paint_star_continue:
    ld b, a
    ld a, l
    call neo_grb_pixel
    ret    

; Paint function fills the grb buffer
;Draw a clock
neo_paint_clock:
    ld a, (neo_bright)
    ld c, a
    call mktime
    ld a, (tm + 0)  \ ld b, 2 \ call neo_grb_pixel  ; Second hand 
    ld a, (tm + 1)  \ ld b, 0 \ call neo_grb_pixel  ; Minute hand
    ld a, (tm + 2) ; a is hours [0-23], scale to 60 [0-59]. Hours * 5 + minutes / 12
    ld h, a
    ld e, 5
    call Mul8b      ; HL=H*E
    ld e, l         ; e = Hours * 5
    ld a, (tm + 1)
    ld H, 0
    ld l, a
    ld d, 12
    call Div8       ; HL=HL/D, l = Minutes / 12
    ld a, l
    add a, e
    ld l, a
    ld a, (neo_bright)
    ld c, a
    ld a, l         \ ld b, 1 \ call neo_grb_pixel  ; Hour hand

    ; Draw dots for hours. Half the brightness for the 12 hour dot, another half the brightness
    ; for the other hour dots.
    ld a, c \ srl a \ ld c, a
    ld a, 0 \ ld b, 0  \ call neo_grb_pixel \ ld b, 1 \ call neo_grb_pixel \ ld b, 2 \ call neo_grb_pixel
    ld a, c \ srl a \ ld c, a
    ld a, 0
    ld d, 11
neo_paint_clock_hour_dot:
    add a, 5 \ ld b, 0 \ call neo_grb_pixel \ ld b, 1 \ call neo_grb_pixel \ ld b, 2 \ call neo_grb_pixel
    dec d
    jr nz, neo_paint_clock_hour_dot
    ret
