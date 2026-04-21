; Rotating dot (rodo) animation. Divides the circle in 240 points, each 4 points are for one LED.
; Deposits some activation in some points, logic is per point instead of per LED.
neo_paint_rodo:
    call calc_dt
    call neo_rodo_calc_shift
    call neo_rodo_calc_pos
    ld a, (neo_bright) \ ld c, a \ srl c \ srl c

    ld a, (neo_rodo_pos) \ add a,0 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,1 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,2 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,3 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,4 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,5 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,6 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,7 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  
    ld a, (neo_rodo_pos) \ add a,8 \ srl a \ srl a \ ld b, 3 \ call neo_grb_pixel  

    ret;

neo_rodo_calc_pos:
    ld de, (neo_rodo_shift)
    ld hl, (neo_rodo_posw)
    add hl, de   
 
    ld de, 240 << 6
    call Cmp16  ; HL - DE -> Only carry bit
    jr c, neo_rodo_calc_pos_2
    call Sub16   ; HL = HL - DE
neo_rodo_calc_pos_2:
    ld (neo_rodo_posw), hl

    ld a, 6
    call Shr16  ; HL = HL >> A
    ld a, l
    ld (neo_rodo_pos), a

    ret

neo_rodo_calc_shift:
    ld a, (dt)
    ld d, 0
    ld e, a
    ld a, (neo_rodo_speed)
    call Mul8   ; HL=DE*A
    ld (neo_rodo_shift), hl
    ret

neo_rodo_speed: .db 96  ; Steps in position per dt / 64
neo_rodo_shift: .dw 0   ; Shift of rotating dot, dt * speed
neo_rodo_pos:   .db 0   ; Position on profile
neo_rodo_posw:  .dw 0   ; Position on profile, word sized
