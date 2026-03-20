neo_port:   .equ    0xA0    ; Port where the neopixel driver is located

; Function that turns the LEDs off
neo_off:
    call neo_clear_grb
    call neo_grb_to_cmd
    call neo_command_run
    ret

; Function that gets cyclic called in the main loop
neo_cyclic:
    call neo_clear_grb
    call neo_paint
    call neo_grb_to_cmd
    call neo_command_run
    ret

; Paint function fills the grb buffer
neo_paint:
    ; Add painters here    
    ; Reverse rotation direction
    ld b, a
    ld a, 120
    sub a, b

    ; a is displacement
    srl a \ rl b; \ srl a \ rl b ; The rightmost bit is decimal
    ld c, 10     ; intensitiy green
    ld h, 10     ; intensity red
    ld l, 10     ; intensity blue
    ld d, 8     ; line length

    call neo_grb_line_color
    add a, 20
    call neo_grb_line_color
    add a, 20
    call neo_grb_line_color

    ;ld c, 40
    ;ld a, 1
    ;ld b, 2
    ;call neo_grb_pixel

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
