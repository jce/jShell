;------------------------------------------------------------------------------------------------------
; Paint function fills the grb buffer
neo_paint_rainbow:
    ; for led b in range 0-59
    ld d, 60
    
neo_paint_rainbow_pixel_loop:

    ; point on activation curve e:
    ; e = d * 256 / 60
    ld b, d
    ld h, d
    ld l, 0
    ld d, 60
    call Div8   ; HL = HL / D
    ld e, l
    ld d, b
    
    ; Activation for color 1
    ld a, e
    call sin
    ld c, a     ; quantity to add
    ld b, 0     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    ; Activation for color 2
    ld a, 256 * 1 / 3
    add a, e
    call sin
    ld c, a     ; quantity to add
    ld b, 1     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    ; Activation for color 3
    ld a, 256 * 2 / 3
    add a, e
    call sin
    ld c, a     ; quantity to add
    ld b, 2     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    dec d
    ld a, d
    or a
    jr nz, neo_paint_rainbow_pixel_loop

    call neo_grb_scale_brightness

    ret

neo_paint_rainbow2:
    ; for led b in range 0-59
    ld d, 60
    
neo_paint_rainbow_pixel_loop2:

    ; point on activation curve e:
    ; e = d * 256 / 60
    ld b, d
    ld h, d
    ld l, 0
    ld d, 60
    call Div8   ; HL = HL / D
    ld e, l
    ld d, b
    
    ; Activation for color 1
    ld a, e
    call rb2_activation
    ld c, a     ; quantity to add
    ld b, 0     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    ; Activation for color 2
    ld a, 256 * 1 / 3
    add a, e
    call rb2_activation
    ld c, a     ; quantity to add
    ld b, 1     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    ; Activation for color 3
    ld a, 256 * 2 / 3
    add a, e
    call rb2_activation
    ld c, a     ; quantity to add
    ld b, 2     ; color
    ld a, d     ; pixel number
    call neo_grb_pixel

    dec d
    ld a, d
    or a
    jr nz, neo_paint_rainbow_pixel_loop2

    call neo_grb_scale_brightness

    ret

; Activation function for rainbow2
; in/out : a (position, activation)
rb2_activation:
    cp 256*1/3 
    jr c, rb2_q1
    cp 256*2/3 
    jr c, rb2_q2
    jr rb2_q3
rb2_q1:
    push de
    push hl
    ld d, 0
    ld e, 3
    call Mul8   ; HL=DE*A
    ld a, l
    pop hl
    pop de
    ret
rb2_q2:
    push de
    push hl
    sub a, 256*1/3
    ld d, 0
    ld e, 3
    call Mul8
    ld a, 0xff
    sub a, l
    pop hl
    pop de
    ret
rb2_q3:
    ld a, 0
    ret


neo_grb_scale_brightness
    ; Just scale every color of every pixel according to neo_bright
    ; Pixel brightness scaled = pixel brightness * neo_bright / 256
    ld ix, neo_grb
    ld b, 60*3
    ld d, 0
    ld a, (neo_bright)  
neo_grb_scale_brightness_loop:
    ld e, (ix)
    call Mul8           ;   HL = DE * A    
    ld (ix), h
    inc ix
    djnz neo_grb_scale_brightness_loop
    ret




















