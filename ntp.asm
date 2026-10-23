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

ntpoffs:
    ld a, e
    cp 2
    jp nz, ntpoffs_not_ok
    inc hl \ inc hl
    ld de, (hl)
    ld hl, de
    call atosi8
    ld (loc_NTP_offs), a
    print "OK."
    ret

ntpoffs_not_ok:
    print "Please supply one argument, [-12 - 12]"
    ret

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
    ; Some verification tests
    ; de:hl
    ;print "Certificerings test"
    ;ld d, 0x6A \ ld e, 0xDA \ ld h, 0x4C \ ld l, 0x93 \ call ntp_interpret_timestamp
    ;ld d, 0x01 \ ld e, 0x51 \ ld h, 0x80 \ ld l, 0x00 \ call ntp_interpret_timestamp
    ;ld d, 0x01 \ ld e, 0x51 \ ld h, 0x80 \ ld l, 0x01 \ call ntp_interpret_timestamp
    ;ld d, 0x01 \ ld e, 0x51 \ ld h, 0x7F \ ld l, 0xFF \ call ntp_interpret_timestamp
    ;ld d, 0x02 \ ld e, 0xA3 \ ld h, 0x00 \ ld l, 0x00 \ call ntp_interpret_timestamp
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

ntp_timestamp_to_unix_timestamp:


;    print "ntp_interpret_timestamp"
    ld a, (ntp_time+0) \ ld l, a
    ld a, (ntp_time+1) \ ld h, a
    ld a, (ntp_time+2) \ ld e, a
    ld a, (ntp_time+3) \ ld d, a
    ld a, l \ sub 0x80 \ ld l, a
    ld a, h \ sbc 0x7E \ ld h, a
    ld a, e \ sbc 0xAA \ ld e, a
    ld a, d \ sbc 0x83 \ ld d, a

    
    ld a, l \ ld (ntp_time+0), a
    ld a, h \ ld (ntp_time+1), a
    ld a, e \ ld (ntp_time+2), a
    ld a, d \ ld (ntp_time+3), a
    ret

ntp_interpret_timestamp:
;    push hl
;    push de
;    print "unix time:"
;    ld de, ntp_time \ call uint32tostr_dec_buf
;    call sio_prstr
;    ld hl, sio_newline \ call sio_prstr
;    pop de
;    pop hl

    call ntp_timestamp_to_unix_timestamp
    call ntp_apply_offset
    call ntp_hour_minute_second
    call ntp_year_month_day

    ld a, (hours_in_day) \ printa "Hour:"
    ld (tm+2), a
    ld a, (minutes_in_hour) \ printa "Minute:"
    ld (tm+1), a
    ld a, (seconds_in_minute) \ printa "Second:"
    ld (tm+0), a
    ld a, (year_1900) \ ld h, 0 \ ld l, a \ ld bc, 1900 \ add hl, bc \ printhl "Year:"
    ld bc, 2000 \ or a \ sbc hl, bc \ ld a, l \ ld (tm+5), a
    ld a, (month) \ printa "Month:"
    ld (tm+4), a
    ld a, (day_in_month) \ printa "Day in month:"
    ld (tm+3), a

    print "Setting clock"
    call settime

    ret

ntp_hour_minute_second:
    ; Mistral helped me to this divider (s)
    ; Bigloop: Cuts down in big steps the amount of seconds into days
        ld bc, 0
ntp_big_days:
        ld      a,d
        cp      2
        jr      c, ntp_bd_d1        ; D < 2
        jr      ntp_bd_sub          ; D >= 2: altijd aftrekken
ntp_bd_d1:
        or      a                   ; A = D
        jr      z, day_loop         ; D == 0 → kleine lus
        ld      a,e                 ; D == 1:
        cp      0x51
        jr      c, day_loop         ; E < 0x51
        jr      nz, ntp_bd_sub      ; E > 0x51
        ld      a,h
        cp      0x80
        jr      c, day_loop         ; H < 0x80 (H==0x80 altijd ≥)
ntp_bd_sub:
        or      a                   ; carry=0; L ongemoeid (chunk-lo = 0x00)
        ld      a,h
        sbc     0x80
        ld      h,a
        ld      a,e
        sbc     0x51
        ld      e,a
        ld      a,d
        sbc     0x01
        ld      d,a
        inc     b                   ; dagen += 256
        jr      ntp_big_days
; Small loop, accurate loop.
; ------------------------------------------------------------------
; dagen_lus: DE:HL = unix-tijd
;   uit: BC = dagen sinds 1970-01-01 (0..)
;        DE:HL = seconden-van-vandaag (0..86399 — let op: 17 bits!)
; ------------------------------------------------------------------
day_loop:
        ld a, d
        or a
        jr nz, day_sub        ; D >= 1 → waarde >= 2^24 → altijd aftrekken
        ld a, e
        or a
        jr z, day_done        ; DE == 0 → rest < 65536 < 86400 → klaar
        cp 2
        jr nc, day_sub        ; E >= 2 → waarde >= 131072 → aftrekken
        ; — mesgeval: D==0, E==1 → waarde = 65536 + HL vs 86400 —
        ld a, h
        cp 0x51
        jr c, day_done
        jr nz, day_sub
        ld a, l
        cp 0x80
        jr c, day_done
day_sub:
        ; DE:HL -= 86400 (0x0001:0x5180)
        ld a, l
        sub 0x80
        ld l, a
        ld a, h
        sbc 0x51
        ld h, a
        ld a, e
        sbc 1
        ld e, a
        ld a, d
        sbc 0
        ld d, a
        inc bc
        jp day_loop
day_done:
        ; BC = dagen, DE:HL = seconden-vandaag (DE is 0 of 1)

    ld (days_in_epoch), bc
    ld (seconds_in_day+2), de
    ld (seconds_in_day), hl

    ld d, 60
    call EHL_Div_D
    ; E:HL / D -> E:HL, rest A
    ; E:HL is minutes on the day, A is 0-59, seconds in the minute
    ld (minutes_in_day), hl
    ld (seconds_in_minute), a
    call EHL_Div_D
    ; E:HL is hours on the day, A is minutes in the hour.
    ld (minutes_in_hour), a
    ld a, l
    ld (hours_in_day), a

    ret

days_in_epoch:      .block 2
seconds_in_day:     .block 4
minutes_in_day:     .block 2
seconds_in_minute:  .block 1
minutes_in_hour:    .block 1
hours_in_day:       .block 1
day_in_year:        .block 2
year_1900:          .block 1
month:              .block 1
day_in_month:       .block 1

ntp_apply_offset:
; In/out: DE:HL (unix timestamp)
    ; Applies the offset from loc_NTP_offs in hours
    ld a, (loc_NTP_offs)
    or a
    ret z           ; 0? Return
    jp p, ofs_add   ; Positive?
    neg             ; We work with positive numbers only
ofs_sub:
    ld b, a
ofs_sub_loop:
    or a            ; Reset carry
    ld a, l \ sub 0x10 \ ld l, a
    ld a, h \ sbc 0x0E \ ld h, a
    ld a, e \ sbc 0x00 \ ld e, a
    ld a, d \ sbc 0x00 \ ld d, a
    djnz ofs_sub_loop
    ret
ofs_add:
    ld b, a
ofs_add_loop:
    or a            ; Reset carry
    ld a, l \ add 0x10 \ ld l, a
    ld a, h \ adc 0x0E \ ld h, a
    ld a, e \ adc 0x00 \ ld e, a
    ld a, d \ adc 0x00 \ ld d, a
    djnz ofs_add_loop
    ret

ntp_year_month_day:
    ; Given the number of days since 1 jan 1970 in days_in_epoch
    ; Calculates the year since 1970, month [1-12], day [0-33]
    ld hl, (days_in_epoch)
    ; The Year loop, from Mistral

ntp_cal:
        ld      b,70
cal_yloop:
        ld      e,0
        ld      a,b
        and     3
        jr      nz, cal_len
        ld      a,b
        cp      200
        jr      z, cal_len
        inc     e               ; E = 1 bij schrikkel
cal_len:
        ld      d,1
        ld      a,0x6D
        add     a,e
        ld      e,a             ; DE = 0x016D + flag = 365/366
        or      a               ; carry=0
        sbc     hl,de
        jr      c, cal_ydone
        inc     b
        jr      cal_yloop
cal_ydone:
        add     hl,de           ; herstel: HL = dag-van-het-jaar (0-based)

    ld a, b
    ld (year_1900), a
    ld (day_in_year), hl
    printhl "day of year:"

    ; And the month loop from Mistral

cal_mdone_setup:                  ; na cal_ydone
        ; schrikkelcheck herhalen op B → D-bit 0
        ld      a,b
        and     3
        ld      d,0
        jr      nz, cal_msetup    ; j&3 ≠ 0 → geen schrikkel
        ld      a,b
        cp      200               ; 2100 (j = 2100-1900) → géén schrikkel
        jr      z, cal_msetup
        inc     d                 ; schrikkeljaar → D-bit 0 aan
cal_msetup:
        ld      c,1
        ld      ix,cal_mtab
cal_mloop:
        ld      e,(ix)
        ld      a,c
        cp      2
        jr      nz, cal_mcmp     ; alleen februari past aan
        bit     0,d
        jr      z, cal_mcmp
        inc     e               ; feb 28 → 29
cal_mcmp:
        ld      a,h
        or      a
        jr      nz, cal_msub    ; rest ≥ 256 > 31 → altijd aftrekken
        ld      a,l
        cp      e
        jr      c, cal_mfin     ; rest < lengte → maand vast
cal_msub:
        or      a
        ld      a,l
        sub     e
        ld      l,a
        ld      a,h
        sbc     0
        ld      h,a
        inc     c
        inc     ix
        jr      cal_mloop
cal_mfin:
        inc     hl              ; dag = rest + 1
        ld a, c \ ld (month), a
        ld a, l \ ld (day_in_month), a
        ret
cal_mtab:
        .db     31,28,31,30,31,30,31,31,30,31,30,31

