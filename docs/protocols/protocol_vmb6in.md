# VMB6IN Six-Channel Input Module Protocol (Edition 1 rev.2)

## Module Overview
- Module type `0x05`; six dry-contact inputs with companion status LEDs share the same address set by onboard hex switches (page 3).
- Module status frame reports contact states plus LED steady/slow/fast indications, mirroring what wall controllers display (page 2).
- Module type frame (build ≥0649) includes LED bitmasks and production year/week, allowing diagnostics to confirm hardware revision (page 2).

## Message Formats
- Standard Velbus CAN frames `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA – CRC – ACK – EOF – IFS>`; priorities: `SID10..9 = 00` for input transitions, `11` for telemetry/config (page 2).
- Input identifiers travel as bitmasks (`0b00000001` = input 1 … `0b00100000` = input 6) in naming frames and LED commands (pages 2–3).
- Memory services access low memory only (`high address` must be `0x00`); block operations require build ≥0736 (pages 3–4).

## Transmitted Messages
- **Input transitions**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` with “just closed”, “just opened”, and “long closed (>0.85 s)” bitmasks (page 2).
- **Module status**: `0xED` reports current input states plus LED steady/slow/fast masks; steady overrides blinking, and slow+fast yields very-fast blink (page 2).
- **Module type**: `0xFF` returns type `0x05`, LED masks, and build year/week on recent firmware (page 2).
- **Input naming**: `0xF0`/`0xF1`/`0xF2` send 16-character ASCII names per input; unused characters are `0xFF` (pages 2–3).
- **Memory data**: `0xFE` single-byte read and `0xCC` 4-byte block read (`0x0000–0x007F`) for configuration storage (pages 3–4).
- **Diagnostics**: `0xDA` bus error counters (build ≥0649) expose TX/RX/bus-off counts (page 4).

## Accepted Commands
- **LED maintenance**: `0xF4` update, `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink; steady overrides blinking, and slow+fast produces very-fast blink (pages 4–5).
- **Telemetry queries**: `0xFA` module status request (select channels via bitmask), RTR `COMMAND_MODULE_TYPE`, `0xD9` bus error request, `0xEF` input name request (pages 5–6).
- **Memory services**: `0xFD` byte read, `0xCB` dump (build ≥0736), `0xFC` byte write; block write not available. Observe ≥10 ms delay between consecutive writes (page 6).

## Memory & Timing Notes
- Input names store up to 15 characters (plus padding) per channel; unused bytes are `0xFF` (page 6).
- Document lists valid acknowledgment response times: `0x05` = 65 ms, `0x4C` = 1 s, `0x99` = 2 s, `0xE0` = 3 s (page 6).

## Conversion Notes
- OCR misread “openend” and similar typos; hex values normalised to `0x` notation.
- Memory map graphics were minimal; consult “VMB6IN Protocol – edition 1 rev.2” if precise offsets beyond `0x007F` are required.
