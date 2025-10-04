# VMB1RYNOS Normally-Closed Relay Module Protocol (Edition 1)

## Module Overview
- Six-relay module (four physical channels plus two virtual) designed for normally-closed contact configurations (`VMB1RYNOS_TYPE = 0x29`).
- Shares feature set with VMB1RYNO: local mode push buttons, timers, blinking modes, forced on/off and inhibit commands, and per-channel naming.
- Velbus CAN frames follow `<SOF SID10..0 RTR IDE r0 DLC DATA CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Local Status (page 2)
- **Push button & relay switch status**: `SID10..9 = 0b00`, module address, `DLC = 4`, data `[0x00, pressed_mask, released_mask, long_press_mask]`.

### LED Control (pages 2-3)
All frames use `SID10..9 = 0b11`, remote push button address:
- Clear `[0xF5, mask]`, set `[0xF6, mask]`, slow blink `[0xF7, mask]`, fast blink `[0xF8, mask]`, very fast `[0xF9, mask]`.

### Relay Status (page 3)
- `SID10..9 = 0b11`, module address, `DLC = 8`, data `[0xFB, channel_bit, disable_inhibit_forced_flags, relay_state, led_flags, delay_hi, delay_mid, delay_lo]`.
  - Delay bytes encode a 24-bit remaining timer in seconds.

### Module Identification (page 4)
- `[0xFF, 0x29, serial_hi, serial_lo, memory_map_version, build_year, build_week]`.

### Diagnostics & Memory (page 4)
- Single-byte memory read `[0xFE, addr_hi, addr_lo, value]` and block read `[0xCC, addr_hi, addr_lo, byte1..4]` for addresses `0x0000-0x04FC`.
- Relay name segments `[0xF0/0xF1/0xF2, channel_bit, chars...]`.
- Bus error counters `[0xDA, tx_err, rx_err, bus_off]`.

## Received Commands

### Relay Control (pages 6-9)
- Clear LED `[0xF5, mask]`.
- Switch off `[0x01, channel_bit]`, switch on `[0x02, channel_bit]`.
- Start timer `[0x03, channel_bit, timeout_hi, timeout_mid, timeout_lo]` (24-bit seconds, `0x000000` ignored, `0xFFFFFF` permanent on).
- Start blinking timer `[0x0D, channel_bit, timeout...]` (same rules).
- Forced off `[0x12, channel_bit, timeout...]`; cancel `[0x13, channel_bit]`.
- Forced on `[0x14, channel_bit, timeout...]`; cancel `[0x15, channel_bit]`.
- Inhibit `[0x16, channel_bit, timeout...]`; cancel `[0x17, channel_bit]`.
- Relay status request `[0xFA, channel_bit]`.

### Identification & Memory (pages 8-11)
- Module type RTR request (`RTR = 1`, `DLC = 0`).
- Relay name request `[0xEF, channel_bit]`.
- Read word `[0xFD, addr_hi, addr_lo]`; read block `[0xC9, addr_hi, addr_lo]` (valid `0x0000-0x04FC`).
- Memory dump `[0xCB]`.
- Write word `[0xFC, addr_hi, addr_lo, value]`; write block `[0xCA, addr_hi, addr_lo, bytes]`. Wait >=10 ms or until the module echoes a memory block before issuing additional writes.
- Bus error counter status request `[0xD9]`.
- Write module address/serial `[0x6A, 0x10, current_serial_hi, current_serial_lo, new_address, new_serial_hi, new_serial_lo]` sent with priority `SID10..9 = 0b01` to the current address.

## Memory Map Highlights

### Version 1 (page 12-13)
- For each relay channel (1-4) and virtual channel (5):
  - Up to 36 push button link slots (module address, bit number, action code, three timing parameters).
  - Contact configuration byte (`0xFF` normally open, `0x00` normally closed).
  - Location/group/circuit/load identifiers (build-dependent metadata), plus module-level IDs and name strings.
  - 16-character channel names stored at `0x00F0/0x01F0/...`.

### Address Range
- Entire table spans `0x0000-0x04FF`; block responses cover 4-byte aligned regions throughout this space.

## Action Codes (page 14)
Common action mappings (parameters default to `0xFF` unless noted):
- `0x00` Momentary toggle.
- `0x01/0x05/0x09` for direct Off/On/Toggle with variants `0x02-0x0C` disabling timers or differentiating short/long press.
- `0x0D` Start/stop timer (short press uses time1, long press time2).
- `0x0E` Restartable timer, `0x0F` non-retriggerable, `0x10` trigger-on-release.
- `0x11-0x18` Provide delayed on/off and interval behaviour (use timeout/pulse/pause parameters as noted).
- `0x19-0x1D` Disable commands, `0x1E-0x22` forced-on sequences, `0x23-0x27` inhibit controls.

## Time Parameter Lookup (page 15)
- Encodings include `0x00` no timer, `0x01` 1 s, `0x02` 2 s, `0x13` 1 min 59 s, `0x20` 2 min, `0x27` 4 min 45 s, `0x32` 5 min, `0x33` 5 min 30 s, `0x38` 29 min 30 s, `0x52` 30 min, `0x83` 31 min, `0xD3` 1 h 15 min, `0xE3` 4 h 45 min, `0xE4` 5 h, `0xE5` 5 h 30 min, `0xED` 9 h 30 min, `0xEE` 10 h, `0xEF` 11 h, `0xFB` 23 h, `0xFC` 1 day, `0xFD` 2 days, `0xFE` 3 days, `0xFF` infinite.

## Operational Notes
- Forced and inhibit commands respect the same timeout semantics as VMB1RYNO; zero is ignored, `0xFFFFFF` is permanent.
- Contact configuration bytes determine normally open/closed behaviour—update carefully when altering memory.
- When readdressing firmware, the protocol uses module type `0x10` within the write-address frame (per documentation).
- Maintain the 10 ms delay (or wait for memory response) after writes to avoid overloading the module’s buffer.
