# VMB1TS Temperature Sensor Protocol (Edition 1, Rev 4)

## Module Overview
- Single-channel wall temperature sensor with onboard push buttons and differential sensor option (`COMMAND_TEMP_SENSOR_STATUS = 0xEA`, source: page 4).
- Publishes comfort/day/night/safe program data, local overrides, min/max temperatures, and time statistics to the Velbus CAN bus (pages 4–8).
- Reports in standard Velbus CAN frames with priority bits `SID10..9` (`00` = highest, `11` = lowest) and module address in `SID8..1` (page 3).

## Message Formats
- Outgoing frames use `RTR = 0` with DLC between 2 and 8 bytes; status and telemetry packets are sent with lowest priority (`SID10..9 = 11`).
- Sleep timers are 16-bit big-endian minute counters; `0x0000` disables, `0x0001–0xFEFF` counts down, `0xFFFF` locks manual mode (page 5).
- Temperature values are two’s complement; status packets use 0.5 °C resolution while detailed telemetry uses 0.0625 °C (page 6).

## Transmitted Messages
- **Output Status – `0x00`**: reports channels just activated/deactivated; byte 4 reserved (page 3).
- **Manual Push Button Status – `0x00`**: publishes just pressed, just released, and >0.85 s long press flags (page 3).
- **Sensor Status – `0xEA`**: operating mode, program step mode, output state, current temperature, target temperature, and sleep timer (page 4–5).
- **Sensor Temperature – `0xE6`**: current, minimum, and maximum temperatures as high/low byte pairs (page 5–6).
- **Time Statistics – `0xC8`**: BCD-encoded heater/cooler run-time and selected mode durations, indexed per mode (page 6).
- **Settings Blocks** (`0xE8`, `0xE9`, `0xC6`, `0xB9`): publish heating presets, cooling presets, alarms, calibration, differential sensor address, and (build ≥0949) minimum switching time (pages 6–8).
- **Configuration Data – `0xBB`**: configuration flags, limit/hysteresis thresholds (upper nybble only), current output state, and timeout (page 7–8).
- **Sensor Name Parts – `0xF0/0xF1/0xF2`**: 16-character ASCII name split across three frames; unused slots contain `0xFF` (page 8–9).
- **Memory Echo – `0xFE` / `0xCC`**: word and 4-byte block reads; high address must be `0x00` (pages 9–10).
- **Remote LED Control – `0xF4–0xF9`**: update, clear, set, slow blink, very-fast blink for linked push-button modules; continuous-on overrides blink, and conflicting blink bits produce very-fast blink (page 10).
- **Bus Error Counters – `0xDA`**: transmit, receive, and bus-off counters (page 10–11).
- **Differential Target – `0xE4` with index `0x20`**: write target temperature for the linked slave sensor (page 11).

## Accepted Commands
- **Push Button Status (`0x00`)**: ingests remote button edges and long press indications (page 12).
- **LED Control (`0xF4–0xF9`)**: accepts update, clear, set, slow, fast, and very-fast blink instructions for local indicator LEDs (pages 12–14).
- **Module Type Probe**: RTR frame answered with module identification (`COMMAND_TEMPERATURE_SENSOR_TYPE`, page 14).
- **Bus Error Request – `0xD9`**: triggers counter response (page 14).
- **Sensor Telemetry Requests**: `0xE9` (temperature + autosend interval), `0xFA` (status), `0xE7` (settings), `0xBA` (config), `0xEF` (name), `0xC7` (time statistics) (pages 14–15).
- **Local Control**: lock/unlock (`0xE1/0xE2`), set heating/cooling mode (`0xE0/0xDF`), assign zone (`0xC9`, response echoes module type) (pages 15–16).
- **Memory Services**: word read/write (`0xFD/0xFC`), block read/write (`0xC9/0xCA`), full dump (`0xCB`); wait for corresponding feedback before the next write (pages 15–17).
- **Sleep & Temperature Management**: default sleep (`0xE3`), direct set-point/preset write via pointered `0xE4`, reset min/max temperatures, reset time statistics, and enable/disable anti-block heater/pump feature (pages 17–18).
- **Mode Overrides**: comfort/day/night/safe commands (`0xDB–0xDE`) with 16-bit sleep timers; `0xFF00` marks a program step, `0xFFFF` forces manual, `0x0000` cancels (pages 18–19).
- **Program Availability – `0xBC`**: controller notification carrying availability flag, type (day/special), and sensor address whenever VMB1TC updates schedules (page 19–20).

## Channel Naming & LED Behaviour
- Push-button and LED frames share the same bit order; byte 2 uses bit masks to address individual buttons/LEDs (page 3 and 12–14).
- LED control prioritises steady-on > slow blink > fast blink; requesting both blink modes results in the documented very-fast blink override (page 10).

## Sensor & Analog Output Settings
- Heating presets (comfort/day/night/anti-freeze) and cooling presets (comfort/day/night/safe) carry 0.5 °C resolution values; auto-send interval: `0` disabled, `1–9` on-change, `10–255` seconds (pages 6–7).
- Alarm thresholds, range limits, calibration (−8…+7.5 °C), and hysteresis (0…15.5 °C) share 0.5 °C granularity; differential sensor address `0xFF` disables the slave sensor (pages 7–8 & 23–25).
- Output timeout byte counts down to zero; zero indicates the channel timed out and should be refreshed (page 8).

## Program & Scheduling Controls
- `0xE3` default sleep sets the fallback countdown; manual overrides (`0xDB–0xDE`) inherit the sleep semantics (pages 17–19).
- Pointered `0xE4` writes allow updating the active set-point, hysteresis, or cooling presets directly; see pointer table on page 17 for slot mapping (0=current, 6=hysteresis, 8=day cooling, 9=night cooling, etc.).
- Reset commands clear min/max temperature history and per-mode statistics; wait ≥10 ms between successive writes as advised on page 18.

## Memory Map
- Builds 0927/0947 store push-button linkage pairs (module address + bit mask) for comfort/day/night/safe/heating/cooling/lock/unlock buttons at `0x0000–0x00B7`; differential sensor address lives at `0x00D9` (page 20–21).
- Builds 0949/1001 add slots for normally-open/closed disable switches and relocate minimum switching time to `0x00D8`; temperature presets and metadata remain at `0x00DA–0x00EF` with name characters at `0x00F0–0x00FF` (pages 22–23).
- Write-protected addresses include `0x00CC–0x00CF` (build ≥0949). Unused locations and name characters are `0xFF` (pages 21–23).

## Linked Push Button Actions
- Comfort/day/night/safe overrides, heating/cooling mode toggles, and lock/unlock commands each map to stored button masks, enabling remote stations to mirror local control (pages 20–22).
- Program availability notifications (`0xBC`) allow the controller to highlight sensors with downloadable schedules (page 19–20).

## Conversion Notes
- Command mnemonics follow the Velbus specification; OCR misreadings such as `COMMAND_BUS_ERROR_CONTER` were normalised (pages 14–15).
- Pointer values for `COMMAND_SET_TEMP` beyond the documented entries should be cross-checked against the original PDF before scripting (page 17).
- Memory maps were condensed from tabular listings; always consult the source PDF for exhaustive address tables when developing tooling (pages 20–23).
