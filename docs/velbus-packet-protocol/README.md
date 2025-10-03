# Velbus Packet Protocol Documentation

This folder contains comprehensive documentation of the Velbus packet protocol, derived from the official [velbus/packetprotocol](https://github.com/velbus/packetprotocol) repository and adapted for use with node-red-contrib-velbus.

## Contents

- **[01-overview.md](01-overview.md)** - High-level overview of the Velbus protocol
- **[02-packet-structure.md](02-packet-structure.md)** - Detailed packet framing and field definitions
- **[03-checksum-and-encoding.md](03-checksum-and-encoding.md)** - Checksum calculation and data encoding
- **[04-message-types.md](04-message-types.md)** - Complete reference of message types and commands
- **[05-bus-behavior.md](05-bus-behavior.md)** - Bus timing, priorities, and behavior
- **[06-node-red-mapping.md](06-node-red-mapping.md)** - How protocol concepts map to Node-RED nodes

## Quick Reference

### Packet Format
```
[STX] [PRIORITY] [ADDRESS] [DATA_SIZE] [DATA...] [CHECKSUM] [ETX]
```

### Key Constants
- **STX** (Start of Text): `0x0F`
- **ETX** (End of Text): `0x04`
- **PRIORITY_HIGH**: `0xF8`
- **PRIORITY_LOW**: `0xFB`
- **MAX_PACKET_SIZE**: 14 bytes

## Source Attribution

This documentation is derived from the official Velbus protocol specifications:
- Original source: https://github.com/velbus/packetprotocol
- Implementation reference: https://github.com/openhab/openhab2-addons (Velbus binding)

## Related Documentation

- [Module Protocol Documentation](../velbus-module-protocol/README.md) - Module-specific protocol details
- [Module and IDs Reference](../velbus-module-protocol/modules-and-ids.md) - Complete module listing
