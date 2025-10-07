# VMB8DC-20 Eight-Channel Dimmer/Controller Protocol (Edition 3)

## Module Overview
- Module type `0x4B`; eight-channel dimmer/controller supporting linear/RGBW scenes, group membership, sunrise/sunset automation, and CAN FD memory blocks (pages 3–8).
- Module type frame returns serial number, memory-map version, build year/week, and a properties byte describing firmware capabilities (page 3).
- Module status (`0xEE`) and dim value status (`0xA5`) expose per-channel output levels (0–254, 255 = unchanged) for automation feedback (page 6).

## Message Formats
- Standard Velbus CAN frames with `SID10..9 = 00` for high-priority channel events, `11` for telemetry/configuration (page 3).
- Supports CAN FD for block reads/writes up to 60 bytes; unused payload bytes filled with `0x55`, valid address range `0x0000–0x0800` minus length (page 4).
- Channel identifiers use 1–8 indices in most frames; LED control frames still rely on bitmasks matching linked keypad LEDs (page 7).

## Transmitted Messages
- **System & clock**: `0xAB` power-up, `0xD7` RTC request, `0xD8` RTC status, `0xB7` date, `0xAF` daylight saving flag (pages 2–3).
- **Identity & diagnostics**: `0xFF` module type (type `0x4B`), `0xDA` bus error counters, `0xFE` byte read, `0xCC` block read (standard and CAN FD variants) across `0x0000–0x07FF` (pages 3–4).
- **Channel telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` for on-device button/switch inputs; `0xEE` module status lists current on/off state by channel; `0xA5` dim value status streams up to four channel levels per frame (pages 5–6).
- **Naming**: `0xF0`/`0xF1`/`0xF2` deliver 16-character ASCII channel names, unused slots `0xFF` (pages 5–6).
- **Linked LED control**: `0xF5–0xF8` keep external keypads synchronised (pages 6–7).
- **Device settings**: `0xE8` (`COMMAND_TEMP_SENSOR_SETTINGS_P1`) re-purposed to push scene levels (linear + RGBW), power-on/system-failure defaults, fade time/rate, and group membership; OCR captured indices but not byte metadata—verify against the PDF (page 8).
- **Program metadata**: `0xC1` program step info summarises calendar masks, actions, and target channels; table headings are partially lost (pages 9–10).

## Accepted Commands
- **Linked push-button input**: `0x00` mirrors remote keypad activity (page 11).
- **Housekeeping**: accepts broadcast power-up (`0xAB`), CAN-FD enable (`0xB5`), and RTC queries/updates (`0xD7/0xD8/0xB7/0xAF`) similar to other modules (pages 11–12).
- **LED & channel control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast, and `0xF4` LED update for local indicators (pages 11–12).
- **Memory services**: `0xFD` read byte, `0xC9` block read, `0xCB` dump, `0xFC` write byte, `0xCA` write block (CAN FD supported); observe address limits and wait for feedback before issuing subsequent writes (pages 3–4, 11–12).
- **Automation**: commands listed include sunrise/sunset toggles (`0xAE`), alarm clocks (`0xC3`), program enable/disable/select, and read/write program steps (`0xC0/0xC2`); byte layouts mirror those in other Velbus scheduling modules and should be cross-checked in the PDF (pages 2–3, 9–10).

## Scene & Device Settings
- Scene indices 0–9, power-on/system-failure defaults, fade time/rate, and group membership are all set via the `0xE8` payload; values use 0–254 (255 = unchanged) for linear/RGBW levels (page 8).
- Device type enumerations (fluorescent, emergency, discharge, LV lamp, dimmer, LED module, relay, color control, sequencer, etc.) are returned within the settings frame; OCR lost parts of the table—confirm exact codes in the PDF (page 9).

## Conversion Notes
- OCR omitted key details from the program tables and scene-setting payload; consult “VMB8DC-20 Protocol – edition 3” for precise byte order, especially when scripting scene data or program actions.
- Hex literals standardised to `0x` form; ambiguous command names follow Velbus conventions for readability.
