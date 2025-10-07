# VMB8IN-20 Eight-Channel Input Module Protocol (Edition 1)

## Module Overview
- Module type `0x4A`; eight-channel input module with LED indicators, sunrise/sunset automation, onboard scheduling, and support for linked push-button LEDs (pages 1–2).
- Module status frame mirrors button state, enable/invert/lock bits, and program disable flag similar to other Velbus input modules (content inferred from family behaviour; PDF confirmation recommended due to OCR loss).
- Module type payload returns serial number, memory-map version, build year/week, and a properties byte (page 1).

## Message Formats
- Standard Velbus CAN framing; `SID10..9 = 00` for immediate channel transitions, `11` for telemetry and configuration messages (page 1).
- Memory services access `0x0000–0x07FF`; block operations use 4-byte chunks (CAN FD extension not evident in OCR) (page 6).
- Auto-send interval for telemetry is shared across all channels (page 5).

## Transmitted Messages
- **System & clock**: `0xAB` power-up, `0xD7` RTC request, `0xD8` RTC status, `0xB7` date status, `0xAF` daylight-saving status (pages 1–2).
- **Channel telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` emits just pressed/released/long-pressed masks for each input channel (page 1).
- **Module identity**: `0xFF` module type (type `0x4A`), serial number, memory-map version, build info (page 1).
- **Module status**: `0xED` frame described in companion modules is expected to report channel enable/invert/lock/program disable bits; OCR tables were unreadable—verify the PDF for exact bytes.
- **Channel naming**: `0xF0`/`0xF1`/`0xF2` deliver up to 16 ASCII characters per channel; unused characters contain `0xFF` (inferred from family behaviour, OCR table corrupted on pages 4–5).
- **Diagnostics & memory**: `0xDA` bus error counters, `0xFE` byte read, `0xCC` block read across `0x0000–0x07FC` (pages 5–6).
- **Linked LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink target associated push-button modules (page 1).
- **Program metadata**: `0xC1` program-step info is present but OCR degraded the tables; consult the PDF for calendar masks, action codes, and channel references (pages 8–10).

## Accepted Commands
- **Linked push-button input**: `0x00` updates local channels based on a paired keypad (page 2).
- **Status & identity queries**: RTR `COMMAND_MODULE_TYPE`, `0xED` module-status request, `0xEF` channel-name request, `0xFA` status resend, `0xD9` bus error request (page 2).
- **LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast, `0xF4` LED update apply to local LED rings (page 2).
- **Memory services**: `0xFD` read byte, `0xC9` read block, `0xCB` memory dump, `0xFC` write byte, `0xCA` write block; respect the `0x07FF/0x07FC` boundaries and wait for feedback before issuing consecutive writes (pages 2 & 6).
- **Timekeeping & automation**: `0xD8` set clock, `0xB7` set date, `0xAF` set daylight saving, `0xAE` toggle sunrise/sunset globally (`0x00`) or locally (module address), `0xC3` configure global/local alarms, and program enable/disable/select/read/write commands follow the same semantics as other push-button modules (page 2).

## Conversion Notes
- OCR output for this PDF is severely degraded—tables for auto-send settings, program actions, and channel mapping are unreadable. Always confirm byte layouts using “VMB8IN-20 Protocol – edition 1” before coding against this summary.
- Hex literals were normalised to `0x` form; ambiguous field names are inferred from earlier Velbus documentation for consistency.
