neo_port:   .equ    0xA0    ; Port where the neopixel driver is located

; A command gets argc in e and argv in hl
neo:
    ld a, e
    or a
    cp 2
    jr nz, neononefound
    inc hl \ inc hl
    ld de, (hl)
    ld hl, onstr    \ call strcmp \ jr z, neoonfound
    ld hl, offstr   \ call strcmp \ jr z, neoofffound
    ld hl, neo_clock\ call strcmp \ jr z, neoclockfound
    ld hl, neo_tape \ call strcmp \ jr z, neotapefound
    ld hl, neo_sg   \ call strcmp \ jr z, neosgfound
    ld hl, neo_sg2  \ call strcmp \ jr z, neosgfound
    ld hl, neo_star \ call strcmp \ jr z, neostarfound
    ld hl, de
    call hstoui16
    ld a, e
    ld (neo_bright), a
    jr neooktext
neononefound:
    ld hl, nonefound
    call sio_prstr_nl
    ret
neoonfound:
    ld a, (neo_mode)
    and a,  0b00111111
    or a,   0b10000000
    ld (neo_mode), a
    jr neooktext
neoofffound:
    ld a, (neo_mode)
    and a,  0b00111111
    or a,   0b11000000
    ld (neo_mode), a
    jr neooktext
neoclockfound:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_clock
    ld (neo_mode), a
    jr neooktext
neotapefound:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape
    ld (neo_mode), a
    jr neooktext
neosgfound:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_sg
    ld (neo_mode), a
    jr neooktext
neostarfound:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_star
    ld (neo_mode), a
    jr neooktext
neooktext:
    ld hl, lcd_ok_text  
    call sio_prstr_nl
    ret

neo_mode:       .db     0x80 + neo_mode_tape
neo_mode_clock: .equ    0x01
neo_mode_tape:  .equ    0x02
neo_mode_sg:    .equ    0x03
neo_mode_star:  .equ    0x04
neo_tape_step:  .db     0x00
neo_bright:     .db     10
neo_clock:      .db     "clock",0
neo_tape:       .db     "tape",0
neo_sg:         .db     "stargate",0
neo_sg2:        .db     "sg",0
neo_star:       .db     "star",0

; Function that gets cyclic called in the main loop
neo_cyclic:
    ld a, (neo_mode)
    bit 7, a            \   ret z
    call neo_clear_grb
    bit 6, a            \   jr nz, neo_cyclic_off
    and 0b00111111
    cp  neo_mode_clock  \   jr z, neo_cyclic_clock
    cp  neo_mode_tape   \   jr z, neo_cyclic_tape
    cp  neo_mode_sg     \   jr z, neo_cyclic_sg
    cp  neo_mode_star   \   jr z, neo_cyclic_star
    jr neo_cyclic_end
neo_cyclic_off:
    and 0b00111111
    ld (neo_mode), a
    jr neo_cyclic_end
neo_cyclic_clock:
    call neo_paint_clock
    jr neo_cyclic_end
neo_cyclic_tape:
    call neo_paint_tape
    jr neo_cyclic_end
neo_cyclic_sg:
    call neo_paint_sg
    jr neo_cyclic_end
neo_cyclic_star:
    call neo_paint_star
    jr neo_cyclic_end
neo_cyclic_end:
    call neo_grb_to_cmd
    call neo_command_run
    ret

; ==========================================================================
; Paint function fills the grb buffer
;Draw a stargate: 10 rotating lobes of altering color and rotation direction
neo_paint_sg:
    call calc_dt
    call neo_calc_shift
    call neo_calc_pos

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

neo_calc_pos:
    ld a, (sg_shift) \ ld b, a
    ld a, (sg_pos)
    add b
    ld (sg_pos), a
    ret
sg_pos: .db 0   ; position 0-0xff

neo_calc_shift:
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
; ==========================================================================

neo_paint_star:
    call xrnd
    ld a, h
    call dim
    ld c, a
    call xrnd
    ld a, h
neo_paint_star_loop:
    cp 3
    jr c, neo_paint_star_continue
    sub 3
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

; Add line section with color
; a - start pixel
; c - quantity green
; d - length
; h - quantity red
; l - quantity blue
neo_grb_line_color:
    push bc 
    ld b, 0
    call neo_grb_line
    ld b, 1
    ld c, h
    call neo_grb_line
    ld b, 2
    ld c, l
    call neo_grb_line
    pop bc
    ret

; Add a line section.
; a - start pixel
; b - color
; c - quantity
; d - length
neo_grb_line:
    push af
    push de
neo_grb_line_loop:
    call neo_grb_pixel
    inc a
    dec d
    jr z, neo_grb_line_end
    jr neo_grb_line_loop
neo_grb_line_end:
    pop de
    pop af
    ret

; Add a value to a grb cell. Folds cell numbers.
; a - pixel number
; b - g (0), r (1), b (2)
; c - quantity to add
neo_grb_pixel:
    push af
    push bc
    push de
    push hl
neo_grb_pixel_loop:
    ; Wrap around the 60
    cp 60           
    jr c, neo_grb_add_continue
    sub a, 60
    jr neo_grb_pixel_loop
neo_grb_add_continue:
    ; The index is 3 times the cell number (grb)
    ld d, a
    add a, d
    add a, d
    ; color offset
    add a, b
    ; calculate cell index
    ld hl, neo_grb
    ld d, c
    ld b, 0
    ld c, a
    add hl, bc
    ; load cell value
    ld a, (hl)
    ; store increased value
    add a, d
    ld (hl), a
    pop hl
    pop de
    pop bc
    pop af
    ret

; Clears the grb buffer
neo_clear_grb:
    ld b, 60*3
    ld hl, neo_grb
neo_clear_loop:
    ld (hl), 0x00 \ inc hl
    djnz neo_clear_loop
    ret

; Translate the grb buffer to command buffer    
neo_grb_to_cmd:
    ld ix, neo_grb
    ld iy, neocommandbuffer
    ld c, 60 * 3
neo_grb_to_cmd_loop:
    ld b, 8
    ld a, (ix) \ inc ix
neo_grb_to_cmd_byte:
    sla a
    jr c, neo_grb_to_cmd_bit_true
    inc iy \ ld (iy), 0x51 \ inc iy    
    jr neo_grb_to_cmd_bit_end
neo_grb_to_cmd_bit_true:
    inc iy \ ld (iy), 0x59 \ inc iy    
neo_grb_to_cmd_bit_end:
    djnz neo_grb_to_cmd_byte
    dec c
    jr nz, neo_grb_to_cmd_loop
    ret

neo_grb:             ; Neo color buffer. Green, Red, Blue
    .block 3*60     ; 3 bytes * 60 leds

; Runs the commands in the commandbuffer
neo_command_run:
    ld c, neo_port
    ld d, 0x01
    ld e, 0x02
    di
neocommandbuffer:
    ;out(c), d  ; 0xED 0x51
    ;out(c), e  ; 0xED 0x59
    .block 3*8*2*60 ; 3 bytes, 8 bits, 2 bytes/bit, 60 leds
    ei
    ret

; Init the static part of the command buffer
neo_init:
    ld ix, neocommandbuffer
    ld c, 60*3
neo_init_outerloop:
    ld b, 8
neo_init_loop:
    ld (ix), 0xED \ inc ix \ inc ix
    djnz neo_init_loop
    dec c
    jr nz, neo_init_outerloop
    ret
