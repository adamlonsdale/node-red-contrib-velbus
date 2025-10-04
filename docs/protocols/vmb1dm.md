# VMB1DM Dimmer Module Protocol (Edition 1, Rev 5)

## Module Overview
- Electronic transformer dimmer module (`DIMMER_MODULE_FOR_ELECTRONIC_TRANSFORMER_TYPE = 0x07`).
- Provides a single dimmer channel with optional local push button, slider input and atmospheric presets.
- Supports multiple operating modes: start/stop timer, staircase timer, classic dimmer (with/without memory), multistep dimmer, and slow on/off variants.
- Reports slider position, local button activity, LED states, configuration, firmware build and error counters over the standard Velbus CAN frame `<SOF SID10..0 RTR IDE DLC3..0 DATA.. CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Local Control Status (page 2)
- **Local push button & dimmer switch status** (build >= 0819): `SID10..9 = 0b00`, module address, `RTR = 0`, `DLC = 4`, data `[0x00, pressed_mask, released_mask, long_press_mask]`.
- **Dimmer slider status** (build >= 0917): `SID10..9 = 0b00`, module address, `RTR = 0`, `DLC = 4`, data `[0x0F, 0x01, dim_percent(0-100), 0x00]`.

### LED Control Frames (pages 2-4)
All use `SID10..9 = 0b11`, destination push button module, `RTR = 0`.
- Update LED states: `[0xF4, steady_mask, slow_blink_mask, fast_blink_mask]` (steady overrides blink; combining slow + fast yields very fast blink).
- Clear LEDs: `[0xF5, mask]`.
- Set LEDs: `[0xF6, mask]`.
- Slow blink: `[0xF7, mask]`.
- Fast blink: `[0xF8, mask]`.
- Very fast blink: `[0xF9, mask]`.

### Dimmer Status Report (page 4)
- Frame: `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 8`, data `[0xEE, mode, dim_value, led_flags, delay_hi, delay_mid, delay_lo, config]`.
  - `mode` enumerations: `0=start/stop timer`, `1=staircase timer`, `2=dimmer`, `3=dimmer with memory`, `4=multistep dimmer`, `5=slow on`, `6=slow off`, `7=slow on/off`.
  - `led_flags`: `0x00` LED off, `0x80` steady on, `0x40` slow blink, `0x20` fast blink, `0x10` very fast blink.
  - `[delay_hi..delay_lo]` encode a 24-bit remaining timer in seconds.
  - `config` bits: `bit6`=zero crossing error, `bit5`=too inductive load, `bit4` selects mains frequency (`0=50 Hz`, `1=60 Hz`), `bit3` selects transformer type (`0=electronic`, `1=ferro`), lower three bits encode the firmware version.

### Module Type (page 5)
- Payload `[0xFF, 0x07, mode, time_switch, config, build_year, build_week]`.
  - `time_switch` mapping: `0=momentary`, `1=5 s`, `2=10 s`, `3=15 s`, `4=30 s`, `5=1 min`, `6=2 min`, `7=5 min`, `8=10 min`, `9=15 min`, `0x0A=30 min`, `0x0B=1 h`, `0x0C=2 h`, `0x0D=5 h`, `0x0E=1 day`, `0x0F=no timer / max dim speed`.
  - `config` shares the same bit layout described for the status frame, additionally using bit6 to signal zero-crossing errors and bit5 for inductive load warnings.

### Diagnostics & Metadata
- **Bus error counters**: `[0xDA, tx_err, rx_err, bus_off]` (page 5).
- **Name segments**: opcodes `0xF0/0xF1/0xF2` broadcast 16-character dimmer and local push button names (pages 6-7); unused bytes are `0xFF`.
- **Memory data**: `[0xFE, addr_hi(0x00), addr_lo, value]` and `[0xCC, addr_hi, addr_lo, byte1..byte4]` for block responses (page 7).

## Received Commands

### Remote Inputs (page 8)
- **Push button status** frames from remote modules: `[0x00, pressed, released, long_press]`.
- **Slider status** frames from remote sliders: `[0x0F, channel, value, long_press]`.
- **Clear LED command** (build >= 0819): `[0xF5, mask]`.

### Dimmer Control (pages 8-10)
- **Set dim value**: `[0x07, 0x01, level(0-100), dimspeed_hi, dimspeed_lo]`. Dimspeed is a 16-bit second value for 0-100% transitions. `0x0000` selects the DIP speed; `0xFFFF` forces the fastest ramp (1.5 s).
- **Restore last dim value** (build >= 1006): `[0x11, 0x01, don't_care, dimspeed_hi, dimspeed_lo]` (same dimspeed rules).
- **Stop dimming** (build >= 1005): `[0x10, 0x01]`.
- **Start dimmer timer**: `[0x08, 0x01, timeout_hi, timeout_mid, timeout_lo]` where timeout is 24-bit seconds; `0x000000` uses DIP timer, `0xFFxxxx` (high byte 0xFF) keeps the load on indefinitely.
- **Dimmer status request**: `[0xFA, 0x01]`.

### Identification & Names (page 9)
- Module type RTR request (`SID10..9 = 0b11`, `RTR = 1`, `DLC = 0`).
- Bus error counter status request: `[0xD9]`.
- Name request: `[0xEF, selector]` with `0x01` for dimmer name and `0x10` for local dim push button name.

### Memory Access (pages 9-10)
- Read word: `[0xFD, 0x00, addr_lo]`.
- Read block: `[0xC9, 0x00, addr_lo]` (low address `0x00-0xFC`).
- Memory dump: `[0xCB]`.
- Write word: `[0xFC, 0x00, addr_lo, value]`.
- Write block: `[0xCA, 0x00, addr_lo, byte1..byte4]`.
- Wait at least 10 ms or until the module returns a `COMMAND_MEMORY_DATA_BLOCK` frame before issuing further write operations.

## Memory Map

### Firmware <= 0x0743 (page 11)
- `0x0000-0x001B`: Linked push button module addresses and clear LED bit masks for up to 14 buttons.
- `0x001C-0x0037`: Push button addresses for set LED actions.
- `0x0038-0x0053`: Toggle push button addresses and bit masks.
- `0x0054-0x006F`: Dim push button assignments (press-and-hold dimming).
- `0x0070-0x008B`: Slider module addresses and bit numbers.
- `0x008C-0x00C3`: Dim-up/dim-down push button assignments.
- `0x00C4-0x00ED`: Atmospheric preset buttons and 14 stored dim values.
- `0x00EE-0x00F3`: Runtime status (timer/dim flags and configuration).
- `0x00F4-0x00FF`: Dimmer name characters 1-16.
- Unused locations contain `0xFF`.

### Firmware >= 0x0819 (page 12)
- Structure updated to support 13-button groups and local dim push button naming.
- `0x0000-0x009D`: Same categories as above but with condensed address spacing (supports clear/set/toggle/dim assignments for up to 13 buttons).
- `0x00B6-0x00CF`: Atmospheric presets.
- `0x00D0-0x00DF`: 14 atmospheric dimmer values.
- `0x00E0-0x00EF`: Local dim push button name (16 characters).
- `0x00F0-0x00FF`: Dimmer name (16 characters).
- All unused addresses remain `0xFF`.

## Operational Notes
- Mode and time switch settings reported in the module type frame mirror DIP-switch selections on the physical module.
- Dimmer configuration bits expose hardware issues (zero-crossing faults, inductive loads) and hardware options (mains frequency, transformer type); monitor them via the status or module type frames.
- Slider reports always advertise channel `0x01`; reserve byte 4 for long-press flags (currently `0x00`).
- To maintain bus stability, obey the 10 ms spacing or wait-for-feedback rule after memory writes, as noted in the datasheet.
- Name frames reuse the same opcodes as other Velbus modules; ensure byte 2 carries `0x01` for the dimmer or `0x10` for the local dim push button when requesting or broadcasting names.
