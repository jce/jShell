; LCD is at DA/DB

ds1302reg equ  0xc0

ds1302_init:
    ld a, 0x00
    out (ds1302reg), a
    ret    


; ====================================================
; logic block that assumes registers are all ours
; ====================================================
; e - communication byte to the RTC
ds1302_rv: .db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
ds1302_wv: .db 0x35, 0x20, 0x18, 0x21, 0x02, 0x02, 0x26, 0x02

ds1302_read:
;    ld b, 9
;    ld hl, ds1302_rv
;    ld c, 0b10000001
;ds1302_read_loop:
;    ld d, c
;    call ds1302_txrx
;    ld a, d
;    ld (hl), a
;    inc hl
;    inc c
;    inc c
;    djnz ds1302_read_loop

;	call ds1302_burstwriteclock
	call ds1302_burstreadclock
    ret

ds1302_write:
	call ds1302_burstwriteclock
	ret

ds1302_burstwriteclock:
    push bc
    push de
    push hl
; a - scratchpad, function parameter
; b - iterator counter
; c - scratchpad
; d - input / output byte
; e - out register value

; Remove write protection
	ld d, 0x8E
	call ds1302_tx
	ld d, 0x00
	call ds1302_tx
    call ds1302_CE_disable
    call ds1302_clock_low
; Write date time in a single burst
    ld e, 0			; Start out with an output register value of 0
    ld d, 0xBE		; Burst write command
 	ld hl, ds1302_wv; write value pointer to hl
	call ds1302_tx
	ld b, 8        ; Iterate over 7 bytes
ds1302_burstwriteclock_loop: 
	ld d, (hl)
	inc hl
	push bc
	call ds1302_tx
	pop bc
	djnz ds1302_burstwriteclock_loop
	call ds1302_CE_disable
    call ds1302_clock_low
        
; Enable write protection
	ld d, 0x8E
	call ds1302_tx
	ld d, 0x80
	call ds1302_tx
    call ds1302_CE_disable
    call ds1302_clock_low
    
    pop hl
    pop de
    pop bc
    ret

; burst read clock has no parameters
; it writes ds1302_rv
ds1302_burstreadclock:
    push bc
    push de
    push hl
; a - scratchpad, function parameter
; b - iterator counter
; c - scratchpad
; d - input / output byte
; e - out register value
    ld e, 0			; Start out with an output register value of 0
    ld d, 0xBF		; Burst read command
	ld hl, ds1302_rv; return value pointer to hl
	call ds1302_tx
    ld b, 8        ; Iterate over 8 x 8 bits
ds1302_burstreadclock_readloop: 
	push bc
    call ds1302_rx
	pop bc
    ld a, d
    ld (hl), a
	inc hl
	djnz ds1302_burstreadclock_readloop
    call ds1302_CE_disable
    pop hl
    pop de
    pop bc
    ret

; Send one byte, receive another
; a - destroyed
; b - destroyed
; c - destroyed
; d - output byte, to be transmitted. Returns input byte here as well
; e - output register value
; Leaves the clock high!
ds1302_txrx:
    push bc
    push hl
    ld e, 0
	call ds1302_tx
	call ds1302_rx
    call ds1302_CE_disable
    pop hl
    pop bc
    ret

; tx one byte
; a - destroyed
; b - destroyed
; c - destroyed
; d - output byte, to be transmitted
; e - output register value
; Leaves the clock high!
ds1302_tx:
    ld b, 8         ; Iterate for 8 times
    call ds1302_CE_enable
    call ds1302_WE_enable
ds1302_tx_byte_loop:
    call ds1302_clock_low   ; Clock low (again, completing the pulse)
    ld a, d         ; output byte to a 
    and 0b00000001  ; select the lowest bit only
    rrc a           ; locate it at the highest bit
    ld c, a         ; to register c
    ld a, e         ; output register value to a
    and 0b01111111   ; Select the lowest 7 bits only
    or c            ; Or with the top one bit from the bottom of the output byte
    ld e, a         ; Copy to output register
    out (ds1302reg), a  ; Put output register to the out address
    call ds1302_clock_high  ; ds1302 samples input at rising edge of clock
    rrc d           ; Shift output byte one position to left, looping values
    djnz ds1302_tx_byte_loop; Loop    

    call ds1302_data_low
    call ds1302_WE_disable
	ret

; rx one byte
; a - destroyed
; b - destroyed
; c - safe
; d - input bute, to be received
; e - output register value
ds1302_rx:
    ld b, 8         ; Iterate over 8 bits
    ld d, 0         ; d contains the output
ds1302_rx_byte_loop:
    call ds1302_clock_high  ; 
    call ds1302_clock_low   ; ds1302 produces data on the falling edge of the clock
    in a, (ds1302reg)
    and 0b00000001  ; Take only the lowest bit
    or d            ; Add the bit to output register
    rrc a           ; shift output right
    ld d, a         ; store in d
    djnz ds1302_rx_byte_loop
    ret

; Note that WE is inverted in the circuit
ds1302_WE_enable:
    ld a, e
    and 0b11011111
    out (ds1302reg), a
    ld e, a
    ret

; Note that WE is inverted in the circuit
ds1302_WE_disable:
    ld a, e
    or 0b00100000
    out (ds1302reg), a
    ld e, a
    ret

ds1302_CE_enable:
    ld a, e
    or 0b00010000
    out (ds1302reg), a
    ld e, a
    ret

ds1302_CE_disable:
    ld a, e
    and 0b11101111
    out (ds1302reg), a
    ld e, a
    ret

ds1302_clock_high:
    ld a, e
    or 0b01000000
    out (ds1302reg), a
    ld e, a
    ret

ds1302_clock_low:
    ld a, e
    and 0b10111111
    out (ds1302reg), a
    ld e, a
    ret

ds1302_data_high:
    ld a, e
    or 0b10000000
    out (ds1302reg), a
    ld e, a
    ret

ds1302_data_low:
    ld a, e
    and 0b01111111
    out (ds1302reg), a
    ld e, a
    ret
