
; Ramtest will do destructive ram testing. Display results
; ..FF...........................................F................
; one dot per 1 K (0x400). Dot for pass, F for fail
; Keep repeating the whole memory range
; jce, 12-3-2026

ramtest
    ld hl, rtwarning
    call sio_prstr_nl
    ld ix, 0x10000 - (rtend - rtbegin)
    ;ld ixh, 0xff
    ;ld ixl, 256 - (rtend - rtbegin)
    ld hl, 0x0000   ; Pointer where to start testing
    di
    jr rtloadandrun
rtwarning: .db "Copying ram tester to stack (overwriting stack)",0

; Copies the rtfunction (rtbegin to rtend) to ix, then
; sets the stack before rtbegin, then jumps to rtbegin.
; All without touching hl
rtloadandrun:
    ld b, rtend - rtbegin
    ld iy, rtbegin
rtcopy:
    ld a, (iy)
    ld (ix), a
    inc ix
    inc iy
    djnz rtcopy
    ld b, rtend - rtbegin
rtcountback:
    dec ix
    djnz rtcountback
    dec ix
    ld sp, ix
    inc ix
    jp ix

rtbegin:
    ld a, l
    and 0b01111111
    cp 0x00
    jr nz, rtcontinue

    ld b, 13
    call sio_prchr
    ld b, 10
    call sio_prchr
    call sio_uint16_hex ; Prints hl
    ld b, 32
    call sio_prchr
    ld b, 32
    call sio_prchr

rtcontinue:

    ld b, 0x80
    ld e, (hl)

rtcontinue2:
    ld (hl), 0xF0
    ld a, (hl)
    cp 0xF0
    jr nz, rtfail

    ld (hl), 0x0F
    ld a, (hl)
    cp 0x0F
    jr nz, rtfail

    ld (hl), 0x00
    ld a, (hl)
    cp 0x00
    jr nz, rtfail

    ld (hl), 0xFF
    ld a, (hl)
    cp 0xFF
    jr nz, rtfail

    ld (hl), 0b01010101
    ld a, (hl)
    cp 0b01010101
    jr nz, rtfail

    ld (hl), 0b10101010
    ld a, (hl)
    cp 0b10101010
    jr nz, rtfail

    djnz rtcontinue2    

    jr  rtpass
rtfail:
    ld (hl), e
    ld b, 'F'
    call sio_prchr
rtfailloop:
    jr rtfailloop
    jr rtcontinue3    

rtpass:
    ld (hl), e
    ld b, '.'
    call sio_prchr
    jr rtcontinue3

rtcontinue3:
    inc hl
    
    ld a, l
    cp 0x00
    jr nz, rtbegin

    ld a, h

    cp 0xFE
    jr nz, rtcontinue4
    ld ix, 0xFE00 - (rtend - rtbegin)
    jp rtloadandrun
rtcontinue4:

    cp 0x00
    jr nz, rtbegin
    ld ix, 0x10000 - (rtend - rtbegin)
    jp rtloadandrun

rtend:
