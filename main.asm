.ORG $000
init:
int_offs .equ 0x0

    jr proginit ; at 0x8000

.dw sio_isr     ; at 0x8002

proginit:
    ld sp, 0x0
    call lcd_init
    call ds1302_init
    call log_startup       ; needs to be after the clock init
    call SIO_A_RESET

    ld b, 13
    call sio_prchr
    ld b, 10
    call sio_prchr

    ld hl, jshellname
    call lcd_write_string
    ld b, ' '
    call lcd_wrd
    ld hl, jshellver
    call lcd_write_string
    ld b, ' '
    call lcd_wrd

    ld hl, ctime_buf        ; Hack, who needs a clock buffer now?
    ld de, init
    call ui16tohs
    ld a, 0
    ld (ctime_buf + 4), a
    ld hl, ctime_buf
    call lcd_write_string

    ld hl, jshellname
    call sio_prstr
    ld b, ' '
    call sio_prchr
    ld hl, jshellver
    call sio_prstr
    ld b, ' '
    call sio_prchr
    ld hl, init
    call sio_uint16_hex_nl

    ld hl, jshellprompt
    call sio_prstr

    ; Init interrupts, offset at 0x80
    ld a, int_offs
    ld i, a
    IM 2
    ei

    ld a, 1
    ld (run_enabled), a

    ld c, 0
mainloop:
    call main_pwm
    ;call jshell
    call main_clock

    ld a, (run_enabled)
    or a
    jr nz, mainloop
    ret

main_clock:
    ld a, (main_clock_ctr)
    dec a
    or a
    ld b, a
    jr nz, main_clock_pass
    ld b, 0xff
    call ctime
    ld a, 1
    call lcd_goto_line
    call lcd_write_string
main_clock_pass:
    ld a, b
    ld (main_clock_ctr), a
    ret
main_clock_ctr: .db 1

main_pwm:
    ld a, (pwm_enabled)
    or a
    jr z, pwm_enable_pass
    call zero_pwm_data  
    ld a, c
    call sin
    ld b, a
    call rain_in_bins
    call f_pwm
    inc c
    inc c
pwm_enable_pass:
    ret

main_enablepwm:
    ld a, 0xff
    ld (pwm_enabled), a
    ret

main_disablepwm:
    ld a, 0
    ld (pwm_enabled), a
    call zero_pwm_data  
    ret

pwm_enabled: .db 1
run_enabled: .db 1

#include "stackframe.asm"
#include "math.asm"
#include "pwm.asm"
#include "sio.asm"
#include "delay.asm"
#include "hd44780.asm"
#include "strcmp.asm"
#include "jshell.asm"
#include "hstoui.asm"
#include "hexload.asm"
#include "ds1302.asm"
#include "log.asm"
#include "memview.asm"
#include "dump.asm"

.END
