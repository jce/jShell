neo_port:   .equ    0xA0    ; Port where the neopixel driver is located

; A command gets argc in e and argv in hl
neo:
    ld a, e
    or a
    cp 2
    jr nz, neononefound
    inc hl \ inc hl
    ld de, (hl)
    ld hl, onstr    \ call strcmp \ jp z, neoonfound
    ld hl, offstr   \ call strcmp \ jp z, neoofffound
    ld hl, neo_clock\ call strcmp \ jp z, neoclockfound
    ld hl, neo_tape \ call strcmp \ jp z, neotapefound
    ld hl, neo_sg   \ call strcmp \ jp z, neosgfound
    ld hl, neo_sg2  \ call strcmp \ jp z, neosgfound
    ld hl, neo_star \ call strcmp \ jp z, neostarfound
    ld hl, neo_tape2\ call strcmp \ jp z, neotape2found
    ld hl, neo_tape3\ call strcmp \ jp z, neotape3found
    ld hl, neo_tape4\ call strcmp \ jp z, neotape4found
    ld hl, neo_tape5\ call strcmp \ jp z, neotape5found
    ld hl, neo_tape6\ call strcmp \ jp z, neotape6found
    ld hl, de
    call hstoui16
    ld a, e
    ld (neo_bright), a
    jp neooktext
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
neotape2found:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape2
    ld (neo_mode), a
    jr neooktext
neotape3found:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape3
    ld (neo_mode), a
    jr neooktext
neotape4found:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape4
    ld (neo_mode), a
    jr neooktext
neotape5found:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape5
    ld (neo_mode), a
    jr neooktext
neotape6found:
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   neo_mode_tape6
    ld (neo_mode), a
    jr neooktext
neooktext:
    ld hl, lcd_ok_text  
    call sio_prstr_nl
    ret

neo_mode:       .db     0x80 + neo_mode_tape3
neo_mode_clock: .equ    0x01
neo_mode_tape:  .equ    0x02
neo_mode_sg:    .equ    0x03
neo_mode_star:  .equ    0x04
neo_mode_tape2: .equ    0x05
neo_mode_tape3: .equ    0x06
neo_mode_tape4: .equ    0x07
neo_mode_tape5: .equ    0x08
neo_mode_tape6: .equ    0x09
neo_tape_step:  .db     0x00
neo_bright:     .db     10
neo_clock:      .db     "clock",0
neo_tape:       .db     "tape",0
neo_sg:         .db     "stargate",0
neo_sg2:        .db     "sg",0
neo_star:       .db     "star",0
neo_tape2:      .db     "tape2",0
neo_tape3:      .db     "tape3",0
neo_tape4:      .db     "tape4",0
neo_tape5:      .db     "tape5",0
neo_tape6:      .db     "tape6",0

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
    cp  neo_mode_tape2  \   jr z, neo_cyclic_tape2
    cp  neo_mode_tape3  \   jr z, neo_cyclic_tape3
    cp  neo_mode_tape4  \   jr z, neo_cyclic_tape4
    cp  neo_mode_tape5  \   jr z, neo_cyclic_tape5
    cp  neo_mode_tape6  \   jr z, neo_cyclic_tape6
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
neo_cyclic_tape2:
    call neo_paint_tape2
    jr neo_cyclic_end
neo_cyclic_tape3:
    call neo_paint_tape3
    jr neo_cyclic_end
neo_cyclic_tape4:
    call neo_paint_tape4
    jr neo_cyclic_end
neo_cyclic_tape5:
    call neo_paint_tape5
    jr neo_cyclic_end
neo_cyclic_tape6:
    call neo_paint_tape6
    jr neo_cyclic_end
neo_cyclic_end:
    call neo_grb_to_cmd
    call neo_command_run
    ret

;------------------------------------------------------------------------------------------------------
.include "neo_stargate.asm"
.include "neo_star_clock.asm"
.include "neo_tape.asm"
;------------------------------------------------------------------------------------------------------

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
; b - g (0), r (1), b (2), w(3)
; c - quantity to add
neo_grb_pixel:
    push af
    ld a, b
    cp 3 \ jr z, neo_grb_white
    cp 4 \ jr z, neo_grb_rb
    cp 5 \ jr z, neo_grb_bg
    cp 6 \ jr z, neo_grb_gr
    pop af
    call neo_grb_pixel2
    ret
neo_grb_white:
    pop af
    ld b, 0 \ call neo_grb_pixel2
    ld b, 1 \ call neo_grb_pixel2
    ld b, 2 \ call neo_grb_pixel2
    ret
neo_grb_rb:
    pop af
    ld b, 1 \ call neo_grb_pixel2
    ld b, 2 \ call neo_grb_pixel2
    ret
neo_grb_bg:
    pop af
    ld b, 0 \ call neo_grb_pixel2
    ld b, 2 \ call neo_grb_pixel2
    ret
neo_grb_gr:
    pop af
    ld b, 0 \ call neo_grb_pixel2
    ld b, 1 \ call neo_grb_pixel2
    ret

neo_grb_pixel2:
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
    jr nc, neo_grb_nocarry
    ld a, 0xff
neo_grb_nocarry:
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
