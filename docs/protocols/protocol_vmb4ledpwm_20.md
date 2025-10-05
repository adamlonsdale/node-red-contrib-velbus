# VMB4LEDPWM-20 LED PWM Controller Protocol (Edition 1)

## Module Overview
- Four-channel LED PWM driver with real-time clock, sunrise/sunset automation, and CAN FD memory support (`module type 0x06`, page 3).
- Broadcasts power-up, clock, and diagnostics frames, plus module status reflecting channel enable/lock/program flags (pages 2–4, 6).
- Supports CAN FD block transfers up to 60 bytes for rapid configuration updates (page 4).

## Message Formats
- Power-up message `0xAB` announces the module address; clock frames reuse `0xD7/0xD8` and `0xB7` for date, `0xAF` for daylight-saving flag (pages 2–3).
- Module type frame includes serial number, memory-map version, build date, and a properties byte (bit-field for terminator/CAN FD features) (page 3).
- Memory access covers `0x0000–0x07FF`, with CAN FD block reads/writes requiring padding `0x55` for unused bytes (pages 3–4).

## Transmitted Messages
- **Clock & Calendar**: `0xAB`, `0xD7`, `0xD8`, `0xB7`, `0xAF` (pages 2–3).
- **Diagnostics**: `0xFF` module type, `0xDA` bus error counters (page 3).
- **Channel Naming**: `0xF0/0xF1/0xF2` deliver 16-character ASCII names for channels 1–4 (pages 5–6).
- **Channel & Module Status**: `0x00` push-button status (channel events) and `0xEE` dimmer-style module status with enable/inhibit/lock bits and program selection (pages 5–6).
- **Memory Echo**: `0xFE` word read, `0xCC` block read (4 or 5–60 bytes via CAN FD) (pages 3–4).

## Accepted Commands
- **Motion/Dim Control**: set output (`0x07`), restore last (`0x11`), start timer (`0x08`), stop (`0x10`), and scene selection/preset commands shared with dimmer family (from OCR context, confirm with PDF, pages 7–9).
- **Overrides**: forced on/off (`0x12/0x14`), cancel forced (`0x13/0x15`), inhibit (`0x16`), cancel inhibit (`0x17`), lock/unlock channels (`0x1A/0x1B`), with 24-bit timers and channel broadcast support (pages 7–9).
- **Automation & Clock**: enable/disable sunrise/sunset actions, configure local/global alarm clocks, daylight-saving settings, RTC set (pages 2–3, 10–13).
- **Memory Services**: read/write word (`0xFD/0xFC`), block (`0xC9/0xCA`), dump (`0xCB`); CAN FD commands include block length parameter. Wait for feedback before issuing consecutive writes (pages 3–4, 15–16).
- **LED/Linked Control**: update/clear/set/slow/fast/very-fast LED commands (`0xF4–0xF9`) for linked push-button modules (page 2).

## Channel Naming & LED Behaviour
- Channel naming sequences include channel number in byte 2; unused characters use `0xFF` padding (pages 5–6).
- LED control semantics match other Velbus lighting modules: continuous-on overrides blink, overlapping blink bits produce very-fast blink (page 2).

## Program & Scheduling Controls
- Module status `0xEE` exposes inhibit/lock/program selections allowing automation controllers to monitor active override and scheduling states (page 6).
- Timer-based overrides interpret `0x000000` as “no timer” and `0xFFFFFF` as “persistent” for supported commands (pages 7–9).

## Memory Map
- Address space `0x0000–0x07FF` stores channel presets, automation flags, and configuration data; CAN FD support enables large batch updates (pages 3–4).
- Always check the memory-map version from `COMMAND_MODULE_TYPE` before writing to ensure offsets align with firmware revisions (page 3).
- Detailed tables in the PDF map scenes, timers, and channel properties; consult the original when scripting configuration changes (pages 15–18).

## Conversion Notes
- OCR artefacts were normalised (e.g. spacing in command names); verify specific opcodes—for example forced/inhibit commands—against the PDF when implementing drivers (pages 7–9).
- The document assumes familiarity with dimmer command semantics; cross-reference VMB4DC/VMB2DC behaviour for shared opcodes (pages 7–9).
