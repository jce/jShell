; Rotating dot (rodo) animation. Divides the circle in 240 points, each 4 points are for one LED.
; Deposits some activation in some points, logic is per point instead of per LED.
neo_paint_drodo:
    call calc_dt
    call neo_drodo_calc_shift
    call neo_drodo_calc_pos
    ld a, (neo_bright) \ ld c, a \ srl c \ srl c

    ld a, (neo_drodo_pos) \ add a,0 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,1 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,2 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,3 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,4 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,5 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,6 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,7 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_drodo_pos) \ add a,8 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  

    ret;

neo_drodo_calc_pos:
    ld de, (neo_drodo_shift)
    ld hl, (neo_drodo_posw)
    add hl, de   
 
    ld de, 240 << 6
    call Cmp16  ; HL - DE -> Only carry bit
    jr c, neo_drodo_calc_pos_2
    call Sub16   ; HL = HL - DE
neo_drodo_calc_pos_2:
    ld (neo_drodo_posw), hl

    ld a, 6
    call Shr16  ; HL = HL >> A
    ld a, l
    ld (neo_drodo_pos), a

    ret

neo_drodo_calc_shift:
    ld a, (dt)
    ld d, 0
    ld e, a
    ld a, (speed)
    call Mul8   ; HL=DE*A
    ld (neo_drodo_shift), hl
    ret

neo_drodo_calc_color:
; Input: (global) color. [0-FF]
; Output: (global) neo_col_g/r/b [00-FF]
;
;  Blue |\      Green /\    Red      /
;       | \          /  \           /
;       |  \___     /    \      ___/
    ld a, (color)
    cp 0x80
    jr nc, color_q2
color_q1:
    sla a ; a = a * 2
    ld b, a
    ; green
    ld (neo_col_g), a 
    ; red
    ld a, 0
    ld (neo_col_r), a
    ; blue a = 0x100 - 2 * x
    ld a, 0xff
    sub b
    ld (neo_col_b), a
    ret
color_q2:
    sub 0x80
    sla a ; a = a * 2
    ld b, a
    ; green
    ld a, 0xff
    sub b
    ld (neo_col_g), a 
    ; red
    ld a, b
    ld (neo_col_r), a
    ; blue a = 0x100 - 2 * x
    ld a, 0
    ld (neo_col_b), a
    ret

neo_drodo_scale_brightness:
; Input: (global) neo_bright [0-FF]
; Input: (global) neo_col_g/r/b [0-FF]
; Output: (global) neo_col_g/r/b [0-FFFF]
    ld a, (neo_bright)
    ld e, a
    ld d, 0
    ld a, (neo_col_g)
    call Mul8   ;   hl = de * a, color * brightness
    ld (neo_col_g), hl
    ld a, (neo_bright)
    ld e, a
    ld d, 0
    ld a, (neo_col_r)
    call Mul8   ;   hl = de * a, color * brightness
    ld (neo_col_r), hl
    ld a, (neo_bright)
    ld e, a
    ld d, 0
    ld a, (neo_col_b)
    call Mul8   ;   hl = de * a, color * brightness
    ld (neo_col_b), hl
    ret

neo_drodo_shift:.dw 0   ; Shift of rotating dot, dt * speed
neo_drodo_pos:  .db 0   ; Position on profile
neo_drodo_posw: .dw 0   ; Position on profile, word sized
neo_col_g:      .dw 0   ; Green
neo_col_r:      .dw 0   ; Red
neo_col_b:      .dw 0   ; Blue
