; unit memory layout:
; 0 - output [0-ff]
; 1 - reserved
; 2 - Class id (0x05 for PLL)
; 3, 4 = l, h for counter (little endian)
; 5, 6 = l, h for counter_max
; 7 - PLL fase  [0-ff] = 0-2Pi


unit_pll:
    ld l, (ix+3)        ; Increment counter
    ld h, (ix+4)
    inc hl
    ld (ix+3), l
    ld (ix+4), h

    ld e, (ix+5)        ; Test for hitting counter_max
    ld d, (ix+6)
    or a
    sbc hl, de
    jr c, pll_no_wrap

    ld hl, 0            ; Setting phase and counter to 0
    ld a, 0
    ld (ix+3), l
    ld (ix+4), h    
    ld (ix+7), a
    jr pll_no_phase

pll_no_wrap:            ; Calculating phase
    push ix             ; phase is counter * 0x100 / counter_max
    ld a, (ix+4) \ ld c, a  ; c = (ix+4) (counter_h)
    ld a, (ix+3) \ ld ixh, a; ixh = (ix+3) (counter_l)
    xor a \ ld ixl, a       ; ixl = 0, a = 0
    call Div32By16      ; ACIX / DE -> CIX    
    ld a, ixl
    pop ix
    ld (ix+7), a

pll_no_phase:
    call sin            ; a = sin(a) [0-0xFF]
    srl a
    srl a               ; we want a Q6 [0-0x40]
    ld (ix+0), a        ; That is our output
    ret
