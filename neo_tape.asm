;------------------------------------------------------------------------------------------------------
; Paint function fills the grb buffer
; Paints a tape recorder reel rotating
neo_paint_tape:
    ld a, (neo_tape_step)
    inc a
    cp 120
    jr nz, neo_paint_tape_continue
    ld a, 0
neo_paint_tape_continue:
    ld (neo_tape_step), a

    ; Reverse rotation direction
    ld b, a
    ld a, 120
    sub a, b

    ; a is displacement
    srl a \ rl b; \ srl a \ rl b ; The rightmost bit is decimal
    push af
    ld a, (neo_bright)
    ld c, a     ; intensitiy green
    ld h, a     ; intensity red
    ld l, a     ; intensity blue
    ld d, 8     ; line length
    pop af

    call neo_grb_line_color
    add a, 20
    call neo_grb_line_color
    add a, 20
    call neo_grb_line_color

    ret

; ==========================================================================

neo_paint_tape2:
    call calc_dt
    call neo_tape2_calc_shift
    call neo_tape2_calc_pos

    ld a, (neo_tape2_pos) \ add  256*0/ 30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 0 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*1/ 30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 1 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*2/ 30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 2 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*3/ 30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 3 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*4 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 4 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*5 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 5 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*6 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 6 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*7 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 7 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*8 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 8 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*9 /30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 9 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*10/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 10\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*11/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 11\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*12/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 12\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*13/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 13\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*14/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 14\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*15/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 15\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*16/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 16\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*17/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 17\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*18/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 18\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*19/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 19\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*20/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 20\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*21/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 21\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*22/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 22\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*23/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 23\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*24/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 24\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*25/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 25\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*26/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 26\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*27/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 27\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*28/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 28\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*29/30 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 29\ call neo_grb_pixel  

    ld ix, neo_grb
    ld iy, neo_grb+30*3
    ld b, 30*3
grb_copy_loop2:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop2    
    ret;

; Calculate activation for a point on the position curve
; in: a - point on position curve
; out: a - activation at this point of curve
flanklen:   .equ    3 * 256 / 20
toplen:     .equ    90
endlen:     .equ    toplen+flanklen
act:
    cp flanklen \ jr c, q1
    cp toplen   \ jr c, q2
    cp endlen   \ jr c, q3
                  jr    q4
q1:
    ld h, a         ; Load in high byte: a * 0x100
    ld l, 0         ; y - a / flanklen * ff
    ld d, flanklen  ; 
    call Div8       ; HL=HL/D
    ld a, l
    ret
q2:
    ld a, 0xff
    ret
q3:
    sub toplen
    ld h, a
    ld l, 0
    ld d, flanklen
    call Div8       ; HL = HL/D
    ld a, 0xff
    sub l
    ret
q4:
    ld a, 0
    ret

neo_tape2_calc_pos:
    ld a, (neo_tape2_shift) \ ld b, a ; Loads only the low byte of shift
    ld a, (neo_tape2_pos)
    add b
    ld (neo_tape2_pos), a
    ret

neo_tape2_calc_shift:
    ld a, (dt)
    ld d, 0
    ld e, a
    ld a, (neo_tape2_speed)
    call Mul8   ; HL=DE*A
    ld (neo_tape2_shift), hl
    ret

neo_tape2_speed:    .db 2   ; Steps in position per dt
neo_tape2_shift:    .dw 0   ; Shift of animation, dt * speed
neo_tape2_pos:      .db 0   ; position 0-0xff, pos + shift

; ======================================================================================================
neo_paint_tape3:
    call calc_dt
    call neo_tape2_calc_shift
    call neo_tape2_calc_pos

    ld a, (neo_tape2_pos) \ add  256*0/ 20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 0 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*1/ 20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 1 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*2/ 20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 2 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*3/ 20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 3 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*4 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 4 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*5 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 5 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*6 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 6 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*7 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 7 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*8 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 8 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*9 /20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 9 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*10/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 10\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*11/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 11\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*12/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 12\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*13/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 13\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*14/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 14\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*15/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 15\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*16/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 16\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*17/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 17\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*18/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 18\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*19/20 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 19\ call neo_grb_pixel  

    ld ix, neo_grb
    ld iy, neo_grb+20*3
    ld b, 40*3
grb_copy_loop3:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop3    
    ret;

neo_paint_tape4:
    call calc_dt
    call neo_tape2_calc_shift
    call neo_tape2_calc_pos

    ld a, (neo_tape2_pos) \ add  256*0/ 15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 0 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*1/ 15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 1 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*2/ 15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 2 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*3/ 15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 3 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*4 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 4 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*5 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 5 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*6 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 6 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*7 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 7 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*8 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 8 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*9 /15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 9 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*10/15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 10\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*11/15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 11\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*12/15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 12\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*13/15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 13\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*14/15 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 14\ call neo_grb_pixel  

    ld ix, neo_grb
    ld iy, neo_grb+15*3
    ld b, 45*3
grb_copy_loop4:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop4    
    ret;

neo_paint_tape5:
    call calc_dt
    call neo_tape2_calc_shift
    call neo_tape2_calc_pos

    ld a, (neo_tape2_pos) \ add  256*0/ 12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 0 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*1/ 12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 1 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*2/ 12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 2 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*3/ 12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 3 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*4 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 4 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*5 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 5 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*6 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 6 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*7 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 7 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*8 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 8 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*9 /12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 9 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*10/12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 10\ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*11/12 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 11\ call neo_grb_pixel  

    ld ix, neo_grb
    ld iy, neo_grb+12*3
    ld b, 48*3
grb_copy_loop5:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop5   
    ret;

neo_paint_tape6:
    call calc_dt
    call neo_tape2_calc_shift
    call neo_tape2_calc_pos

    ld a, (neo_tape2_pos) \ add  256*0/ 10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 0 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*1/ 10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 1 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*2/ 10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 2 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*3/ 10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 3 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*4 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 4 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*5 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 5 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*6 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 6 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*7 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 7 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*8 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 8 \ call neo_grb_pixel  
    ld a, (neo_tape2_pos) \ add  256*9 /10 \ call act \ call dim \ ld c, a \ ld b, 3 \ ld a, 9 \ call neo_grb_pixel  

    ld ix, neo_grb
    ld iy, neo_grb+10*3
    ld b, 50*3
grb_copy_loop6:
    ld a, (ix) \ inc ix
    ld (iy), a \ inc iy
    djnz grb_copy_loop6   
    ret;

