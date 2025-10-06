# VMB4PD IR Remote Protocol Summary

## Signal Characteristics
- Modified RECS80 pulse-distance modulation operating at 38 kHz carrier with 1/3 duty cycle (page 1).
- Logic `0`: 700 µs burst (`0x001B`) followed by 5.06 ms space (`0x00C0`); logic `1`: 700 µs burst followed by 7.59 ms space (`0x0120`) (page 1).
- Frame length: 11 bits (start/reference bit, fixed toggle bit, 3-bit subsystem, 6-bit command) plus terminating burst; code repeats every 55 ms while button remains pressed (pages 1–2).

## Frame Layout
- Bit order: `start (1)` → `toggle (fixed 1)` → subsystem bits `S2..S0` (MSB first) → command bits `F..A` (MSB first) (page 2).
- Subsystem addressing supports up to 8 subsystems; command field maps 64 functions per subsystem (page 2).
- Hex tables enumerate captured burst sequences for channels `x0`–`x3`, channels `CH1–CH8`, showing raw burst timings suitable for IR transmitter programming (pages 2–4).

## Command Mapping Highlights
- `x0-CH#` entries represent subsystem `0`, channels 1–8; subsequent `x1`, `x2`, `x3` blocks advance subsystem address for alternate control banks (pages 2–4).
- Each listing provides hexadecimal RECS80 codes (`0x6xx` etc.) plus raw burst sequences (`001B 0120 ... 001B 082A`) for quick lookup (pages 2–4).

## Integration Notes
- When recreating signals, preserve the 700 µs burst and spacing ratios; the receiver relies on consistent pulse separation (page 1).
- Toggle bit is fixed high in this protocol variant; systems expecting RECS80 toggle alternation should be configured accordingly (page 2).
- Lead-out burst `001B 082A` ensures frame end; do not omit the final burst when emulating the remote (pages 1–2).

## Conversion Notes
- OCR misreads of hexadecimal values (e.g., `00CO` vs `00C0`) were normalised; verify against the PDF for precision when generating firmware (pages 2–4).
- Subsystem/channel tables appear dense; confirm indices when mapping custom commands to avoid collisions (pages 2–4).
