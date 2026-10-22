; A command gets argc in e and argv in hl

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ntpip:
    ld a, e         ; We want 5 arguments to set, other to read back.
    cp 5
    jp nz, ntpip_readback
    digit loc_NTP_ip+0  ; Macro borrowed from w5500.asm
    digit loc_NTP_ip+1
    digit loc_NTP_ip+2
    digit loc_NTP_ip+3
    jp w_ok

ntpip_readback:
    print "NTP ip:"     ; Another macro, this time from macro.asm
    ld a, (loc_NTP_ip+0) \ call sio_uint8 \ ld b, '.' \ call sio_prchr
    ld a, (loc_NTP_ip+1) \ call sio_uint8 \ ld b, '.' \ call sio_prchr
    ld a, (loc_NTP_ip+2) \ call sio_uint8 \ ld b, '.' \ call sio_prchr
    ld a, (loc_NTP_ip+3) \ call sio_uint8 \ ld hl, sio_newline \ call sio_prstr
    jp w_ok

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ntp_request:
    .db 0x1B
    .block 47, 0
ntp_req_time:   .block 1    ; Timeout during NTP request.
ntp_time:       .block 4    ; Readback time value from NTP.
ntp_rp:         .block 2    ; Read pointer for start of message.
ntp_rl:         .block 2    ; The read length, what is present in the read buffer.

ntp:
    ; Check if socket 1 is opened
    ld e, SOCK1R \ ld hl, Sn_SR \ call w5500_read8
    cp 0x22
    jr z, ntp_sock_alive

    ; Sock still closed. Open here
    ; Socket is UDP, use none of the blockers
    ld e, SOCK1R \ ld a, 0b00000010 \ ld hl, Sn_MR \ call w5500_write8

    ; Set port 5144
    ld bc, 5144 \ ld hl, Sn_PORT \ call w5500_write16

    ; Open socket command
    ld a, 0b00000001 \ ld hl, Sn_CR \ call w5500_write8
    print "Socket opened"
ntp_sock_wait:
    ld e, SOCK1R \ ld hl, Sn_SR \ call w5500_read8
    cp 0x22
    jr nz, ntp_sock_wait

ntp_sock_alive:         ; Socket is open
    print "Socket is open"

    ; Get RX_RSR, the receive buffer used.
    ld e, SOCK1R \ ld hl, Sn_RX_RSR \ call w5500_read16

    ld a, l
    or h                ; Test if there is data waiting for us
    jp z, ntp_sock_alive_nodata
    ; Oh crap, there is data waiting for us. We did not request it, it is 
    ; certainly not a valid, up-to-date timestamp. Get rid of it! Shoo!
    print "There is data waiting for us. This is unexected. Cleaning it up..."
    ld bc, hl
    ; Get the current write counter
    ld e, SOCK1R \ ld hl, Sn_RX_RD \ call w5500_read16
    add hl, bc  ; Increment it with the number of bytes ready
    ; Push it back
    ld bc, hl \ ld e, SOCK1R \ ld hl, Sn_RX_RD \ call w5500_write16  
    ; Call RECV on the socket.
    ld a, 0x40 \ ld e, SOCK1R \ ld hl, Sn_CR \ call w5500_write8   
    ; Whew, we cleaned that up good!

ntp_sock_alive_nodata:
    print "No data waiting, going for a request"
    call ntp_request_f

    ; Wait for data or timeout
    ld a, 250               ; 250 x 4 ms = 1 sec
    ld (ntp_req_time), a    ; Store as request reference time   
 
ntp_request_wait:
    ld e, SOCK1R \ ld hl, Sn_RX_RSR \ call w5500_read16
    ld a, l
    or h                ; Test if there is data waiting for us
    jr nz, ntp_sock_alive_data

    ld a, (ntp_req_time)
    or a
    jr z, ntp_timeout
    dec a
    ld (ntp_req_time), a

    ; Crude delay, since shell runs in interrupt context, our uptime counter does not increment.
    ld a, 0 \ ld hl, 4 \ call delay_ms  ; 4 ms steps
    jr ntp_request_wait
    
ntp_timeout:
    print "Timeout"
    ret

ntp_sock_alive_data:
    printhl "There is data waiting for us:"
    ld (ntp_rl), hl     ; Store the amount in RX buffer

    ; Get RX_RD, The returned hl is the read pointer
    ld e, SOCK1R \ ld hl, Sn_RX_RD \ call w5500_read16
    ld (ntp_rp), hl   
    printhl "read pointer"

    ; Read the 2 bytes that contain the preamble length
    ld bc, hl
    ld hl, 6
    add hl, bc
    ld e, SOCK1RX \ call w5500_read16
    ld de, hl           ; Test if this is the expected 48
    ld hl, 48
    or a
    sbc hl, de
    ret nz              ; Jump out if mismatch.

    ; Read the 4 bytes that contain the actual timestamp.
    ld hl, (ntp_rp)
    ld bc, hl
    ld hl, 40
    add hl, bc
    printhl "reading from address"

    ld a, SOCK1RX \ ld bc, ntp_time \ ld de, 4 \ call w5500_readbuf  

    ld hl, (ntp_time)   ; Juggling the bytes to fix big endianness
    ld de, hl
    ld hl, (ntp_time+2)
    ld a, h \ ld h, l \ ld l, a
    ld a, d \ ld d, e \ ld e, a
    ld (ntp_time), hl
    ld hl, de
    ld (ntp_time+2), hl
    
    print "ntp time:"
    ld de, ntp_time \ call uint32tostr_dec_buf
    call sio_prstr
    ld hl, sio_newline \ call sio_prstr

    ld hl, (ntp_rl)
    ld de, hl
    ld hl, (ntp_rp)
    add hl, de          ; Increment the read pointer with whatever is present in cache.

    ; Push the incremented read pointer to the W5500
    ld bc, hl \ ld e, SOCK1R \ ld hl, Sn_RX_RD \ call w5500_write16  

    ; Call RECV on the socket.
    ld a, 0x40 \ ld e, SOCK1R \ ld hl, Sn_CR \ call w5500_write8   
 
    ;Debug print code, to display the datagram at the shell output.
;    ld b, 56
;    ld hl, ntp_reply
;ntp_bufloop:
;    ld a, (hl)
;    call sio_uint8_hex
;    push bc
;    ld b, ' '
;    call sio_prchr
;    pop bc    
;    inc hl
;    djnz ntp_bufloop
;    ld hl, sio_newline
;    call sio_prstr

    call ntp_interpret_timestamp
    ret

ntp_request_f:
    ; Destination IP
    ld a, SOCK1R \ ld bc, loc_NTP_ip \ ld de, 4 \ ld HL, Sn_DIPR \ call w5500_writebuf
    ; Destination Port
    ld bc, 123 \ ld e, SOCK1R \ ld hl, Sn_DPORT \ call w5500_write16    
    ; Write pointer in hl
    ld e, SOCK1R \ ld hl, Sn_TX_WR \ call w5500_read16    
    ; Copy the package content
    ld a, SOCK1TX \ ld bc, ntp_request \ ld de, 48 \ call w5500_writebuf
    ; Increment write pointer
    ld bc, 48
    add hl, bc
    ; Write write-pointer back to w5500
    ld bc, hl \ ld e, SOCK1R \ ld hl, Sn_TX_WR \ call w5500_write16
    ; Kick off the transmission
    ld a, 0x20 \ ld e, SOCK1R \ ld hl, Sn_CR \ call w5500_write8    
ntp_request_loop:
   ; Read command register, only continue if this returns to 0x00
    ld e, SOCK1R \ ld hl, Sn_CR \ call w5500_read8
    or a
    jr nz, ntp_request_loop
    print "NTP request sent"
    ret

ntp_interpret_timestamp:
    print "ntp_interpret_timestamp"
    ret













































