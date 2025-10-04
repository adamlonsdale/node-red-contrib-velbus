# VMB1RY Relay Module Protocol (Edition 1, Rev 4)

## Module Overview
- Single-channel relay module (`ONE_CHANNEL_RELAY_MODULE_TYPE = 0x02`).
- Supports start/stop, staircase, non-retriggerable, on/off delay, triggered-on-release, blinking, and dual timer modes controlled by DIP switches.
- Provides a local mode push button for manual override (build >= 0814) and reports combined push button/relay activity, LED states, timers, and naming.
- Velbus frames use `<SOF SID10..0 RTR IDE r0 DLC3..0 DATA CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Local Status (page 2)
- **Push button & relay switch status** (build >= 0814): `SID10..9 = 0b00`, module address, data `[0x00, pressed_mask, released_mask, long_press_mask]`.

### LED Control Frames (pages 2-3)
All use `SID10..9 = 0b11`, remote push button module address:
- Update LEDs: `[0xF4, steady_mask, slow_blink_mask, fast_blink_mask]` (steady overrides blink; slow+fast = very fast blink).
- Clear: `[0xF5, mask]`.
- Set: `[0xF6, mask]`.
- Slow blink: `[0xF7, mask]`.
- Fast blink: `[0xF8, mask]`.
- Very fast blink: `[0xF9, mask]`.

### Relay Status (page 3)
- Frame: `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 8`, data `[0xFB, 0x01, mode, relay_state, led_flags, delay_hi, delay_mid, delay_lo]`.
  - `mode` enumerations: `0=start/stop`, `1=staircase`, `2=non-retriggerable`, `3=turn-off delay`, `4=turn-on delay`, `5=trigger-on-release`, `6=blinking timer`, `7+=dual timer variants per module type table`.
  - `relay_state`: `0x00` off, `0x01` on, `0x11` blink.
  - `led_flags` mirror LED mask usage (`0x80` steady, `0x40` slow, `0x20` fast, `0x10` very fast).
  - `[delay_hi..delay_lo]` encode remaining timer (24-bit seconds).

### Module Type (page 4)
- `[0xFF, 0x02, hex_setting, build_year, build_week]` where `hex_setting` stores DIP mode/time selections:
  - High nibble (mode/time2): `0` start/stop, `1` staircase, `2` non-retriggerable, `3` turn-off delay, `4` turn-on delay, `5` trigger-on-release, `6` blinking, `7` dual timer (time2=5 min), `8` dual timer (10 min), `9` dual timer (15 min), `0xA` dual timer (30 min), `0xB` dual timer (1 h), `0xC` dual timer (2 h), `0xD` dual timer (5 h), `0xE` dual timer (1 day), `0xF` dual timer (on/off sequence).
  - Low nibble (time1): `0` momentary, `1` 5 s, `2` 10 s, `3` 15 s, `4` 30 s, `5` 1 min, `6` 2 min, `7` 5 min, `8` 10 min, `9` 15 min, `0xA` 30 min, `0xB` 1 h, `0xC` 2 h, `0xD` 5 h, `0xE` 1 day, `0xF` on/off sequence).

### Naming & Diagnostics (pages 4-6)
- Relay name segments: `[0xF0/0xF1/0xF2, 0x01, chars...]` (unused bytes `0xFF`).
- Local mode push button name (build >= 0814): `[0xF0/0xF1/0xF2, 0x10, chars...]`; final byte of part 3 fixed `0xFF`.
- Bus error counters (build >= 0648): `[0xDA, tx_err, rx_err, bus_off]`.
- Memory read responses: `[0xFE, 0x00, addr_lo, value]` and `[0xCC, 0x00, addr_lo, b1..b4]` (build >= 0736).

## Received Commands (pages 7-9)
- Push button status frames `[0x00, pressed, released, long_press]` from remote modules.
- Clear LED `[0xF5, mask]` (build >= 0814).
- Switch relay off `[0x01, 0x01]`; switch on `[0x02, 0x01]`.
- Start relay timer `[0x03, 0x01, timeout_hi, timeout_mid, timeout_lo]`; `0x000000` selects DIP timer (momentary = no change; toggle = latch on), `0xFFFFFF` holds permanently.
- Start relay blinking timer `[0x0D, 0x01, timeout_hi, timeout_mid, timeout_lo]` with same timeout rules.
- Relay status request `[0xFA, 0x01]`.
- Module type RTR request (`RTR = 1`, `DLC = 0`).
- Bus error counter status request `[0xD9]` (build >= 0648).
- Name request `[0xEF, selector]` (`0x01` relay, `0x10` local push button, build >= 0814).
- Memory read `[0xFD, 0x00, addr_lo]` (`0x00-0x7F`).
- Memory dump `[0xCB]` (build >= 0736).
- Write word `[0xFC, 0x00, addr_lo, value]`; wait >=10 ms before next Velbus command.

## Memory Map

### Firmware <= 0x0736 (page 9)
- `0x0000-0x000D`: Clear LED assignments for up to 7 remote buttons.
- `0x000E-0x001B`: Set LED assignments.
- `0x001C-0x0029`: Toggle LED assignments.
- `0x002A-0x0037`: Activate mode push button assignments.
- `0x0038-0x0045`: Toggle timer1 assignments.
- `0x0046-0x0053`: Toggle timer2 assignments.
- `0x0054-0x0061`: Start timer1 assignments.
- `0x0062-0x006F`: Start timer2 assignments.
- `0x0070-0x007F`: Relay name (16 characters).
- Unused addresses contain `0xFF`.

### Firmware >= 0x0814 (page 10)
- Consolidated layout supporting 6-button groupings and local push button naming:
  - `0x0000-0x000B`: Clear LED assignments.
  - `0x000C-0x0017`: Set LED assignments.
  - `0x0018-0x0023`: Toggle assignments.
  - `0x0024-0x002F`: Activate mode assignments.
  - `0x0030-0x003B`: Toggle timer1 assignments.
  - `0x003C-0x0047`: Toggle timer2 assignments.
  - `0x0048-0x0053`: Start timer1 assignments.
  - `0x0054-0x005F`: Start timer2 assignments.
  - `0x0060-0x006E`: Local push button name (15 chars) with response time at `0x006F` (`0x05=65 ms`, `0x4C=1 s`, `0x99=2 s`, `0xE0=3 s`).
  - `0x0070-0x007F`: Relay name (16 chars).
  - Unused addresses remain `0xFF`.

## Operational Notes
- Timer commands accept big-endian 24-bit seconds; DIP settings provide defaults when `0x000000` is supplied.
- For blinking/timer modes configured through DIP switches, ensure mode/time mapping is interpreted using the module type frame’s hex setting.
- Observe the 10 ms spacing (or wait for memory data feedback) after memory writes to avoid bus contention.
- When requesting names, set selector bit `0x01` for the relay itself or `0x10` for the local push button to receive the full three-part ASCII name.
