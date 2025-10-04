# VMB1BL Blind Module Protocol (Edition 1, Rev 4)

## Module Overview
- One-channel blind module (`ONE_CHANNEL_BLIND_MODULE_TYPE = 0x03`).
- Provides a single up/down blind relay pair with local up/down push buttons.
- Broadcasts LED states, blind status and naming information to the bus.
- Bus error counters and build year/week are included from build 0648 onward; local push button names and status reports are available from build 0815 onward.
- Frames follow the standard Velbus binary format `<SOF SID10..0 RTR IDE DLC3..0 DATA... CRC ACK EOF IFS>` _(source: page 1)._ 

## Transmitted Messages

### Local Push Button & Blind Relay Status (Build >= 0815)
- `SID10..9 = 0b00` (highest priority), `SID8..1 = module address`, `RTR = 0`, `DLC = 4`.
- Data bytes _(source: page 2)_:
  1. `0x00` (`COMMAND_PUSH_BUTTON_STATUS`).
  2. Bitmask of push buttons just pressed / blind relays just switched on.
  3. Bitmask of push buttons just released / relays switched off.
  4. Bitmask of push buttons long-pressed (>0.85 s).

### LED Control Messages to Push Button Modules
All messages use `SID10..9 = 0b11` (lowest priority) and target `SID8..1` set to the address of the remote push button module. `RTR = 0`.
- **Update LED states** _(page 2)_: `DLC = 4`, data `[0xF4, steady_on_bits, slow_blink_bits, fast_blink_bits]`. Steady on overrides blinking. When both slow and fast blink bits are set the LED blinks very fast.
- **Clear LED bits** _(page 2)_: `DLC = 2`, data `[0xF5, clear_mask]`. Each set bit clears the matching LED.
- **Set LED bits** _(page 3)_: `DLC = 2`, data `[0xF6, set_mask]`.
- **Fast blink LEDs** _(page 3)_: `DLC = 2`, data `[0xF8, fast_mask]`.
- **Very fast blink LEDs** _(page 3)_: `DLC = 2`, data `[0xF9, very_fast_mask]`.

### Memory Reporting
- **Single byte read-back** _(page 3)_: `SID10..9 = 0b11`, `SID8..1 = module address`, `RTR = 0`, `DLC = 4`, data `[0xFE, high_addr (must be 0x00), low_addr (0x00-0x7F), value]`.
- **Four-byte memory block** (Build >= 0735) _(page 3)_: same identifier with `DLC = 7`, data `[0xCC, high_addr (0x00), low_addr (0x00-0x7C), byte1, byte2, byte3, byte4]`.

### Blind Status Broadcast
- `SID10..9 = 0b11`, `SID8..1 = module address`, `RTR = 0`, `DLC = 8` _(page 4)_.
- Data: `[0xEC, blind_channel_bits (0b00000011), timeout_setting, blind_status, led_status, delay_hi, delay_mid, delay_lo]`.
- The delay fields encode a 24-bit delay in seconds.

### Module Identification
- `SID10..9 = 0b11`, `SID8..1 = module address`, `RTR = 0`, `DLC = 5` _(page 4)_.
- Data: `[0xFF, 0x03, timeout_dip_setting, build_year (>= build 0648), build_week (>= build 0648)]`.

### Blind Name Segments
Each segment uses `SID10..9 = 0b11`, `SID8..1 = module address`, `RTR = 0` _(page 5)_.
- **Part 1** (`DLC = 8`): `[0xF0, channel_bits, char1, ..., char6]`.
- **Part 2** (`DLC = 8`): `[0xF1, channel_bits, char7, ..., char12]`.
- **Part 3** (`DLC = 6`): `[0xF2, channel_bits, char13, char14, char15, char16]`.
- Unused character slots contain `0xFF`.

### Local Push Button Names (Build >= 0815)
Same opcodes as the blind name frames with identifier bits selecting the target _(pages 5-6)_:
- Identifier bits (`data[1]`): `0x10` for the local up button, `0x20` for the local down button.
- Part 1/2/3 payload structure matches the blind name segments; unused characters are `0xFF` and part 3 byte 5 is fixed to `0xFF`.

### Bus Error Counters (Build >= 0648)
- `SID10..9 = 0b11`, `SID8..1 = module address`, `RTR = 0`, `DLC = 4` _(page 6)_.
- Data: `[0xDA, tx_error_count, rx_error_count, bus_off_count]`.

## Received Commands

### Push Button Module Messages
- **Push button status** _(page 6)_: `SID10..9 = 0b00`, `SID8..1 = remote push button module`, `RTR = 0`, `DLC = 4`, data `[0x00, just_pressed, just_released, long_pressed]`.
- **Clear LED command** (Build >= 0815) _(page 6)_: `SID10..9 = 0b11`, `SID8..1 = remote push button address`, `DLC = 2`, data `[0xF5, led_mask]`.

### Blind Movement Commands
- **Switch blind off** _(page 7)_: `SID10..9 = 0b00`, `SID8..1 = module address`, `DLC = 2`, data `[0x04, channel_bits]`.
- **Switch blind up** _(page 7)_: `SID10..9 = 0b00`, `DLC = 5`, data `[0x05, channel_bits, timeout_hi, timeout_mid, timeout_lo]`.
- **Switch blind down** _(page 7)_: same framing, command byte `0x06`.
- Timeout bytes form a 24-bit value in seconds. `0x000000` selects the DIP-switch timeout; `0xFFFFFF` keeps the output on permanently.

### Status & Identification Requests
- **Blind status request** _(page 8)_: `SID10..9 = 0b11`, `SID8..1 = module address`, `DLC = 2`, data `[0xFA, channel_bits]`.
- **Module type request** _(page 8)_: `SID10..9 = 0b11`, `RTR = 1`, `DLC = 0`.
- **Bus error counter status request** (Build >= 0648) _(page 8)_: `SID10..9 = 0b11`, `DLC = 1`, data `[0xD9]`.
- **Blind or push button name request** (Build >= 0815) _(page 8)_: `SID10..9 = 0b11`, `DLC = 2`, data `[0xEF, selector_bits]` where `0x03` requests blind name, `0x10` the local up button name, and `0x20` the local down button name.

### Memory Access Commands
- **Read single location** _(page 8)_: data `[0xFD, high_addr (0x00), low_addr (0x00-0x7F)]`.
- **Read 4-byte block** (Build >= 0743) _(page 8)_: data `[0xC9, high_addr (0x00), low_addr (0x00-0x7C)]`.
- **Memory dump request** (Build >= 0735) _(page 8)_: data `[0xCB]`; module responds with successive `COMMAND_MEMORY_DATA_BLOCK` frames.
- **Write single location** _(page 9)_: data `[0xFC, high_addr (0x00), low_addr (0x00-0x7F), value]`. Wait at least 10 ms before issuing another Velbus command.
- **Write 4-byte block** (Build >= 0743) _(page 9)_: data `[0xCA, high_addr (0x00), low_addr (0x00-0x7C), byte1, byte2, byte3, byte4]`. Wait for the corresponding `COMMAND_MEMORY_DATA_BLOCK` feedback before sending the next command.

## Memory Map
All unused locations contain `0xFF`. Address pairs use even offsets for the linked module address and the next odd offset for the bitmask within that module.

### Firmware <= 0x0743 _(page 10)_
- Up push button links: `0x0000/0x0001` through `0x001A/0x001B` (14 entries).
- Immediate up links: `0x001C/0x001D` through `0x0036/0x0037` (14 entries).
- Down push button links: `0x0038/0x0039` through `0x0052/0x0053` (14 entries).
- Immediate down links: `0x0054/0x0055` through `0x006E/0x006F` (14 entries).
- Blind name characters: `0x0070-0x007F` (16-character ASCII string).

### Firmware 0x0804 _(page 10)_
- Up push button links: `0x0000/0x0001` through `0x0014/0x0015` (11 entries).
- Immediate up links: `0x0016/0x0017` through `0x002A/0x002B` (11 entries).
- Down push button links: `0x002C/0x002D` through `0x0040/0x0041` (11 entries).
- Immediate down links: `0x0042/0x0043` through `0x0056/0x0057` (11 entries).
- Combined up/down links: `0x0058/0x0059` through `0x006C/0x006D` (11 entries).
- `0x006E` and `0x006F` are unused.
- Blind name characters: `0x0070-0x007F`.

### Firmware >= 0x0815 _(page 11)_
- Up push button links: `0x0000/0x0001` through `0x000E/0x000F` (8 entries).
- Immediate up links: `0x0010/0x0011` through `0x001E/0x001F` (8 entries).
- Down push button links: `0x0020/0x0021` through `0x002E/0x002F` (8 entries).
- Immediate down links: `0x0030/0x0031` through `0x003E/0x003F` (8 entries).
- Combined up/down links: `0x0040/0x0041` through `0x004E/0x004F` (8 entries).
- Local up push button name: `0x0050-0x005E` (15 characters, ASCII) with response time at `0x005F` (seconds).
- Local down push button name: `0x0060-0x006E` with response time at `0x006F`.
- Blind name characters: `0x0070-0x007F`.

## Operational Notes
- LED command mask bits correspond to the remote push button LEDs and may be combined; steady-on overrides blink modes.
- Timeouts and delays are always encoded as big-endian 24-bit integers representing seconds.
- After writing memory, ensure the recommended delays are observed to avoid missed acknowledgements.
- Name frames reuse the blind-name opcodes; always set the selector bits in byte 2 to target blind (`0x03`), local up (`0x10`), or local down (`0x20`) identifiers.
