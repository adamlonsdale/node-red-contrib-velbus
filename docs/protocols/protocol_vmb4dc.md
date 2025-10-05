# VMB4DC Four-Channel Dimmer Protocol (Edition 9)

## Module Overview
- Four-channel dimmer with LED feedback, slider support, and automation overrides (`module type 0x12`, page 4).
- Provides channel/state telemetry, LED control for linked buttons, and support for forced, inhibit, and timer-based dimming commands (pages 1–4, 7–9).
- High-priority frames report immediate channel or slider events; low-priority frames handle configuration, naming, and diagnostics (pages 2–4).

## Message Formats
- Channel switch status (`0x00`) and slider status (`0x0F`) frames broadcast on `SID10..9 = 00`, delivering per-channel mask bits and slider percentages (page 2).
- Dimmer status frame `0xB8` includes channel id, inhibit/forced flags, target level, LED state, and active timeout (24-bit seconds) (page 3).
- Memory transactions cover addresses `0x0000–0x03FF` for single bytes and `0x0000–0x03FC` for 4-byte blocks (pages 3–5).

## Transmitted Messages
- **LED Control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink for linked push-button modules (pages 1–3).
- **Status & Telemetry**: channel switch (`0x00`), slider (`0x0F`), dimmer status (`0xB8`), module type (`0xFF`), and bus error counters (`0xDA`) (pages 2–4).
- **Naming**: channel names distributed via `0xF0/0xF1/0xF2` with ASCII characters and `0xFF` padding (page 4–5).
- **Memory Echo**: `0xFE` word read and `0xCC` block read for configuration synchronisation (page 5).

## Accepted Commands
- **Core Dimming**: set dim value (`0x07`), restore last value (`0x11`), start timer (`0x08`), stop dimming (`0x10`), go to scene (`0x1D`), with 24-bit timeouts and optional fade parameters (pages 2–3, 7–9).
- **Overrides** (build ≥1105): forced off/on (`0x12/0x14`), cancel forced (`0x13/0x15`), inhibit (`0x16`), cancel inhibit (`0x17`), each supporting 24-bit timers and channel broadcast `0xFF` (pages 1–2, 7–9).
- **Discovery & LEDs**: module type request (RTR), bus error request (`0xD9`), channel name request (`0xEF`), and LED clear (`0xF5`) (pages 1–2, 8).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); wait for memory echo before chaining writes (pages 2–3).
- **Input Handling**: module consumes push-button status/slider status frames from external panels to drive dimmer levels (page 1).

## Channel Naming & LED Behaviour
- Each channel name spans 16 characters across three frames; unused characters transmit `0xFF`, simplifying parsing (pages 4–5).
- LED precedence matches Velbus conventions: steady-on overrides blink; combined blink flags escalate to very-fast behaviour when commanded via update masks (pages 1–3).

## Program & Scheduling Controls
- Dimmer status exposes inhibit/forced bits enabling supervisory systems to infer automation state (page 3).
- Timer commands allow countdown-based control; `0xFFFFFF` timeouts keep overrides active until explicitly cleared (page 7–9).

## Memory Map
- Base map `0x0000–0x03FF` records channel configuration, LED defaults, scenes, and overrides; inspect `memory map version` from the module-type frame before modifications (page 4).
- Memory tables in the PDF provide per-channel offsets for scenes and timers; refer to the scan when writing automation tooling (pages 5–9).

## Conversion Notes
- OCR glitches such as mixed casing were normalised; uncommon opcodes (e.g. forced/inhibit commands) were cross-checked against the document text (pages 1–9).
- Some memory diagrams are graphical; consult the original PDF for detailed offsets when scripting updates (pages 5–9).
