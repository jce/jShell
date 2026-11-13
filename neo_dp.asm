
; Rotating dot (rodo) animation. Divides the circle in 240 points, each 4 points are for one LED.
; Deposits some activation in some points, logic is per point instead of per LED.
neo_paint_dp:
    call d_dc_test
    jp nz, neo_paint_d_dc
    ld a, (flags)
    bit 0, a
    jp nz, neo_paint_d_alarm
    bit 1, a
    jp nz, neo_paint_d_bell

    call calc_dt
    call neo_dp_calc_shift
    ld ix, neo_dp_shifta \ call neo_dp_calc_pos
    ld ix, neo_dp_shiftb \ call neo_dp_calc_pos
    ld ix, neo_dp_shiftc \ call neo_dp_calc_pos

    ld a, 0x00 \ ld (neo_col_g), a
    ld a, 0x00 \ ld (neo_col_r), a
    ld a, (neo_bright) \ ld (neo_col_b), a
    ld ix, neo_dp_posa \ call neo_dot

    ld a, 0x00 \ ld (neo_col_g), a
    ld a, (neo_bright) \ ld (neo_col_r), a
    ld a, 0x00 \ ld (neo_col_b), a
    ld ix, neo_dp_posb \ call neo_dot

    ld a, (neo_bright) \ ld (neo_col_g), a
    ld a, 0x00 \ ld (neo_col_r), a
    ld a, 0x00 \ ld (neo_col_b), a
    ld ix, neo_dp_posc \ call neo_dot

    ret

; Single neopixel dot painter. Set IX to the correct position value.
neo_dot:
    ld a, (ix) \ add a,0 \ srl a \ srl a \ call neo_grb_pixel3 
    ld a, (ix) \ add a,1 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,2 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,3 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,4 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,5 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,6 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,7 \ srl a \ srl a \ call neo_grb_pixel3
    ld a, (ix) \ add a,8 \ srl a \ srl a \ call neo_grb_pixel3
    ret
    
; Param: ix points to the data block.
neo_dp_calc_pos:
    ld de, (ix+0)           ; Shift
    ld hl, (ix+2)           ; posw
    add hl, de              ; hl << 2, use four adds
    add hl, de              ; Will wrap around 0/65535 or -32768/32767
    add hl, de
    add hl, de
    ld (ix+2), hl

    ; We want neo_dp_posw, linearly scaled to 0-239.
    ; pos = posw * 240 / 65536  which are [posw * 240] and [>> 16]
    ex de, hl
    ld hl, 240 \ ld bc, hl
    call Mul16              ; DEHL=BC*DE. D will be 0 for B was 0.
    ld a, e
    ld (ix+4), a
    ret

neo_dp_calc_shift:
    ld a, (dt)
    ld c, a
    ld a, (Pa)
    call mul8_signed    ; a(signed) * c -> hl (signed)
    ld (neo_dp_shifta), hl
    ld a, (dt)
    ld c, a
    ld a, (Pb)
    call mul8_signed 
    ld (neo_dp_shiftb), hl
    ld a, (dt)
    ld c, a
    ld a, (Pc)
    call mul8_signed
    ld (neo_dp_shiftc), hl
    ret

; Note: relative distances matter in this block!
neo_dp_shifta:.dw 0   ; Shift of rotating dot, dt * speed
neo_dp_poswa: .dw 0   ; Position on profile, word sized
neo_dp_posa:  .db 0   ; Position on profile

neo_dp_shiftb:.dw 0   ; Shift of rotating dot, dt * speed
neo_dp_poswb: .dw 0   ; Position on profile, word sized
neo_dp_posb:  .db 0   ; Position on profile

neo_dp_shiftc:.dw 0   ; Shift of rotating dot, dt * speed
neo_dp_poswc: .dw 0   ; Position on profile, word sized
neo_dp_posc:  .db 0   ; Position on profile


