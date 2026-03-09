; Experimenting with stack frame techniques
cnt = 0
.macro TEST &tag1
    ld b, &tag1
macro_begin{cnt}:
    call fsp
    djnz macro_begin{cnt}
cnt = cnt + 1
    .endm


stackframe:
    call fsp


    ld a, 0x12
    ld bc, 0x2345
    ld de, 0x3456
    ld hl, 0x4567 
    ld ix, 0x5678
    ld iy, 0x6789

    sfo 100   

    ld b, 100
    ld a, 0
stackframeloop:
    ld (ix), a
    inc a
    inc ix
    djnz stackframeloop

    TEST 1
    
    sfc

    TEST 1
    
    ld d, 10

    ld a, 0x34
    call sio_uint8_hex_nl
    ;ld hl, 0x1234
    call framefunc
    call sio_uint8_hex_nl

    ret

framefunc:
    call sio_uint8_hex_nl
    sfo 100

;    call sio_uint16_hex_nl
    call sio_uint8_hex_nl

    ld c, a
    ld a, d
    or a
    ld a, c
    jr z, framefunc_b0
    jr framefunc_bx

framefunc_bx:
    dec d
    call framefunc
    jr framefunc_end

framefunc_b0:
   TEST 1
    jr framefunc_end
    
framefunc_end:
    sfc
    ret



























