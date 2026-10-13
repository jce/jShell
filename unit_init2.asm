; unit system init function

unit_init:

    ld ix, units_c
    ld bc, 0x40

    ; switch 0
    ld a, 1 \ ld (ix+2), a
    ld a, 0 \ ld (ix+3), a
    add ix, bc
    
    ; switch 1
    ld a, 1 \ ld (ix+2), a
    ld a, 1 \ ld (ix+3), a
    add ix, bc
    
    ; switch 2
    ld a, 1 \ ld (ix+2), a
    ld a, 2 \ ld (ix+3), a
    add ix, bc
    
    ; switch 3
    ld a, 1 \ ld (ix+2), a
    ld a, 3 \ ld (ix+3), a
    add ix, bc
    
    ; switch 4
    ld a, 1 \ ld (ix+2), a
    ld a, 4 \ ld (ix+3), a
    add ix, bc
    
    ; switch 5
    ld a, 1 \ ld (ix+2), a
    ld a, 5 \ ld (ix+3), a
    add ix, bc
    
    ; switch 6
    ld a, 1 \ ld (ix+2), a
    ld a, 6 \ ld (ix+3), a
    add ix, bc
    
    ; switch 7
    ld a, 1 \ ld (ix+2), a
    ld a, 7 \ ld (ix+3), a
    add ix, bc
    
    ; led 0
    ld a, 2 \ ld (ix+2), a
    ld a, 0 \ ld (ix+3), a
    ld a, 16 \ ld (ix+4), a
    add ix, bc

    ; led 1
    ld a, 2 \ ld (ix+2), a
    ld a, 1 \ ld (ix+3), a
    ld a, 17 \ ld (ix+4), a
    add ix, bc

    ; led 2
    ld a, 2 \ ld (ix+2), a
    ld a, 2 \ ld (ix+3), a
    ld a, 18 \ ld (ix+4), a
    add ix, bc

    ; led 3
    ld a, 2 \ ld (ix+2), a
    ld a, 3 \ ld (ix+3), a
    ld a, 19 \ ld (ix+4), a
    add ix, bc

    ; led 4
    ld a, 2 \ ld (ix+2), a
    ld a, 4 \ ld (ix+3), a
    ld a, 20 \ ld (ix+4), a
    add ix, bc

    ; led 5
    ld a, 2 \ ld (ix+2), a
    ld a, 5 \ ld (ix+3), a
    ld a, 21 \ ld (ix+4), a
    add ix, bc

    ; led 6
    ld a, 2 \ ld (ix+2), a
    ld a, 6 \ ld (ix+3), a
    ld a, 22 \ ld (ix+4), a
    add ix, bc

    ; led 7
    ld a, 2 \ ld (ix+2), a
    ld a, 7 \ ld (ix+3), a
    ld a, 23 \ ld (ix+4), a
    add ix, bc

    ; PLL 0
    ld a, 5 \ ld (ix+2), a
    ld a, 1 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 0 \ ld (ix+8), a
    add ix, bc

    ; PLL 1
    ld a, 5 \ ld (ix+2), a
    ld a, 2 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 1 \ ld (ix+8), a
    add ix, bc

    ; PLL 2
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 2 \ ld (ix+8), a
    add ix, bc

    ; PLL 3
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 3 \ ld (ix+8), a
    add ix, bc

    ; PLL 4
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 4 \ ld (ix+8), a
    add ix, bc

    ; PLL 5
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 5 \ ld (ix+8), a
    add ix, bc

    ; PLL 6
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 6 \ ld (ix+8), a
    add ix, bc

    ; PLL 7
    ld a, 5 \ ld (ix+2), a
    ld a, 0 \ ld (ix+5), a
    ld a, 10 \ ld (ix+6), a
    ld a, 7 \ ld (ix+8), a
    add ix, bc


    ret    


