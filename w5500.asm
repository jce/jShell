; A command gets argc in e and argv in hl

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
digit .macro $loc
    inc hl \ inc hl \ push hl ; Go to argument 1
    ld de, (hl)     ; Juggling the dereference of hl
    ld hl, de
    call atoui8     ; Translate the string in hl to uint8_t in a
    ld ($loc), a
    pop hl
    .endm

hdigit .macro $loc
    inc hl \ inc hl \ push hl ; Go to argument 1
    ld de, (hl)     ; Juggling the dereference of hl
    ld hl, de
    call hstoui16     ; Translate the string in hl to uint8_t in a
    ld a, e
    ld ($loc), a
    pop hl
    .endm

wmac:
    ld a, e         ; We want 7 arguments
    cp 7
    jp nz, w_not_ok ; No? Complain.
    hdigit loc_W5500_mac+0
    hdigit loc_W5500_mac+1
    hdigit loc_W5500_mac+2
    hdigit loc_W5500_mac+3
    hdigit loc_W5500_mac+4
    hdigit loc_W5500_mac+5
    call w5500_init
    jp w_ok

wip:
    ld a, e         ; We want 5 arguments
    cp 5
    jp nz, w_not_ok ; No? Complain.
    digit loc_W5500_ip+0
    digit loc_W5500_ip+1
    digit loc_W5500_ip+2
    digit loc_W5500_ip+3
    call w5500_init
    jp w_ok

wmask:
    ld a, e         ; We want 5 arguments
    cp 5
    jp nz, w_not_ok ; No? Complain.
    digit loc_W5500_mask+0
    digit loc_W5500_mask+1
    digit loc_W5500_mask+2
    digit loc_W5500_mask+3
    call w5500_init
    jp w_ok

wgw:
    ld a, e         ; We want 5 arguments
    cp 5
    jp nz, w_not_ok ; No? Complain.
    digit loc_W5500_gw+0
    digit loc_W5500_gw+1
    digit loc_W5500_gw+2
    digit loc_W5500_gw+3
    call w5500_init
    jp w_ok

wspeed:
    ld a, e
    cp 2
    jp nz, w_not_ok
    digit speed
    jp w_ok

wcolor:
    ld a, e
    cp 2
    jp nz, w_not_ok
    digit color
    jp w_ok

walarm:
    ld a, e
    cp 2
    jp nz, w_not_ok
    digit alarm
    jp w_ok

w_not_ok:
    ld hl, w_not_ok_str
    call sio_prstr_nl
    ret
w_not_ok_str:   .db "Parameters not correct.",0
w_ok:
    ld hl, w_ok_str
    call sio_prstr_nl
    ret
w_ok_str:   .db "OK.",0
speed: .db 10
color: .db 0x80
alarm: .db 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

w5500_init:
    ret

w5500_cyclic:
    ret




wtest:
    printhl "dit is hl"
    ld hl, 0x1234
    printhl "en nu is het dit"
    printa "nu is dit a"
    printa "nu is het dit"
    ld a, 0x12
    printa "en nu na loaden van 0x12 is het dit"
    print "test"
    print "test twee"
    print "test een hele boel woorden op een lijn. Regel. Regel bedoelde ik. Bla die bla bliep bliep"

    ld e, 0
    ld hl, 0x0039
    call w5500_read8
    printa "dit staat in 0x0039:"

    ld hl, 0x0019
    call w5500_read16
    printhl "dit staat in 0x0019:"

    ld a, 0x12
    ld hl, 0x0019
    call w5500_write8
    print "written 0x12 to 0x0019"
    ld a, 0x00

    call w5500_read8
    printa "Readback at 0x0019:"

    ld bc, 0x1234
    call w5500_write16
    print "0x1234 written to 0x0019"

    ld hl, 0x0019
    call w5500_read16
    printhl "Readback from 0x0019:"

    ; Tx test
; --- writebuf test: socket 0 TX buffer, block 2 ---
txtest:
    ; patroon naar TX-buffer @ 0x0000
    ld  hl, 0x0000
    ld  bc, txpat
    ld  de, 8
    ld  a, 2              ; block: socket 0 TX
    call w5500_writebuf

    print "wrote 8 bytes to TX0"

    ; teruglezen naar RAM
    ld  hl, 0x0000
    ld  bc, rxbuf
    ld  de, 8
    ld  a, 2
    call w5500_readbuf

    print "readback:"

    ; dump: 8 bytes hex
    ld  hl, rxbuf
    ld  b, 8
xdump:
    ld  a, (hl)
    call sio_uint8_hex
    push bc
    ld  b, ' '
    call sio_prchr
    pop bc
    inc hl
    djnz xdump
    print " "
    ret

txpat: db 0xde, 0xad, 0xbe, 0xef, 0x00, 0x11, 0x22, 0x33
rxbuf: .block 8


















    ld a, 0x08
    out(0x5e), a

    ld a, 0x00
    out(0x5c), a

    ld a, 0x39
    ld a, 0x1A
    out(0x5c), a

    ld a, 0x00
    out(0x5c), a

    in a, (0x5d)
    in a, (0x5c) 

    push af

    ld a, 0x00
    out(0x5e), a

    pop af
    call sio_uint8


    ret

w5500_addr .equ 0x5C

; Read8 reads one byte from the W5500.
; Input: E - Block number
; Input: HL - Chip address
; Output: A - Readback value
w5500_read8:
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    ld a, e
    sla a \ sla a \ sla a
    ; or 0x00 ; Read, OP mode = 0
    out(w5500_addr), a
    in a, (w5500_addr+1)
    in a, (w5500_addr)
    push af
    ld a, 0x00
    out(w5500_addr+2), a
    pop af
    ret

; Read16 reads two bytes from the W5500.
; Input: E - Block number
; Input: HL - Chip address
; Output: HL - Readback value
w5500_read16:
    push af
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    ld a, e
    sla a \ sla a \ sla a
    ; or 0x00 ; Read, OP mode = 0
    out(w5500_addr), a
    in a, (w5500_addr+1)
    in a, (w5500_addr+1)
    ld h, a
    in a, (w5500_addr)
    ld l, a
    ld a, 0x00
    out(w5500_addr+2), a
    pop af
    ret

; Readbuf reads a buffer from the W5500.
; Input: A - Block number (different from the other functions)
; Input: BC - Local buffer address
; Input: DE - Length (2 or more)
; Input: HL - W5500 buffer address
w5500_readbuf:
    push af
    push bc
    push de
    push hl
    push af
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    pop af
    sla a \ sla a \ sla a
    ; or 0x00 ; Read, OP mode = 0
    out(w5500_addr), a

    in a, (w5500_addr+1)    ; Prime the reader circuit
    dec de                  ; The last read does not need a prime

w5500_readbuf_loop:
    in a, (w5500_addr+1)    ; Read and prime the reader circuit
    ld (bc), a
    dec de
    inc bc

    ld a, d
    or e
    jr nz, w5500_readbuf_loop

    in a, (w5500_addr)      ; Read without priming
    ld (bc), a

    ld a, 0x00
    out(w5500_addr+2), a

    pop af
    pop hl
    pop de
    pop bc
    ret

; Write8 writes one byte to the W5500
; Input: A - Byte to write
; Input E - Block number
; Input HL - chip address
w5500_write8:
    push af
    push af
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    ld a, e
    sla a \ sla a \ sla a
    or 0x04 ; Write, OP mode = 0
    out(w5500_addr), a
    pop af
    out(w5500_addr), a
    ld a, 0x00
    out(w5500_addr+2), a
    pop af
    ret

; Write16 writes two bytes to the W5500
; Input: BC - Bytes to write
; Input E - Block number
; Input HL - chip address
w5500_write16:
    push af
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    ld a, e
    sla a \ sla a \ sla a
    or 0x04 ; Write, OP mode = 0
    out(w5500_addr), a
    ld a, b
    out(w5500_addr), a
    ld a, c
    out(w5500_addr), a
    ld a, 0x00
    out(w5500_addr+2), a
    pop af
    ret

; Writebuf reads a buffer from the W5500.
; Input: A - Block number (different from the other functions)
; Input: BC - Local buffer address
; Input: DE - Length
; Input: HL - W5500 buffer address
w5500_writebuf:
    push af
    push bc
    push de
    push hl
    push af
    ld a, 0x08
    out(w5500_addr+2), a
    ld a, h
    out(w5500_addr), a
    ld a, l
    out(w5500_addr), a
    pop af
    sla a \ sla a \ sla a
    or 0x04                 ; Write, OP mode = 0
    out(w5500_addr), a
    jr w5500_writebuf_loop_start

w5500_writebuf_loop:
    ld a, (bc)
    out (w5500_addr), a
    dec de
    inc bc
w5500_writebuf_loop_start:
    ld a, d
    or e
    jr nz, w5500_writebuf_loop

    ld a, 0x00
    out(w5500_addr+2), a
    pop af
    pop hl
    pop de
    pop bc
    ret


























































