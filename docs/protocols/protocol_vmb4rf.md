# VMB4RF RF Receiver Module Protocol (Edition 4)

## Module Overview
- Four-channel RF receiver with programmable channels, LED feedback, and remote learning mode (`module type 0x1A`, page 4).
- Reports channel events, module status, and clock/calendar data; exposes received RF codes for integration with Velbus automation (pages 1–4).
- Supports alarm scheduling, program selection, and channel locking similar to other push-button modules (pages 2–3).

## Message Formats
- Clock frames follow the Velbus standard: `0xD7` request, `0xD8` status, `0xB7` date (page 3).
- Channel switch status (`0x00`) conveys pressed/released/long-press flags; module status `0xB4` adds enable/lock/program disable and learn-mode bits (page 4).
- Module type response provides serial number, memory-map version, and build information (page 4).
- Memory reads (`0xFE`) address `0x0000–0x02FF`; block reads (`0xCC`) span up to `0x02FC` for 4-byte segments (pages 4–5).

## Transmitted Messages
- **Channel & Module Status**: `0x00` channel events, `0xB4` module status, `0xFF` module type, `0xDA` bus error counters (pages 3–4).
- **Clock & Calendar**: broadcasts `0xD7`, `0xD8`, `0xB7` as needed; includes real-time clock request echo (page 3).
- **Naming & Memory**: channel names via `0xF0/0xF1/0xF2`; memory echo through `0xFE/0xCC` (pages 4–5).
- **Received Code Notification**: document notes the module can emit received RF code frames, enabling external logging (page 1 summary).

## Accepted Commands
- **LED Control**: update/clear/set/slow/fast/very-fast LED commands (`0xF4–0xF9`), matching other Velbus button modules (page 1–2).
- **Automation & Scheduling**: lock/unlock channels, disable/enable channel program, select program, configure local/global alarms, and manage sunrise/sunset actions (pages 2–3, 10–12).
- **RF Learning**: enable/clear learning mode via the module status byte; commands toggle learn-transmitter mode to pair new remotes (page 2, inferred from module status description).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); wait for feedback before chain operations (pages 2, 5).
- **Status Queries**: module type RTR, module status request (`0xFA`), channel name request (`0xEF`), real-time clock status request (`0xD7`) (pages 2–3).

## Channel Naming & LED Behaviour
- Channel names use the standard three-frame sequence with `0xFF` padding for unused characters (page 4).
- LED precedence follows Velbus conventions: steady-on overrides blink; conflicting slow/fast flags result in very-fast blinking (page 1–2).

## Memory Map
- Base map extends to `0x02FF`, storing channel configuration, RF pairing data, and scheduling information (page 5).
- Always inspect the memory-map version returned by `COMMAND_MODULE_TYPE` before performing scripted writes to ensure offsets align with firmware revision (page 4).

## Conversion Notes
- OCR corrections normalised command identifiers (e.g. `COMMAND_MODULE_STATUS`); verify learn-mode handling against the source PDF when implementing pairing workflows (pages 3–4).
- Received-code payload specifics are summarised but not detailed; refer to the PDF if raw RF data handling is required (page 1).
