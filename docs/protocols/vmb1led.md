# VMB1LED PWM LED Strip Dimmer Protocol (Edition 3)

## Module Overview
- Single-channel PWM LED strip dimmer (`PWM_LED_STRIP_DIMMER_MODULE = 0x0F`).
- Shares feature set with the VMB1DM dimmer: configurable operating modes, timer behaviour, local push button, slider input and atmospheric presets.
- Broadcasts module configuration, slider readings, local button activity, LED indicators and firmware data using the Velbus CAN frame format `<SOF SID10..0 RTR IDE DLC3..0 DATA.. CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Local Inputs (page 2)
- **Local push button & dimmer switch status**: `SID10..9 = 0b00`, module address, data `[0x00, pressed_mask, released_mask, long_press_mask]`.
- **Dimmer slider status**: `SID10..9 = 0b00`, module address, data `[0x0F, 0x01, dim_percent(0-100), 0x00]` (`0x00` indicates no long press).

### LED Control Frames (pages 2-3)
All use `SID10..9 = 0b11`, target push button module, `RTR = 0`.
- Update LED states: `[0xF4, steady_mask, slow_blink_mask, fast_blink_mask]`.
- Clear LEDs: `[0xF5, mask]`.
- Set LEDs: `[0xF6, mask]`.
- Slow blink: `[0xF7, mask]`.
- Fast blink: `[0xF8, mask]`.
- Very fast blink: `[0xF9, mask]`.

### Dimmer Status (page 3)
- Frame: `SID10..9 = 0b11`, module address, `RTR = 0`, `DLC = 8`, data `[0xEE, mode, dim_value, led_flags, delay_hi, delay_mid, delay_lo, config]`.
  - Modes: `0=start/stop timer`, `1=staircase`, `2=dimmer`, `3=dimmer with memory`, `4=multistep`, `5=slow on`, `6=slow off`, `7=slow on/off`.
  - `led_flags`: `0x80` steady on, `0x40` slow blink, `0x20` fast blink, `0x10` very fast blink, `0x00` off.
  - `[delay_hi..delay_lo]`: 24-bit remaining timer in seconds.
  - `config`: lower three bits encode firmware version; other bits reserved.

### Module Type (page 4)
- Payload `[0xFF, 0x0F, mode, time_setting, config, build_year, build_week]`.
  - `time_setting` mapping: `0=momentary`, `1=5 s`, `2=10 s`, `3=15 s`, `4=30 s`, `5=1 min`, `6=2 min`, `7=5 min`, `8=10 min`, `9=15 min`, `0x0A=30 min`, `0x0B=1 h`, `0x0C=2 h`, `0x0D=5 h`, `0x0E=1 day`, `0x0F=no timer/max dim speed`.
  - `config` retains the firmware version in its three lower bits.

### Diagnostics & Metadata (pages 4-6)
- **Bus error counters**: `[0xDA, tx_err, rx_err, bus_off]`.
- **Dimmer name**: part 1/2/3 frames (`0xF0/0xF1/0xF2`) carrying 16 ASCII characters; unused bytes are `0xFF`.
- **Local dim push button name**: same opcodes with selector byte `0x10`.
- **Memory data**: `[0xFE, 0x00, addr, value]` and `[0xCC, 0x00, addr, byte1..byte4]`.

## Received Commands

### External Inputs (page 7)
- Push button status frames `[0x00, pressed, released, long_press]`.
- Slider status frames `[0x0F, channel, value, long_press_flag]`.
- Clear LED command `[0xF5, mask]`.

### Dimmer Operation (pages 7-9)
- **Set dim value**: `[0x07, 0x01, level, speed_hi, speed_lo]`. Speed is 16-bit seconds for full-scale dimming; `0x0000` uses DIP setting, `0xFFFF` = fastest (1.5 s).
- **Restore last dim value** (build >= 1006): `[0x11, 0x01, 0x00, speed_hi, speed_lo]` with same speed rules.
- **Stop dimming** (build >= 1005): `[0x10, 0x01]`.
- **Start dimmer timer**: `[0x08, 0x01, timeout_hi, timeout_mid, timeout_lo]`; timeout `0x000000` selects DIP timer; `0xFFxxxx` keeps the output on permanently.
- **Dimmer status request**: `[0xFA, 0x01]`.

### Identification & Diagnostics (page 8)
- Module type RTR request (`DLC = 0`, `RTR = 1`).
- Bus error status request `[0xD9]`.
- Name request `[0xEF, selector]` where `0x01` addresses the dimmer name and `0x10` the local dim push button name.

### Memory Access (pages 8-9)
- `[0xFD, 0x00, addr]` read word.
- `[0xC9, 0x00, addr]` read 4-byte block (addresses `0x00-0xFC`).
- `[0xCB]` memory dump trigger.
- `[0xFC, 0x00, addr, value]` write word (wait >=10 ms before sending another command).
- `[0xCA, 0x00, addr, byte1..byte4]` write block (wait for feedback before continuing).

## Memory Map (build 0947/1005) (page 10)
- `0x0000-0x0017`: Clear LED push button module/bit assignments for up to 12 buttons.
- `0x0018-0x002F`: Set LED push button assignments.
- `0x0030-0x0047`: Toggle LED push button assignments.
- `0x0048-0x005F`: Dim push button assignments.
- `0x0060-0x0077`: Slider module addresses and bit numbers.
- `0x0078-0x008F`: Dim-up push button assignments.
- `0x0090-0x00A7`: Dim-down push button assignments.
- `0x00A8-0x00BF`: Atmospheric mode push button assignments.
- `0x00C0-0x00CB`: Atmospheric dim values (0-100%).
- `0x00CC-0x00D7`: Atmospheric dim times with bit7 indicating units (`0=seconds`, `1=minutes`) and lower bits defining duration (see table below).
- `0x00D8-0x00DF`: Reserved/unused.
- `0x00E0-0x00EF`: Local dim push button name (16 characters).
- `0x00F0-0x00FF`: Dimmer name (16 characters).
- Unused addresses contain `0xFF`.

### Atmospheric Dim Time Encoding (page 10)
- `0x00` = fastest dim time.
- `0x01-0x7E` represent 1-126 seconds.
- `0x7F` repeats the fastest dim time.
- `0x80` = fastest dim time (minutes range).
- `0x81-0xFE` represent 1-126 minutes (bit7 set).
- `0xFF` again encodes the fastest dim time.

## Operational Notes
- LED behaviour mirrors VMB1DM; steady-on overrides slow/fast blink and combining slow+fast yields very fast blink.
- Slider reports always use channel `0x01`; byte 4 is reserved for the long-press flag.
- Memory write pacing rules match the rest of the Velbus ecosystem: pause 10 ms or wait for the data block echo before issuing another write.
- When requesting names, set byte 2 to `0x01` for the dimmer or `0x10` for the local dim push button to receive the appropriate three-part response.
