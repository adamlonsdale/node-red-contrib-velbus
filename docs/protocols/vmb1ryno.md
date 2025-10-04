# VMB1RYNO Multi-Channel Relay Module Protocol (Edition 5)

## Module Overview
- Four-channel relay module with two virtual relay channels for grouped control (`VMB1RYNO_TYPE = 0x1B`).
- Provides local mode push buttons, supports timer/blinking logic, and (build >= 1105) allows forced on/off and inhibit states with optional timeouts.
- Reports individual relay state, disabling flags, LED indicators, and timing data over Velbus CAN frames (`<SOF SID10..0 RTR IDE r0 DLC DATA CRC ACK EOF IFS>`, page 1).

## Transmitted Messages

### Local Status (page 2)
- **Push button & relay switch status**: `SID10..9 = 0b00`, module address, `DLC = 4`, data `[0x00, pressed_mask, released_mask, long_press_mask]`.

### LED Management (pages 2-3)
All frames use `SID10..9 = 0b11`, destination push button module address:
- Clear LEDs `[0xF5, mask]`.
- Set LEDs `[0xF6, mask]`.
- Slow blink `[0xF7, mask]`.
- Fast blink `[0xF8, mask]`.
- Very fast blink `[0xF9, mask]`.

### Relay Status (page 3)
- Frame: `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 8`, data `[0xFB, channel_bit, inhibit_forced_flags, relay_state, led_flags, delay_hi, delay_mid, delay_lo]`.
  - `relay_state` encodes on/off/blink; `led_flags` match LED mask semantics; `[delay_hi..lo]` hold remaining timer (24-bit seconds).

### Module Identification (page 4)
- Payload `[0xFF, 0x1B, serial_hi, serial_lo, memory_map_version, build_year, build_week]`.

### Memory Data (page 4)
- Single-byte readback `[0xFE, addr_hi, addr_lo, value]` and 4-byte blocks `[0xCC, addr_hi, addr_lo, byte1..byte4]` covering addresses `0x0000-0x04FC`.
- Relay name segments `[0xF0/0xF1/0xF2, channel_bit, chars...]` (unused bytes `0xFF`).
- Bus error counters: `[0xDA, tx_err, rx_err, bus_off]`.

## Received Commands

### Core Relay Operations (pages 6-9)
- Clear LED `[0xF5, mask]`.
- Switch relay off `[0x01, channel_bit]`; switch on `[0x02, channel_bit]`.
- Start relay timer `[0x03, channel_bit, timeout_hi, timeout_mid, timeout_lo]`. `0x000000` skips (command ignored); `0xFFFFFF` latches relays on.
- Start blinking timer `[0x0D, channel_bit, timeout_hi, timeout_mid, timeout_lo]` (same timeout rules).
- Forced off `[0x12, channel_bit, timeout_hi, timeout_mid, timeout_lo]` (build >= 1105). `0x000000` ignored; `0xFFFFFF` permanent. Cancel forced off `[0x13, channel_bit]`.
- Forced on `[0x14, channel_bit, timeout...]` (build >= 1105). Cancel `[0x15, channel_bit]`.
- Inhibit `[0x16, channel_bit, timeout...]` (build >= 1105). Cancel `[0x17, channel_bit]`.
- Relay status request `[0xFA, channel_bit]`.

### Identification & Memory (pages 8-11)
- Module type RTR request: `RTR=1`, `DLC=0`.
- Relay name request `[0xEF, channel_bit]`.
- Memory read `[0xFD, addr_hi, addr_lo]` (`0x0000-0x04FC`).
- Memory block read `[0xC9, addr_hi, addr_lo]` (same range).
- Memory dump `[0xCB]`.
- Memory write `[0xFC, addr_hi, addr_lo, value]` and block write `[0xCA, addr_hi, addr_lo, b1..b4]`; wait >=10 ms or for `COMMAND_MEMORY_DATA_BLOCK` feedback before sending the next command.
- Bus error counter status request `[0xD9]` (build >= 0647).
- Write module address & serial (`0x6A`) targeting current address (firmware priority `SID10..9 = 0b01`).

## Memory Maps

### Build 1026 (page 12-13)
- Each relay channel (1-4) and virtual channel (5) stores up to 39 push button link definitions; each entry spans module address, bit number, action code, and up to three timing parameters.
- Channel contact configuration at `0x00EA/0x01EA/...`: `0xFF` = normally open, `0x00` = normally closed.
- `0x00F0-0x00FF`, `0x01F0-0x01FF`, etc hold 16-character relay names for channels 1-5.

### Memory Map Version 1 (build >= 1409) (pages 16-17)
- Extends each channel block with location, group, circuit, and load identifiers plus module metadata.
- Module name string stored from `0x00E3` onwards; terminator at `0x00E1/0x00E5` depending on channel.
- Structure repeats for channels 1-5; addresses align similarly to build 1026 with added metadata bytes.

## Action Codes (page 14)
`action` values bind push button links to behaviours; commonly used codes include:
- `0x00` Momentary toggle.
- `0x01` Off; `0x05` On; `0x09` Toggle.
- `0x0D` Start/stop timer (short press triggers time1, long press time2).
- `0x0E` Restartable timer; `0x0F` Non-retriggerable timer.
- `0x10` Trigger-on-release timer; `0x11-0x18` provide delayed on/off and interval behaviours.
- `0x19-0x1D` disable commands; `0x1E-0x22` forced-on controls; `0x23-0x27` inhibit controls.
- Unless a timeout is specified, unused parameters are `0xFF`.

## Time Parameter Encoding (page 15)
- Lookup values: `0x00` no timer, `0x01` 1 s, `0x02` 2 s, `0x13` 1 min 59 s, `0x20` 2 min, `0x27` 4 min 45 s, `0x32` 5 min, `0x33` 5 min 30 s, `0x38` 29 min 30 s, `0x52` 30 min, `0x83` 31 min, `0xD3` 1 h 15 min, `0xE3` 4 h 45 min, `0xE4` 5 h, `0xE5` 5 h 30 min, `0xED` 9 h 30 min, `0xEE` 10 h, `0xEF` 11 h, `0xFB` 23 h, `0xFC` 1 day, `0xFD` 2 days, `0xFE` 3 days, `0xFF` infinite. Values between follow the documented progression.

## Operational Notes
- Forced and inhibit commands require firmware build >= 1105; commands with zero timeout are ignored.
- Each channel’s normal-open/normal-closed flag sits alongside the push button action table; update with care to avoid writing `0x00` inadvertently.
- After any memory write, respect the 10 ms pause (or wait for block feedback) to keep the bus stable.
- Write-address command uses module type `0x10` (VMB4RYLD) as per documentation; ensure proper target when readdressing devices.
