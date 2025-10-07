# Velbus Documentation

Welcome to the comprehensive documentation for the `node-red-contrib-velbus` Node-RED integration package. This documentation covers both the Velbus packet protocol and individual module specifications.

## Documentation Structure

### 📡 [Packet Protocol Documentation](velbus-packet-protocol/)

Core protocol documentation covering how Velbus modules communicate:

- **[Overview](velbus-packet-protocol/01-overview.md)** - Introduction to Velbus protocol architecture
- **[Packet Structure](velbus-packet-protocol/02-packet-structure.md)** - Detailed packet format and field definitions
- **[Checksum and Encoding](velbus-packet-protocol/03-checksum-and-encoding.md)** - Data encoding, checksums, and conversion
- **[Message Types](velbus-packet-protocol/04-message-types.md)** - Complete command reference (80+ commands)
- **[Bus Behavior](velbus-packet-protocol/05-bus-behavior.md)** - Timing, priorities, and collision handling
- **[Node-RED Mapping](velbus-packet-protocol/06-node-red-mapping.md)** - How protocol maps to Node-RED nodes

### 🔌 [Module Protocol Documentation](velbus-module-protocol/)

Module-specific documentation and reference:

- **[Modules and IDs](velbus-module-protocol/modules-and-ids.md)** - Complete reference table of 56+ modules
- **[README](velbus-module-protocol/README.md)** - Module documentation overview and contribution guide
- **Module Documentation** - Individual module manuals (OCR conversion in progress)

### 📝 [Contributing Guidelines](CONTRIBUTING_DOCS.md)

Guide for contributing to documentation:
- How to perform OCR on PDF manuals
- Markdown templates and style guide
- Proofreading standards
- Submission process

## Quick Start

### For Users

**New to Velbus?** Start here:
1. Read the [Protocol Overview](velbus-packet-protocol/01-overview.md)
2. Understand [Packet Structure](velbus-packet-protocol/02-packet-structure.md)
3. Learn [Node-RED Integration](velbus-packet-protocol/06-node-red-mapping.md)
4. Find your modules in [Modules and IDs](velbus-module-protocol/modules-and-ids.md)

**Working with specific modules?**
1. Find module in [Modules and IDs](velbus-module-protocol/modules-and-ids.md)
2. Note module ID and capabilities
3. Check if detailed documentation exists
4. See [Message Types](velbus-packet-protocol/04-message-types.md) for commands

**Building flows in Node-RED?**
1. Review [Node-RED Mapping](velbus-packet-protocol/06-node-red-mapping.md)
2. Understand available nodes (Relay, Dimmer, Button, etc.)
3. Check [Message Types](velbus-packet-protocol/04-message-types.md) for raw commands
4. Use [Checksum Examples](velbus-packet-protocol/03-checksum-and-encoding.md) for debugging

### For Contributors

**Want to help?**
1. Read [Contributing Guidelines](CONTRIBUTING_DOCS.md)
2. Choose a module from [Modules and IDs](velbus-module-protocol/modules-and-ids.md)
3. Perform OCR on PDF manual
4. Submit pull request

**Contribution priorities:**
- OCR conversion of module manuals
- Proofreading existing OCR documents
- Adding practical examples
- Improving cross-references
- Creating diagrams and illustrations

## What is Velbus?

Velbus is a home automation system from Velleman (Belgium) that uses a 4-wire bus for communication between modules. Key features:

- **Distributed intelligence** - Each module has its own microcontroller
- **Robust protocol** - RS-485 differential signaling with checksums
- **Modular design** - Mix relays, dimmers, sensors, panels, etc.
- **No central controller required** - Modules communicate peer-to-peer
- **Professional grade** - Used in residential and commercial installations

## Node-RED Integration

This package (`node-red-contrib-velbus`) enables integration of Velbus with Node-RED:

### Architecture

```
Physical Velbus Bus (RS-485)
        ↕
USB Interface (VMB1USB/VMBRSUSB)
        ↕
TCP Gateway (VelServ)
        ↕
Node-RED (this package)
        ↕
Your automation flows
```

### Available Nodes

| Node | Purpose | Documentation |
|------|---------|---------------|
| **Velbus Connector** | TCP connection to gateway | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#1-velbus-connector-configuration-node) |
| **Send Raw Bytes** | Send any Velbus command | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#2-send-raw-bytes-node) |
| **Receive Raw Bytes** | Monitor bus traffic | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#3-receive-raw-bytes-node) |
| **Button/Switch** | Simulate button presses | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#4-buttonswitch-node) |
| **Relay** | Control relays | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#5-relay-node) |
| **Dimmer** | Control dimmers | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#6-dimmer-node) |
| **Temperature** | Read/set temperature | [Mapping](velbus-packet-protocol/06-node-red-mapping.md#7-temperature-node) |

## Documentation Source Attribution

### Protocol Documentation

Derived from:
- **Official Velbus Protocol**: https://github.com/velbus/packetprotocol
- **OpenHAB Velbus Binding**: https://github.com/openhab/openhab2-addons (Velbus binding)
- **This Repository**: `velbus/packet.js`, `velbus/velbus.js`, `velbus/const.js`

### Module Documentation

Derived from:
- **Official Module Manuals**: https://github.com/velbus/moduleprotocol
- **This Repository**: `velbus/const.js`, `info/moduleInfo.js`

All documentation is created for the purpose of supporting this Node-RED integration package.

## Key Concepts

### Packet Protocol

Every Velbus communication uses packets:
```
[STX] [PRIORITY] [ADDRESS] [DATA_SIZE] [DATA...] [CHECKSUM] [ETX]
```

- **STX/ETX**: Frame delimiters (0x0F, 0x04)
- **Priority**: HIGH (0xF8) or LOW (0xFB)
- **Address**: Module address (0x00-0xFF)
- **Data**: Command + parameters (0-8 bytes)
- **Checksum**: 2's complement error detection

### Module Addressing

- Each module has a configurable address (0x01-0xFF)
- Address 0x00 is broadcast (all modules listen)
- Some modules use multiple addresses for more channels
- Addresses must be unique on the bus

### Command Types

80+ commands organized by category:
- **Relay control** (on/off, timer, blink)
- **Dimmer control** (value, transition, timer)
- **Blind control** (up, down, stop)
- **Temperature** (read, set, mode)
- **Status** (queries and reports)
- **Configuration** (memory, names, settings)

## Module Categories

### Input Modules
Push buttons, touch panels, PIR sensors, input detectors

**Examples**: VMB8PB, VMBGP4, VMBEL4, VMBPIRO

### Output Modules
Relays, dimmers, blind controllers

**Examples**: VMB4RY, VMBDMI, VMB1LED, VMB2BLE

### Sensor Modules
Temperature, weather, analog I/O

**Examples**: VMB1TS, VMBMETEO, VMB4AN

### Interface Modules
USB, RF, network interfaces

**Examples**: VMB1USB, VMBUSBIP, VMB4RF

### Display Modules
OLED panels, LCD displays

**Examples**: VMBGPO, VMBELO, VMBLCDWB

## Protocol Features

### Priority System
- **HIGH priority (0xF8)**: Real-time control, status updates
- **LOW priority (0xFB)**: Configuration, memory operations
- Prevents configuration tasks from delaying control commands

### Error Detection
- **Checksum**: Detects transmission errors
- **Framing**: STX/ETX ensure packet boundaries
- Invalid packets are discarded

### Auto-Reconnection
- Node-RED connector auto-reconnects on TCP failure
- 3-second retry interval
- Module discovery on reconnection

## Common Use Cases

### Home Automation
- Control lights, blinds, heating
- Monitor temperature, occupancy
- Integrate with dashboards
- Create scenes and timers

### Integration
- Connect Velbus to MQTT
- Log data to databases
- Integrate with voice assistants
- Create custom interfaces

### Monitoring
- Track energy usage (via relay status)
- Log temperature over time
- Monitor system health
- Debug protocol issues

## Support and Community

### Getting Help

- **GitHub Issues**: https://github.com/adamlonsdale/node-red-contrib-velbus/issues
- **Velbus Forum**: https://forum.velbus.eu/
- **Node-RED Forum**: https://discourse.nodered.org/

### Useful Links

- **Velbus Official**: https://www.velbus.eu/
- **VelServ Gateway**: https://github.com/jeroends/velserv
- **Protocol Specs**: https://github.com/velbus/packetprotocol
- **Module Manuals**: https://github.com/velbus/moduleprotocol

## Documentation Status

| Area | Status | Details |
|------|--------|---------|
| Packet Protocol | ✅ Complete | 6 documents covering all aspects |
| Module Reference | ✅ Complete | 56+ modules with IDs and capabilities |
| Module Manuals | 🚧 In Progress | OCR conversion needed (contributions welcome) |
| Examples | 🚧 In Progress | More practical examples needed |
| Diagrams | 🚧 In Progress | Wiring and architecture diagrams |

## Contributing

We welcome contributions! See [CONTRIBUTING_DOCS.md](CONTRIBUTING_DOCS.md) for:
- How to perform OCR on PDF manuals
- Documentation standards and style guide
- Module documentation template
- Pull request process

**High-value contributions:**
- OCR module manuals to Markdown
- Proofread existing documentation
- Add practical Node-RED examples
- Create diagrams and illustrations
- Fix errors and typos

## License

Documentation is provided to support the `node-red-contrib-velbus` package and is derived from official Velbus specifications for integration purposes.

---

**Last Updated**: 2024
**Module Count**: 56+ supported modules
**Protocol Commands**: 80+ documented commands

For the latest information, visit: https://github.com/adamlonsdale/node-red-contrib-velbus
