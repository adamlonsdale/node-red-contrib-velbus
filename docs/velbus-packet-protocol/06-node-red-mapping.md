# Node-RED Integration and Mapping

This document explains how Velbus protocol concepts map to Node-RED nodes in the `node-red-contrib-velbus` package.

## Architecture Overview

The integration consists of three layers:

```
┌─────────────────────────────────────────┐
│    Node-RED Flow (User Level)          │
│  ┌─────┐  ┌──────┐  ┌────────┐        │
│  │Button│  │Relay │  │Temperature│     │
│  └─────┘  └──────┘  └────────┘        │
└─────────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────────┐
│    Node-RED Node Implementation         │
│  (velbus-switch.js, velbus-relay.js)   │
│  - Packet construction                  │
│  - Event handling                       │
│  - Status management                    │
└─────────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────────┐
│    Velbus Core (velbus.js)             │
│  - TCP connection management            │
│  - Module discovery                     │
│  - Packet parsing                       │
│  - Event emission                       │
└─────────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────────┐
│    TCP Gateway (VelServ)                │
│  - USB to TCP conversion                │
│  - Velbus bus interface                 │
└─────────────────────────────────────────┘
                 ↕
┌─────────────────────────────────────────┐
│    Physical Velbus Bus                  │
│  - Modules (relays, dimmers, sensors)  │
└─────────────────────────────────────────┘
```

## Node-RED Nodes

### 1. Velbus Connector (Configuration Node)

**File:** `node-red/velbus-connector.js` + `.html`

**Purpose:** Manages TCP connection to Velbus gateway

**Configuration:**
```javascript
{
    ip: "raspberrypi.local",  // Gateway hostname/IP
    port: "6000"               // Gateway port (typically 6000)
}
```

**Functionality:**
- Creates single `Velbus` instance per connection
- Shared by all Velbus nodes in flow
- Auto-reconnects on connection loss
- Performs module discovery on startup

**Protocol Mapping:**
- Manages TCP socket connection
- Handles packet framing (STX/ETX detection)
- Emits events for received packets
- Provides `write()` method for sending packets

---

### 2. Send Raw Bytes Node

**File:** `node-red/velbus-send-raw-bytes.js` + `.html`

**Purpose:** Send arbitrary Velbus commands

**Input Message:**
```javascript
msg.payload = {
    day: 3,      // For clock commands
    hour: 14,
    minute: 30
}
```

**Configuration:**
```javascript
{
    address: "0x05",           // Target module address (hex or dropdown)
    priority: 0xF8,            // HIGH or LOW priority
    rtr: false,                // Request to respond flag
    dataBytes: "{{day}} {{hour}} {{minute}}"  // Template with placeholders
}
```

**Protocol Mapping:**
- User selects **address** → `Packet.address`
- User selects **priority** → `Packet.priority` (0xF8 or 0xFB)
- User selects **RTR** → `Packet.rtr` flag
- **Data bytes** template → `Packet.setDataBytes([...])`
- Node renders template with msg.payload values
- Calls `packet.pack()` to add STX, ETX, checksum
- Sends via `connector.write(packet.getRawBuffer())`

**Example: Set Real-Time Clock**

User config:
```
Address: 0x00 (broadcast)
Priority: LOW
Data Bytes: D8 {{day}} {{hour}} {{minute}}
```

Incoming message:
```javascript
msg.payload = { day: 3, hour: 14, minute: 30 }
```

Generated packet:
```
0F FB 00 04 D8 03 0E 1E [checksum] 04
```

**Command Assistance:**
- HTML interface shows command options from `info/commandInfo.js`
- User selects command (e.g., "COMMAND_SET_REALTIME_CLOCK")
- Template auto-fills with placeholders

---

### 3. Receive Raw Bytes Node

**File:** `node-red/velbus-receive-raw-bytes.js` + `.html`

**Purpose:** Listen for and filter Velbus packets

**Configuration:**
```javascript
{
    filterAddress: "0x05",     // Only packets from this address
    filterCommand: "0xFB",     // Only specific command
    addressType: "hex"         // "hex" or "module"
}
```

**Output Message:**
```javascript
msg.payload = {
    address: 5,
    command: 0xFB,
    commandName: "COMMAND_RELAY_SWITCH_STATUS",
    priority: 0xF8,
    dataSize: 2,
    dataBytes: [0xFB, 0x01],
    rawPacket: [0x0F, 0xF8, 0x05, ...]
}
```

**Protocol Mapping:**
- Listens to Velbus `onPacket` event
- Extracts fields from received `Packet` object:
  - `packet.address` → `msg.payload.address`
  - `packet.command` → `msg.payload.command`
  - `packet.getCommandName` → `msg.payload.commandName`
  - `packet.getDataBytes` → `msg.payload.dataBytes`
- Applies filters (address, command)
- Outputs matching packets to flow

**Use Cases:**
- Monitor button presses from specific module
- Log all relay status changes
- Capture temperature sensor readings
- Debug protocol communication

---

### 4. Button/Switch Node

**File:** `node-red/velbus-switch.js` + `.html`

**Purpose:** Simulate button presses on Velbus modules

**Configuration:**
```javascript
{
    address: "0x08",           // Module address
    channel: 3,                // Button channel (1-8+)
    pressType: "short"         // "short", "long", "release"
}
```

**Output Message (when button pressed on physical module):**
```javascript
msg.payload = {
    address: 8,
    channel: 3,
    state: "pressed",  // or "released", "long"
    timestamp: Date.now()
}
```

**Protocol Mapping:**

**Sending button press:**
- User config → Packet construction
  - Address: `packet.address = config.address`
  - Command: `COMMAND_SWITCH_STATUS (0x00)`
  - Channel: Converted to bitmask (`1 << (channel - 1)`)
  - State: 0x00=pressed, 0x01=released, 0x02=long press
  
```javascript
let channelBit = Math.pow(2, channel - 1);
let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([0x00, channelBit, stateCode]);
packet.pack();
```

**Receiving button events:**
- Listen for packets with `command === 0x00`
- Filter by configured address and channel
- Decode bitmask to channel number:
  ```javascript
  let channelBit = packet.getDataByte(1);
  let channel = Math.log2(channelBit) + 1;
  ```
- Decode state byte (byte 2):
  - 0x00 = pressed
  - 0x01 = released
  - 0x02 = long press started

**Example:**

Physical button on module 0x08, channel 3 is pressed:
```
Bus packet: 0F F8 08 03 00 04 00 [checksum] 04

Parsing:
  Address: 0x08
  Command: 0x00 (COMMAND_SWITCH_STATUS)
  Channel bitmask: 0x04 (bit 2 = channel 3)
  State: 0x00 (pressed)

Node output:
  msg.payload = { address: 8, channel: 3, state: "pressed" }
```

---

### 5. Relay Node

**File:** `node-red/velbus-relay.js` + `.html`

**Purpose:** Control and monitor relay modules

**Input Message:**
```javascript
msg.payload = true   // Turn on
msg.payload = false  // Turn off
```

**Configuration:**
```javascript
{
    address: "0x05",
    channel: 1,
    action: "toggle"  // "on", "off", "toggle"
}
```

**Output Message (status update from module):**
```javascript
msg.payload = {
    address: 5,
    channel: 1,
    state: true,      // On/Off
    timestamp: Date.now()
}
```

**Protocol Mapping:**

**Sending relay commands:**
```javascript
// Turn on
let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([
    0x02,                        // COMMAND_SWITCH_RELAY_ON
    Math.pow(2, channel - 1)     // Channel bitmask
]);

// Turn off
packet.setDataBytes([
    0x01,                        // COMMAND_SWITCH_RELAY_OFF
    Math.pow(2, channel - 1)
]);
```

**Receiving relay status:**
- Listen for `COMMAND_RELAY_SWITCH_STATUS (0xFB)`
- Parse channel bitmask:
  ```javascript
  let statusBits = packet.getDataByte(1);
  let channelState = (statusBits & Math.pow(2, channel - 1)) !== 0;
  ```
- Update node status indicator
- Output status to flow

**Status Display:**
- Node shows colored dot: 🟢 (on) or ⚫ (off)
- Implemented with `this.status()`:
  ```javascript
  this.status({
      fill: state ? "green" : "grey",
      shape: "dot",
      text: state ? "ON" : "OFF"
  });
  ```

---

### 6. Dimmer Node

**File:** `node-red/velbus-dimmer.js` + `.html`

**Purpose:** Control and monitor dimmer modules

**Input Message:**
```javascript
msg.payload = 75           // Set to 75%
msg.payload = { 
    value: 50, 
    transition: 2000       // 2 second fade
}
```

**Configuration:**
```javascript
{
    address: "0x0A",
    channel: 1,
    defaultTransition: 0   // Instant by default
}
```

**Output Message:**
```javascript
msg.payload = {
    address: 10,
    channel: 1,
    value: 75,         // Percentage (0-100)
    rawValue: 191,     // Raw value (0-255)
    timestamp: Date.now()
}
```

**Protocol Mapping:**

**Sending dimmer commands:**
```javascript
// Convert percentage to 0-255
let dimmerValue = Math.round(percent * 2.55);

// Convert transition time to 100ms units
let transitionTime = Math.round(milliseconds / 100);

let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([
    0x07,                           // COMMAND_SET_DIMMER_VALUE
    Math.pow(2, channel - 1),       // Channel bitmask
    dimmerValue,                    // Value (0-255)
    transitionTime & 0xFF,          // Time low byte
    (transitionTime >> 8) & 0xFF    // Time high byte
]);
```

**Receiving dimmer status:**
- Listen for `COMMAND_DIMMER_STATUS (0xEE)` or `COMMAND_VARIABLE_DIMMER_STATUS (0xB8)`
- Parse status:
  ```javascript
  let channelBit = packet.getDataByte(1);
  let rawValue = packet.getDataByte(2);
  let percentage = Math.round((rawValue / 255) * 100);
  ```

**Status Display:**
- Shows current dimmer percentage
- Example: "Dimmer: 75%"

---

### 7. Temperature Node

**File:** `node-red/velbus-temperature.js` + `.html`

**Purpose:** Monitor and control temperature sensors/thermostats

**Input Message:**
```javascript
msg.payload = 21.5         // Set target temperature to 21.5°C
```

**Configuration:**
```javascript
{
    address: "0x0C",
    mode: "monitor"        // "monitor" or "control"
}
```

**Output Message:**
```javascript
msg.payload = {
    address: 12,
    current: 22.0,         // Current temperature (°C)
    target: 21.5,          // Target temperature (°C)
    mode: "day",           // Operating mode
    timestamp: Date.now()
}
```

**Protocol Mapping:**

**Requesting temperature:**
```javascript
let packet = new Packet(address, Packet.PRIORITY_LOW);
packet.setDataBytes([0xE5]);  // COMMAND_TEMPERATURE_SENSOR_TEMPERATURE_REQUEST
```

**Receiving temperature:**
- Listen for `COMMAND_TEMPERATURE_SENSOR_TEMPERATURE (0xE6)`
- Parse temperature values:
  ```javascript
  // Temperature in 0.5°C units, signed 16-bit
  let currentRaw = (packet.getDataByte(1) << 8) | packet.getDataByte(2);
  let currentTemp = currentRaw / 2.0;  // Convert to °C
  
  let targetRaw = (packet.getDataByte(3) << 8) | packet.getDataByte(4);
  let targetTemp = targetRaw / 2.0;
  ```

**Setting temperature:**
```javascript
// Convert °C to 0.5°C units
let tempValue = Math.round(temperature * 2);

let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([
    0xE4,                      // COMMAND_TEMPERATURE_SENSOR_SET_TEMPERATURE
    (tempValue >> 8) & 0xFF,   // High byte
    tempValue & 0xFF           // Low byte
]);
```

**Status Display:**
- Shows current temperature
- Example: "🌡️ 22.0°C → 21.5°C"

---

## Common Patterns

### Module Discovery Integration

All nodes can use module discovery to populate dropdowns:

```javascript
// In HTML configuration panel
<script type="text/javascript">
    RED.nodes.registerType('velbus-relay', {
        // ...
        oneditprepare: function() {
            // Get modules from connector
            let connector = RED.nodes.node(this.connector);
            if (connector && connector.modules) {
                // Populate address dropdown
                connector.modules.forEach(module => {
                    if (module.nrOfRelays > 0) {
                        $('#node-input-address').append(
                            `<option value="${module.address}">
                                ${module.name} (${module.address})
                            </option>`
                        );
                    }
                });
            }
        }
    });
</script>
```

### Status Subscription Pattern

Nodes subscribe to relevant packets:

```javascript
function VelbusRelayNode(config) {
    RED.nodes.createNode(this, config);
    
    let connector = RED.nodes.getNode(config.connector);
    
    // Subscribe to relay status packets
    connector.on('packet', (packet) => {
        if (packet.address === config.address && 
            packet.command === 0xFB) {  // RELAY_SWITCH_STATUS
            
            let channelBit = packet.getDataByte(1);
            let isOn = (channelBit & Math.pow(2, config.channel - 1)) !== 0;
            
            // Update status
            this.status({
                fill: isOn ? "green" : "grey",
                text: isOn ? "ON" : "OFF"
            });
            
            // Send to flow
            this.send({
                payload: { state: isOn, channel: config.channel }
            });
        }
    });
}
```

### Input Handler Pattern

Nodes process input messages:

```javascript
this.on('input', (msg) => {
    let value = msg.payload;
    
    // Construct packet
    let packet = new Packet(config.address, Packet.PRIORITY_HIGH);
    packet.setDataBytes([
        constants.commands.COMMAND_SWITCH_RELAY_ON,
        Math.pow(2, config.channel - 1)
    ]);
    packet.pack();
    
    // Send to bus
    connector.velbusClient.write(packet.getRawBuffer());
});
```

## Message Flow Examples

### Example 1: User Turns On Relay via Dashboard

```
1. User clicks button in Node-RED dashboard
   → Inject node sends: msg.payload = true

2. Relay node receives message
   → Constructs packet: COMMAND_SWITCH_RELAY_ON (0x02)
   → Sends to Velbus connector

3. Connector writes packet to TCP socket
   → VelServ forwards to Velbus bus
   → Packet: 0F F8 05 02 02 01 [checksum] 04

4. Relay module receives packet
   → Turns on relay channel 1
   → Sends status: COMMAND_RELAY_SWITCH_STATUS (0xFB)

5. Connector receives status packet
   → Emits 'packet' event

6. Relay node receives event
   → Updates status indicator to green
   → Sends msg.payload = { state: true } to flow

7. Dashboard updates to show relay is on
```

### Example 2: Physical Button Press

```
1. User presses button on VMB8PB module (address 0x08, channel 3)

2. Module sends packet to bus
   → Packet: 0F F8 08 03 00 04 00 [checksum] 04
   → Command: SWITCH_STATUS (0x00)

3. VelServ forwards packet to TCP
   → Node-RED receives packet

4. Connector parses packet
   → Emits 'packet' event with Packet object

5. Button node filters packet
   → Address matches: 0x08
   → Command matches: 0x00
   → Channel matches: bit 2 = channel 3

6. Button node outputs message
   → msg.payload = { channel: 3, state: "pressed" }

7. Flow processes button press
   → Can trigger relay, send notification, etc.
```

## Module Metadata Usage

The `velbus/const.js` module metadata is used throughout nodes:

```javascript
// Example: Check if module supports relays
let module = velbus.modules.find(m => m.address === config.address);
if (module && module.nrOfRelays > 0) {
    // Show relay channels 1 to module.nrOfRelays
    for (let i = 1; i <= module.nrOfRelays; i++) {
        // Add channel option
    }
}

// Example: Check for temperature sensor
if (module && module.hasTemperatureSensor) {
    // Enable temperature monitoring
}
```

## Error Handling

Nodes should handle common errors:

```javascript
// Connection error
connector.on('error', (err) => {
    node.status({ fill: "red", text: "Connection error" });
    node.error("Velbus connection error: " + err.message);
});

// Timeout waiting for response
setTimeout(() => {
    node.warn("No response from module " + config.address);
    node.status({ fill: "yellow", text: "Timeout" });
}, 5000);

// Invalid configuration
if (!config.address || !config.channel) {
    node.error("Missing required configuration");
    return;
}
```

## Best Practices

1. **Use HIGH priority for user commands** (relay on/off, dimmer changes)
2. **Use LOW priority for queries** (status requests, name requests)
3. **Subscribe only to relevant packets** (filter by address and command)
4. **Update node status** to show current state visually
5. **Handle reconnection** gracefully (nodes should recover automatically)
6. **Validate input** before sending to bus
7. **Log errors** appropriately (use `node.warn()` or `node.error()`)

## Related Documentation

- [Protocol Overview](01-overview.md)
- [Packet Structure](02-packet-structure.md)
- [Message Types](04-message-types.md)
- [Module Protocol](../velbus-module-protocol/README.md)

## Source Files

- Node implementations: `node-red/*.js`
- Node UI definitions: `node-red/*.html`
- Core Velbus class: `velbus/velbus.js`
- Packet class: `velbus/packet.js`
- Constants and metadata: `velbus/const.js`
