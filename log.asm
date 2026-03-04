; Run in the init section
log_startup:
    ; Create a shutdown record
    ld hl, ctime_buf        ; Dirty hack to get the shutdown time approximately
    call log_add_str    
    ld a, ' '
    call log_addch
    ld hl, log_shutdown_str
    call log_add_str
    ld a, 13
    call log_addch
    ld a, 10
    call log_addch         

    ; Create a startup record
    call ctime
    call log_add_str
    ld a, ' '
    call log_addch
    ld hl, log_startup_str
    call log_add_str
    ld hl, jshellname
    call log_add_str
    ld a, ' '
    call log_addch
    ld hl, jshellver
    call log_add_str

    ld a, ' '
    call log_addch
    ld de, init
    ld hl, log_buf
    push hl
    call ui16tohs
    pop hl
    call log_add_str

    ld a, 13
    call log_addch
    ld a, 10
    call log_addch

    ret
log_buf: .db "0000",0
log_shutdown_str: .db "Shutdown",0
log_startup_str: .db "Startup ",0
    
; Call from jshell, show log file
log_show:
    push hl
    ld hl, show_log_string
    call sio_prstr
    ld hl, (log_location)
    call sio_uint16_hex     ; Show log configuration in one line
    ld hl, show_log_string2
    call sio_prstr

    ld bc, (log_location)
    ld ix, (log_location)
    ld hl, (ix+0)
    or 0                    ; Clear C flag
    sbc hl, bc
    inc hl                  
    call sio_uint16_hex_nl
    pop hl

    ld hl, (ix+2)           ; Look for the write pointer
    inc hl                  ; Increment one, for the write pointer points at a 0 byte
    call sio_prstr          ; Show that string (second half)
    ld hl, (log_location)   ; Back to the beginning
    ld bc, 4
    add hl, bc
    call sio_prstr          ; Show this string as well (first half)
    ret
show_log_string: .db "Log at: ",0
show_log_string2: .db " length: ",0

; Call from jshell, add a line to the log with date time stamp.
; hl - pointer to string to add to the log
log_add:
    push hl
    call ctime
    call log_add_str
    ld a, ' '
    call log_addch
    pop hl
    call log_add_str
    ld a, 13
    call log_addch
    ld a, 10
    call log_addch
    ld hl, lcd_ok_text
    call sio_prstr_nl
    ret

; Adds string to log
; hl - pointer to string
log_add_str:
    ld a, (hl)
    cp 0
    ret z
    ld b, a
    push hl
    call log_addch
    pop hl
    inc hl
    jr log_add_str

; Add a single character to the log
; a - input character
log_addch:
;    ld d, a
;    ld ix, (log_location)   ; leave if write pointer is 0xffff
;    ld bc, (ix+2)           ; which is never the case for RAM uninitialised RAM :(
;    ld a, b
;    and c
;    cp 0xff
;    ret z
;    ld a, d

    ld ix, (log_location)
    ld hl, (ix+2)           ; hl is the write pointer
    ld bc, (ix+0)           ; bc is the end pointer
    ld (hl), a              ; Put the character
    inc hl                  ; increment write pointer

    ld a, h                 ; Compare write pointer with end pointer.
    cp b                    ; If not equal, return
    jr nz, log_addch_end
    ld a, l
    cp c
    jr nz, log_addch_end

    ld hl, (log_location)   ; If equal, load the log location
    inc hl                  ; And increment by four
    inc hl
    inc hl
    inc hl
    ld (ix+2), hl           ; Store write pointer
    jr log_addch_end

log_addch_end:
    ld (ix+2), hl           ; Store write pointer
    ld (hl), 0              ; Put a null to terminate the first half
    ret

; init log, initializes the structure. Not to be confused with the init section in main.
; hl - location
; de - size
log_init:
    ld (log_location), hl   ; Store the location in application memory
    add hl, de              ; hl contains end location
    ld de, hl               ; de changes from size to end location
    ld hl, (log_location)   ; Start from the beginning
                            ; hl is write pointer, de is end pointer
log_init_continue:          ; Fill the whole block with zeroes
    ld (hl), 0              ;
    inc hl
    ld a, h
    cp d
    jr nz, log_init_continue
    ld a, l
    cp e
    jr nz, log_init_continue

    ld hl, (log_location)   ; Back to the beginning
    dec de
    ld (hl), de             ; Store end location
    inc hl
    inc hl
    ld de, hl
    inc de
    inc de
    ld (hl), de             ; Store write pointer: 4 past beginning

    ld hl, lcd_ok_text
    call sio_prstr_nl
    ret

log_location: .dw 0xA000
