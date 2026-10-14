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
speed: .db 0x80

wcolor:
    ld a, e
    cp 2
    jp nz, w_not_ok
    digit color
    jp w_ok
color: .db 0x80

walarm:
    ld a, e
    cp 2
    jp nz, w_not_ok
    digit alarm
    jp w_ok
alarm: .db 0

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
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

w5500_init:
    ret

w5500_cyclic:
    ret























