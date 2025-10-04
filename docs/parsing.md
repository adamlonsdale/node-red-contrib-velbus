# Parsing Velbus Protocol PDFs

This guide documents a repeatable process for converting Velbus protocol PDFs into comprehensive Markdown references. Follow these steps to extract every relevant identifier, register, rule, and behavioural note from a scanned document.

## 1. Prerequisites
- **ImageMagick** (`magick`) with Ghostscript support for rasterising PDFs.
- **Tesseract OCR** with the English language pack (`tesseract -l eng`).
- **Python 3** (or another scripting language) for text post-processing.

Verify the tools before starting:
```bash
magick -version
tesseract --version
python3 --version
```

## 2. Split the PDF into Images
Render each page at a resolution that balances fidelity and processing time. Use 200–300 DPI for protocol sheets:
```bash
magick -density 200 docs/pdf/<protocol>.pdf docs/pdf/<protocol>_page_%02d.png
```
> The command creates one PNG per page alongside the source PDF. If Ghostscript is missing, install it (e.g. `brew install ghostscript`).

## 3. Run OCR on Every Page
Process each generated image with Tesseract. Page segmentation mode 6 treats content as a block of text and works well for these documents:
```bash
for f in docs/pdf/<protocol>_page_*.png; do 
  tesseract "$f" "${f%.png}" -l eng --psm 6
done
```
Each page now has a matching `.txt` file containing the raw OCR output.

## 4. Consolidate OCR Output
Combine the per-page text files into a single working file to make downstream parsing easier:
```bash
python3 - <<'PY'
import glob, os, pathlib
base = pathlib.Path('docs/pdf')
pages = sorted(base.glob('<protocol>_page_*.txt'))
with open(base / '<protocol>_ocr.txt', 'w') as out:
    for page in pages:
        out.write(f"===== {page.name} =====\n")
        out.write(page.read_text())
        out.write('\n')
PY
```
This master file becomes the source for manual review, cleanup, and data extraction.

## 5. Clean and Validate the OCR Text
1. **Manual proofreading**: open `<protocol>_ocr.txt` and correct garbled characters, split/merge words, and fix numeric errors. Pay special attention to tables that hold memory addresses or timing values.
2. **Cross-check with images**: when unsure, open the corresponding `_page_##.png` to verify the text.
3. **Search for anomalies**: use `rg` or your editor to locate placeholders like `___`, unexpected symbols, or improbable numbers.

## 6. Structure the Markdown Reference
Create a new Markdown file (e.g. `docs/protocols/<protocol>.md`) that captures every actionable detail. Use consistent headings so future automation or parsing scripts can rely on the structure.

Recommended outline:
```markdown
# <Module Name> Protocol (Edition X)

## Module Overview
- Module family, build year/week, firmware identifiers
- Channel summary (inputs, outputs, sensors)

## Message Formats
- Frame layout description (SOF, SID, RTR, DLC, data bytes, CRC, ACK, EOF)
- Priority rules and address conventions

## Transmitted Messages
For each outbound message:
- **Name** – command mnemonic and hex code
- **Trigger** – when and why it is sent
- **Payload** – byte-by-byte meaning (include ranges, enumerations, flags)

## Accepted Commands
For each inbound command:
- **Frame details** – priority bits, DLC, command code
- **Parameters** – descriptions, allowed values, timing rules
- **Effects** – state changes, required acknowledgements, dependencies

## Channel Naming & LED Behaviour
- Naming message sequence (part 1/2/3)
- LED control commands and bit mapping

## Sensor & Analog Output Settings
- Raw value format and resolution maths
- Auto-send thresholds, sleep timers, presets, offsets
- Analog output status structure and timeout encoding

## Program & Scheduling Controls
- Program step layout, group selection, clock alarms, sunrise/sunset rules
- Lock/force/inhibit semantics with timing rules

## Memory Map
- Tabular list of address ranges with descriptions
- Highlight EEPROM vs RAM sections
- Note special values (e.g. `0xFF` unused, `0xFFFFFF` = permanent)

## Linked Push Button Actions
- Action codes, parameters, affected channels, allowed timers

## Conversion Notes
- Any OCR uncertainties you resolved
- Deviations between the scan and official documentation
```

Within each section, capture:
- **Identifiers**: module type values, command codes, channel numbers.
- **Settings**: parameter ranges, default states, timing values, unit conversions.
- **Rules**: enable/disable behaviours, permanent vs temporary flags, dependencies between commands.
- **References**: cite the original page (e.g. `source: page 12`) for traceability.

## 7. Verify Completeness
- Compare the final Markdown against the page list to confirm every section of the PDF is represented.
- Re-run targeted OCR on problematic regions if anything remains unclear.
- Optionally share the Markdown for peer review or import it into Node-RED documentation.

## 8. Clean Up (Optional)
If storage is a concern, delete intermediate PNG/TXT files after the Markdown is finished:
```bash
rm docs/pdf/<protocol>_page_*.png docs/pdf/<protocol>_page_*.txt
```

Following this workflow ensures each Velbus protocol document is transformed into a searchable, well-structured Markdown reference covering all commands, IDs, settings, and behavioural rules.
