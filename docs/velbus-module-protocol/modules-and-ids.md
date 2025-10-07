# Velbus Modules and IDs Reference

This document provides a comprehensive listing of all Velbus module types supported by this Node-RED integration, including their hexadecimal IDs, capabilities, and protocol references.

## Quick Reference Table

| Module ID | Module Name | Description | Buttons | Relays | Dimmers | Temp | Protocol File |
|-----------|-------------|-------------|---------|--------|---------|------|---------------|
| 0x01 | VMB8PD | 8-Channel Push Button Module | 8 | 0 | 0 | ❌ | protocol_vmb8pb.txt |
| 0x02 | VMB1RY | Relay Module | 0 | 5 | 0 | ❌ | protocol_vmb1ry.txt |
| 0x05 | VMB6IN | 6-Channel Input Module | 6 | 0 | 0 | ❌ | protocol_vmb6in.txt |
| 0x07 | VMB1DM | Dimmer Module | 0 | 0 | 1 | ❌ | protocol_vmb1dm.txt |
| 0x08 | VMB4RY | 4-Channel Relay Module | 0 | 5 | 0 | ❌ | protocol_vmb4ry.txt |
| 0x0A | VMB8IR | Infrared Remote Control Receiver Module | 8 | 0 | 0 | ❌ | protocol_vmb8ir.txt |
| 0x0B | VMB4PD | Push Button and Timer Panel | 8 | 0 | 0 | ❌ | protocol_vmb4pd.txt |
| 0x0C | VMB1TS | Temperature Sensor Module | 0 | 0 | 0 | ✅ | protocol_vmb1ts.txt |
| 0x0F | VMB1LED | PWM LED Strip Dimmer Module | 0 | 0 | 1 | ❌ | protocol_vmb1led.txt |
| 0x10 | VMB4RYLD | 4-Channel Relay Module (Direct Load) | 0 | 5 | 0 | ❌ | protocol_vmb4ryld.txt |
| 0x11 | VMB4RYNO | 4-Channel Relay Module (Normal Open) | 0 | 5 | 0 | ❌ | protocol_vmb4ryno.txt |
| 0x12 | VMB4DC | 0/1-10V Dimmer Controller Module | 0 | 0 | 4 | ❌ | protocol_vmb4dc.txt |
| 0x14 | VMBDME | Dimmer Module | 0 | 0 | 1 | ❌ | protocol_vmbdme.txt |
| 0x15 | VMBDMI | Dimmer for Resistive or Inductive Load | 0 | 0 | 1 | ❌ | protocol_vmbdmi.txt |
| 0x16 | VMB8PBU | 8-Channel Push Button Interface Module | 8 | 0 | 0 | ❌ | protocol_vmb8pbu.txt |
| 0x17 | VMB6PBN | Push Button Module (4 or 6 NIKO buttons) | 6 | 0 | 0 | ❌ | protocol_vmb6pbn.txt |
| 0x18 | VMB2PBN | Push Button Module (1 or 2 NIKO buttons) | 2 | 0 | 0 | ❌ | protocol_vmb2pbn.txt |
| 0x1B | VMB1RYNO | 1-Channel Relay Module (Normal Open) | 0 | 5 | 0 | ❌ | protocol_vmb1ryno.txt |
| 0x1D | VMB2BLE | 2-Channel Blind Module | 0 | 0 | 0 | ❌ | protocol_vmb2ble.txt |
| 0x1E | VMBGP1 | Glass Panel (1-2 touch buttons) | 2 | 0 | 0 | ✅ | protocol_vmbgp1_2_4.txt |
| 0x1F | VMBGP2 | Glass Panel (2-4 touch buttons) | 4 | 0 | 0 | ✅ | protocol_vmbgp1_2_4.txt |
| 0x20 | VMBGP4 | Glass Panel (4-8 touch buttons) | 8 | 0 | 0 | ✅ | protocol_vmbgp1_2_4.txt |
| 0x21 | VMBGPO | Touch Panel with OLED Display | 33 | 0 | 0 | ✅ | protocol_vmbgpo_vmbgptc.txt |
| 0x22 | VMB7IN | 7-Channel Input Module | 8 | 0 | 0 | ❌ | protocol_vmb7in.txt |
| 0x28 | VMBGPOD | Touch Panel with OLED Display | 33 | 0 | 0 | ✅ | protocol_vmbgpod.txt |
| 0x29 | VMB1RYNOS | 1-Channel Relay Module | 0 | 5 | 0 | ❌ | protocol_vmb1rynos.txt |
| 0x2A | VMBPIRM | Mini PIR Detector Module | 0 | 0 | 0 | ❌ | protocol_vmbpirm.txt |
| 0x2B | VMBPIRC | Ceiling PIR Detector Module | 0 | 0 | 0 | ❌ | protocol_vmbpirc.txt |
| 0x2C | VMBPIRO | Outdoor PIR Detector Module | 0 | 0 | 0 | ✅ | protocol_vmbpiro.txt |
| 0x2D | VMBGP4PIR | 4-Button Glass Panel with PIR Detector | 9 | 0 | 0 | ✅ | protocol_vmbgp4pir.txt |
| 0x2E | VMB1BLS | 1-Channel Blind Module | 0 | 0 | 0 | ❌ | protocol_vmb1bls.txt |
| 0x2F | VMBDMIR | Dimmer for Resistive Load (Rotary Control) | 1 | 0 | 1 | ❌ | protocol_vmbdmi_r.txt |
| 0x30 | VMBRFR8S | 8-Channel RF Receiver | 8 | 0 | 0 | ❌ | - |
| 0x31 | VMBMETEO | Weather Station | 0 | 0 | 0 | ✅ | protocol_vmbmeteo.txt |
| 0x32 | VMB4AN | 4-Channel Analog I/O Module | 4 | 0 | 0 | ❌ | protocol_vmb4an.txt |
| 0x33 | VMBVP1 | Doorbird Interface Module | 8 | 0 | 0 | ❌ | protocol_vmbvp01.txt |
| 0x34 | VMBEL1 | Edge-lit 1-Button Glass Panel | 16 | 0 | 0 | ✅ | protocol_vmbel1_2_4.txt |
| 0x35 | VMBEL2 | Edge-lit 2-Button Glass Panel | 16 | 0 | 0 | ✅ | protocol_vmbel1_2_4.txt |
| 0x36 | VMBEL4 | Edge-lit 4-Button Glass Panel | 24 | 0 | 0 | ✅ | protocol_vmbel1_2_4.txt |
| 0x37 | VMBELO | Edge-lit Touch Panel with OLED | 24 | 0 | 0 | ✅ | protocol_vmbelo.txt |
| 0x3A | VMBGP1-2 | Glass Panel v2 (1-button) | 9 | 0 | 0 | ✅ | protocol_vmbgp1_2_4_ed2.txt |
| 0x3B | VMBGP2-2 | Glass Panel v2 (2-button) | 9 | 0 | 0 | ✅ | protocol_vmbgp1_2_4_ed2.txt |
| 0x3C | VMBGP4-2 | Glass Panel v2 (4-button) | 9 | 0 | 0 | ✅ | protocol_vmbgp1_2_4_ed2.txt |
| 0x3D | VMBGPOD-2 | Touch Panel with OLED v2 | 9 | 0 | 0 | ✅ | protocol_vmbgpod_ed2.txt |
| 0x3E | VMBGP4PIR-2 | 4-Button Panel with PIR v2 | 9 | 0 | 0 | ✅ | protocol_vmbgp4pir_ed2.txt |
| 0x3F | VMCM3 | Cable Module 3m | 0 | 0 | 0 | ❌ | - |
| 0x40 | VMBUSBIP | USB/Ethernet Interface | 0 | 0 | 0 | ❌ | - |
| 0x41 | VMB1RYS | 1-Channel Relay Module with Security | 0 | 5 | 0 | ❌ | - |

## Module Categories

### Input Modules (Push Buttons, Touch Panels)

#### Standard Push Button Modules
- **VMB8PD (0x01)** - 8 channels, edition 1
- **VMB8PBU (0x16)** - 8 channels, universal interface, edition 7
- **VMB6PBN (0x17)** - 6 NIKO buttons, edition 7
- **VMB2PBN (0x18)** - 2 NIKO buttons, edition 7
- **VMB4PD (0x0B)** - 4 channels with timer panel

#### Glass Touch Panels (VMBGP Series)
- **VMBGP1 (0x1E)** - 1-2 buttons, temperature sensor, edition 2
- **VMBGP2 (0x1F)** - 2-4 buttons, temperature sensor, edition 2
- **VMBGP4 (0x20)** - 4-8 buttons, temperature sensor, edition 2
- **VMBGP1-2 (0x3A)** - 1 button, v2, 9 channels total
- **VMBGP2-2 (0x3B)** - 2 buttons, v2, 9 channels total
- **VMBGP4-2 (0x3C)** - 4 buttons, v2, 9 channels total

#### Edge-Lit Glass Panels (VMBEL Series)
- **VMBEL1 (0x34)** - 1 button, 16 total channels, temperature
- **VMBEL2 (0x35)** - 2 buttons, 16 total channels, temperature
- **VMBEL4 (0x36)** - 4 buttons, 24 total channels, temperature
- **VMBELO (0x37)** - OLED display, 24 channels, temperature

#### OLED Display Panels
- **VMBGPO (0x21)** - Touch panel, 33 channels, temperature
- **VMBGPOD (0x28)** - Touch panel, 33 channels, temperature
- **VMBGPOD-2 (0x3D)** - Touch panel v2, 9 channels, temperature

#### PIR Motion Detectors
- **VMBPIRM (0x2A)** - Mini PIR, no temperature
- **VMBPIRC (0x2B)** - Ceiling PIR, no temperature
- **VMBPIRO (0x2C)** - Outdoor PIR, with temperature
- **VMBGP4PIR (0x2D)** - 4 buttons + PIR, temperature
- **VMBGP4PIR-2 (0x3E)** - 4 buttons + PIR v2, temperature

#### Input Detection Modules
- **VMB6IN (0x05)** - 6 inputs, edition 1
- **VMB7IN (0x22)** - 7 inputs, edition 5

### Output Modules (Relays, Dimmers)

#### Relay Modules (Standard)
- **VMB1RY (0x02)** - 1 channel + 4 virtual, edition 1
- **VMB4RY (0x08)** - 4 channels + 1 virtual, edition 1
- **VMB1RYS (0x41)** - 1 channel with security features

#### Relay Modules (Special Contacts)
- **VMB4RYLD (0x10)** - 4 channels, direct load, edition 5
- **VMB4RYNO (0x11)** - 4 channels, normally open, edition 5
- **VMB1RYNO (0x1B)** - 1 channel, normally open, edition 5
- **VMB1RYNOS (0x29)** - 1 channel, normally open, special

#### Dimmer Modules
- **VMB1DM (0x07)** - 1 channel dimmer, edition 1
- **VMBDME (0x14)** - 1 channel dimmer, edition 1
- **VMBDMI (0x15)** - 1 channel, resistive/inductive, edition 2
- **VMBDMIR (0x2F)** - 1 channel, with rotary control, edition 2
- **VMB4DC (0x12)** - 4 channels, 0/1-10V, edition 8
- **VMB1LED (0x0F)** - PWM LED strip dimmer, edition 3

#### Blind/Shutter Controllers
- **VMB1BL (0x03)** - 1 channel blind, edition 1 (note: not in const.js list)
- **VMB2BL (0x09)** - 2 channels blind (note: not in const.js list)
- **VMB1BLS (0x2E)** - 1 channel blind, edition 2
- **VMB2BLE (0x1D)** - 2 channels blind, edition 5

### Sensor Modules

#### Temperature Sensors
- **VMB1TS (0x0C)** - Temperature sensor, edition 1
- **VMB1TC (0x0D)** - Temperature controller (note: not in const.js list)

#### Weather Station
- **VMBMETEO (0x31)** - Meteo station, temperature, edition 3

#### Analog I/O
- **VMB4AN (0x32)** - 4 channels analog I/O, edition 3

### Interface Modules

#### USB/Network Interfaces
- **VMB1USB** - USB interface (not in const.js list)
- **VMBRSUSB** - RS232/USB interface (not in const.js list)
- **VMBUSBIP (0x40)** - USB/Ethernet interface

#### RF Receivers
- **VMB8IR (0x0A)** - Infrared receiver, 8 channels, edition 3
- **VMB4RF (0x1C)** - RF receiver, 4 channels (note: not in const.js list)
- **VMBRFR8S (0x30)** - RF receiver, 8 channels

#### Special Interfaces
- **VMBVP1 (0x33)** - Doorbird interface, 8 channels, edition 1
- **VMCM3 (0x3F)** - Cable module, 3m

### Display Modules

#### LCD Panels
- **VMBLCDWB (0x13)** - Multi-page LCD panel (note: not in const.js list)

## Module Capabilities Explained

### Buttons
- **Number**: Total button/input channels available
- **Multi-address modules**: Channels distributed across multiple addresses
  - Example: VMBELO with 24 channels uses 3 addresses (8 channels each)

### Relays
- **Count**: Number shown includes virtual relays
  - Standard count: 4-channel module often shows 5 (4 physical + 1 virtual)
  - Virtual relay: Used for status indication without physical output

### Dimmers
- **Count**: Number of independent dimmer channels
- **Types**: 
  - Standard: Trailing edge dimmer
  - Resistive: For resistive loads
  - Inductive: For inductive loads (transformers)
  - 0/1-10V: Control voltage for LED drivers

### Temperature Sensor
- **✅ Has sensor**: Module includes temperature measurement
- **Usage**: Thermostat control, ambient monitoring, outdoor temperature
- **Format**: Readings in 0.5°C units

### Request Name Binary
- **true**: Module uses binary channel number for name requests
- **false**: Module uses channel bitmask for name requests
- **Affects**: How channel names are requested from module

## Edition and Version Notes

### Edition Numbering
- **Edition 1**: Original release
- **Edition 2-8**: Subsequent hardware/firmware revisions
- **Version 1**: Alternative versioning scheme

### Version 2 Modules (-2 suffix)
Second-generation modules with enhanced features:
- VMBGP1-2, VMBGP2-2, VMBGP4-2 (0x3A-0x3C)
- VMBGPOD-2 (0x3D)
- VMBGP4PIR-2 (0x3E)

Changes in v2:
- Typically 9 channels total (enhanced from original)
- Improved temperature sensing
- Enhanced protocol support

## Protocol File References

Protocol files referenced in `info/moduleInfo.js`:
- Files are plain text specifications (`.txt` format)
- Originally from https://github.com/velbus/moduleprotocol
- Contain command details, memory maps, and configuration info
- Not all modules have dedicated protocol files

### Missing Protocol Files
Some modules in `velbus/const.js` don't have associated protocol files in `info/moduleInfo.js`:
- VMB1BL (0x03) - Blind Control Module
- VMB2BL (0x09) - 2-channel Blind Module
- VMB1TC (0x0D) - Temperature Controller
- VMBLCDWB (0x13) - LCD Panel
- VMB4RF (0x1C) - RF Receiver (has moduleInfo entry but different file)
- VMBRFR8S (0x30) - No protocol file
- VMCM3 (0x3F) - Cable module (no protocol needed)
- VMBUSBIP (0x40) - Interface module
- VMB1RYS (0x41) - No protocol file yet

## Multi-Address Module Details

### VMBELO (0x37)
- **Base address**: User-configurable (e.g., 0x08)
- **Additional**: +1, +2 (e.g., 0x09, 0x0A)
- **Channels**: 8 per address = 24 total
- **Channel mapping**: 1-8 (addr 0x08), 9-16 (addr 0x09), 17-24 (addr 0x0A)

### VMBEL4 (0x36)
- **Base address**: User-configurable
- **Additional**: +1, +2
- **Channels**: 8 per address = 24 total

### VMBEL1/VMBEL2 (0x34, 0x35)
- **Base address**: User-configurable
- **Additional**: +1
- **Channels**: 8 per address = 16 total

## Implementation Reference

### Module Metadata (velbus/const.js)
```javascript
moduleMetaData: [
    {
        type: 0x10,                    // Module ID
        name: "VMB4RYLD",              // Module name
        nrOfButtons: 0,                // Button count
        nrOfRelays: 5,                 // Relay count (includes virtual)
        nrOfDimmers: 0,                // Dimmer count
        hasTemperatureSensor: false,   // Temperature capability
        requestNameBinary: false       // Name request format
    },
    // ... more modules
]
```

### Module Info (info/moduleInfo.js)
```javascript
moduleInfo = [
    {
        file: 'protocol_vmb4ryld.txt',
        type: 'VMB4RYLD',
        info: '4 channel relay module with direct load connections',
        version: 'edition 5'
    },
    // ... more modules
]
```

## Finding Module Information

### By Module ID
1. Look up ID in table above (e.g., 0x10)
2. Find module name (VMB4RYLD)
3. Check capabilities (0 buttons, 5 relays, no dimmer, no temp)
4. Reference protocol file (protocol_vmb4ryld.txt)

### By Module Name
1. Search table for module name
2. Note module ID and capabilities
3. Check if protocol file is available
4. See if detailed documentation exists

### In Code
```javascript
// Find module by ID
let module = constants.moduleMetaData.find(m => m.type === 0x10);
console.log(module.name);  // "VMB4RYLD"

// Find module by name
let module = constants.moduleMetaData.find(m => m.name === "VMB4RYLD");
console.log(module.type);  // 0x10

// Get protocol file
let info = require('./info/moduleInfo').find(m => m.type === "VMB4RYLD");
console.log(info.file);  // "protocol_vmb4ryld.txt"
```

## Module Documentation Status

| Status | Count | Description |
|--------|-------|-------------|
| Metadata Complete | 56 | In `velbus/const.js` |
| Protocol File Listed | 44 | In `info/moduleInfo.js` |
| OCR Documentation | 0 | Markdown docs (contributions welcome!) |

## Contributing Module Documentation

To add or improve module documentation:

1. Select a module from the table above
2. Obtain the PDF manual from https://github.com/velbus/moduleprotocol
3. Perform OCR and create Markdown documentation
4. Submit pull request with the new documentation

See [README.md](README.md) for detailed contribution guidelines.

## Related Documentation

- [Module Protocol README](README.md) - Overview and contribution guide
- [Packet Protocol](../velbus-packet-protocol/README.md) - Core protocol documentation
- [Module Metadata](../../velbus/const.js) - Implementation metadata

## External Resources

- **Official Module Repository**: https://github.com/velbus/moduleprotocol
- **Velbus Forum**: https://forum.velbus.eu/
- **Product Catalog**: https://www.velbus.eu/products/

## Notes

1. **Virtual Relays**: Many relay modules show count +1 for virtual relay used in status indication
2. **Temperature Sensors**: Integrated in many glass panels for ambient temperature monitoring
3. **Multi-Address**: Advanced panels use multiple addresses to support 16-24 channels
4. **Protocol Files**: Original text format from official repository, may need OCR for PDF manuals
5. **Editions**: Higher edition numbers indicate newer hardware revisions

---

*Last updated: 2024*
*Module count: 56+ supported modules*
*For updates, see: https://github.com/adamlonsdale/node-red-contrib-velbus*
