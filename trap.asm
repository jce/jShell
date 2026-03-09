; Trap functin, akin SCM.
; The hope is to catch which function does a spurious jump to wrong memory. This
; information will be on the stack, so we want to see the stack!

trap:
    ld hl, trapbuf
    ld (hl), 'T' \ inc hl 
    ld (hl), 'r' \ inc hl 
    ld (hl), 'a' \ inc hl 
    ld (hl), 'p' \ inc hl 
    ld (hl), ' ' \ inc hl 
    ld (hl), 'S' \ inc hl 
    ld (hl), 'P' \ inc hl 
    ld (hl), ':' \ inc hl 
    ld (hl), ' ' \ inc hl
    ld bc, hl
    ld hl, 0x0000
    add hl, sp
    ld de, hl
    ld hl, bc
    call ui16tohs
    ld (hl), ' ' \ inc hl
    ld (hl), '(' \ inc hl
    ld (hl), 'S' \ inc hl
    ld (hl), 'P' \ inc hl
    ld (hl), ')' \ inc hl
    ld (hl), ':' \ inc hl
    ld (hl), ' ' \ inc hl
    ld bc, hl
    ld hl, de
    ld de, (hl)
    ld hl, bc
    call ui16tohs
    ld (hl), 0

    ld hl, trapbuf
    call log_add    

    ld hl, trapbuf
    call sio_prstr_nl
    ret

trapbuf: .block 64

trap_init:
    ; There are two blocks we can trap. The first is from end of program, "end", to begin of log, 0xa000
    ; and end of log 0xc000 to begin of stack, SP - 400
    ld hl, 0x0000
    ld bc, init
    call trap_init_block
    ld hl, end
    ld bc, 0xa000
    call trap_init_block
    ld hl, 0xc000
    ld bc, 0xf000
    call trap_init_block
    ld hl, 0xf000
    ld bc, 0xf900
    call trap_init_block
    ld hl, 0xf900
    ld bc, 0xfa00
    call trap_init_block
    ld hl, 0xfa00
    ld bc, 0xfb00
    call trap_init_block
    ld hl, 0xfb00
    ld bc, 0xfc00
    call trap_init_block
    ld hl, 0xfc00
    ld bc, 0xfd00
    call trap_init_block
    ld hl, 0xfd00
    ld bc, 0xfe00
    call trap_init_block

; Inits a block of nops ending with 0xC3 0xTR 0xAP
; DO NOT USE for blocks of length 1 to 3!

trap_init_block:
    or a            ; Carry is zero
    ld de, hl
    sbc hl, bc      ; Length
    ld hl, de
    jr z, trap_init_done ; Length is zero, ignore sectioni
trap_init_a:
    or a
    ld de, hl
    sbc hl, bc
    ld hl, de
    jr z, trap_init_b
    ld (hl), 0x00   ; NOP instruction
    inc hl
    jp trap_init_a
trap_init_b:
    ld de, trap
    dec hl \ dec hl \ dec hl
    ld (hl), 0xC3 \ inc hl
    ld (hl), e \ inc hl
    ld (hl), d
trap_init_done:      
    ret






















