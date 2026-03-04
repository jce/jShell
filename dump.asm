; Assembly to dump the content of almost all the ram content, only avoiding the
; stack area so a new download will work fine.


; A command gets argc in e and argv in hl
dump:
    sfo 77  ; Give us a temporary string with 9 + 2 * 32 + 4 positions
    ld de,0 ; Read pointer    

dump_line:
    ld c, 0         ; C is the sum for checksum
    ld a, ixh
    ld h, a
    ld a, ixl
    ld l, a
    ld (hl), ':'    ; Start record
    inc hl
    ld (hl), '2'    ; 0x20 length
    inc hl
    ld (hl), '0'
    inc hl
    ld c, 0x20
    call ui16tohs   ; hl - pointer where to write, incremented, de - value, memory address
    ld a, c         ; Add byte values to checksum
    add a, d
    add a, e
    ld c, a
    ld (hl), '0'    ; Record type 0x00
    inc hl
    ld (hl), '0'
    inc hl
    ld a, c         ; Add record type to checksum. May be omitted for it is 0, but still...
    add a, 0x00
    ld c, a
    ld b, 0x20
dump_byte:
    ld a, (de)
    call ui8tohs    ; Add content of byte de
    add a, c
    ld c, a         ; Sum for checksum
    inc de          ; Increment read pointer
    djnz dump_byte

    ld a, c
    xor a, 0xff
    add a, 0x01     ; two's complement of C is the checksum byte
    call ui8tohs    ; Add the checksum

    ld (hl), 0      ; Zero terminated
    inc hl

    ld a, ixh
    ld h, a
    ld a, ixl
    ld l, a
    call sio_prstr_nl

    ld a, 0xf0
    cp d
    jr nz, dump_line
    ld a, 0x00
    cp e
    jr nz, dump_line

    ; There is another line, that of the end file record. This one is completely constant.
    ld hl, dump_endfilerecord
    call sio_prstr_nl
    


    sfc
    ret

dump_endfilerecord: .db ":00000001FF",0
