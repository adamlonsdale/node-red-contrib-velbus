# VMB1TSW Temperature Sensor with Hex Switch Addressing (Edition 1)

## Module Overview
- Surface-mount temperature sensor with local buttons, LED feedback, and a hardware address set by hex switches (page 3).
- Shares telemetry and program behaviour with VMB1TS, including comfort/day/night/safe temperature management and differential sensor support (pages 4–8).
- Communicates on Velbus CAN using priority bits `SID10..9` (`00` = highest, `11` = lowest) and the switch-selected node id in `SID8..1` (page 3).

## Message Formats
- All outgoing frames use `RTR = 0`; DLC ranges from 2 to 8 bytes depending on payload (pages 3–8).
- Sleep timers are 16-bit big-endian minute counters: `0x0000` disables, `0x0001–0xFEFF` run a countdown, `0xFFFF` forces manual mode (page 5).
- Temperature values are two’s complement; summary packets use 0.5 °C resolution while detailed measurements use 0.0625 °C and always clear the five LSbs (pages 5–6).

## Transmitted Messages
- **Output Status – `0x00`**: indicates rising/falling edges on actuator outputs; final byte reserved (page 3).
- **Manual Push Button Status – `0x00`**: exposes just pressed, just released, and >0.85 s long press flags (page 3).
- **Sensor Status – `0xEA`**: operating mode, program step mode, output state, current temperature, target temperature, and sleep timer (pages 4–5).
- **Sensor Temperature – `0xE6`**: current/min/max temperature pairs (0.0625 °C resolution) (page 5–6).
- **Time Statistics – `0xC8`**: heater/cooler runtime and mode durations, BCD encoded by index (page 6).
- **Settings Blocks** (`0xE8`, `0xE9`, `0xC6`, `0xB9`): publish heating presets, cooling presets, alarms, calibration factor, differential sensor address (`0xFF` when unused), and build ≥0949 minimum switching time (pages 6–8, 19).
- **Configuration Data – `0xBB`**: configuration byte, limit/hysteresis thresholds (upper nybble significant), output state, timeout countdown (page 7–8).
- **Sensor Name Segments – `0xF0/0xF1/0xF2`**: 16-character ASCII name with unused characters filled by `0xFF` (page 8–9).
- **Memory Feedback – `0xFE` / `0xCC`**: single-byte and four-byte memory echoes; high address must be `0x00` (pages 9–10).
- **Remote LED Control – `0xF4–0xF9`**: update, clear, set, slow blink, fast blink, and very fast blink for associated push-button modules; steady-on overrides blink and dual blink flags trigger the very-fast pattern (pages 10–11).
- **Bus Error Counters – `0xDA`**: transmit, receive, and bus-off counters (page 10–11).
- **Differential Target – `0xE4` with index `0x20`**: writes the desired setpoint for the slave sensor used in differential mode (page 11).

## Accepted Commands
- **Push Button Status (`0x00`)**: collects remote button edges and long press flags from paired modules (page 12).
- **LED Control (`0xF4–0xF9`)**: update, clear, set, slow, fast, and very-fast blink directives for onboard LEDs (pages 12–14).
- **Module Type Probe**: RTR request answered with module type enumeration (page 14).
- **Bus Error Request – `0xD9`**: prompts a `0xDA` counter reply (page 14).
- **Sensor Telemetry Requests**: `0xE9` temperature/autosend, `0xFA` status, `0xE7` settings, `0xBA` configuration, `0xEF` name, and `0xC7` statistics (pages 14–15).
- **Operational Control**: lock/unlock (`0xE1/0xE2`), heating/cooling selection (`0xE0/0xDF`), and zone assignment (`0xC9`, echoing module type on success) (pages 15–16).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); always wait for memory feedback prior to the next command (pages 15–17).
- **Sleep & Setpoint Management**: default sleep (`0xE3`), pointer-based setpoint writes (`0xE4`, pointer 0=current, 6=hysteresis, 8=day cooling, 9=night cooling, etc.), reset min/max values, reset statistics modes, and toggle the anti-block heater/pump routine (pages 17–19).
- **Mode Overrides**: comfort/day/night/safe commands (`0xDB–0xDE`) honour the timer semantics (`0xFF00` = program step, `0xFFFF` = manual, `0x0000` = cancel) (pages 19–20).
- **Program Availability – `0xBC`**: notification from VMB1TC including availability flag, program type, and sensor address (page 20–21).

## Channel Naming & LED Behaviour
- Button and LED bitfields align; byte 2 encodes the button/LED mask so remote modules can mirror local actions (pages 3 & 12–14).
- Conflicting blink requests escalate to very-fast blink as documented; steady-on remains dominant (pages 10–11).

## Sensor & Analog Output Settings
- Heating presets (comfort/day/night/anti-freeze) and cooling presets (comfort/day/night/safe) use 0.5 °C granularity; auto-send interval `0` disables, `1–9` = on-change, `10–255` seconds (pages 6–7).
- Alarm thresholds, range limits, calibration (−8…+7.5 °C) and hysteresis (0…15.5 °C) maintain 0.5 °C resolution; differential sensor address `0xFF` denotes no slave (pages 7–8 & 24).
- Output timeout byte drops to `0x00` when the actuator timed out, signalling clients to refresh the command (page 8).

## Program & Scheduling Controls
- Default sleep timer (`0xE3`) defines fallback manual duration; manual overrides via `0xDB–0xDE` reuse the same semantics (pages 17–20).
- Pointered `0xE4` updates allow scripts to change live presets or hysteresis without rewriting the entire settings blocks (page 18–19).
- Reset commands clear min/max temperature history and per-mode runtime statistics; allow ≥10 ms between successive commands as advised (page 19).

## Memory Map
- Builds 0927/0947: push-button linkage pairs span `0x0000–0x00B7`; differential sensor address stored at `0x00D9` while several slots (`0x00D0–0x00D7`) remain unused (page 21).
- Builds 0949/1001: add storage for normally-open/closed disable switches and relocate the minimum switching time to `0x00D8`; presets, calibration, and autosend fields persist at `0x00DA–0x00EF`, with name characters at `0x00F0–0x00FF` (pages 22–23).
- Reserved/write-protected addresses include `0x00CC–0x00CF`; unused table entries and name characters hold `0xFF` (pages 21–23).

## Linked Push Button Actions
- Comfort/day/night/safe overrides, heating/cooling toggles, lock/unlock, and disable switch behaviours read the stored address/mask pairs, enabling distributed control panels (pages 21–22).
- Program availability broadcasts (`0xBC`) let supervisory controllers flag sensors holding downloadable schedules (page 20–21).

## Conversion Notes
- OCR artefacts such as `COMMAND_BUS_ERROR_CONTER` and truncated pointer tables were normalised; consult the source PDF when automating against pointer values beyond those listed (pages 14–19).
- Hex-switch addressing is called out wherever the original table referenced “address set by hex switches” to differentiate from software-assigned node ids (pages 3–6).
- Memory tables were summarised; refer to the PDF for exhaustive address-bit combinations before generating tooling (pages 21–23).
