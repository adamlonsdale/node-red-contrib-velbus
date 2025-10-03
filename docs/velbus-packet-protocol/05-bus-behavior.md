# Velbus Bus Behavior and Timing

This document describes the behavior of the Velbus bus, including timing requirements, priority handling, and collision avoidance.

## Bus Characteristics

### Physical Layer
- **Topology**: Multi-drop bus (all modules connected in parallel)
- **Signaling**: RS-485 differential (2-wire data)
- **Baud Rate**: 38,400 bps
- **Framing**: 8 data bits, no parity, 1 stop bit (8N1)
- **Voltage**: 12V DC on power lines

### Bus Access
- **Half-duplex**: Only one module can transmit at a time
- **No master**: Any module can initiate communication
- **Carrier sense**: Modules check if bus is idle before transmitting
- **Priority-based arbitration**: Higher priority packets win collisions

## Timing Requirements

### Inter-Packet Gap
Minimum time between packets:
- **Recommended**: 10ms between successive transmissions
- **Minimum**: ~3ms (time for slowest module to process packet)

**Implementation in velbus/velbus.js:**
```javascript
// Auto-reconnect timing
setTimeout(() => {
    this.init();
}, 3000);  // 3 second delay before reconnection
```

### Packet Transmission Time

Time to transmit a packet depends on its size:

**Formula:** `transmission_time = (packet_size * 10 bits) / 38400 bps`

| Packet Size | Transmission Time |
|-------------|-------------------|
| 6 bytes (min) | ~1.6 ms |
| 10 bytes (typical) | ~2.6 ms |
| 14 bytes (max) | ~3.6 ms |

**Breakdown for 10-byte packet:**
- 10 bytes = 80 bits data
- Add start/stop bits: 10 bytes × 10 bits = 100 bits total
- Time: 100 / 38400 = 2.604 ms

### Response Timing

When a module receives a request command (with RTR flag):
- **Typical response time**: 10-50ms
- **Maximum response time**: 100ms

For status requests:
```
Controller → Module: REQUEST (RTR set)
    [10-50ms delay]
Module → Controller: RESPONSE (status data)
```

## Priority System

### Priority Levels

Velbus supports two priority levels:

| Priority | Value | Typical Usage |
|----------|-------|---------------|
| **HIGH** | 0xF8 | Real-time control, button presses, status updates |
| **LOW**  | 0xFB | Configuration, memory operations, name requests |

### Priority Arbitration

When multiple modules attempt to transmit simultaneously:

1. **Carrier sense**: Module checks if bus is idle
2. **Start transmission**: Module begins sending packet
3. **Collision detection**: If another packet detected, compare priority bytes
4. **Priority wins**: Higher priority (numerically smaller value) wins
   - 0xF8 (HIGH) wins over 0xFB (LOW)
5. **Loser backs off**: Lower priority module stops and retries later

**Example:**
```
Module A wants to send HIGH priority packet (0xF8)
Module B wants to send LOW priority packet (0xFB)

Both start transmitting STX (0x0F)
Both transmit priority byte:
  - Module A: 0xF8
  - Module B: 0xFB
  
Module B detects that A has higher priority (0xF8 < 0xFB)
Module B stops transmission and waits
Module A continues transmission
```

### Priority Guidelines

**Use HIGH priority (0xF8) for:**
- Relay on/off commands
- Dimmer value changes
- Button press notifications
- Real-time status updates
- Time-critical operations

**Use LOW priority (0xFB) for:**
- Module discovery
- Memory read/write operations
- Configuration changes
- Name requests
- Statistics requests
- Firmware operations

**Implementation:**
```javascript
// High priority command
let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([COMMAND_SWITCH_RELAY_ON, 0x01]);

// Low priority command
let packet = new Packet(address, Packet.PRIORITY_LOW);
packet.setDataBytes([COMMAND_READ_MEMORY_BLOCK, 0x00, 0x00]);
```

## Bus States

### Normal Operation
- Modules listen continuously for packets
- Any module can transmit when bus is idle
- Priority arbitration resolves conflicts

### Bus Scan (Module Discovery)

On startup or when new modules are added, a bus scan is performed:

1. **Broadcast address range**: Typically 0x01 to 0xFF
2. **For each address**:
   - Send MODULE_STATUS_REQUEST to address
   - Wait for MODULE_TYPE response
   - Record module type and address
3. **Low priority**: Discovery uses LOW priority to not interfere with operation

**Implementation in velbus/velbus.js:**
```javascript
scanBus() {
    for (let address = 0x01; address <= 0xFF; address++) {
        let packet = new Packet(address, Packet.PRIORITY_LOW);
        packet.setDataBytes([COMMAND_MODULE_STATUS_REQUEST]);
        packet.pack();
        this.client.write(packet.getRawBuffer());
        
        // Wait between scans to avoid flooding
        await delay(10);
    }
}
```

### Collision and Retry

When a transmission fails due to collision:

1. **Detect collision**: Module notices unexpected data on bus
2. **Stop transmission**: Module stops mid-packet
3. **Random backoff**: Wait random time (10-100ms)
4. **Retry**: Attempt transmission again
5. **Max retries**: Typically 3-5 attempts before reporting error

**Backoff Algorithm (pseudo-code):**
```javascript
let retries = 0;
const MAX_RETRIES = 3;

while (retries < MAX_RETRIES) {
    if (transmitPacket()) {
        break;  // Success
    }
    
    // Exponential backoff
    let delay = Math.random() * (10 * Math.pow(2, retries));
    await sleep(delay);
    retries++;
}
```

## Module Addressing

### Address Allocation

- **Range**: 0x00 to 0xFF (0-255)
- **Broadcast**: 0x00 (use sparingly, all modules respond)
- **Individual**: 0x01 to 0xFF

### Multi-Address Modules

Some modules (like VMBELO, VMBEL4) occupy multiple consecutive addresses:

**Example: VMBELO with base address 0x08**
- Primary address: 0x08
- Additional addresses: 0x09, 0x0A (for extended channels)
- Total channels: 24 (8 per address)

**Channel to Address Mapping:**
```javascript
// From velbus/packet.js
static getPhysicalAddress(velbus, address, channel) {
    let realChannel = channel;
    let realAddress = address;
    let cnt = 0;
    
    const moduleMetaData = velbus.modules.find(i => i.address === address);
    if (moduleMetaData) {
        // Each address handles 8 channels
        while (realChannel > 8) {
            realChannel = realChannel - 8;
            realAddress = moduleMetaData.extraAddresses[cnt];
            cnt++;
        }
    }
    return realAddress;
}
```

## TCP Gateway Behavior

When using a TCP gateway (like VelServ) between Velbus bus and Node-RED:

### Connection Handling

**Socket connection:**
- Gateway maintains persistent TCP connection
- Forwards packets bidirectionally between TCP and RS-485 bus
- No protocol translation (raw packet pass-through)

**Reconnection:**
```javascript
// From velbus/velbus.js
this.client.on('error', (err) => {
    console.log('Velbus TCP error:', err.message);
    this.emit('onError', err);
    
    // Auto-reconnect after 3 seconds
    setTimeout(() => {
        this.init();
    }, 3000);
});

this.client.on('close', () => {
    console.log('Velbus connection closed');
    this.emit('onError', 'Connection closed');
    
    // Auto-reconnect
    setTimeout(() => {
        this.init();
    }, 3000);
});
```

### Buffer Management

**Gateway buffering:**
- Gateway buffers incoming TCP data
- Sends complete packets to Velbus bus
- Respects bus timing and priority

**Node-RED buffering:**
```javascript
// Accumulate bytes until complete packet received
this.buffer += data;

// Parse complete packets
while (this.buffer.length >= 6) {
    // Check for STX
    if (this.buffer[0] === Packet.STX) {
        let size = this.buffer[3] + 6;
        
        // Check if complete packet available
        if (this.buffer.length >= size && 
            this.buffer[size - 1] === Packet.ETX) {
            
            // Extract and process packet
            let packetBytes = this.buffer.slice(0, size);
            this.processPacket(packetBytes);
            
            // Remove from buffer
            this.buffer = this.buffer.slice(size);
        } else {
            break;  // Wait for more data
        }
    } else {
        // Discard invalid byte
        this.buffer = this.buffer.slice(1);
    }
}
```

## Performance Considerations

### Bus Loading

Maximum theoretical throughput:
- **Best case**: ~2600 packets/second (minimum 6-byte packets)
- **Practical**: ~200-500 packets/second (accounting for gaps, collisions)

**Guidelines:**
- Avoid continuous polling of modules
- Use event-driven updates (modules send status changes)
- Batch configuration operations
- Use LOW priority for non-critical operations

### Module Discovery Time

Bus scan of all 255 addresses:
- **Typical**: 2-5 seconds (with 10ms delay between probes)
- **Fast**: < 1 second (aggressive timing)

**Implementation trade-off:**
- Faster scan = more bus congestion
- Slower scan = delayed startup but smoother operation

### Network Latency

When using TCP gateway over network:
- **Local network**: < 5ms additional latency
- **Remote network**: Variable (depends on network conditions)
- **Impact**: Status updates may be delayed, but bus behavior unchanged

## Error Conditions

### Common Errors

**1. Checksum mismatch**
- Packet corrupted during transmission
- Discard packet silently
- Module may retry or request status again

**2. Timeout**
- Expected response not received within timeout period
- Retry request (up to max retries)
- Report error if all retries fail

**3. Bus collision**
- Multiple modules transmitting simultaneously
- Priority arbitration resolves most collisions
- Random backoff and retry for others

**4. Gateway disconnection**
- TCP connection to gateway lost
- Auto-reconnect after delay
- Queue packets during disconnection (optional)

### Debugging Bus Issues

**Check for:**
- Physical bus connections (loose wires)
- Power supply issues (voltage drop)
- Module configuration conflicts (duplicate addresses)
- Too many modules on single bus segment
- Excessive packet rate (bus overload)

**Tools:**
```javascript
// Enable packet logging in velbus.js
console.log('TX:', packet.toString());  // Transmitted packets
console.log('RX:', packet.toString());  // Received packets

// Monitor bus activity
this.on('packet', (packet) => {
    console.log(`${new Date().toISOString()} - ${packet.toString()}`);
});
```

## Best Practices

### For Controller Applications

1. **Use appropriate priorities**
   - HIGH for user-initiated commands
   - LOW for background operations

2. **Implement timeouts**
   - Wait up to 100ms for response
   - Retry up to 3 times
   - Report error to user

3. **Avoid polling loops**
   - Let modules send status changes
   - Request status only on startup or user request

4. **Handle reconnection gracefully**
   - Detect connection loss
   - Auto-reconnect with exponential backoff
   - Rescan bus after reconnection

### For Module Simulation

1. **Respect timing**
   - Wait 10ms+ between packets
   - Respond within 50ms to requests

2. **Support RTR**
   - Send response when RTR flag set
   - Use appropriate command for response

3. **Handle broadcast correctly**
   - Process packets to address 0x00
   - Do not respond to broadcast (unless required)

## Related Documentation

- [Packet Structure](02-packet-structure.md) - Packet format details
- [Message Types](04-message-types.md) - Command reference
- [Node-RED Mapping](06-node-red-mapping.md) - Integration with Node-RED

## Source References

- TCP connection: `velbus/velbus.js` in this repository
- Packet handling: `velbus/packet.js` in this repository
- VelServ gateway: https://github.com/jeroends/velserv
- Official protocol: https://github.com/velbus/packetprotocol
