# VMB7IN Seven-Channel Input & Energy Counter Protocol (Edition 5)

## Module Overview
- Module type `0x22`; seven digital inputs with integrated energy pulse counters, LED indicators, and on-board scheduling/automation (pages 2–4).
- Module status frame exposes press state, enable/invert flags, lock state, program disable flag, and alarm/program selection identical to other multi-input modules (page 4).
- Counter status frame (`0xBE`) aggregates pulse totals for channels 1–4 plus metadata describing units, divider settings, and scaling (page 4); firmware ≥1426 adds “load counter” capability (page 3).

## Message Formats
- Standard Velbus CAN framing with priorities `SID10..9 = 00` for real-time channel transitions and `11` for all telemetry and configuration (pages 2–3).
- Supports real-time clock, date, and daylight-saving frames shared across the automation family (`0xD7/0xD8/0xB7/0xAF`) (page 3).
- Memory services address `0x0000–0x03FF`; block transfers use 4-byte pages, CAN FD support is not mentioned (page 4).

## Transmitted Messages
- **Clock & calendar**: broadcast RTC status request (`0xD7`) plus addressed RTC (`0xD8`), date (`0xB7`), and daylight-saving status (`0xAF`) (page 3).
- **Channel telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` reports just pressed, just released, and long-pressed flags for channels 1–8 (page 3).
- **Module identity**: `0xFF` module type returns code `0x22`, serial number, memory-map version, and build year/week (page 3).
- **Module status**: `0xED` carries channel state, enable/invert, lock, program disable, and alarm/program selection bits (page 4).
- **Counter statistics**: `0xBE` counter status delivers per-channel pulse totals and divider information; OCR omitted field definitions—consult the PDF for byte ordering (page 4).
- **Diagnostics & naming**: `0xDA` bus error counters, `0xF0/0xF1/0xF2` channel-name strings (unused characters `0xFF`), `0xFE` byte reads, and `0xCC` 4-byte block reads (pages 2–4).
- **Linked LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink target associated push-button modules (page 2).

## Accepted Commands
- **Input mirroring**: `0x00` linked push-button status keeps remote keypads synchronised (page 2).
- **Status & identity**: RTR `COMMAND_MODULE_TYPE`, `0xED` module-status request, `0xEF` channel-name request, `0xFA` module-status resend, `0xD9` bus-error request, `0xBD` kWh counter status request (page 2).
- **Counter management**: `0xB4` reset counter and (build ≥1426) `0xB5` load counter value; OCR did not retain byte layout—verify offsets before writing tooling (page 3).
- **LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast, and `0xF4` update apply to local LEDs (page 2).
- **Memory & diagnostics**: `0xFD` read, `0xC9` block read, `0xCB` dump, `0xFC` write byte, `0xCA` write block; respect `0x03FF/0x03FC` limits and wait for feedback before continuing (pages 2–4).
- **Timekeeping & automation**: `0xD8` set clock, `0xB7` set date, `0xAF` set daylight saving, `0xAE` toggle sunrise/sunset globally (`address 0x00`) or locally (module address), `0xC3` configure global/local alarms, and program-management commands (disable/enable/select/read/write) share semantics with other multi-input modules (page 3).

## Conversion Notes
- OCR omitted the detailed counter-status byte descriptions and program tables; refer to “VMB7IN Protocol – edition 5” for exact struct layouts, scaling factors, and action codes before scripting.
- Hex literals were normalised to `0x` notation; ambiguous mnemonics (e.g., `COMMAND_COUNTER_STATUS`) follow Velbus naming conventions for consistency.
