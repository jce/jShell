; Experimenting with stack frame techniques
cnt = 0
.macro TEST &tag1
    ld b, &tag1
macro_begin{cnt}:
    call fsp
    djnz macro_begin{cnt}
cnt = cnt + 1
    .endm

; Stack frame open macro
; Takes 6 bytes of stack in addition to $size
; uses ix as frame pointer
; Preserves registers, trashes flags
sfo .macro $size
sfo_size = $size
    push af             ; Push the registers that
    push bc             ; the macro uses
    push hl
    ld hl, 0            ;
    add hl, sp          ; Read SP
    ld bc, $size        ; Load size in bc
    or a                ; Clear c flag
    sbc hl, bc          ; Subtract size from sp
    ld sp, hl           ; Store the new stackpointer
    ld bc, hl           ; Some acrobatics to get 
    ld ixh, b           ; hl into ix
    ld ixl, c           ; so ix can be used as offset register for the SP values
    ld hl, (ix+$size+0) ; Load hl from the push, but its not pop for its not on the top of the stack
    ld bc, (ix+$size+2) ; Load bc from the push
    ;ld af, (ix+$size+4); Not allowed!
    ld a, (ix+$size+5)  ; okay, then only a, not flags
    .endm

; Stack frame close macro. Preserves registers,
; trashes flags.
sfc .macro 
    ld (ix+sfo_size+0), hl  ; Store hl in the pushed hl
    ld (ix+sfo_size+2), bc  ; Store bc in the pushed bc
    ;ld (ix+sfo_size+4), af ; Not allowed either!
    ld (ix+sfo_size+5), a   ; Store a in the pushed af (ignoring flags)
    ld hl, 0            ; clear hl      
    add hl, sp          ; Get SP in hl
    ld bc, {sfo_size}   ; Get size in bc
    add hl, bc          ; Add size to sp
    ld sp, hl           ; Store SP
    pop hl              ; Pop hl
    pop bc              ; Pop bc
    pop af              ; Pop af
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



























