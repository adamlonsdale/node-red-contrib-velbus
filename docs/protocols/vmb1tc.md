# VMB1TC Temperature Controller Protocol (Edition 1, Rev 4)

## Module Overview
- Central heating/cooling controller managing up to 32 sensor/thermostat nodes via Velbus (`COMMAND_TEMPERATURE_CONTROLLER_TYPE`).
- Coordinates daily/weekly programs, clock alarms, and sensor set-points for heating/cooling zones.
- Communicates using Velbus CAN frames `<SOF SID10..0 RTR IDE r0 DLC3..0 DATA CRC ACK EOF IFS>` (page 1).

## Transmitted Messages

### Clock & Output Status (pages 3, 10)
- Real-time clock status request broadcast: `SID10..9 = 0b11`, `SID = 0x00`, `DLC = 1`, data `[0xD7]`.
- Real-time clock status response: `[0xD8, day(0-6), hour(0-23), minute(0-59)]`.
- Global clock alarm definition: `[0xC3, alarm_id (1/2), wake_hour, wake_min, bed_hour, bed_min, enable_flag]`.
- Controller output status: `[0x00, outputs_just_on, outputs_just_off, linked_outputs]` for actuated channels.

### Program Authoring (pages 10-12)
- Write program step: `SID10..9 = 0b11`, `SID = program_storage_address`, data `[0xC2, zone_id, sensor_addr, step_id, schedule_flags, hour, minute, relative_time]`.
  - Zone IDs: `0` all rooms, `1-6` zone 1..6, `7` = zone 7, etc.
  - Schedule flags encode weekday/weekday groups and program mode.
- Read program step: `[0xC0, zone_id, sensor_addr, step_id]`.
- Program step info frames return expanded detail (time references, modes) when requested via `[0xC1,...]` (implicit from documentation).

### Sensor Coordination (pages 13-17)
- Zone assignment: `[0xC9, zone_id]` delivered to a sensor’s address.
- Sensor metadata requests: `[0xEF, sensor_no]` (name), `[0xE7, sensor_no]` (settings), `[0xFA, sensor_no]` (status), `[0xE5, interval]` (temperature autosend request), `[0xC7, stats_index]` (time statistics).
- Control commands:
  - Lock/unlock local control: `[0xE1, sensor_no]` / `[0xE2, sensor_no]`.
  - Switch heating/cooling mode: `[0xE0, sensor_no]` (heating), `[0xDF, sensor_no]` (cooling).
  - Sleep/default timers: `[0xE3, sleep_hi, sleep_lo]`.
  - Mode overrides: `[0xDB/0xDC/0xDD/0xDE, sleep_hi, sleep_lo]` for comfort/day/night/standby; `0xFFFF` enters manual, `0xFF00` marks program step, `0x0000` cancels manual.
  - Target and preset temperatures: comfort/day/night/anti-frost for heating, comfort/day/night plus limits for cooling, hysteresis and differential adjustments.
  - Calibration and alarms: `[0xE6, calibration_byte]`, low/high temp alarms, valve/pump unjamming enable.
  - Statistics reset: dedicated commands to clear min/max or time statistics (per spec).
- Temperature/time statistics responses provide actual sensor data on request.

### Controller Identification & Diagnostics (pages 12-14)
- Module type scan uses RTR frame (`SID10..9 = 0b11`, `RTR = 1`); sensors answer with `COMMAND_TEMPERATURE_CONTROLLER_TYPE` enumerations describing connected device types.
- Bus error counters: `[0xDA, tx_err, rx_err, bus_off]`.
- Controller name frames: `[0xF0/0xF1/0xF2, 0x01, chars...]` over three segments.

## Received Commands (pages 3-11)
Controller accepts the same suite of requests sent by other modules or automation clients:
- Real-time clock status request/response, global alarm definition, module type inquiry.
- Full suite of memory operations: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`), plus program-step read/write commands.
- Sensor messages (temperature, status, settings, names) follow the same opcodes but originate from sensor nodes; controller relays them to automation clients.

## Memory Layout (pages 34-41)
- Program storage is divided into sections:
  - “All rooms” program block followed by dedicated blocks for zones 1–7.
  - Each sensor (1–32) owns a program block storing up to 31 steps (0–30) with time/mode data.
- Addresses `0x0070`, `0x0071`, `0x00EC`, `0x00EF` are write-protected (display configuration and contact settings).
- Configuration flags include backlight levels, contrast, language index, etc.
- Contact configuration bytes mark each relay’s default state (0 = closed, 1 = open) and store zone/group/circuit/load identifiers for integration.

## Operational Notes
- Sleep-mode parameters: `0x0001-0xFEFF` start a countdown in minutes (1–65,279). `0xFFFF` locks manual mode; `0x0000` cancels manual/sleep.
- Autosend temperature request `[0xE5]`: values `1-9` trigger autosend on change, `10-255` set interval in seconds, `0` disables autosend.
- Program steps rely on combined weekday/mode flag byte; ensure schedule flags align with the original spec when authoring steps.
- After writing memory or program blocks, wait for the controller’s memory-data feedback or at least 10 ms before issuing the next write command to avoid overruns.
