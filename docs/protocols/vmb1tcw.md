# VMB1TCW Temperature Controller Protocol (Edition 1)

## Module Overview
- Wall-mounted temperature controller gateway (`NODETYPE_TEMPERATURE_CONTROLLER = 0x0E`) that orchestrates zones and remote Velbus thermostats.
- Inherits the same messaging surface as VMB1TC: clock scheduling, program editing, sensor overrides, and diagnostics.
- Emits Velbus frames in standard CAN layout `<SOF SID10..0 RTR IDE r0 DLC DATA CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Clock & Alarm Management (pages 3–4)
- Real time clock status request to the bus: `[0xD7]` broadcast from `SID = 0x00`.
- Clock status response: `[0xD8, day(0-6), hour, minute]`.
- Global clock alarm definition: `[0xC3, alarm_id (1/2), wake_hour, wake_min, bed_hour, bed_min, enable]`.

### Program Operations (pages 3, 7–9)
- Set sensor program location: `[0xBF, high_addr, mid_addr, low_addr]` at controller address `0x00`.
- Program step info: `[0xC1, zone_id, sensor_addr, step_id, flags, hour, minute, relative]`.
- Write program step: same payload with opcode `0xC2`; read program step uses `[0xC0, zone_id, sensor_addr, step_id]`.
  - Zone ids: `0` = all rooms, `1-6` = zones, `7` etc as defined in controller.
  - Flags byte merges weekday mask and mode bits.
- Output status updates: `[0x00, just_on_mask, just_off_mask, link_mask]` push changes to actuators.

### Sensor Coordination (pages 9–17)
- Zone assignment: `[0xC9, zone_id]` to each sensor.
- Metadata requests: `[0xEF, sensor_no]` (name), `[0xE7, sensor_no]` (settings), `[0xFA, sensor_no]` (status), `[0xE5, interval]` (temperature autosend), `[0xC7, stats_index]` (time statistics).
- Local control: lock `[0xE1, sensor_no]`, unlock `[0xE2, sensor_no]`.
- Mode control: heating `[0xE0, sensor_no]`, cooling `[0xDF, sensor_no]`.
- Sleep timer & overrides: `[0xE3, sleep_hi, sleep_lo]` sets default sleep; `[0xDB/0xDC/0xDD/0xDE, sleep_hi, sleep_lo]` drive comfort/day/night/standby overrides.
  - Sleep value `0xFFFF` enters manual mode; `0xFF00` denotes program step; `0x0000` clears overrides.
- Temperature presets and limits: comfort/day/night/anti-frost heating, cooling presets, upper/lower limits, hysteresis/differential, calibration, alarms, valve/pump unjamming settings, statistics reset, differential sensor selection.

### Identification & Diagnostics (pages 4, 12–14)
- Module type frame: `[0xFF, 0x0E, build_year, build_week]` plus configuration byte & language code (pages 4–6).
- Bus error counters: `[0xDA, tx_err, rx_err, bus_off]`.
- Controller name frames: `[0xF0/0xF1/0xF2, 0x01, chars...]` forming a 16-character ASCII identifier.

## Received Messages (pages 2–11)
- Accepts the same suite of requests issued to sensors: clock status, alarm updates, module type scans, memory reads/writes, program read/write, sensor status/temperature packets, and statistics.
- Sensor-originated data (temperature, status, settings, names) arrive with the matching opcodes and are distributed to clients.

## Memory Map (pages 29–37)
- Dedicated regions store program steps for all rooms, zones 1–7, and sensors 1–32.
- Each sensor block records program entries (step number, time reference, mode) and metadata (zone, address, location/group/circuit/load ids, channel names).
- Contact configuration bytes: `0x00` = normally closed, `0xFF` = normally open; located alongside zone metadata (e.g., addresses `0x00D8`, `0x01D8`, etc.).
- User interface configuration includes protected addresses (`0x0070`, `0x0071`, `0x00EC`, `0x00EF`), backlight/contrast settings, and language index (`0` = English).
- General rule: unused addresses contain `0xFF`.

## Operational Notes
- Autosend request `[0xE5, value]`: `1–9` triggers on-change autosend, `10–255` sets interval in seconds, `0` disables.
- All timer-related commands expect big-endian 24-bit seconds; `0x000000` generally ignored, `0xFFFFFF` implies permanent effect (sleep/forced/inhibit).
- After memory or program writes, wait at least 10 ms or for the controller to echo a `COMMAND_MEMORY_DATA_BLOCK` before sending the next write.
- For module type scans, the controller returns `COMMAND_TEMPERATURE_CONTROLLER_TYPE`; sensors answer with their own type codes, enabling automatic topology discovery.
