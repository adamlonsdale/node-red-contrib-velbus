# VMB1BLS Blind Module Protocol (Edition 3)

## Module Overview
- Two-channel blind module with integrated real-time clock, alarm scheduler and sunrise/sunset automation (`VMB1BLS_TYPE = 0x2E`).
- Supports full blind movement, position presets, forced and inhibit modes, plus auto programs and alarm clock integration.
- Communicates with linked push button modules for manual control and LED feedback.
- Reports build metadata, serial number and memory-map version through the standard Velbus frame format `<SOF SID10..0 RTR IDE DLC3..0 DATA.. CRC ACK EOF IFS>` (source: page 1).

## Transmitted Messages

### Real-Time Clock Poll
- **Clock status request broadcast** (page 3): `SID10..9 = 0b11`, `SID8..1 = 0x00`, `RTR = 0`, `DLC = 1`, data `[0xD7]` (`COMMAND_REALTIME_CLOCK_STATUS_REQUEST`).

### Calendar & Time Reports (page 3)
- **Clock status**: `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 4`, data `[0xD8, day, hour, minute]`, with `day` enumerated 0=Mon .. 6=Sun.
- **Date status**: `DLC = 5`, data `[0xB7, day(1-31), month(1-12), year_hi, year_lo]`.
- **Daylight saving status**: `DLC = 2`, data `[0xAF, enabled_flag]` (`0` disabled, `1` enabled).

### Blind Relay State Reports
- **Relay status** (page 3): `SID10..9 = 0b00`, module address, `RTR = 0`, `DLC = 4`, data `[0x00, on_mask, off_mask, 0x00]`. Bits report which channels have just switched on/off.
- **Blind status frame** (page 6): `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 8`, data `[0xEC, channel_bits, default_timeout_s, status_flags, led_flags, position, mode_flags, alarm_auto_flags]` where:
  - `position` is a 0-100% blind position.
  - `mode_flags` encodes lock, inhibit, forced up/down states.
  - `alarm_auto_flags` captures active alarms and auto mode selection.

### LED Control Frames to Push Button Modules (page 4)
All use `SID10..9 = 0b11`, `SID8..1 = target push button module`, `RTR = 0`.
- Clear LEDs: `[0xF5, clear_mask]`.
- Set LEDs: `[0xF6, set_mask]`.
- Fast blink LEDs: `[0xF8, blink_mask]`.

### Diagnostic & Identity Frames
- **Bus error counters** (page 4): `[0xDA, tx_err, rx_err, bus_off]`.
- **Module type** (page 4): `[0xFF, 0x2E, serial_hi, serial_lo, memory_map_version, build_year, build_week]`.

### Memory Reporting
- **Single location readback** (page 4): `[0xFE, addr_hi, addr_lo, value]` with `addr_hi` in `0x00-0x01`.
- **4-byte memory block** (page 5): `[0xCC, addr_hi, addr_lo, byte1, byte2, byte3, byte4]`, valid for `0x0000-0x01FC`.

### Name Frames (page 5)
- Blind name parts 1/2/3: opcodes `0xF0/0xF1/0xF2` with channel selector in byte 2 and ASCII characters following; unused slots are `0xFF`.

## Received Messages & Commands

### Linked Push Button Traffic (page 7)
- **Linked push button status**: `SID10..9 = 0b00`, remote module address, data `[0x00, pressed_mask, released_mask, long_press_mask]`.
- **Clear linked button LEDs**: `SID10..9 = 0b11`, remote address, data `[0xF5, mask]`.

### Blind Motion & Position Commands (pages 9-11)
- `0x04` Switch blind off (`DLC = 2`, channel mask).
- `0x05` Blind up, `DLC = 5`, includes 24-bit timeout; `0x000000` uses default, `0xFFFFFF` holds permanently.
- `0x06` Blind down (same structure as up).
- `0x1C` Set blind position (`DLC = 3`, channel, position 0-100%).
- `0x1A` Lock channel (`DLC = 5`, channel, 24-bit delay; zero skips, `0xFFFFFF` locks permanently).
- `0x1B` Unlock channel (`DLC = 2`).

### Forced & Inhibit Controls (pages 10-12)
Commands accept channel byte plus 24-bit timer (unless noted) and skip when timer is zero.
- `0x12` Forced up, `0x13` Cancel forced up.
- `0x14` Forced down, `0x15` Cancel forced down.
- `0x16` Inhibit, `0x17` Cancel inhibit.
- `0x18` Inhibit with preset up, `0x19` Inhibit with preset down.
- Timers set to `0xFFFFFF` make the state permanent.

### Scheduler & Automation (pages 8-9)
- **Global sunrise/sunset enable**: `[0xAE, channel, flags]` sent to `SID8..1 = 0x00` for global scope.
- **Local sunrise/sunset enable**: same payload addressed to the module.
- **Set global alarm clock**: `[0xC3, alarm (1/2), wake_hour, wake_min, bed_hour, bed_min, enable_flag]` to `SID=0x00`.
- **Set local alarm clock**: same payload sent to module address.
- **Select auto mode**: `[0xB3, channel, mode_id]` (0 disables all, 1-3 select program).

### Real-Time Clock Configuration (page 7-8)
- Set clock: `[0xD8, day, hour, minute]` (address `0x00`).
- Set date: `[0xB7, day, month, year_hi, year_lo]` (address `0x00`).
- Set daylight saving: `[0xAF, enable]` (address `0x00`).
- Real time clock status request: `[0xD7]` directed at module.

### Memory & Identification Commands (pages 8, 13-14)
- Blind status request: `[0xFA, channel]`.
- Module type request: RTR frame with `SID10..9 = 0b11`, `DLC = 0`.
- Blind name request: `[0xEF, channel]`.
- Read memory word: `[0xFD, addr_hi, addr_lo]` (addr `0x0000-0x017F`).
- Read memory block: `[0xC9, addr_hi, addr_lo]` (valid range `0x0000-0x017C`).
- Memory dump request: `[0xCB]`.
- Write memory word: `[0xFC, addr_hi, addr_lo, value]`; wait >=10 ms or until data feedback frame before the next command.
- Write memory block: `[0xCA, addr_hi, addr_lo, byte1..byte4]` with the same wait requirement; valid range `0x0000-0x017C`.
- Bus error counter status request: `[0xD9]`.
- Write module address & serial number (priority 0b01) (page 15): `[0x6A, 0x2E, serial_hi, serial_lo, new_address, new_serial_hi, new_serial_lo]` sent to the current address.

## Push Button Link Table (pages 18, 25, 33)
- Memory addresses `0x0100-0x017C` store up to 25 linked push button definitions.
- Each entry consumes 6 bytes: module address, bit number, action code, first time parameter, second time parameter, plus padding.
- Entries map button presses to blind control actions defined below.

## Push Button Action Codes (pages 19-20, 26-27)

| Code | Description | First Parameter | Second Parameter |
| --- | --- | --- | --- |
| 0x00 | Up | 0xFF (unused) | 0xFF |
| 0x01 | Direct up | Delayed on time | 0xFF |
| 0x02 | Direct up at release | Delayed on time | 0xFF |
| 0x03 | Down | 0xFF | 0xFF |
| 0x04 | Direct down | Delayed on time | 0xFF |
| 0x05 | Direct down at release | Delayed on time | 0xFF |
| 0x06 | Up/down toggle | 0xFF | 0xFF |
| 0x07 | Go to position | Delayed on time | Position (0-100%) |
| 0x08 | Go to position at release | Delayed on time | Position (0-100%) |
| 0x09 | Up in auto mode 1 | 0xFF | 0xFF |
| 0x0A | Direct up in auto mode 1 | Delayed on time | 0xFF |
| 0x0B | Direct up at release in auto mode 1 | Delayed on time | 0xFF |
| 0x0C | Down in auto mode 1 | 0xFF | 0xFF |
| 0x0D | Direct down in auto mode 1 | Delayed on time | 0xFF |
| 0x0E | Direct down at release in auto mode 1 | Delayed on time | 0xFF |
| 0x0F | Up/down in auto mode 1 | 0xFF | 0xFF |
| 0x10 | Go to position in auto mode 1 | Delayed on time | Position (0-100%) |
| 0x11 | Go to position at release in auto mode 1 | Delayed on time | Position (0-100%) |
| 0x12 | Select auto mode 1 | 0xFF | 0xFF |
| 0x13 | Select auto mode 1 at release | Delayed on time | 0xFF |
| 0x14 | Select/deselect auto mode 1 | Delayed on time | 0xFF |
| 0x15 | Deselect auto mode 1 | Delayed on time | 0xFF |
| 0x16 | Deselect auto mode 1 at release | Delayed on time | 0xFF |
| 0x17 | Up in auto mode 2 | 0xFF | 0xFF |
| 0x18 | Direct up in auto mode 2 | Delayed on time | 0xFF |
| 0x19 | Direct up at release in auto mode 2 | Delayed on time | 0xFF |
| 0x1A | Down in auto mode 2 | 0xFF | 0xFF |
| 0x1B | Direct down in auto mode 2 | Delayed on time | 0xFF |
| 0x1C | Direct down at release in auto mode 2 | Delayed on time | 0xFF |
| 0x1D | Up/down in auto mode 2 | 0xFF | 0xFF |
| 0x1E | Go to position in auto mode 2 | Delayed on time | Position (0-100%) |
| 0x1F | Go to position at release in auto mode 2 | Delayed on time | Position (0-100%) |
| 0x20 | Select auto mode 2 | 0xFF | 0xFF |
| 0x21 | Select auto mode 2 at release | 0xFF | 0xFF |
| 0x22 | Select/deselect auto mode 2 | 0xFF | 0xFF |
| 0x23 | Up in auto mode 3 | 0xFF | 0xFF |
| 0x24 | Direct up in auto mode 3 | Delayed on time | 0xFF |
| 0x25 | Direct up at release in auto mode 3 | Delayed on time | 0xFF |
| 0x26 | Down in auto mode 3 | 0xFF | 0xFF |
| 0x27 | Direct down in auto mode 3 | Delayed on time | 0xFF |
| 0x28 | Direct down at release in auto mode 3 | Delayed on time | 0xFF |
| 0x29 | Up/down in auto mode 3 | 0xFF | 0xFF |
| 0x2A | Go to position in auto mode 3 | Delayed on time | Position (0-100%) |
| 0x2B | Go to position at release in auto mode 3 | Delayed on time | Position (0-100%) |
| 0x2C | Select auto mode 3 | 0xFF | 0xFF |
| 0x2D | Select auto mode 3 at release | 0xFF | 0xFF |
| 0x2E | Select/deselect auto mode 3 | 0xFF | 0xFF |
| 0x2F | Lock at closed switch | 0xFF | 0xFF |
| 0x30 | Lock at open switch | 0xFF | 0xFF |
| 0x31 | Lock | 0xFF | 0xFF |
| 0x32 | Lock/unlock toggle | 0xFF | 0xFF |
| 0x33 | Unlock | 0xFF | 0xFF |
| 0x34 | Forced up at closed switch | 0xFF | 0xFF |
| 0x35 | Forced up at open switch | 0xFF | 0xFF |
| 0x36 | Forced up (timed) | Timeout | 0xFF |
| 0x37 | Forced up / cancel forced up | Timeout | 0xFF |
| 0x38 | Cancel forced up | 0xFF | 0xFF |
| 0x39 | Forced down at closed switch | 0xFF | 0xFF |
| 0x3A | Forced down at open switch | 0xFF | 0xFF |
| 0x3B | Forced down (timed) | Timeout | 0xFF |
| 0x3C | Forced down / cancel forced down | Timeout | 0xFF |
| 0x3D | Cancel forced down | 0xFF | 0xFF |
| 0x3E | Inhibit at closed switch | 0xFF | 0xFF |
| 0x3F | Inhibit at open switch | 0xFF | 0xFF |
| 0x40 | Inhibit (timed) | Timeout | 0xFF |
| 0x41 | Inhibit / cancel inhibit | Timeout | 0xFF |
| 0x42 | Cancel inhibit | 0xFF | 0xFF |
| 0x43 | Inhibit with preset up at closed switch | 0xFF | 0xFF |
| 0x44 | Inhibit with preset up at open switch | 0xFF | 0xFF |
| 0x45 | Inhibit with preset up (timed) | Timeout | 0xFF |
| 0x46 | Inhibit with preset up / cancel | Timeout | 0xFF |
| 0x47 | Cancel inhibit with preset up | 0xFF | 0xFF |
| 0x48 | Inhibit with preset down at closed switch | 0xFF | 0xFF |
| 0x49 | Inhibit with preset down at open switch | 0xFF | 0xFF |
| 0x4A | Inhibit with preset down (timed) | Timeout | 0xFF |
| 0x4B | Inhibit with preset down / cancel | Timeout | 0xFF |
| 0x4C | Cancel inhibit with preset down | 0xFF | 0xFF |
| 0x4D | Enable alarm 1 at closed switch | 0xFF | 0xFF |
| 0x4E | Enable alarm 1 at open switch | 0xFF | 0xFF |
| 0x4F | Disable alarm 1 at closed switch | 0xFF | 0xFF |
| 0x50 | Disable alarm 1 at open switch | 0xFF | 0xFF |
| 0x51 | Enable alarm 1 | 0xFF | 0xFF |
| 0x52 | Enable/disable alarm 1 | 0xFF | 0xFF |
| 0x53 | Disable alarm 1 | 0xFF | 0xFF |
| 0x54 | Enable alarm 2 at closed switch | 0xFF | 0xFF |
| 0x55 | Enable alarm 2 at open switch | 0xFF | 0xFF |
| 0x56 | Disable alarm 2 at closed switch | 0xFF | 0xFF |
| 0x57 | Disable alarm 2 at open switch | 0xFF | 0xFF |
| 0x58 | Enable alarm 2 | 0xFF | 0xFF |
| 0x59 | Enable/disable alarm 2 | 0xFF | 0xFF |
| 0x5A | Disable alarm 2 | 0xFF | 0xFF |
| 0x5B | Enable sunrise at closed switch | 0xFF | 0xFF |
| 0x5C | Enable sunrise at open switch | 0xFF | 0xFF |
| 0x5D | Disable sunrise at closed switch | 0xFF | 0xFF |
| 0x5E | Disable sunrise at open switch | 0xFF | 0xFF |
| 0x5F | Enable sunrise | 0xFF | 0xFF |
| 0x60 | Enable/disable sunrise | 0xFF | 0xFF |
| 0x61 | Disable sunrise | 0xFF | 0xFF |
| 0x62 | Enable sunset at closed switch | 0xFF | 0xFF |
| 0x63 | Enable sunset at open switch | 0xFF | 0xFF |
| 0x64 | Disable sunset at closed switch | 0xFF | 0xFF |
| 0x65 | Disable sunset at open switch | 0xFF | 0xFF |
| 0x66 | Enable sunset | 0xFF | 0xFF |
| 0x67 | Enable/disable sunset | 0xFF | 0xFF |
| 0x68 | Disable sunset | 0xFF | 0xFF |

## Time Parameter Encoding (page 21)
- Time parameter byte uses a lookup where `0x00=0 seconds`, `0x01=1 s`, `0x02=2 s`, `0x13=1 min 59 s`, `0x20=2 min`, `0x27=4 min 45 s`, `0x33=5 min 30 s`, `0x38=29 min 30 s`, `0x52=30 min`, `0x83=31 min`, `0xD3=1 h 15 min`, `0xE3=4 h 45 min`, `0xE4=5 h`, `0xE5=5 h 30 min`, `0xED=9 h 30 min`, `0xEE=10 h`, `0xEF=11 h`, `0xFB=23 h`, `0xFC=1 day`, `0xFD=2 days`, `0xFE=3 days`, `0xFF=infinite`. Values not listed follow the incremental pattern shown in the table.

## Memory Map Summary

### Version 1 (early firmware) (pages 15-18)
- `0x0000-0x000F`: Blind 1 name (16 ASCII characters).
- `0x0021-0x0022`: Blind default timeout factor (stored as `256/(timeout*0.0131072)`).
- `0x0027`: Blind unwind delay in seconds.
- `0x0029`: Blind collapse delay in seconds.
- `0x003C-0x0044`: Location, group, circuit and load identifiers (low/high bytes per field).
- `0x004C-0x008B`: Module name string (64 characters).
- `0x008C`: Sunrise offset (-128..127 minutes).
- `0x008D`: Sunset offset (-128..127 minutes).
- `0x0090-0x009F`: Not used.
- `0x00A0-0x00A7`: Wake-up and go-to-bed times for two schedules.
- `0x00B0-0x00C9`: Monthly sunrise calibration offsets (21st and 5th of each month).
- `0x00CB-0x00E3`: Sunset calibration offsets (mirrors sunrise table).
- `0x00E4-0x00ED`: Module identifiers (location, group, circuit, load).
- `0x00EE-0x00F3`: Forced, inhibit, and lock status bitfields (see below).
- `0x00F4`: Blind auto mode selection.
- `0x00F5`: Alarm configuration bitfield.
- `0x00F8-0x00FB`: Current date (day, month, year hi, year lo).
- `0x00FC`: Module zone address.
- `0x00FD`: Module address.
- `0x00FE-0x00FF`: Serial number (high/low).
- `0x0100-0x017C`: Linked push button definitions.

### Version 2 (build 1809-1817) (pages 22-25)
- Same structure as version 1, retaining the same reserved ranges and offsets.
- Additional warning to avoid overwriting addresses `0x00EE-0x00FF` (forced/inhibit, date and identity fields).

### Version 3 (build 1935+) (pages 29-31)
- Adds `0x002B` storing blind slats rotate time; if zero, the blind has no rotating slats.
- Inserts a terminator at `0x00E5` preceding the module ID fields.
- Remaining layout matches version 2, including protected status bytes and push button tables.

### Status Bitfields (pages 16-17, 23-24, 30-31)
- **Forced up (`0x00EE`)**: bit clear = cancelled, bit set = channel forced up.
- **Forced down (`0x00EF`)**: same pattern for forced down state.
- **Inhibit (`0x00F0`)**: bit set when inhibited.
- **Inhibit preset up (`0x00F1`)** / **down (`0x00F2`)**: indicate preset-specific inhibit.
- **Lock state (`0x00F3`)**: bit set = locked.
- **Auto mode selection (`0x00F4`)**: 0 = none, 1/2/3 = active program.
- **Alarm configuration (`0x00F5`)**: bit-field capturing alarm enable, scope (local/global), sunrise/sunset enable and summer-time flag as detailed on page 17.

## Operational Notes
- Timers supplied in commands are big-endian 24-bit second counters; `0x000000` skips execution and `0xFFFFFF` applies indefinitely.
- LED mask commands may be combined; clearing uses `1` bits to clear.
- After any memory write, wait for the module to echo the updated memory block or pause at least 10 ms before sending the next command to avoid bus contention.
- For sunrise/sunset related commands, use `SID = 0x00` for global changes and the module address for local overrides (page 8).
- Do not overwrite reserved addresses listed above; they hold real-time state and identity information used by the module firmware.
