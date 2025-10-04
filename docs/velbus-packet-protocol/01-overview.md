# Velbus Protocol Overview

## Introduction

The Velbus protocol is a serial communication protocol used in the Velleman Velbus home automation system. It enables communication between various modules (relays, dimmers, input modules, sensors, etc.) over a shared bus using a master-slave architecture.

## Architecture

### Communication Model

Velbus uses a **multi-drop serial bus** architecture where:
- All modules are connected to a common 4-wire bus
- Communication is **packet-based** with defined framing
- Each module has a unique **address** (0x00 to 0xFF)
- Modules can both send and receive messages
- No centralized master - any module can initiate communication

### Physical Layer

The Velbus system uses:
- **4-wire bus**: 2 for power (12V DC), 2 for data (RS-485 differential signaling)
- **Baud rate**: 38400 bps (8 data bits, no parity, 1 stop bit)
- **Maximum distance**: 1000m (depending on cable quality)
- **Module addressing**: Each module has a configurable bus address (0x00-0xFF)

## Connection to Node-RED

### TCP Gateway Requirement

To use Velbus with Node-RED, you need a **TCP/IP gateway** that converts the serial Velbus bus to a TCP socket connection. The recommended options are:

1. **VelServ** (recommended) - https://github.com/jeroends/velserv
   - Rock-solid, lightweight TCP gateway
   - Runs on Linux/Debian-based systems
   - Converts USB serial to TCP socket

2. **USB Interface Modules**
   - VMB1USB or VMBRSUSB
   - Connects Velbus bus to USB port
   - Used with VelServ or similar gateway software

### Node-RED Integration

The `node-red-contrib-velbus` package provides:
- **Velbus Connector** configuration node - manages TCP connection to gateway
- **Send Raw Bytes** node - sends protocol packets to the bus
- **Receive Raw Bytes** node - receives and filters protocol packets
- **High-level nodes** - Button, Relay, Dimmer, Temperature nodes with protocol abstraction

## Protocol Characteristics

### Packet-Based Communication

All communication happens through discrete **packets**:
- Fixed structure with framing bytes (STX/ETX)
- Variable length data payload (0-8 bytes typically)
- Checksum for error detection
- Priority-based transmission

### Message Types

The protocol supports various message categories:
- **Control commands** - Switch relays, set dimmers, control blinds
- **Status requests** - Query module state
- **Status responses** - Report module state
- **Configuration** - Memory read/write, module discovery
- **Real-time** - Clock synchronization, temperature readings
- **Firmware** - Updates and memory operations

### Addressing

- **Module address**: 1 byte (0x00-0xFF)
- **Special addresses**:
  - 0x00: Broadcast to all modules
  - Individual addresses: 0x01-0xFF
- Some modules (like VMBELO) use **multiple addresses** for extended channel support

## Protocol Features

### Priority System

Packets have priority levels to manage bus access:
- **HIGH priority (0xF8)**: Time-critical commands, status updates
- **LOW priority (0xFB)**: Configuration, memory operations, name requests

### Request-To-Respond (RTR)

- Modules can request a response from another module
- RTR bit in packet header indicates response expected
- Used for status queries and polling

### Error Detection

- **Checksum**: 2's complement checksum on all packet bytes
- **Framing**: STX/ETX bytes ensure packet boundaries
- Invalid packets are discarded

## Implementation in This Project

### Core Components

1. **`velbus/packet.js`** - Packet construction, encoding, decoding
2. **`velbus/velbus.js`** - TCP connection, module discovery, event handling
3. **`velbus/const.js`** - Module metadata and command constants
4. **`info/protocol.json`** - Complete protocol specification

### Key Classes

- **`Packet` class**: Represents a single Velbus packet with methods for:
  - Setting/getting address, priority, data bytes
  - Packing (adding framing and checksum)
  - Checksum calculation
  - String representation for debugging

- **`Velbus` class**: Manages TCP connection and provides:
  - Auto-reconnection on connection loss
  - Module discovery on startup
  - Event emission for received packets
  - Module name retrieval

## Related Documentation

- [Packet Structure Details](02-packet-structure.md)
- [Message Types Reference](04-message-types.md)
- [Node-RED Mapping](06-node-red-mapping.md)

## Source References

This documentation is derived from:
- Official Velbus packet protocol: https://github.com/velbus/packetprotocol
- OpenHAB Velbus binding: https://github.com/openhab/openhab2-addons
- Implementation in this repository: `velbus/packet.js`, `velbus/velbus.js`
