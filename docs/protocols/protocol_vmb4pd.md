# VMB4PD Push Button + LCD Module Protocol (Edition 1)

## Module Overview
- Eight-button module with LED indicators, integrated LCD (up to four lines), and optional push-button timers (`module type 0x0B`, page 3).
- Publishes button events, LED states, LCD text segments, and clock data while supporting backlight control and memory access (pages 1–4).
- Designed for automation panels requiring programmable labels, timers, and remote LED feedback (pages 1–3).

## Message Formats
- Push-button status `0x00` reports just-pressed, just-released, and long-press bitmasks; module status `0xED` returns LED modes and timer enable bits (pages 2–3).
- Module type `0xFF` includes LED state bytes, build date, and an operating mode field (bit0 timer, bit1 channel count, bit3 display mode) (page 3).
- LCD text frames use `0xCD/0xCE/0xCF` with line-bit selectors; push-button names use `0xF0/0xF1/0xF2` with button-bit selectors (pages 3–4).
- Memory transactions cover `0x0000–0x03FF` for `0xFE` word reads and `0x0000–0x03FC` for `0xCC` block reads (page 5).

## Transmitted Messages
- **Status & Discovery**: button status (`0x00`), module status (`0xED`), module type (`0xFF`), and bus error counters (`0xDA`) (pages 2–3).
- **Naming & Display**: button names (`0xF0/0xF1/0xF2`), LCD line text (`0xCD/0xCE/0xCF`), enabling remote UIs to mirror on-device labels (pages 3–4).
- **Clock & Automation**: `0xD7`/`0xD8` clock, `0xB7` date, `0xAF` daylight-saving (page 2).
- **Memory Echo**: `0xFE`/`0xCC` respond with configuration bytes; block size 5–60 supported for firmware ≥0743 (page 5).

## Accepted Commands
- **LED Control**: update (`0xF4`), clear (`0xF5`), set (`0xF6`), slow (`0xF7`), fast (`0xF8`), very fast (`0xF9`) LED blinking; link to other modules via standard Velbus semantics (page 1).
- **Backlight & Display**: set/restore LCD backlight (`COMMAND_LCD_BACKLIGHT` variants per PDF), set/restore push-button backlight, push-button timer enable toggles, and LCD line text requests (pages 1–4, 6–8).
- **Clock & Automation**: real-time clock requests and setters; sunrise/sunset enable (if supported), push-button timers (enable/disable) (pages 1–3, 8–9).
- **Memory Services**: read/write word (`0xFD/0xFC`), block (`0xC9/0xCA`), dump (`0xCB`); wait for feedback before next write (page 2).
- **Discovery**: module type RTR, status request (`0xFA`), push-button name request (`0xEF`), LCD text request (`0xCD/0xCE/0xCF`), bus error request (`0xD9`) (pages 1–2, 6–7).

## Channel Naming & LED Behaviour
- Push-button names use bitmask selectors; unused characters default to `0xFF` ensuring consistent string termination (pages 3–4).
- LED priority: steady-on overrides blinking, conflicting blink requests create the “very fast” pattern per module status semantics (pages 2–3).

## Program & Scheduling Controls
- Timer enable bits in module status support toggling push-button timers; additional commands enable/disable timers and adjust timing behaviour (pages 2–3, 8–9).
- The operating mode byte indicates whether timers and display labels are active, enabling automation systems to adjust UI behaviour (page 3).

## Memory Map
- Address space `0x0000–0x03FF` covers LED defaults, backlight settings, timer parameters, and LCD content; block writes (>=0743) allow efficient updates (page 5).
- Carefully manage memory addresses for timer configuration and label storage; the PDF provides tables for exact offsets (pages 5–7).

## Conversion Notes
- OCR errors (e.g. repeated LED state bytes in module-type section) were normalised to match expected Velbus constants; verify niche commands (e.g. backlight control) against the original PDF when coding (pages 3–6).
- LCD line command payloads follow the same structure as push-button names; ensure bit selectors match the desired line or button before writing (pages 3–4).
