.org 0x0000
    jp 0x1000

.ORG 0x1000
trap_start .equ         0x0003
int_offs .equ           0x10
nv_block .equ           0xBFE6
loc_NTP_ip .equ         0xBFE6
loc_W5500_mac .equ      0xBFEA
loc_W5500_ip .equ       0xBFF0
loc_W5500_mask .equ     0xBFF4
loc_W5500_gw .equ       0xBFF8
loc_runtime .equ        0xBFFC
log_location_c  .equ    0xC000
log_len_c       .equ    0x2000
