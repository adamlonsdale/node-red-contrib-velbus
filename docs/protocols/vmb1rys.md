# VMB1RYS Relay Module Protocol (Edition 1)

## Module Overview
- Six-channel relay module built on the VMB1RYNO platform with spring-contact outputs (`VMB1RYS_TYPE = 0x41`).
- Exposes four physical relay channels plus two virtual channels, with normally-open contacts indicated by an additional terminator byte in the module-type frame.
- Supports push button linkage, timers, blinking behaviour, forced states, inhibit, and naming per channel.
- Velbus frames use the standard binary layout `<SOF SID10..0 RTR IDE r0 DLC DATA CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Local Status (page 2)
- **Push button & relay switch status**: `SID10..9 = 0b00`, module address, `[0x00, pressed_mask, released_mask, long_press_mask]` for on-board inputs and relay transitions.

### LED Control (pages 2-3)
All frames use `SID10..9 = 0b11`, remote push button module address:
- Clear `[0xF5, mask]`; set `[0xF6, mask]`; slow blink `[0xF7, mask]`; fast blink `[0xF8, mask]`; very fast blink `[0xF9, mask]`.

### Relay Status (page 3)
- `SID10..9 = 0b11`, module address, `DLC = 8`, data `[0xFB, channel_bit, disable_inhibit_forced_flags, relay_state, led_flags, delay_hi, delay_mid, delay_lo]`.
  - Delay bytes encode a 24-bit remaining timer in seconds.

### Module Type (page 4)
- Payload `[0xFF, 0x41, serial_hi, serial_lo, memory_map_version, build_year, build_week, terminator]` where `terminator = 0` indicates normally-open contacts, `1` indicates normally-closed.

### Memory Reporting (page 4)
- Read word `[0xFE, addr_hi, addr_lo, value]` and block `[0xCC, addr_hi, addr_lo, byte1..4]` for address range `0x0000-0x04FC`.
- Relay name parts `[0xF0/0xF1/0xF2, channel_bit, chars...]` (unused bytes `0xFF`).
- Bus error counters `[0xDA, tx_err, rx_err, bus_off]`.

## Received Commands

### Core Relay Controls (pages 6-9)
- Clear LED `[0xF5, mask]`.
- Switch off `[0x01, channel_bit]`; switch on `[0x02, channel_bit]`.
- Start timer `[0x03, channel_bit, timeout_hi, timeout_mid, timeout_lo]`: `0x000000` ignored, `0xFFFFFF` holds on permanently.
- Start blinking timer `[0x0D, channel_bit, timeout...]` (same semantics).
- Forced off `[0x12, channel_bit, timeout...]`; cancel `[0x13, channel_bit]`.
- Forced on `[0x14, channel_bit, timeout...]`; cancel `[0x15, channel_bit]`.
- Inhibit `[0x16, channel_bit, timeout...]`; cancel `[0x17, channel_bit]`.
- Relay status request `[0xFA, channel_bit]`.

### Identification & Memory (pages 8-11)
- Module type RTR request (`RTR = 1`, `DLC = 0`).
- Relay name request `[0xEF, channel_bit]`.
- Memory read `[0xFD, addr_hi, addr_lo]` and block read `[0xC9, addr_hi, addr_lo]` (valid `0x0000-0x04FC`).
- Memory dump `[0xCB]`.
- Write word `[0xFC, addr_hi, addr_lo, value]`; block write `[0xCA, addr_hi, addr_lo, byte1..byte4]`. Wait >=10 ms—or until a memory data block echo—before issuing subsequent writes.
- Bus error status request `[0xD9]`.
- Write module address & serial `[0x6A, 0x10, current_serial_hi, current_serial_lo, new_address, new_serial_hi, new_serial_lo]` (priority `SID10..9 = 0b01`).

## Memory Map (Version 0, pages 12-14)
- For each relay (channels 1-4) and virtual channels 5:
  - 32 push button link slots storing: module address, bit number, action code, and up to three timing parameters.
  - Contact configuration byte (`0xFF` = normally open, `0x00` = normally closed) plus location/group/circuit/load identifiers for each channel.
  - Module-level metadata (location, group, circuit, load, name strings).
  - Channel names stored at `0x00F0/0x01F0/...` (16-character ASCII).

## Action Codes (page 15)
- `0x00` momentary toggle; `0x01/0x05/0x09` for direct Off/On/Toggle with timer-disabling variants (`0x02-0x0C`).
- Timer behaviours: `0x0D` start/stop, `0x0E` restartable, `0x0F` non-retriggerable, `0x10` trigger-on-release.
- Delayed on/off and interval modes (`0x11-0x18`) use timeout/pulse/pause fields.
- Disable (`0x19-0x1D`), forced on (`0x1E-0x22`), and inhibit (`0x23-0x27`) actions mirror VMB1RYNO semantics.

## Time Parameter Table (page 16)
- Key values: `0x00` no timer, `0x01` 1 s, `0x02` 2 s, `0x13` 1 min 59 s, `0x20` 2 min, `0x27` 4 min 45 s, `0x32` 5 min, `0x33` 5 min 30 s, `0x38` 29 min 30 s, `0x52` 30 min, `0x83` 31 min, `0xD3` 1 h 15 min, `0xE3` 4 h 45 min, `0xE4` 5 h, `0xE5` 5 h 30 min, `0xED` 9 h 30 min, `0xEE` 10 h, `0xEF` 11 h, `0xFB` 23 h, `0xFC` 1 day, `0xFD` 2 days, `0xFE` 3 days, `0xFF` infinite.

## Operational Notes
- Terminator byte in the module type frame reveals whether the contacts are wired normally open (`0`) or closed (`1`); adjust automation accordingly.
- Forced/inhibit timeout commands ignore `0x000000` and treat `0xFFFFFF` as permanent state changes.
- Maintain the 10 ms delay (or wait for block feedback) after memory writes to avoid overruns on the Velbus bus.
- Address/serial writes require module type `0x10` in the payload, consistent with other multi-relay modules.
