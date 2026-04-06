# jShell

A simple interactive shell for the **RC2014** computer.  
Written in assembly, jShell provides command-line capabilities for RC2014 systems with specific hardware modules installed.

<img src="Screenshot at 2026-03-24 19-36-09.png" alt="jShell 0.3.12" width="500">

## About

jShell is a shell for the RC2014, inspired by classic monitor shells like SCM.  
It was developed as a hobby project to explore low-level Z80 programming and to make the RC2014 easier to interact with via commands.

### Required Hardware Modules

- LCD module  
- CTC (Counter/Timer Circuit) module  
- RTC (Real-Time Clock) module  

### Recommended Modules

- [NVRAM module](https://github.com/jce/nvram_for_rc2014)  
- [NeoPixel driver](https://github.com/jce/neo_rc2014) (not binary compatible with [RC2014 store driver](https://z80kits.com/shop/neopixel-module-short-board/))  

---

## Features

- Basic command parsing and execution  
- Memory inspection and manipulation  
- Built-in help system  
- Fully written in Z80 assembly 

---

## Commands

jShell 0.3.16 provides the following commands:

| Command | Description |
|---------|-------------|
| `help`, `ls`, `?` | Display this help. |
| `lcd [0-3] <text>` | Write text to one of the four LCD lines. |
| `in [0-FF]` | Read input register. |
| `out [0-FF] [0-FF]` | Write value to output register. |
| `fill [0-FFFF] [0-FFFF] [0-FF]` | Fill memory from start to end with value. |
| `read`, `r [0-FFFF] [0-FFFF]` | Read memory from address for length. |
| `copy [0-FFFF] [0-FFFF] [0-FFFF]` | Copy memory from source to destination for length. |
| `pwm [on/off]` | Turn blinking animation on output 0 on or off. |
| `ret` | Exit jShell. |
| `hexload`, `hl` | Start the hexloader (overwrites stack). |
| `clock` | No parameters: show date/time. 6 parameters: configure date/time (day month year hour minute second). |
| `log [arguments]` | No arguments: show log file. Arguments: add entry. |
| `log init` | Initialize the log file. |
| `dump` | Dump memory 0x0000–0xF000 as Intel HEX. |
| `uptime` | Display uptime in seconds. |
| `runtime [init]` | Display cumulative runtime in seconds; `init` resets counter. |
| `di`, `ei` | Disable or enable interrupts. |
| `go [0-FFFF]` | Run function at specified memory location. |
| `reset` | Soft reset of the processor. |
| `trap` | Trigger the trap function. |
| `ramtest` | Run RAM test (overwrites stack). |
| `neo`, `n [on/off, animation, 0x00-0xFF]` | Control NeoPixel module: turn on/off, set intensity, or select animation. Supported animations: `clock`, `tape`, `stargate`, `sg`, `star`, `tape2`, `tape3`, `tape4`, `tape5`, `tape6`, `rrod`, `rb`, `rb2`. |

> **Note:** Commands that overwrite the stack (`hexload`, `ramtest`) should be used carefully. NeoPixel commands require the custom driver linked above.

---

## Building

The project includes build scripts:

- have zasm installed in `../zasm/zasm`
- `build` — assembles and produces the main `.hex` file
- `build<nr>` — produces and uploads a hexfile for memory location `0x<nr>000`
- `sar.py` — Send And Run script, uploads the hexfile to the configured serial port and gives the run command for SCM
