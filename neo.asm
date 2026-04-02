neo_port:   .equ    0xA0    ; Port where the neopixel driver is located

; Array with neopixel animation commands
; Cannot mix bytes and words, so two lists.
;   id, name,   drawfunc
neopixel_commands:
    .dw 0x0001, s_clock,    neo_paint_clock
    .dw 0x0002, s_tape,     neo_paint_tape
    .dw 0x0003, s_stargate, neo_paint_sg
    .dw 0x0004, s_sg,       neo_paint_sg
    .dw 0x0005, s_star,     neo_paint_star
    .dw 0x0006, s_tape2,    neo_paint_tape2
    .dw 0x0007, s_tape3,    neo_paint_tape3
    .dw 0x0008, s_tape4,    neo_paint_tape4
    .dw 0x0009, s_tape5,    neo_paint_tape5
    .dw 0x000A, s_tape6,    neo_paint_tape6
    .dw 0x000B, s_rrod,     neo_paint_rrod
    .dw 0x0000

s_clock:    .db "clock",0
s_tape:     .db "tape",0
s_stargate: .db "stargate",0
s_sg:       .db "sg",0
s_star:     .db "star",0
s_tape2:    .db "tape2",0
s_tape3:    .db "tape3",0
s_tape4:    .db "tape4",0
s_tape5:    .db "tape5",0
s_tape6:    .db "tape6",0
s_rrod:     .db "rrod",0

neo_mode:       .db     0x80 + 7
neo_bright:     .db     0x10

; A command gets argc in e and argv in hl
neo:
    ld a, e
    or a
    cp 2
    jp nz, neononefound ; only hl is important now, contains the string
    inc hl \ inc hl
    ld de, (hl)
    ld hl, onstr    \ call strcmp \ jp z, neoonfound
    ld hl, offstr   \ call strcmp \ jp z, neoofffound

    ld hl, neopixel_commands
neo_next_cmd:
    inc hl \ inc hl
    ld bc, (hl)
    push hl
    ld hl, bc
    call strcmp     ; a = ((de) - (hl))
    pop hl
    jp z, neo_command_found
    inc hl \ inc hl \ inc hl \ inc hl
    ld a, (hl)
    or a
    jr nz, neo_next_cmd

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
    jp neooktext
neoofffound:
    ld a, (neo_mode)
    and a,  0b00111111
    or a,   0b11000000
    ld (neo_mode), a
    jp neooktext
neo_command_found:
    dec hl \ dec hl
    ld a, (hl)
    ld b, a
    ld a, (neo_mode)
    and a,  0b11000000
    or a,   b
    ld (neo_mode), a
    jp neooktext
neooktext:
    ld hl, lcd_ok_text  
    call sio_prstr_nl
    ret

; Function that gets cyclic called in the main loop
neo_cyclic:
    ld a, (neo_mode)
    bit 7, a            \   ret z
    call neo_clear_grb
    bit 6, a            \   jr nz, neo_cyclic_off
    and 0b00111111

    ld b, a
    ld hl, neopixel_commands
    ld a, (hl)
neo_cyclic_cmdloop:
    cp a, b
    jr nz, neo_cyclic_pass

    inc hl \ inc hl \ inc hl \ inc hl
    ld bc, (hl)
    ld hl, neo_cyclic_end
    push hl
    ld hl, bc
    jp hl

neo_cyclic_pass:
    inc hl \ inc hl
    ld a, (hl)
    or a
    jr nz, neo_cyclic_cmdloop

    jr neo_cyclic_end

neo_cyclic_off:
    and 0b00111111
    ld (neo_mode), a
    jr neo_cyclic_end
neo_cyclic_end:
    call neo_grb_to_cmd
    call neo_command_run
    ret

neo_print_commands:
    ld de, neopixel_commands
neo_print_commands_loop:
    inc de \ inc de
    ld hl, de
    ld bc, (hl)

    push hl
    ld hl, bc
    ld b, ' '
    call sio_prchr
    call sio_prstr
    pop hl

    inc de \ inc de \ inc de \ inc de
    ld a, (de)
    or a
    jr nz, neo_print_commands_loop

    ld hl, sio_newline
    call sio_prstr
    ret

;------------------------------------------------------------------------------------------------------
.include "neo_stargate.asm"
.include "neo_star_clock.asm"
.include "neo_tape.asm"
.include "neo_rrod.asm"
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
