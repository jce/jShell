; Run this in the init section, not log_init
log_startup:
    ld hl, (log_location_c) ; Test if log is sane
    ld bc, log_location_c
    or a
    sbc hl, bc              ; Test if write pointer is larger than log location
    jr c, log_startup_init 
    ld de, log_len_c
    sbc hl, de              ; Test if write pointer - log location is smaller than log length
    jr c, log_startup_init_pass 

log_startup_init:                    
    call log_init           ; Not sane, init log
log_startup_init_pass:

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
    ld hl, show_log_string
    call sio_prstr
    ld hl, log_location_c
    call sio_uint16_hex     ; Show log configuration in one line
    ld hl, show_log_string2
    call sio_prstr
    ld hl, log_len_c                  
    call sio_uint16_hex_nl

    ld hl, (log_location_c) ; Look for the write pointer
    inc hl                  ; Increment one, for the write pointer points at a 0 byte
    call sio_prstr          ; Show that string (second half)
    ld hl, log_location_c   ; Back to the beginning
    inc hl \ inc hl
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

    ld hl, (log_location_c) ; hl is the write pointer
    ld bc, log_location_c + log_len_c - 1; bc is the end pointer. -1 for 2 null characters
    ld (hl), a              ; Put the character
    inc hl                  ; increment write pointer

    ld a, h                 ; Compare write pointer with end pointer.
    cp b                    ; If not equal, return
    jr nz, log_addch_end
    ld a, l
    cp c
    jr nz, log_addch_end

    ld hl, log_location_c   ; If equal, load the log location
    inc hl \ inc hl         ; And increment by two

log_addch_end:
    ld (log_location_c), hl ; Store write pointer
    ld (hl), 0              ; Put a null to terminate the first half
    ret

; init log, initializes the structure. Not to be confused with the init section in main.
; hl - location
; de - size
log_init:
    ld hl, log_location_c
    ld de, log_location_c + log_len_c
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

    ld de, log_location_c   ; 
    inc de \ inc de         ; Write pointer: start 2 positions after beginning
    ld (log_location_c), de ; Store write pointer

    ret

