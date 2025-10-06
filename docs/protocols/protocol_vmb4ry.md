# VMB4RY Four-Channel Relay Protocol (Edition 1 rev.7)

## Module Overview
- Module type code `0x08`; frames expose four independent relay channels with associated LED indicators (page 5).
- Hex switches define the module address and per-channel timing/mode presets; module type report also returns build year and week for firmware traceability (page 5).
- Relay status telegrams return disable/force flags, live relay state, LED states, and an active countdown encoded as a 24-bit second counter (page 5).

## Message Formats
- Frames follow `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC3…DLC0 – DATA – CRC15…CRC0 – CRC delimiter – ACK – EOF – inter-frame space>` (page 2).
- Priority is encoded in `SID10..SID9`; `00` is highest priority (relay control), whereas `11` is lowest priority (telemetry and queries) (pages 2–3).

## Transmitted Messages
- **LED maintenance for linked push-button modules** (page 3)
  - `0xF4` `COMMAND_UPDATE_LED`: four data bytes list LEDs that must be continuously lit, slow blink, or fast blink. Continuous-on supersedes blinking; slow + fast together produces the “very fast” blink.
  - `0xF5` `COMMAND_CLEAR_LED`, `0xF6` `COMMAND_SET_LED`, `0xF7` `COMMAND_SLOW_BLINKING_LED`, `0xF8` `COMMAND_FAST_BLINKING_LED`, `0xF9` `COMMAND_VERYFAST_BLINKING_LED`: each carries one LED bitmask byte identifying the targets (page 3).
- **Operational telemetry** (pages 4–6)
  - `0xDA` `COMMAND_BUSERROR_COUNTER_STATUS`: returns transmit, receive, and bus-off counters for diagnostics (page 3).
  - `0xFB` `COMMAND_RELAY_STATUS`: eight-byte status block containing channel index, mode (start/stop vs blink), relay output, LED state, and a 24-bit remaining timer (page 4).
  - `0xFF` `COMMAND_MODULE_TYPE`: reports module type `0x08` plus the four hex-switch settings (nibbles indicate timing vs mode presets) and, on newer builds, production year/week (page 5).
  - `0xFE` `COMMAND_MEMORY_DATA`: single-byte memory read at the supplied address (page 6).
  - `0xCC` `COMMAND_MEMORY_DATA_BLOCK`: four-byte block read covering addresses `0x0000`–`0x03FC` (build ≥0735) (page 6).
- **Name distribution** (page 6)
  - `0xF0`/`0xF1`/`0xF2` provide relay name characters 1–16 across three frames; unused characters are `0xFF` (page 7).

## Accepted Commands
- **Push-button telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` delivers “just pressed/released/long pressed” bitmasks for an upstream push-button source (page 8).
- **Relay control** (pages 8–10)
  - `0x01` `COMMAND_SWITCH_RELAY_OFF`, `0x02` `COMMAND_SWITCH_RELAY_ON` toggle a specific relay.
  - `0x03` `COMMAND_START_RELAY_TIMER` starts a countdown; `0x000000` uses the hex-switch preset, `0xFFFFFF` latches permanently ON (pages 9–10).
  - `0x0D` `COMMAND_START_BLINK_RELAY_TIMER` mirrors the timer semantics but engages the blink profile (page 10).
- **Status and identity queries** (pages 11–13)
  - `0xFA` `COMMAND_RELAY_STATUS_REQUEST` causes the module to emit the status frame for a channel (page 12).
  - Module type requests use RTR=1 with zero-length payload; responses reuse `COMMAND_MODULE_TYPE` (page 12).
  - `0xEF` `COMMAND_RELAY_NAME_REQUEST` triggers the three-part name broadcast (page 13).
  - `0xFD` `COMMAND_READ_DATA_FROM_MEMORY` and `0xC9` `COMMAND_READ_MEMORY_BLOCK` read EEPROM/flash ranges `0x0000`–`0x03FC`; `0xCB` `COMMAND_MEMORY_DUMP_REQUEST` initiates a full dump sequence (pages 13–14).
  - `0xFC` `COMMAND_WRITE_DATA_TO_MEMORY` writes a single byte; wait ≥10 ms before the next command (page 14).
  - `0xCA` `COMMAND_WRITE_MEMORY_BLOCK` writes four consecutive bytes; wait for the matching `0xCC` feedback before issuing another write (page 14).
  - `0xD9` `COMMAND_BUS_ERROR_COUNTER_STATUS_REQUEST` asks the module to re-send the bus error counters (page 14).

## Relay Action Profiles
- Valid timer presets returned in memory include `0x05` (65 ms), `0x4C` (1 s), `0x99` (2 s), and `0xE0` (3 s) (page 23).
- Action codes observed in the table (page 23) include:
  - `0x06` – Force relay ON while ignoring timer logic.
  - `0x07` / `0x08` – Force ON triggered by short/long press, timers disabled (requires PDF confirmation for parameter defaults).
  - `0x09` – Toggle action; additional rows indicate variants that ignore timers or differentiate short vs long presses.
  - `0x0D` – Start/stop timer with optional alternate time for long press.
  - `0x0E` – Restartable timer with separate press/hold durations.
  - `0x0F` – Non re-triggerable timer.
  - `0x10` – Trigger-on-release timer.
  - `0x11` – Press turns relay ON; release applies a delayed OFF.
  - `0x12` – Delayed OFF only when relay is already ON.
  - `0x13`–`0x15` – Start/stop, restartable, and non-restartable delayed ON behaviours respectively.
  - `0x16`–`0x18` – Interval timers (start/stop, restartable, non-restartable) with timeout/pulse/pause parameters.
  - `0x19` / `0x1A` – Disable actions tied to closed or open external switches.
  - `0x1B` / `0x1C` – Disable/toggle-disable on push-button press.
  - `0x1D` – Cancel disable on push-button press.
  - `0x1E` – Forced ON while a supervising switch remains closed.
- Parameter columns in the scan are partially illegible; consult the PDF for precise byte values before implementing firmware logic.

## Memory Map Notes
- Separate memory layouts are provided for builds ≤0812, 0817/0818, 1019–1022, and ≥1025, but OCR output omits offsets. Use the original diagrams to obtain exact address ranges (pages 15–23).
- Unused locations contain `0xFF` (pages 16 & 23).

## Conversion Notes
- OCR conflated characters such as `F5` → `FS`, `0` → `O`, and merged columns within the action table; numeric values above were normalised where unambiguous.
- Memory map diagrams are unreadable in text form; refer to the PDF (“VMB1RY Protocol – edition 1 rev7”, pages 15–24) for definitive offsets and flag meanings.
