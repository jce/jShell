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
    call w5500_readback
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
    call w5500_readback
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
    call w5500_readback
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
    call w5500_readback
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
    call w5500_readback
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

w5500_print_reg4:
    ; HL is assumed from context, input for this function
    push af
    ld bc, readbackbuf
    ld de, 4
    ld a, COMMON
    call w5500_readbuf
    ld hl, readbackbuf
    ld b, 4
pr4:
    ld a, (hl)
    call sio_uint8
    push bc
    ld b, ' ' 
    call sio_prchr
    pop bc
    inc hl
    djnz pr4
    pop af
    ret

w5500_print_reg6:
    push af
    ld bc, readbackbuf
    ld de, 6
    ld a, COMMON
    call w5500_readbuf
    ld hl, readbackbuf
    ld b, 6
pr6:
    ld a, (hl)
    call sio_uint8_hex
    push bc
    ld b, ' ' 
    call sio_prchr
    pop bc
    inc hl
    djnz pr6
    pop af
    ret

w5500_readback:
    print "Readback"
    ld e, COMMON
    ld hl, VERSIONR
    call w5500_read8
    printa "Version:"
    ld hl, mactxt \ call sio_prstr \ ld hl, SHAR \ call w5500_print_reg6
    ld hl, iptxt  \ call sio_prstr \ ld hl, SIPR \ call w5500_print_reg4
    ld hl, masktxt\ call sio_prstr \ ld hl, SUBR \ call w5500_print_reg4
    ld hl, gwtxt  \ call sio_prstr \ ld hl, GAR  \ call w5500_print_reg4
    ld hl, sio_newline
    call sio_prstr
    ret    

mactxt  .db "MAC: ",0
iptxt  .db "IP: ",0
masktxt  .db "Mask: ",0
gwtxt  .db "Gateway: ",0
readbackbuf .block 6

w5500_init:
    ld a, 0x80              ; Chip reset command
    ld e, COMMON
    ld HL, MR
    call w5500_write8
w5500_init_loop:
    call w5500_read8
    and 0x80
    jr nz, w5500_init_loop  ; Wait for reset to complete  

    ld a, COMMON
    ld de, 6
    ld BC, loc_W5500_mac
    ld HL, SHAR
    call w5500_writebuf
    ld de, 4
    ld BC, loc_W5500_mask
    ld HL, SUBR
    call w5500_writebuf
    ld BC, loc_W5500_gw
    ld HL, GAR
    call w5500_writebuf
    ld BC, loc_W5500_ip
    ld HL, SIPR
    call w5500_writebuf

    ld a, 2
    call lcd_goto_line
    ld hl, lcdstr_kachel
    call lcd_write_string

    ld a, 3
    call lcd_goto_line
    ld hl, lcdstr_kamer
    call lcd_write_string

    ret

lcdstr_kachel   .db "Tkachel       degC  ",0
lcdstr_kamer    .db "Tkamer        degC  ",0

w5500_cyclic:
    ld e, SOCK0R        ; Check if socket 0 is opened
    ld hl, Sn_SR
    call w5500_read8
    cp 0x22
    jr z, sock_alive
                        ; Sock still closed. Open here
    ld e, SOCK0R
    ld a, 0b00000010    ; Socket is UDP, use none of the blockers
    ld hl, Sn_MR
    call w5500_write8

    ld bc, 5143         ; Set port 5143
    ld hl, Sn_PORT
    call w5500_write16

    ld a, 0b00000001    ; Open socket command
    ld hl, Sn_CR
    call w5500_write8

    ret

sock_alive:             ; Socket is open
    ld e, SOCK0R
    ld hl, Sn_RX_RSR
    call w5500_read16   ; Get RX_RSR
    ld a, l
    or h                ; Test if there is data waiting for us
    jr nz, sock_alive_data
    ret

frlen   .equ    32
sock_alive_data:
    ld (RD_RSR), hl     ; Store the amount in RX buffer

    ld e, SOCK0R \ ld hl, Sn_RX_RD
    call w5500_read16   ; Get RX_RD, The returned hl is the read pointer
    ld (RD_RXRD), hl    ; We need it later

    ld a, SOCK0RX \ ld bc, RDBUF \ ld de, frlen+8 ; ld hl, hl ; frlen+8 for there is 8byte preamble.
    call w5500_readbuf  ; Read 40 bytes. Note that this can be different from RX_RD.
                        ; Lucky for us, there is always 40 bytes to read, so this wont fail.
    ld hl, (RD_RSR)
    ld de, hl
    ld hl, (RD_RXRD)
    add hl, de          ; Increment the read pointer with whatever is present in cache.

    ld bc, hl \ ld e, SOCK0R \ ld hl, Sn_RX_RD
    call w5500_write16  ; Push the incremented read pointer to the W5500

    ld a, 0x40 \ ld e, SOCK0R \ ld hl, Sn_CR
    call w5500_write8   ; Call RECV on the socket.
 
                        ; Test if our frame is indeed frlen bytes long
    ld hl, (RDBUF+6)    ; What is the received frame length?
    ld a, h \ ld h, l \ ld l, a ; Fix the big endian    
    ld de, frlen        ; Len is the expected UDP frame length
    or a                ;
    sbc hl, de          ;
    jr z, sock_alive_data_continue
    ret
sock_alive_data_continue:

    ld a, (RDBUF+8)     ; Magic number checks
    cp 0x36
    ret nz
    ld a, (RDBUF+9)
    cp 0xD2
    ret nz
    ld a, (RDBUF+10)
    cp 0x18
    ret nz
    ld a, (RDBUF+11)
    cp 0x8C
    ret nz
    
    ; From here we have the UDP frame + preamble from the W5500 in RDBUF
    ; There still is a checksum to evaluate, however this is omitted as the data
    ; is not critical to any process and checking can take a lot of CPU time.

;    Debug print code, to display the datagram at the shell output.
;    ld b, 40
;    ld hl, RDBUF
;bufloop:
;    ld a, (hl)
;    call sio_uint8_hex
;    push bc
;    ld b, ' '
;    call sio_prchr
;    pop bc    
;    inc hl
;    djnz bufloop
;    ld hl, sio_newline
;    call sio_prstr

    ld a, (RDBUF+16)    ; Read the alarm status from the datagram
    ld (alarm), a       ; Store the alarm in the internal alarm location.

    ld a, (RDBUF+17)    ; Read the speed from the datagram
    ld (speed), a       ; Store the speed in the internal speed location.

    ld a, (RDBUF+18)    ; Read the temperature -3/x/3 from the datagram
    ld (color), a       ; Store in the color variable.

    ld hl, (RDBUF+20)   ; Read the stove temperature from the datagram
    ld d, l \ ld e, h   ; Big to little endian
    call u16toa_d1      ; String goes to live in hl
    ld a, 2 \ ld b, 7 \ call lcd_goto_line_offset
    call lcd_write_string   ; Uses hl

    ld hl, (RDBUF+22)   ; Read the room temperature from the datagram
    ld d, l \ ld e, h   ; Big to little endian
    call u16toa_d2      ; String goes to live in hl
    ld a, 3 \ ld b, 7 \ call lcd_goto_line_offset
    call lcd_write_string   ; Uses hl

    ret

RD_RXRD .block 2
RD_RSR  .block 2
RDBUF   .block 40

;===============================================================
; Chip interaction functions: Read/write byte/word/buf
;===============================================================

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

    pop hl
    pop de
    pop bc
    pop af
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

; Writebuf writes a buffer to the W5500.
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
    pop hl
    pop de
    pop bc
    pop af
    ret

; =========================================================
; Register definitions
; =========================================================

; W5500 address on the Z80 IObus
w5500_addr .equ 0x5C

; Blocks
COMMON  .equ    0x00
SOCK0R  .equ    0x01
SOCK0TX .equ    0x02
SOCK0RX .equ    0x03
SOCK1R  .equ    0x05
SOCK1TX .equ    0x06
SOCK1RX .equ    0x07
SOCK2R  .equ    0x09
SOCK2TX .equ    0x0A
SOCK2RX .equ    0x0B
SOCK3R  .equ    0x0D
SOCK3TX .equ    0x0E
SOCK3RX .equ    0x0F
SOCK4R  .equ    0x11
SOCK4TX .equ    0x12
SOCK4RX .equ    0x13
SOCK5R  .equ    0x15
SOCK5TX .equ    0x16
SOCK5RX .equ    0x17
SOCK6R  .equ    0x19
SOCK6TX .equ    0x1A
SOCK6RX .equ    0x1B
SOCK7TX .equ    0x1D
SOCK7RX .equ    0x1E
SOCK7R  .equ    0x1F

; Common block
MR          .equ    0x0000
GAR         .equ    0x0001
SUBR        .equ    0x0005
SHAR        .equ    0x0009
SIPR        .equ    0x000F
INTLEVEL0   .equ    0x0013
INTLEVEL1   .equ    0x0014
IR          .equ    0x0015
IMR         .equ    0x0016
SIR         .equ    0x0017
SIMR        .equ    0x0018
RTR         .equ    0x0019
RTC         .equ    0x001B
PTIMER      .equ    0x001C
PMAGIC      .equ    0x001D
PHAR        .equ    0x001E
PSID        .equ    0x0024
PMRU        .equ    0x0026
UIPR        .equ    0x0028
UPORTR      .equ    0x002C
PHYCFGR     .equ    0x002E
VERSIONR    .equ    0x0039

; Socket block
Sn_MR       .equ    0x0000
Sn_CR       .equ    0x0001
Sn_IR       .equ    0x0002
Sn_SR       .equ    0x0003
Sn_PORT     .equ    0x0004
Sn_DHAR     .equ    0x0006
Sn_DIPR     .equ    0x000C
Sn_DPORT    .equ    0x0010
Sn_MSSR     .equ    0x0012
Sn_TOS      .equ    0x0015
Sn_TTL      .equ    0x0016
Sn_RXBUF_SIZE   .equ    0x001E
Sn_TXBUF_SIZE   .equ    0x001F
Sn_TX_FSR   .equ    0x0020
Sn_TX_RD    .equ    0x0022
Sn_TX_WR    .equ    0x0024
Sn_RX_RSR   .equ    0x0026
Sn_RX_RD    .equ    0x0028
Sn_RX_WR    .equ    0x002A
Sn_IMR      .equ    0x002C
Sn_FRAG     .equ    0x002D
Sn_DPALVTR  .equ    0x002F
















































