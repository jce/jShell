#include "macro.asm"
#include "conf.asm"

init:
    jr proginit ; at 0x8000

.dw sio_isr     ; at 0x8002
    nop
    nop
    nop
    nop
.dw ctc_isr0    ; at 0x8008
.dw ctc_isr1    ; at 0x800A
.dw ctc_isr2    ; at 0x800C
.dw ctc_isr3    ; at 0x800E

proginit:
    ld sp, 0x0
    ; Init interrupts, offset at 0x80
    ld a, int_offs
    ld i, a
    IM 2
    ei
    call lcd_init
    call ds1302_init
    call log_startup       ; needs to be after the clock init
    call SIO_A_RESET
    call ctc_init
    call trap_init          ; Needs to be after SIO_A
    call jshell_init
    call neo_init

    ld b, 13
    call sio_prchr
    ld b, 10
    call sio_prchr
strange:
    ld hl, jshellname
    call lcd_write_string
    ld b, ' '
    call lcd_wrd
    ld hl, jshellver
    call lcd_write_string
    ld b, ' '
    call lcd_wrd

    ld hl, main_locbuf
    ld de, init
    call ui16tohs
    ld hl, main_locbuf
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

    ld a, 1
    ld (run_enabled), a
    ld (neo_enabled), a

    ld c, 0
mainloop:
    call main_pwm
    ;call jshell
    call main_clock
    call main_command
    call main_neo    

    ld a, (run_enabled)
    or a
    jr nz, mainloop
    ret

main_clock:
    ld a, (ctc_s_flag)    
    or a
    jr z, main_clock_pass

    ld a, 0
    ld (ctc_s_flag), a
    call ctime
    ld a, 1
    call lcd_goto_line
    call lcd_write_string
main_clock_pass:
    ret

main_pwm:
    ld a, 0x00
    out (0), a
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

main_neo:
    ld a, (neo_enabled)
    cp 0x01
    jr z, main_neo_on
    cp 0x02
    jr z, main_neo_shutdown
    ret

main_neo_on:
    ld a, (neo_step)
    inc a
    cp 120
    jr nz, main_neo_continue
    ld a, 0
main_neo_continue:
    ld (neo_step), a
    push bc
    call neo_cyclic
    pop bc
    ret

main_neo_shutdown:
    ld a, 0
    ld (neo_enabled), a
    call neo_off
    ret

main_enableneo:
    ld a, 0x01
    ld (neo_enabled), a
    ret

main_disableneo:
    ld a, 0x02
    ld (neo_enabled), a
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

main_command:
    ld a, (main_cmd)
    cp 1    ; ret
    jr nz, main_command_2
    xor a
    ld (run_enabled), a
main_command_2:
    cp 2
    jr nz, main_command_3
    di
main_command_3:
    cp 3
    jr nz, main_command_4
    ei
main_command_4:
    cp 4
    jr nz, main_command_5
    ld hl, (main_goto)
    push hl
    xor a
    ld (main_cmd), a
    ret
main_command_5:
    cp 5
    jr nz, main_command_6
    xor a
    ld (main_cmd), a
    rst 0
main_command_6:
    xor a
    ld (main_cmd), a
    ret

pwm_enabled:    .db 0
neo_enabled:    .db 1
neo_step:       .db 0
run_enabled:    .db 1
main_cmd:       .db 0
main_goto:      .dw 0
main_locbuf:    .db 0,0,0,0,0

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
#include "ctc.asm"
#include "uint32tostr.asm"
#include "stackframe.asm"
#include "trap.asm"
#include "ramtest.asm"
#include "neo.asm"
end:
.END
