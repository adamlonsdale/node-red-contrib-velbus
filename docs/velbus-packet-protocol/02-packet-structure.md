# Velbus Packet Structure

## Packet Format

Every Velbus packet follows this structure:

```
┌─────┬──────────┬─────────┬───────────┬──────────────┬──────────┬─────┐
│ STX │ PRIORITY │ ADDRESS │ DATA_SIZE │ DATA BYTES   │ CHECKSUM │ ETX │
├─────┼──────────┼─────────┼───────────┼──────────────┼──────────┼─────┤
│  1  │    1     │    1    │     1     │   0-8 bytes  │    1     │  1  │
└─────┴──────────┴─────────┴───────────┴──────────────┴──────────┴─────┘
```

### Total Packet Size
- **Minimum**: 6 bytes (no data payload)
- **Maximum**: 14 bytes (8 bytes data payload)
- **Formula**: `size = dataSize + 6`

## Field Descriptions

### 1. STX (Start of Text)
- **Position**: Byte 0
- **Value**: `0x0F` (15 decimal)
- **Purpose**: Marks the beginning of a packet
- **Implementation**: `Packet.STX`

### 2. PRIORITY
- **Position**: Byte 1
- **Values**:
  - `0xF8` (248 decimal) - HIGH priority
  - `0xFB` (251 decimal) - LOW priority
- **Purpose**: Determines bus access priority
- **Usage**:
  - HIGH: Real-time commands, status updates, button presses
  - LOW: Configuration, memory operations, module name requests
- **Implementation**: `Packet.PRIORITY_HIGH`, `Packet.PRIORITY_LOW`

### 3. ADDRESS
- **Position**: Byte 2
- **Range**: `0x00` to `0xFF` (0-255)
- **Purpose**: Target module address
- **Special values**:
  - `0x00`: Broadcast to all modules (rare, use with caution)
  - `0x01-0xFF`: Individual module addresses
- **Note**: Multi-address modules (like VMBELO) may respond from different addresses

### 4. DATA_SIZE
- **Position**: Byte 3
- **Range**: `0x00` to `0x08` (typically 0-8 bytes)
- **Purpose**: Specifies number of data bytes in the packet
- **Special bits**:
  - **Bit 6 (0x40)**: RTR (Request To Respond) flag
  - **Bits 0-5**: Actual data size
- **Formula**: `dataSize = byte[3] & 0x0F` (without RTR)
- **RTR check**: `rtr = (byte[3] & 0x40) === 0x40`

### 5. DATA BYTES
- **Position**: Bytes 4 to (4 + DATA_SIZE - 1)
- **Length**: 0 to 8 bytes (specified by DATA_SIZE field)
- **Content**: Command and parameters
- **Structure**:
  - **Byte 0 (index 4)**: Command byte (required if DATA_SIZE ≥ 1)
  - **Bytes 1-7 (index 5-11)**: Command parameters (optional)

#### Common Data Byte Patterns

**Example 1: Switch Relay On**
```
DATA_SIZE = 2
DATA[0] = 0x02 (COMMAND_SWITCH_RELAY_ON)
DATA[1] = 0x01 (Channel 1 bitmask)
```

**Example 2: Set Realtime Clock**
```
DATA_SIZE = 4
DATA[0] = 0xD8 (COMMAND_SET_REALTIME_CLOCK)
DATA[1] = 0x03 (Day: Wednesday)
DATA[2] = 0x0E (Hour: 14)
DATA[3] = 0x1E (Minute: 30)
```

**Example 3: Read Memory Block**
```
DATA_SIZE = 3
DATA[0] = 0xC9 (COMMAND_READ_MEMORY_BLOCK)
DATA[1] = 0x00 (High byte of address)
DATA[2] = 0x00 (Low byte of address)
```

### 6. CHECKSUM
- **Position**: Byte (4 + DATA_SIZE)
- **Algorithm**: 2's complement checksum
- **Calculation**:
  1. Sum all bytes from STX to last data byte
  2. Take only the least significant byte (& 0xFF)
  3. Checksum = `0x100 - sum`
- **Purpose**: Error detection
- **Implementation**: See `Packet.checksum_Crc8()` method

#### Checksum Example

For packet: `0F F8 01 02 00 01`
```javascript
sum = 0x0F + 0xF8 + 0x01 + 0x02 + 0x00 + 0x01 = 0x10B
sum_truncated = 0x10B & 0xFF = 0x0B
checksum = 0x100 - 0x0B = 0xF5
```
Final packet: `0F F8 01 02 00 01 F5 04`

### 7. ETX (End of Text)
- **Position**: Last byte (5 + DATA_SIZE)
- **Value**: `0x04` (4 decimal)
- **Purpose**: Marks the end of a packet
- **Implementation**: `Packet.ETX`

## Packet Examples

### Example 1: Query Module Type
Request module at address 0x01 to report its type:

```
Raw bytes: 0F FB 01 01 40 7A 04

Breakdown:
  STX:       0x0F
  PRIORITY:  0xFB (LOW)
  ADDRESS:   0x01
  DATA_SIZE: 0x01
  COMMAND:   0x40 (COMMAND_MODULE_TYPE_REQUEST)
  CHECKSUM:  0x7A
  ETX:       0x04
```

### Example 2: Switch Relay On
Turn on relay channel 1 on module at address 0x05:

```
Raw bytes: 0F F8 05 02 02 01 F2 04

Breakdown:
  STX:       0x0F
  PRIORITY:  0xF8 (HIGH)
  ADDRESS:   0x05
  DATA_SIZE: 0x02
  COMMAND:   0x02 (COMMAND_SWITCH_RELAY_ON)
  CHANNEL:   0x01 (Channel 1 bitmask)
  CHECKSUM:  0xF2
  ETX:       0x04
```

### Example 3: Set Dimmer Value
Set dimmer to 50% on channel 1 of module 0x0A:

```
Raw bytes: 0F F8 0A 05 07 01 7F 00 00 64 04

Breakdown:
  STX:       0x0F
  PRIORITY:  0xF8 (HIGH)
  ADDRESS:   0x0A
  DATA_SIZE: 0x05
  COMMAND:   0x07 (COMMAND_SET_DIMMER_VALUE)
  CHANNEL:   0x01 (Channel 1 bitmask)
  VALUE:     0x7F (50% of 255)
  TIME_LSB:  0x00
  TIME_MSB:  0x00 (Instant change, no transition)
  CHECKSUM:  0x64
  ETX:       0x04
```

### Example 4: Button Press
Button press on channel 3 of module 0x08:

```
Raw bytes: 0F F8 08 03 00 04 00 F6 04

Breakdown:
  STX:       0x0F
  PRIORITY:  0xF8 (HIGH)
  ADDRESS:   0x08
  DATA_SIZE: 0x03
  COMMAND:   0x00 (COMMAND_SWITCH_STATUS / Button press)
  CHANNEL:   0x04 (Channel 3: 2^2 = 0x04 bitmask)
  STATE:     0x00 (Pressed, not long press)
  CHECKSUM:  0xF6
  ETX:       0x04
```

## Implementation Details

### Packet Class (velbus/packet.js)

The `Packet` class in this repository encapsulates packet structure:

```javascript
// Create a new packet
let packet = new Packet(
  address,              // Module address (0x00-0xFF)
  packetPriority,       // PRIORITY_HIGH or PRIORITY_LOW
  dataBytes,            // Array of data bytes
  rtr                   // Request to respond flag
);

// Access packet fields
packet.address        // Get/set address
packet.priority       // Get/set priority
packet.dataSize       // Get data size
packet.command        // Get/set first data byte (command)
packet.rtr           // Get/set RTR flag

// Data byte access
packet.getDataByte(idx)         // Get data byte at index
packet.setDataByte(idx, value)  // Set data byte at index
packet.setDataBytes(byteArray)  // Set all data bytes

// Packet operations
packet.pack()                   // Add STX, ETX, checksum
packet.checksum_Crc8()         // Calculate checksum
packet.getRawBuffer()          // Get as Node.js Buffer
packet.toString()              // Human-readable string
```

### Packing Sequence

When constructing a packet for transmission:

1. Set address: `packet.address = 0x05`
2. Set priority: `packet.priority = Packet.PRIORITY_HIGH`
3. Set data bytes: `packet.setDataBytes([0x02, 0x01])`
4. Pack packet: `packet.pack()` (adds STX, ETX, checksum)
5. Send: `client.write(packet.getRawBuffer())`

### Parsing Received Packets

When receiving raw bytes from the bus:

1. Buffer bytes until complete packet received (STX to ETX)
2. Validate framing (STX at start, ETX at end)
3. Extract fields from raw packet
4. Verify checksum
5. Create Packet object: `packet.setRawBytes(rawBytes)`
6. Access fields: `packet.address`, `packet.command`, etc.

## Related Documentation

- [Overview](01-overview.md) - Protocol introduction
- [Checksum and Encoding](03-checksum-and-encoding.md) - Detailed checksum algorithm
- [Message Types](04-message-types.md) - Command reference
- [Node-RED Mapping](06-node-red-mapping.md) - How packets map to Node-RED nodes

## Source References

- Official protocol: https://github.com/velbus/packetprotocol
- Implementation: `velbus/packet.js` in this repository
- OpenHAB binding: https://github.com/openhab/openhab2-addons (Velbus binding)
