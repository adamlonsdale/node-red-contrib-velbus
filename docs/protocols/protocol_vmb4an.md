# VMB4AN Analog Sensor Interface Protocol (Edition 3)

## Module Overview
- Four-channel analog input/thermostat gateway (`module type 0x32`) supplying temperature/lighting data to the Velbus bus (pages 1–3).
- Emits power-up, clock, and diagnostic frames while exposing subtype information for up to four sub-addressed sensors (page 3).
- Supports extended memory space for calibration and program data (map up to `0x0B3F`, EEPROM window `0x1000–0x13FC`) (page 3).

## Message Formats
- Power-up broadcast `0xAB` announces the assigned module address (page 2).
- Real-time clock/status frames mirror the standard Velbus layout: `0xD7/0xD8` for clock, `0xB7` for date, `0xAF` for daylight-saving indicator (pages 2–3).
- Module subtype frame `0xB0` includes four optional sub-address bytes (`0xFF` when disabled) for downstream sensor identification (page 3).
- Memory operations (`0xFE` / `0xCC`) cover full map and EEPROM, enabling host-side synchronisation (page 3).

## Transmitted Messages
- **Power & Timekeeping**: `0xAB` power-up, `0xD7` clock request, `0xD8` clock status, `0xB7` date status, `0xAF` daylight-saving status (pages 2–3).
- **Identity & Diagnostics**: `0xFF` module type with serial, memory-map version, and build date; `0xB0` subtype frame; `0xDA` bus error counters (pages 2–3).
- **Memory Echo**: `0xFE` word read and `0xCC` block read (4 bytes) for both map (`0x0000–0x0B3F`) and EEPROM window (`0x1000–0x13FC`) (page 3).

## Accepted Commands
- **Discovery & Diagnostics**: module type RTR, subtype request (mirrors `0xB0`), bus error counter request (`0xD9`), and power-up monitoring (pages 1–3).
- **Clock & Automation**: set clock/date/daylight saving; enable or disable global/local sunrise & sunset reactions; program local/global alarm clocks (pages 1–2, 4–6).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); respect address ranges for main map vs EEPROM (pages 1–2).
- **Power-Up Handling**: device responds to inbound `0xAB` from controllers, enabling reinitialisation sequences (page 1).

## Memory Map
- Primary map (`0x0000–0x0B3F`) stores sensor calibration, alarm limits, and configuration registers; EEPROM segment (`0x1000+`) holds persistent settings and historical data (page 3).
- Map version from the `COMMAND_MODULE_TYPE` response determines layout; always check before scripted writes to ensure compatibility (page 3).
- Memory tables in the PDF specify per-channel offsets for calibration and automation parameters—consult the source when authoring tooling (pages 4–6).

## Conversion Notes
- OCR glyph errors (e.g. stray punctuation) were normalised; verify uncommon commands such as subtype queries when integrating (pages 1–3).
- Because the PDF provides map tables graphically, cross-reference the original when editing calibration or alarm registers (pages 4–6).
