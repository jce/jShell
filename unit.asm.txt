; unit system

unit_enabled:    .db 1
main_unit:                  ; Gets called from the mainloop
    push af
    ld a, (unit_enabled)    ; Tests if unit is enabled
    or a
    jr z, $+3
    call main_unit_run    
    pop af
    ret

unit_lastrun:   .db 0
main_unit_run:              ; Gets called only if unit is enabled
    push bc
    ld a, (ctc_ms_coun_ff)  ; a = 10 ms tick counter in uint8
    ld b, a                 ; b = 10 ms tick counter
    ld a, (unit_lastrun)    ; a = tick counter during last run
    cp b                    ; Compare tick counters
    jr z, main_unit_run_end ; Break out if ctc has not changed since last run
    ld a, b                 ; a turned back into tick counter
    ld c, 0b00000111        ; c is mask 0b00000111
    and c                   ; a = a AND c, looks only at bottom most bits
    jr z, $+4               ; Jump over next line if bottom bits are all 0
    jr main_unit_run_end    ; Jump to end
    ld a, b                 ; a = 10 ms tick counter
    ld (unit_lastrun), a    ; Store 10 ms tick counter as lastrun
    call main_unit_scan     ; Call unit_scan
main_unit_run_end:
    pop bc
    ret

main_unit_scan:             ; Called every scan (80 ms)
    push de                 ; a, bc may be trashed
    ld b, 0x00              ; 0x100 times
    ld ix, units_c          ; ix is the unit offset constant
main_uint_scan_loop:
    push af
    push bc
    push de
    push hl
    call unit_call          ; Calls every unit
    pop hl
    pop de
    pop bc
    pop af
    ld de, 0x40             ; de = 0x40
    add ix, de              ; ix = ix + 0x40 (shift to next unit offset)
    djnz main_uint_scan_loop; Loop
    pop de
    ret

unit_call:                  ; Splits out the unit call to the function / class
    ld a, (ix+2)            ; function
    
    cp 0x01
    jr nz, $+5
    jp unit_switch

    cp 0x02
    jr nz, $+5
    jp unit_led

    cp 0x03
    jr nz, $+5
    jp unit_lpf

    cp 0x04
    jr nz, $+5
    jp unit_neuron

    cp 0x05
    jr nz, $+5
    jp unit_pll

    ret

unit_switch:
    in a, (0)               ; Read data byte 0
    ld c, a                 ; c is the readout value
    ld a, (ix+3)            ; a is switch address [0-7]
    ld b, a                 ; b is switch address
    inc b
    jr unit_switch_loop_entry
unit_switch_loop:
    srl c                   ; shift c (readout value) right
unit_switch_loop_entry:
    djnz unit_switch_loop   ; By switch address times
    ld a, c                 ; a is readout value
    ld c, 0x01              ; c is 0x01 (mask)
    and c                   ; a = a and c (0x01)
    ld d, 0x00              ; d (rv) = 0x00
    cp 0x01                 ; is a equal to 0x01?
    jr nz, $+4              ; No? jump 2 forward
    ld d, 0x40              ; d (rv) = 0x40 (64)
    ld a, d                 ; a = d (rv)
    ld (ix+0), a            ; (ix+0) = rv
    ret

unit_read:                  ; reads unit a, returns its output value in a
    push bc
    push de
    push hl
    ld h, a
    ld e, 0x40              ; Mul8b:    HL=H*E
    call Mul8b              ; hl = unit * 0x40
    ld bc, units_c          ; bc = units_c (offset of units start in memory)
    add hl, bc              ; hl = units * 0x40 + offset in memory
    ld a, (hl)              ; a = value at hl
    pop hl
    pop de
    pop bc
    ret                     ; return with a

leds:   .db 0x00            ; Memory value for leds
unit_led:
    ld a, (ix+4)            ; Read led input unit
    call unit_read          ; Trade a-the-input unit for a- the input value
    cp 0x20                 ; compare with 0x20 (32, 50% of 64)
    ld d, 0x00              ; d (rv) = 0
    jr c, $+4               ; if carry is set (input < 0x20), jump over next line
    ld d, 0x01              ; d (rv) = 1
    ld e, 0xFE              ; e has bit 1 cleared
    ld c, d                 ; c is d (rv) as well
    ld a, (ix+3)            ; a is led number
    ld b, a                 ; b is the led number as well
    inc b                   ; Needs to be 1 more, for "1" is the last loop.
    jr unit_led_loop_entry  ; Jump in before the test, so "1" means no executions of the loop content.
unit_led_loop:
    sla d                   ; shifts the bit in d left
    rlc e                   ; rotates e left (shifts the hole left)
unit_led_loop_entry:
    djnz unit_led_loop      ; decrement b
                            ; we have now d, with bit a set if the led is on, and e with bit a set.
    ld a, (leds)            ; Read the historic led value
    and e                   ; mask out the one led we are controlling
    or d                    ; Sets / not sets the one bit we control
    ld (leds), a            ; Store historic leds value
    out 0, a                ; Write leds value to outputs
    ret

unit_lpf:
    ret

unit_neuron:
    ret

unit_pll:
    ret




