jshellname:
    .db 'jShell', 0
jshellver:
    .db '0.2.9', 0
jshellprompt:
    .db ">", 0

ctest: .db "test", 0
c_:    .db "?", 0
cls:   .db "ls", 0
chelp: .db "help", 0
cerror:.db "error", 0
clcd:  .db "lcd", 0
cin:   .db "in", 0
cout:  .db "out", 0
cfill: .db "fill", 0
cread: .db "read", 0
;cwrite:.db "write", 0
ccopy: .db "copy", 0
cpwm:  .db "pwm", 0
cret:  .db "ret", 0
chl:   .db "hl", 0
chexload:.db "hexload", 0
csp:   .db "sp", 0
cclock:.db "clock", 0
clog:  .db "log", 0
csf1:  .db "sf", 0
csf2:  .db "stackframe", 0
cdump: .db "dump", 0
commands:
    .dw c_,     help
    .dw cls,    help
    .dw chelp,  help
    .dw ctest,  test
    .dw cerror, error
    .dw clcd,   lcd
    .dw cin,    in
    .dw cout,   out
    .dw cfill,  fill
    .dw cread,  read
;    .dw cwrite, write
    .dw ccopy,  copy
    .dw cpwm,   fpwm
    .dw cret,   fret
    .dw chl,    fhexload
    .dw chexload,fhexload
    .dw csp,    fsp
    .dw cclock, clock
    .dw clog,   log
    .dw csf1,   stackframe
    .dw csf2,   stackframe
    .dw cdump,  dump
    .db 0, 0

error:
    ld hl, err0 \ call sio_prstr_nl
    ret
err0: .db "Error is terror!",0

help:
    ld hl, jshellname   \ call sio_prstr
    ld b, ' '           \ call sio_prchr
    ld hl, jshellver    \ call sio_prstr
    ld b, ' '           \ call sio_prchr
    ld hl, help0        \ call sio_prstr_nl
    ld hl, help1        \ call sio_prstr_nl
    ld hl, help2        \ call sio_prstr_nl
    ld hl, help3        \ call sio_prstr_nl
    ld hl, help4        \ call sio_prstr_nl
    ld hl, help5        \ call sio_prstr_nl
    ld hl, help6        \ call sio_prstr_nl
    ld hl, help7        \ call sio_prstr_nl
    ld hl, help8        \ call sio_prstr_nl
    ld hl, help9        \ call sio_prstr_nl
;    ld hl, helpa        \ call sio_prstr_nl
    ld hl, helpb        \ call sio_prstr_nl
    ld hl, helpc        \ call sio_prstr_nl
    ld hl, helpd        \ call sio_prstr_nl
    ld hl, helpe        \ call sio_prstr_nl
    ld hl, helpf        \ call sio_prstr_nl
    ld hl, helpg        \ call sio_prstr_nl
    ld hl, helph        \ call sio_prstr_nl
    ld hl, helpi        \ call sio_prstr_nl
    ld hl, helpj        \ call sio_prstr_nl
    ld hl, helpk        \ call sio_prstr_nl
    ret
help0: .db "Help function.", 0
help1: .db " ", 0
help2: .db "help, ls, ? - Display this help.", 0
help3: .db "test - Run the test function.", 0
help4: .db "error - Simple error notification.", 0
help5: .db "lcd [0-3] <text> - Write to LCD screen.", 0
help6: .db "in [0-ff] - Read input register.", 0
help7: .db "out [0-ff] [0-ff] - Write output register.", 0
help8: .db "fill [0-ffff] [0-ffff] [0-ff] - Fill memory from to with value.", 0
help9: .db "read [0-ffff] [0-ffff] - Read memory from len.", 0
;helpa: .db "write [0-ffff] [0-ff]: Write, location, value.", 0
helpb: .db "copy [0-ffff] [0-ffff] [0-ffff] - Copies from, to for length.", 0
helpc: .db "pwm [on/off] turns the blinking animation on out0 on or off.", 0
helpd: .db "ret - Returns from jshell (exit).", 0
helpe: .db "hl, hexload - starts the hexloader.", 0
helpf: .db "sp - print the current stack pointer value.", 0
helpg: .db "clock - No parameters: Tell date and time. 6 parameters: Configure date and time: day month year hour minute second.", 0
helph: .db "log [arguments] - No arguments: Show log file. Arguments: Add to log file.", 0
helpi: .db "log init [location 0-FFFF] [size 0-FFFF] - Initialize the logfile.", 0
helpj: .db "stackframe, sf - Experiment with stackframe technique(s).", 0
helpk: .db "dump - Dump 0x000 to 0xF000 as intel hex.", 0

; A command gets argc in e and argv in hl

; yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
log:
    ld a, e         ; Hunt for "log" (no arguments)
    cp 1
    jr nz, log_with_arguments
    call log_show
    ret

log_with_arguments:
    ld a, e         ; Hunt for "log init aaaa bbbb"
    cp 4            ; 4 words? 
    jr nz, log_not_init ; No? not log init.
    push hl         ; Remember hl
    push de         ; Remember de
    inc hl          ; Increment to word 1 (counting from 0)
    inc hl          ;
    ld de, (hl)     ; Get the string pointer from argv
    ld hl, de       ;
    ld de, str_init ;
    call strcmp     ; Compare to "init"
    pop de    
    pop hl
    jr nz, log_not_init ; No? Not log init.
                    ; Okay, we are satisfied that it is "log init"
    inc hl          ; Increment to second parameter.
    inc hl          ; 
    inc hl          ; 
    inc hl          ; 
    push hl         ;
    ld bc, (hl)     ; Read the string pointer from
    ld hl, bc       ;   argv.
    call hstoui16   ; Reads uint16 from hl, outputs to de.
    ld bc, de       ; Remember the result in bc
    pop hl

    inc hl          ; Increment to third parameter.
    inc hl          ; 
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads uint16 from hl, outputs to de.
    ld hl, bc       ; Remember bc

    call log_init

    ret

log_not_init:
    inc hl
    inc hl
    dec e
    call merge_arguments

    ld de, (hl)
    ld hl, de
    call log_add
    ret

; function that merges arguments 0-n, changing intermediate
; zeroes for spaces. Very un unix, to first separate the arguments
; to just later glue them back together. Anyways... 
; e - argc
; hl - argv
merge_arguments:
    ld a, e         ; Test for 0 or 1 arguments
    cp 0            ;
    ret z           ;
    cp 1
    ret z

    push hl
    push de
    push bc
    ld bc, (hl)     ; store start pointer in bc
    dec e           ; need the one but last pointer, to the last item
merge_arguments_end_loop:
    inc hl
    inc hl
    dec e
    jr nz, merge_arguments_end_loop
    ld de, (hl)     ; store the pointer in hl
    ld hl, de
    or a            ; carry needs to be 0
    sbc hl, bc      ; subtract begin from end, hl is now length
    ld de, hl       ; store in de

merge_arguments_replace_loop:
    ld a, (bc)
    cp 0
    jr nz, merge_arguments_pass
    ld hl, bc
    ld (hl), ' '
merge_arguments_pass:
    inc bc
    dec de
    ld a, d
    or e
    jr nz, merge_arguments_replace_loop    

    pop bc
    pop de
    pop hl
    ret

str_init: .db "init", 0
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
clock:
    ld a, e
    cp 1
    jr z, clock_print_time
    cp 7
    jr z, clock_set_time
    ld hl, clock_err_text
    call sio_prstr_nl
    ret

clock_print_time:
    call ctime
    call sio_prstr_nl
    ret

clock_set_time:
    ld ix, ds1302_wv
    ld bc, hl

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+3), e

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+4), e

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+6), e

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+2), e

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+1), e

    inc bc
    inc bc
    ld hl, bc
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld (ix+0), e

    call ds1302_write
    ret

clock_s: .db "Date and time: ",0
clock_err_text: .db "Give no parameters to tell the time, 6 to set the date and time: day month year hour minute second.",0
; -----------------------------------------------------------------------------------------------
fsp:
    ld hl, spstr
    call sio_prstr
    ld hl, 0
    add hl, sp
    call sio_uint16_hex_nl
    ret

fhexload:
    ld hl, hlwarning
    call sio_prstr_nl
    ld b, hexload_end - hexload
    ld ixh, 0xff
    ld ixl, 256 - (hexload_end - hexload)    
    ld iy, hexload
hexloadcopy:
    ld a, (iy)
    ld (ix), a
    inc iy
    inc ix
    djnz hexloadcopy
    jp 0xff00 + 256 - (hexload_end - hexload)
    ;call hexload
    ret
spstr: .db "SP: ",0
hlwarning: .db "Copying hexloader to stack (overwriting stack)",0

; |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
fret:
    ld a, 0
    ld (run_enabled), a
    ret

; \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
fpwm:
    inc hl
    inc hl
    ld de, (hl)
    ld hl, onstr
    call strcmp
    jr z, onfound
    ld hl, offstr
    call strcmp
    jr z, offfound
    ld hl, nonefound
    call sio_prstr_nl
    ret
onfound:
    call main_enablepwm
    ld hl, lcd_ok_text
    call sio_prstr_nl
    ret

offfound:
    call main_disablepwm
    ld hl, lcd_ok_text  
    call sio_prstr_nl
    ret

onstr:  .db "on",0
offstr: .db "off",0
nonefound: .db "No parameter found or recognized",0

; ///////////////////////////////////////////////////////////////////////////////////////////////
copy:
    ld a, e         ; Complain if not enough arguments
    cp 4
    jp c, copy_toofew_f

    inc hl          ; First argument is function name.
    inc hl          ; We want the second argument/first parameter.

    push hl         ; Remember hl
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld ixh, d       ; Cheating! This is an undocumented opcode!
    ld ixl, e       ; But how else do you get de in ix? push and pop?
    pop hl

    inc hl          ; Increment to second parameter.
    inc hl          ; 
    push hl         ;
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ld iyh, d
    ld iyl, e
    pop hl

    inc hl          ; Increment to second parameter.
    inc hl          ; 
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ld hl, de       ;

    ; now we have
    ; ix - from where
    ; iy - to where
    ; hl - length

copy_loop:
    ld a, h                 ;
    or l                    ;
    ret z                   ; return if no bytes left
    ld a, (ix)              ; load (ix) to a
    ld (iy), a              ; write a in (iy)
    inc ix                  ;
    inc iy                  ; increment pointers
    dec hl                  ; decrement byte counter
    jr copy_loop            ;

copy_toofew_f:
    ld hl, copy_toofew
    call sio_prstr_nl
    ret
copy_toofew: .db "Too few arguments. Please supply 3 arguments, from, to and length.",0
; ///////////////////////////////////////////////////////////////////////////////////////////////

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
fill:
    ld a, e         ; Complain if not enough arguments
    cp 4
    jp c, fill_toofew_f

    inc hl          ; First argument is function name.
    inc hl          ; We want the second argument/first parameter.

    push hl         ; Remember hl
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld bc, de
    pop hl

    inc hl          ; Increment to second parameter.
    inc hl          ; 
    push hl
    inc hl          ; Increment to third parameter
    inc hl          ; 
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ld a, e         ; We need only the first byte of the conversion
    pop hl

    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.

    ; now we have
    ; bc - from where
    ; de - to where
    ; a - value to fill memory with

    ld hl, bc               ; Count in hl, start at bc (from value), freeing bc
    ld b, a                 ; now b is the fill value

fill_loop:
    ld a, h                 ;
    cp d                    ; compare high byte of de (to where)
    jr nz, fill_continue     ; continue if not equal
    ld a, l                 ;
    cp e                    ; compare low byte of de (to where)
    jr nz, fill_continue     ; continue if not equal
    ret                     ; Low and high byte are equal, we arrived at the end.
fill_continue:    
    ld (hl), b              ; write value b to memory location hl
    inc hl                  ; increment hl
    jr fill_loop

fill_toofew_f:
    ld hl, fill_toofew
    call sio_prstr_nl
    ret
fill_toofew: .db "Too few arguments. Please supply 3 arguments, from, to and value.",0

read:
    ld a, e         ; Complain if not enough arguments
    cp 3
    jp c, read_toofew_f

    inc hl          ; First argument is function name.
    inc hl          ; We want the second argument/first parameter.

    push hl         ; Remember hl
    ld de, (hl)     ; Read the string pointer from argv.
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld bc, de
    pop hl

    inc hl          ; Increment to third parameter
    inc hl          ; 
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ld a, e         ; We need only the first byte of the conversion

    ; now we have
    ; bc - from where
    ; de - length
    ld hl, bc
    call view
    ret

;    ld hl, bc
;read_loop:
;    ld a, d                 ;
;    or e                    ; Return if de is zero
;    ret z
;    ld a, (hl)
;    call sio_uint8_hex_nl
;    inc hl
;    dec de
;    jr read_loop

read_toofew_f:
    ld hl, read_toofew
    call sio_prstr_nl
    ret
read_toofew: .db "Too few arguments. Please supply 2 arguments, from and len.",0

;write:
;    ld hl, helpa
;    call sio_prstr_nl
;    ret

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
in:
    ld a, e                 ; Complain if not enough arguments
    cp 2
    jp c, in_toofew 

    inc hl          ; First argument is function name.
    inc hl          ; We want the second argument.
    ld de, (hl)     ; Read the string pointer from.
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ld b, d         ; Top half of address bus.
    ld c, e         ; Bottom half of address bus.
    in a, (c)       ; Read input e.
    call sio_uint8_hex
    ld b, 13
    call sio_prchr
    ld b, 10
    call sio_prchr
    ret
in_toofew:
    ld hl, in_toofew_text
    call sio_prstr_nl
    ret
in_toofew_text: .db "Too few arguments, Please supply 1 argument.", 0

out:
    ld a, e                 ; Complain if not enough arguments
    cp 3
    jp c, out_toofew 

    inc hl          ; First argument is function name.
    inc hl          ; We want the second argument.
    ld de, (hl)     ; Read the string pointer from argv.
    push hl         ; Remember hl
    ld hl, de       ;  
    call hstoui16   ; Reads string from hl, outputs to de.
    ld bc, de
    pop hl
    inc hl          ; Increment past first parameter.
    inc hl          ; 
    ld de, (hl)     ; Read the string pointer from
    ld hl, de       ;   argv.
    call hstoui16   ; Reads string from hl, outputs to de.
    ; now we have:
    ;   -hf destroyed
    ;   -bc value of the address bus of the output
    ;   -(d)e value to write to the output
    out (c), e
    ret
out_toofew:
    ld hl, in_toofew_text
    call sio_prstr_nl
    ret
out_toofew_text: .db "Too few arguments, Please supply 2 arguments.", 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; Test function: Test the arguments, display as list
; A command gets argc in e and argv in hl
test:
    ld b, e

    ld de, hl
    ld hl, teststr
    call sio_prstr
    ld hl, de


test_argument:
    push hl
    ld de, (hl)

    ld hl, de
    ;call sio_uint16_hex
    call sio_prstr
    ld hl, newlinestr
    call sio_prstr
    pop hl

    inc hl
    inc hl
    djnz test_argument

    ld hl, x
    call hstoui16
    ld hl, de
    call sio_uint16_hex

    ld hl, testbuf
    ld a, 0x9
    call ui4tohs
    ld a, 0xA
    call ui4tohs
    ld a, 0x65
    call ui8tohs
    ld de, 0xDEAD
    call ui16tohs
    ld (hl), 0
    ld hl, testbuf
    call sio_prstr_nl

    ret

teststr:
    .db "Hello this is the test program.", 13, 10, 0
newlinestr:
    .db 13, 10, 0
x:
    .db "1234",0
testbuf:
    .block 20

; ----------------------------------------------------------------------------------------------
; LCD write function
; e is argc, hl is argv
lcd:
    ld a, e                 ; Complain if not enough arguments
    cp 2
    jp c, lcd_toofew 

    inc hl
    inc hl                  ; Increment to the next commandline parameter
    push hl
    ld bc, (hl)             ; It contains a string pointer. Read the pointer.
    ld hl, bc
    ld a, (hl)              ; Read the first character that is pointed at.
    sub '0'                 ; One digit conversion to uint8_t
    pop hl
    
    cp 4                    ; Complain if line is 4 or higher
    jp nc, lcd_notline

    inc hl
    inc hl                  ; Increment to next commandline parameter
    dec e
    dec e                   ; Update e for 2 removed parameters

    call lcd_clear_line
    call lcd_goto_line

    ld a, e                 ; If there are no more arguments
    cp 0                    ; clear the line and 
    jr z, lcd_end           ; done.

    call merge_arguments    ; Merge arguments from this position (e, hl)
    push hl
    push de
    ld de, (hl)
    ld hl, de
    call lcd_write_string   ; Write that string to the lcd
    pop de                  ;
    pop hl                  ;
    
    jr lcd_end              ;

lcd_end:
    ld hl, lcd_ok_text
    call sio_prstr_nl
    ret

lcd_notline:
    ld hl, lcd_notline_text
    call sio_prstr_nl
    ret

lcd_toofew:
    ld hl, lcd_toofew_text
    call sio_prstr_nl
    ret
lcd_ok_text:        .db "OK.",0
lcd_toofew_text:    .db "Too few arguments. Need at least 2 (line, text)",0
lcd_notline_text:   .db "Too high line. Line should be [0-3].",0

; =========================================================================================================
; ===============jshell function for cyclic calling. It does the serial port polling ======================
; =========================================================================================================
jshell:
    push af
    push bc
    push de
    push hl

    ; get character
    call sio_getch

    ; return if no character recieved
    jr z, jshellend

    ; Test if backspace is received.
    cp 8           ; cr
    jr z, jshellbackspace

    ; Test if carriage return is received.
    cp 13           ; cr
    jr nz, jshellnotreturn

    ; Carriage return received!
    ; End the buffer with a zero
    ld a, 0
    ld hl, (bufw)
    ld (hl), a

    ; Draw a newline
    ld b, 13        ; cr
    call sio_prchr
    ld b, 10        ; lf
    call sio_prchr
    
    ; Process the received command
    call jshellprocess

    ; Reset the receive buffer
    ld a, 0
    ld (buflen), a
    ld hl, buf
    ld (bufw), hl

    ; Draw the prompt
    ld hl, jshellprompt
    call sio_prstr

    jr jshellend

jshellbackspace:
    ; if buflen > 0
    ;   buflen --
    ;   backspace, space, backspace to terminal
    ld a, (buflen)
    or a
    jr z, jshellend
    dec a
    ld (buflen), a
    ld hl, (bufw)
    dec hl
    ld (bufw), hl
    ld b, 8         ; backspace
    call sio_prchr
    ld b, 32        ; space
    call sio_prchr
    ld b, 8         ; backspace
    call sio_prchr
    jp jshellend 

    ; Carriage return is not received
jshellnotreturn:
    ld c, a

    ; If buffer is full, ignore character
    ld a, bufmaxlen
    ld b, a
    ld a, (buflen)
    cp b
    jp nc, jshellend

    ; Echo to serial
    ld b, c
    call sio_prchr

    ; Write to buffer
    ld a, c
    ld hl, (bufw)
    ld (hl), a    
       
    ; Write buffer length
    ld a, (buflen)
    inc a
    ld (buflen), a

    ; Increment buffer pointer
    ld hl, (bufw)
    inc hl
    ld (bufw), hl

jshellend:
    pop hl
    pop de
    pop bc
    pop af
    ret

; ===========================================================================================
; jshell internal: When a full string is entered, process this string
; ===========================================================================================
jshellprocess:
    ld hl, buf          ; replace tabs with spaces
    ld b, 9             ; tab
    ld c, 32            ; space
    call replacecharacters

    ld e, ' '           ; e is the previous character
    ld d, 0             ; d is argc
                        ; c is
                        ; b is
                        

    ; for every character in buf (zero terminated)
    ld hl, buf          ; use bufw as read pointer
    ld (bufw), hl

    ld hl, argv         ; Set the argvw to the beginning of arg
    ld (argvw), hl
process_next_char:
    ld hl, (bufw)
    ld a, (hl)          ; a is the current character
    or a
    jp z, done_separating_argv ; if char is 0, finished separating in argv

    ; if previous character is whitespace and current character is non whitespace: new arg
    cp ' '         
    jp z, next_char     ; If the current character is whitespace, next char 
    ld a, e
    cp ' '
    jr nz, next_char    ; If the previous character is not whitespace, next char

    ; New argument. It is in hl, or bufw. Store it in argvw.
    ld bc, hl
    ld hl, (argvw)
    ld (hl), bc
    inc hl              ; Increment argvw 2 places
    inc hl
    ld (argvw), hl
    inc d               ; Increment argc
    ld a, d
    ld (argvlen), a

    ; If argument counter is max, done_separating_argv
    ld a, d
    cp argvmaxlen
    jr z, done_separating_argv

next_char:
    ld hl, (bufw)       ;
    ld a, (hl)          ; 
    ld e, a             ; store previous char in e
    inc hl              ; Increment bufw    
    ld (bufw), hl       ;
    jr process_next_char; Return to the process loop

done_separating_argv:
    ld a, d
    ld (argvlen), a     ; Store argc to ram
    ld hl, buf          ; replace spaces by null characters
    ld b, 32            ; space
    ld c, 0             ; null
    call replacecharacters

    ld a, d
    or a
    ret z               ; Return if there are 0 arguments


    ; Find a command that is argv[0] and call that
    ld ix, commands     ; ix is a pointer to the commands list. Items are 4 long: [strh][strl][cmdh][cmdl]
    ld de, (argv)       ; de is a pointer to the first argument

next_command:
    ld a, (ix)          ; ix contains a pointer, need to check two bytes
    ld b, a
    ld a, (ix+1)
    or b
    ret z               ; Return if there is no more command to test

    ld de, (ix)         ;
    ld hl, (argv)
    inc ix
    inc ix
    call strcmp         ; compares de and hl
    jr z, command_match
    inc ix
    inc ix
    jp next_command
   
command_match:
    ld bc, (ix)         ; Read the function pointer from ix.
    ld iy, bc           ; And store it in iy.
    
    ; We cannot call(hl), so we fake a return pointer.
    ld hl, jshell_command_return
    push hl

    ; Prepare e and hl as argc and argv
    ld a, (argvlen)     ;
    ld e, a             ; e is argc
    ld hl, argv         ; hl is argv
    jp (iy)             ; The return pointer is on stack, so we jump instead of call()

jshell_command_return:
    ret

;======================================================================================
replacecharacters:
    ; Return if zero
    ld a, (hl)
    or a
    ret z

    ; If character is b, replace it by c
    cp b
    jp nz, replacecharacters_pass
    ld (hl), c

replacecharacters_pass:
    inc hl
    jp replacecharacters

buf:
    .block 201
bufw:
    .dw buf
buflen:
    .db 0
bufmaxlen equ 200

argv:
    .block 40
argvw:
    .dw argv
argvlen:
    .db 0
argvmaxlen equ 20
