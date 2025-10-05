# VMB1TCW Temperature Controller Protocol (Edition 1)

## Module Overview
- Wall-mounted temperature controller (`NODETYPE_TEMPERATURE_CONTROLLER = 0x0E`) bundling clock, program, and multi-zone supervision for remote thermostats (page 6).
- Issues global schedules, sensor overrides, and diagnostics, while mirroring the VMB1TC feature set for rooms, zones, and individual sensors (pages 1–4, 7–12).
- Communicates over Velbus CAN frames; controller broadcasts use `SID10..9 = 11` with `SID8..1 = 0x00`, while sensor-directed frames reuse their device address (pages 3–4).

## Message Formats
- Outbound frames are standard Velbus CAN (`RTR = 0`) with DLC 1–8; program writes and memory transfers target the sensor memory address rather than the controller (`0xBF/0xC0/0xC2`, pages 4, 8).
- Sleep timers and overrides use 16-bit big-endian minutes: `0x0000` cancels, `0x0001–0xFEFF` counts down, `0xFF00` flags program steps, `0xFFFF` forces manual mode (pages 11–12).
- Program step metadata packs weekday mask and mode flags into a single byte; relative time fields provide sunrise/sunset offsets (pages 7–8).

## Transmitted Messages
- **Clock Coordination**: `0xD7` request and `0xD8` status (day, hour, minute) broadcast from `SID = 0x00` (page 3).
- **Alarms**: `0xC3` defines global wake/bed alarms with enable flag; controller also emits `0xBC` program availability updates containing type and sensor address (pages 3–4).
- **Program Handling**: `0xBF` selects sensor program storage (module addr + program type), `0xC1` publishes program step info, `0xC2` writes steps, `0xC0` reads steps (pages 4, 7–8).
- **Status & Identity**: `0xC4` controller status (output flags, wake/bed schedule, configuration, language), `0xFF` module type with build week/year, `0xDA` bus error counters, and `0xF0/0xF1/0xF2` module name segments (pages 5–6).
- **Output State**: `0x00` reports channels just activated/deactivated plus link mask (page 7).
- **Memory Echo**: `0xFE` single word, `0xCC` 4-byte block (addresses up to `0x14FF`) for sensors and controller (page 4).

## Accepted Commands
- **Discovery & Timekeeping**: accepts `0xD7/0xD8` clock exchange, module type scans (RTR), and alarm definitions from automation clients (pages 18–20).
- **Sensor Management**: forwards or generates sensor requests—`0xEF` name, `0xE7` settings, `0xFA` status, `0xE5` temperature + autosend, `0xC7` statistics—and controls zone assignment via `0xC9` (pages 9–11, 20–23).
- **Local Control Overrides**: lock/unlock (`0xE1/0xE2`), select heating/cooling (`0xE0/0xDF`), set default sleep (`0xE3`), issue comfort/day/night/safe overrides (`0xDB–0xDE`) respecting timer semantics (pages 10–12, 21–22).
- **Target & Preset Updates**: pointer-based `0xE4` commands adjust current setpoint, comfort/day/night presets, limits, hysteresis, calibration, alarms, differential address, and anti-block toggles (pages 12–17).
- **Memory Services**: read/write word (`0xFD/0xFC`), block (`0xC9/0xCA`), dump (`0xCB`); documentation reiterates waiting for `COMMAND_MEMORY_DATA(_BLOCK)` feedback before subsequent writes (pages 4, 17, 22).
- **Program Flow**: `0xBF` selects program storage, `0xC0/0xC2` read/write steps, `0xC1` info, with responses echoing zone, sensor, and step metadata (pages 7–9, 18–19).

## Channel Naming & LED Behaviour
- Controller broadcasts module name parts (`0xF0–0xF2`) for UI labelling; unused characters are `0xFF` (page 5).
- Output status (`0x00`) mirrors actuator transitions and the “link output” mask for synchronised channels (page 7).

## Sensor & Analog Output Settings
- Pointer map under `COMMAND_SET_TEMP (0xE4)` covers current target (index `0x00`), heating presets (`0x01–0x04`), cooling presets (`0x08–0x0B`), limits (`0x0F–0x12`), differential address (`0x13`), hysteresis/differential, calibration, alarms, and anti-block toggles (pages 12–17).
- Temperature fields use 0.5 °C resolution; timers expressed in minutes (sleep) or seconds (statistics). Autosend interval reuses the sensor semantics (`0` disable, `1–9` on-change, `10–255` seconds) (pages 10–12).

## Program & Scheduling Controls
- Program memory divided into “All rooms”, zones 1–7, and sensor-specific blocks (pages 29–31).
- Each step stores zone, address, step id, weekday/mode flags, absolute time, and relative offset for sunrise/sunset adjustments (pages 7–8).
- Controller manages both global (`0xC3`) and sensor-specific (`0xDB–0xDE`) modes, with identical sleep timer behaviour across overrides (pages 3, 11–12).

## Memory Map
- Extensive map covering global configuration (e.g., backlight at `0x00DC`, language, protected UI registers), followed by per-zone and per-sensor program blocks (pages 29–31).
- Sensor sections include addresses for zone metadata, contact configuration, program steps, and name characters; unused slots are `0xFF` (pages 29–31).

## Conversion Notes
- OCR normalised (e.g. `COMMAND_SENSOR_TEMPERATUTE_REQUEST` → `COMMAND_SENSOR_TEMPERATURE_REQUEST`); confirm opcode spellings against firmware before automation (pages 9–10).
- Memory tables in the scan are largely graphical; consult the PDF for precise offsets if tooling requires exact ranges beyond those summarised (pages 29–31).
