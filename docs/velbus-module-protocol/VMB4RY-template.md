---
module_name: VMB4RY
module_id: 0x08
description: 4-Channel Relay Module
edition: Edition 1, Revision 7
channels: 4
capabilities:
  - relays: 5
  - virtual_relay: 1
  - buttons: 0
  - dimmers: 0
  - temperature: false
source_pdf: protocol_vmb4ry.txt
source_url: https://github.com/velbus/moduleprotocol
ocr_status: Template - Not OCR'd
notes: This is a template document showing the expected structure for module documentation
---

# VMB4RY - 4-Channel Relay Module

## Overview

The VMB4RY is a 4-channel relay module for the Velbus home automation system. It provides four independent relay outputs plus one virtual relay for status indication.

**This is a template document.** Actual OCR documentation should be created from the official PDF manual.

## Module Information

| Property | Value |
|----------|-------|
| **Module Type ID** | 0x08 |
| **Module Name** | VMB4RY |
| **Edition** | Edition 1, Revision 7 |
| **Channels** | 4 physical + 1 virtual |
| **Protocol File** | protocol_vmb4ry.txt |

## Capabilities

- ✅ **Relays**: 5 (4 physical + 1 virtual)
- ❌ **Buttons**: Not supported
- ❌ **Dimmers**: Not supported
- ❌ **Temperature Sensor**: Not supported

## Technical Specifications

| Specification | Value |
|---------------|-------|
| Maximum Load per Channel | [To be determined from manual] |
| Contact Type | [Changeover/NO/NC - from manual] |
| Power Supply | 12V DC via Velbus bus |
| Power Consumption | [To be determined from manual] |
| Bus Address Range | 0x01 - 0xFF |
| Dimensions | [To be determined from manual] |

## Supported Commands

### Relay Control

#### Switch Relay On (0x02)
```
Packet: 0F F8 [ADDR] 02 02 [CHANNEL] [CRC] 04
```

#### Switch Relay Off (0x01)
```
Packet: 0F F8 [ADDR] 02 01 [CHANNEL] [CRC] 04
```

#### Start Relay Timer (0x03)
```
Packet: 0F F8 [ADDR] 05 03 [CHANNEL] [TIME_L] [TIME_H] 00 [CRC] 04
```

### Status Commands

#### Relay Status Report (0xFB)
```
Packet: 0F F8 [ADDR] 02 FB [STATUS] [CRC] 04
```

## Channel Mapping

| Channel | Bitmask | Description |
|---------|---------|-------------|
| 1 | 0x01 | Relay channel 1 |
| 2 | 0x02 | Relay channel 2 |
| 3 | 0x04 | Relay channel 3 |
| 4 | 0x08 | Relay channel 4 |
| 5 (Virtual) | 0x10 | Virtual relay for status |

## Node-RED Integration

### Using Relay Node

1. **Add Relay Node** to flow
2. **Configure**:
   - Connector: Select Velbus connector
   - Address: 0x08 (or module's configured address)
   - Channel: 1-4
   - Action: On/Off/Toggle
3. **Send message** to trigger relay

### Example Flow

```
[Inject] --> [Relay Node]
  true         Address: 0x08
               Channel: 1
               Action: On
```

## Configuration

### Module Address
- Configured via VelbusLink software
- Must be unique on bus
- Range: 0x01 to 0xFF

### Channel Names
- Configurable via VelbusLink
- Stored in module memory
- Max 16 characters per channel

## Wiring

[Wiring diagram should be included here from OCR'd manual]

**Safety Warning**: Installation should only be performed by qualified electricians following local electrical codes.

## LED Indicators

| LED | Status |
|-----|--------|
| CH1-4 | Relay status (on/off) |
| BUS | Bus activity indicator |
| PWR | Power indicator |

## Troubleshooting

### Common Issues

**Relay not responding:**
- Check bus address configuration
- Verify power supply
- Check bus connections
- Test with VelbusLink software

**Status not updating:**
- Check Node-RED connector status
- Verify packet filtering
- Check module firmware version

## Implementation Notes

### From velbus/const.js

```javascript
{
    type: 0x08,
    name: "VMB4RY",
    nrOfButtons: 0,
    nrOfRelays: 5,
    nrOfDimmers: 0,
    hasTemperatureSensor: false,
    requestNameBinary: false
}
```

### From info/moduleInfo.js

```javascript
{
    file: 'protocol_vmb4ry.txt',
    type: 'VMB4RY',
    info: '4 channel relay module',
    version: 'edition 1 _ rev7'
}
```

## OCR Notes

**Status**: Template document - full OCR conversion pending

**To complete this documentation:**
1. Obtain PDF manual from https://github.com/velbus/moduleprotocol
2. Run OCR using Tesseract or similar tool
3. Extract wiring diagrams and images
4. Fill in technical specifications
5. Add detailed command documentation
6. Include configuration screenshots
7. Proofread for accuracy

**Expected sections to add:**
- Detailed wiring diagrams
- Pin-out information
- Complete memory map
- Configuration examples
- Physical dimensions drawing
- Installation instructions

## Related Documentation

- [Module Reference](modules-and-ids.md) - All module IDs
- [Relay Control Commands](../velbus-packet-protocol/04-message-types.md#relay-control)
- [Node-RED Integration](../velbus-packet-protocol/06-node-red-mapping.md#5-relay-node)

## References

- **Protocol File**: protocol_vmb4ry.txt
- **Module ID**: 0x08
- **Source**: https://github.com/velbus/moduleprotocol
- **Product Info**: https://www.velbus.eu/

---

**Contributing**: To improve this documentation:
1. Obtain the official PDF manual
2. Perform OCR conversion
3. Add missing technical details
4. Include diagrams and images
5. Submit pull request

See [CONTRIBUTING_DOCS.md](../CONTRIBUTING_DOCS.md) for detailed guidelines.

---

*This template shows the expected structure for module documentation*
*Actual content should be derived from official Velbus manuals via OCR*
