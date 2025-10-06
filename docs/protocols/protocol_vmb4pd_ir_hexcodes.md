# VMB4PD IR Hex Code Reference

## Overview
- Companion listing for the VMB4PD infrared remote showing pre-formatted burst sequences per channel and subsystem (page 1).
- Uses pulse-width modulation at 38 kHz with 27-cycle bursts (`0x001B` ≈ 700 µs) and defined lead-in/lead-out timings (page 1).

## Burst Definitions
- Lead-in: `001B 0120` (700 µs burst + 7.59 ms space).
- Logic `0`: `001B 00C0` (burst + 5.06 ms space).
- Logic `1`: `001B 0120` (burst + 7.59 ms space).
- Lead-out: `001B 082A` (burst + 55 ms gap) before repeating while the key remains held (page 1).

## Channel Tables
- Blocks `x0-CH1` … `x3-CH8` enumerate the full burst trains for subsystems 0–3 and channels 1–8, formatted as Pronto-style hex sequences (pages 1–2).
- Each listing groups bursts in transmission order, allowing direct import into IR learning tools or firmware that expects hexadecimal timings (pages 1–2).

## Usage Notes
- Preserve sequence order, including repeated lead-in bursts, when replaying codes; altering the spacing breaks receiver decoding (page 1).
- Codes repeat automatically during a button hold; implementations should duplicate the listed sequence while the control remains active (page 1).

## Conversion Notes
- OCR normalised ambiguous glyphs (`00CO` → `00C0`, etc.); confirm timing constants against the PDF before embedding in production firmware (pages 1–2).
- Subsystem/channel labels match those in `protocol_vmb4pd_ir.pdf`; reference that document for binary decoding if required (page 1).
