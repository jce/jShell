;------------------------------------------------------------------------------------------------------
; Paint function fills the grb buffer
; Paints a tape recorder reel rotating
neo_paint_rrod:
    ld a, (neo_bright)
    ld c, 0     ; intensitiy green
    ld h, a     ; intensity red
    ld l, 0     ; intensity blue
    ld d, 11    ; line length

    ld a, 19
    call neo_grb_line_color
    add a, 15
    call neo_grb_line_color
    add a, 15
    call neo_grb_line_color

    ld a, (neo_bright)
    ld h, a
    srl h \ srl h \ srl h
    ld a, 0
    ld d, 60
    call neo_grb_line_color

; Making it a bit jittery. Jitters every pixel between 0 and +1
;    ld a, 60    ; 60 pixels
;    ld b, 1     ; color: red
;    
;neo_paint_rrod_loop:
;    dec a
;    call xrnd
;    ld c, l
;    srl c \ srl c \ srl c \ srl c \ srl c \ srl c \ srl c
;    call neo_grb_pixel
;
;    or a, a
;    jr nz, neo_paint_rrod_loop

; Making it a bit jittery. Jitters every pixel between 0 and +50%
    ld b, 60
    ld de, neo_grb
    inc de
neo_paint_rrod_loop:
    call xrnd
    ld a, h
    bit 2, h
    jr nz, neo_paint_rrod_continue

    ld hl, de
    ld c, (hl)
    ld a, c
    srl c; \ srl c \ srl c
    add a, c
    ld (hl), a    

neo_paint_rrod_continue:
    inc de \ inc de \ inc de
    djnz neo_paint_rrod_loop

    ret

