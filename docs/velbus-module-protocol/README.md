# Velbus Module Protocol Documentation

This folder contains documentation for individual Velbus module types, including their capabilities, commands, and configuration.

## Contents

- **[modules-and-ids.md](modules-and-ids.md)** - Complete reference table of all Velbus modules with IDs and descriptions
- **Module-specific documentation** - Detailed documentation for each module type (where available)

## Module Organization

Modules are documented with the following information:
- **Module Name** - Official Velbus module designation (e.g., VMB4RYLD)
- **Module ID** - Hexadecimal type identifier (e.g., 0x10)
- **Description** - Brief description of module function
- **Capabilities** - Number of buttons, relays, dimmers, temperature sensors
- **Protocol File** - Reference to protocol specification file
- **Manual Source** - Link to PDF manual (if available)

## About Module Documentation

### Source Attribution

Module protocol information is derived from:
- **Official Velbus repository**: https://github.com/velbus/moduleprotocol
- **Implementation in this project**: `velbus/const.js` and `info/moduleInfo.js`
- **Protocol specifications**: `info/protocol.json`

### OCR and Manual Conversion

The official Velbus module manuals are provided as PDF files, many of which are scanned documents. To make this information more accessible:

1. **OCR Process**: Manual PDFs are processed using OCR (Optical Character Recognition) tools
2. **Markdown Conversion**: Extracted text is formatted as Markdown documents
3. **Image Extraction**: Diagrams, schematics, and figures are extracted as PNG files
4. **Metadata**: Each document includes frontmatter with module details and OCR information
5. **Proofreading**: OCR output is manually reviewed for accuracy

### OCR Limitations

Please note that OCR-generated documentation may contain:
- Formatting inconsistencies
- Recognition errors in technical terms
- Missing or misinterpreted special characters
- Table alignment issues

**Contributions to improve accuracy are welcome!** See [Contributing](#contributing) below.

## Module Categories

Modules are organized by function:

### Input Modules
- Push button interfaces (VMB8PB, VMB6PBN, VMB2PBN, etc.)
- Touch panels (VMBGP series, VMBEL series)
- Input detectors (VMB6IN, VMB7IN)
- PIR motion sensors (VMBPIRM, VMBPIRC, VMBPIRO)

### Output Modules
- Relay modules (VMB1RY, VMB4RY, VMB4RYLD, VMB4RYNO, etc.)
- Dimmer modules (VMB1DM, VMBDME, VMBDMI, VMB4DC)
- LED strip controller (VMB1LED)
- Blind/shutter controllers (VMB1BL, VMB2BL, VMB2BLE, VMB1BLS)

### Sensor Modules
- Temperature sensors (VMB1TS, VMB1TC)
- Weather station (VMBMETEO)
- Analog I/O (VMB4AN)

### Interface Modules
- USB interface (VMB1USB, VMBRSUSB, VMBUSBIP)
- RF receiver (VMB4RF, VMBRFR8S)
- Doorbird interface (VMBVP1)
- Cable module (VMCM3)

### Display Modules
- Glass panels with OLED (VMBGPO, VMBGPOD, VMBELO)
- LCD panels (VMBLCDWB)

## Module Metadata Structure

Each module in `velbus/const.js` has the following metadata:

```javascript
{
    type: 0x10,                    // Hexadecimal module type ID
    name: "VMB4RYLD",              // Module name
    nrOfButtons: 0,                // Number of button inputs
    nrOfRelays: 5,                 // Number of relay outputs (includes 5th virtual relay)
    nrOfDimmers: 0,                // Number of dimmer channels
    hasTemperatureSensor: false,   // Temperature sensor capability
    requestNameBinary: false       // Name request format (binary vs bitmask)
}
```

## Multi-Address Modules

Some advanced modules use multiple bus addresses for extended channel support:

**Example: VMBELO (0x37)**
- Base address: e.g., 0x08
- Additional addresses: 0x09, 0x0A
- Total channels: 24 buttons (8 per address)

**Example: VMBEL4 (0x36)**
- Base address: e.g., 0x10
- Additional addresses: 0x11, 0x12
- Total channels: 24 buttons (8 per address)

## Module Versions and Editions

Many modules have multiple editions/versions:
- **Edition 1** - Original version
- **Edition 2** - Updated version (often with "-2" suffix)
- Different editions may have different capabilities or protocol variations

Examples:
- VMBGP1 (edition 2) vs VMBGP1-2 (version 1)
- VMBDMI (edition 2) vs VMBDMI-R (edition 2, resistive variant)

## Contributing

We welcome contributions to improve and expand module documentation!

### How to Contribute Module Documentation

1. **Find the source PDF**: Locate the module manual in https://github.com/velbus/moduleprotocol

2. **OCR the PDF**: Use OCR tools such as:
   - Adobe Acrobat Pro
   - Tesseract OCR (open source)
   - Online OCR services
   - `ocrmypdf` Python tool

3. **Create Markdown file**: 
   - Name: `[MODULE_TYPE].md` (e.g., `VMB4RYLD.md`)
   - Include frontmatter (see template below)
   - Format text as Markdown
   - Extract images as PNG files

4. **Proofread**: Review OCR output for accuracy
   - Check technical terms
   - Verify command codes
   - Fix table formatting
   - Correct special characters

5. **Submit PR**: Create pull request with:
   - Module markdown file
   - Extracted images (in `images/` subfolder)
   - Updated `modules-and-ids.md` if needed

### Module Documentation Template

```markdown
---
module_name: VMB4RYLD
module_id: 0x10
description: 4-Channel Relay Module with Direct Load Connections
edition: Edition 5
source_pdf: protocol_vmb4ryld.txt
source_url: https://github.com/velbus/moduleprotocol
ocr_tool: Tesseract 4.1.1
ocr_date: 2024-01-15
proofreading_status: Partial
---

# VMB4RYLD - 4-Channel Relay Module

## Overview

[Description of module]

## Technical Specifications

- **Channels**: 4 relay outputs + 1 virtual channel
- **Load Type**: Direct load connection
- **Maximum Load**: [specs]
- **Power Supply**: 12V DC via Velbus bus

## Supported Commands

### Relay Control

[Command documentation]

## OCR Notes

[Any notes about OCR quality, missing information, or areas needing review]
```

### Proofreading Standards

When reviewing OCR output:
- ✅ Command codes must be verified (e.g., 0xFB not 0xFE)
- ✅ Tables should be properly formatted
- ✅ Technical terms should be spelled correctly
- ✅ Figures should be referenced correctly
- ✅ Section headers should follow hierarchy

## Module Documentation Status

See [modules-and-ids.md](modules-and-ids.md) for the current status of module documentation.

Current coverage:
- **Total modules**: 56+
- **With OCR docs**: 0 (contributions welcome!)
- **Metadata complete**: 56 (in `velbus/const.js`)

## Quick Reference

For quick lookups:
- **Module IDs**: See [modules-and-ids.md](modules-and-ids.md)
- **Module capabilities**: Check `velbus/const.js` in repository
- **Protocol files**: See `info/moduleInfo.js` for protocol file references

## Related Documentation

- [Packet Protocol](../velbus-packet-protocol/README.md) - Core protocol documentation
- [Official Module Protocol Repo](https://github.com/velbus/moduleprotocol) - Source PDFs

## Support

For questions about module documentation:
- **Issues**: https://github.com/adamlonsdale/node-red-contrib-velbus/issues
- **Velbus Forum**: https://forum.velbus.eu/
- **Original Author**: @gertst

## License

Module documentation is derived from official Velbus specifications and is provided for reference purposes to support integration with this Node-RED package.
