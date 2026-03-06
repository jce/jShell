; Collection of macro's

; Debug a value to the LEDs on out0
; in one single line.
; example: dbg 20
dbg .macro $int
    push af
    ld a, $int
    out (0), a
    pop af
    .endm
