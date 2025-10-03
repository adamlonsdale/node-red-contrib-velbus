# Velbus Message Types and Commands

This document provides a comprehensive reference of all Velbus protocol commands. Commands are organized by category for easy reference.

## Command Overview

Velbus supports over 80 different command types, ranging from basic relay control to advanced temperature management and firmware updates. Each command is identified by a single byte (0x00 to 0xFF) as the first data byte in a packet.

## Command Categories

- [Relay Control](#relay-control)
- [Dimmer Control](#dimmer-control)
- [Blind Control](#blind-control)
- [Button and Input Status](#button-and-input-status)
- [Temperature Control](#temperature-control)
- [Module Discovery and Configuration](#module-discovery-and-configuration)
- [Memory Operations](#memory-operations)
- [Real-Time Clock](#real-time-clock)
- [LED and Backlight Control](#led-and-backlight-control)
- [LCD Display](#lcd-display)
- [Firmware Operations](#firmware-operations)
- [Bus Management](#bus-management)
- [Statistics and Diagnostics](#statistics-and-diagnostics)

---

## Relay Control

### COMMAND_SWITCH_RELAY_OFF (0x01)
Turn off one or more relay channels.

**Data Format:**
```
Byte 0: 0x01 (Command)
Byte 1: Channel bitmask (bit 0 = channel 1, bit 1 = channel 2, etc.)
```

**Example:** Turn off channel 1
```
Data: 01 01
```

**Node-RED:** Used by **Relay node** when switching off

---

### COMMAND_SWITCH_RELAY_ON (0x02)
Turn on one or more relay channels.

**Data Format:**
```
Byte 0: 0x02 (Command)
Byte 1: Channel bitmask
```

**Example:** Turn on channels 1 and 3
```
Data: 02 05  (0x01 | 0x04 = 0x05)
```

**Node-RED:** Used by **Relay node** when switching on

---

### COMMAND_START_RELAY_TIMER (0x03)
Start a timed relay operation (auto-off after specified time).

**Data Format:**
```
Byte 0: 0x03 (Command)
Byte 1: Channel bitmask
Byte 2: Time low byte (units: seconds)
Byte 3: Time high byte
Byte 4: Timer type (0x00 = off timer, 0x01 = on timer)
```

**Example:** Turn on channel 1 for 60 seconds
```
Data: 03 01 3C 00 01
```

---

### COMMAND_START_BLINK_RELAY_TIMER (0x0D)
Start blinking relay operation.

**Data Format:**
```
Byte 0: 0x0D (Command)
Byte 1: Channel bitmask
Byte 2: On time low byte (units: 100ms)
Byte 3: On time high byte
Byte 4: Off time low byte
Byte 5: Off time high byte
Byte 6: Blink count (0 = infinite)
```

---

### COMMAND_RELAY_SWITCH_STATUS (0xFB)
Relay status report from module.

**Data Format:**
```
Byte 0: 0xFB (Command)
Byte 1: Channel bitmask (bits set = channels ON)
Byte 2: (Optional) Timer status
```

**Direction:** Module → Controller

**Node-RED:** Received by **Relay node** for status updates

---

## Dimmer Control

### COMMAND_SET_DIMMER_VALUE (0x07)
Set dimmer to specific brightness level with optional transition.

**Data Format:**
```
Byte 0: 0x07 (Command)
Byte 1: Channel bitmask
Byte 2: Dimmer value (0-255, 0=off, 255=100%)
Byte 3: Transition time low byte (units: 100ms)
Byte 4: Transition time high byte
```

**Example:** Set channel 1 to 50% with 2 second transition
```
Data: 07 01 7F 14 00
      (127 = 50%, 20 = 2000ms/100)
```

**Node-RED:** Used by **Dimmer node**

---

### COMMAND_START_DIMMER_TIMER (0x08)
Start dimmer auto-off timer.

**Data Format:**
```
Byte 0: 0x08 (Command)
Byte 1: Channel bitmask
Byte 2: Time low byte (units: seconds)
Byte 3: Time high byte
```

---

### COMMAND_DIMMER_STATUS (0xEE)
Dimmer status report from module.

**Data Format:**
```
Byte 0: 0xEE (Command)
Byte 1: Channel bitmask
Byte 2: Dimmer value (0-255)
Byte 3: (Optional) Delay time
```

**Direction:** Module → Controller

**Node-RED:** Received by **Dimmer node**

---

### COMMAND_VARIABLE_DIMMER_STATUS (0xB8)
Extended dimmer status with additional information.

**Data Format:**
```
Byte 0: 0xB8 (Command)
Byte 1: Channel bitmask
Byte 2: Dimmer value
Byte 3: LED status
```

**Direction:** Module → Controller

---

## Blind Control

### COMMAND_BLIND_OFF (0x04)
Stop blind movement.

**Data Format:**
```
Byte 0: 0x04 (Command)
Byte 1: Channel bitmask
```

---

### COMMAND_BLIND_UP (0x05)
Move blind(s) up.

**Data Format:**
```
Byte 0: 0x05 (Command)
Byte 1: Channel bitmask
Byte 2: (Optional) Timeout seconds
```

---

### COMMAND_BLIND_DOWN (0x06)
Move blind(s) down.

**Data Format:**
```
Byte 0: 0x06 (Command)
Byte 1: Channel bitmask
Byte 2: (Optional) Timeout seconds
```

---

### COMMAND_BLIND_SWITCH_STATUS (0xEC)
Blind position status report.

**Data Format:**
```
Byte 0: 0xEC (Command)
Byte 1: Channel bitmask
Byte 2: Status (0x00=stopped, 0x01=up, 0x02=down)
Byte 3: (Optional) Position percentage
```

**Direction:** Module → Controller

---

## Button and Input Status

### COMMAND_SWITCH_STATUS (0x00)
Button press or input change notification.

**Data Format:**
```
Byte 0: 0x00 (Command)
Byte 1: Channel bitmask
Byte 2: Status (0x00=pressed, 0x01=released, 0x02=long press start)
```

**Direction:** Module → Controller

**Node-RED:** Received by **Button node**

**Example:** Channel 3 pressed
```
Data: 00 04 00  (0x04 = channel 3 bitmask)
```

---

### COMMAND_INPUT_SWITCH_STATUS (0xED)
Input module status change.

**Data Format:**
```
Byte 0: 0xED (Command)
Byte 1: Channel bitmask (active inputs)
```

**Direction:** Module → Controller

---

### COMMAND_SLIDER_STATUS (0x0F)
Slider position update.

**Data Format:**
```
Byte 0: 0x0F (Command)
Byte 1: Channel number
Byte 2: Slider value (0-255)
```

**Direction:** Module → Controller

---

## Temperature Control

### COMMAND_TEMPERATURE_SENSOR_TEMPERATURE (0xE6)
Temperature sensor reading report.

**Data Format:**
```
Byte 0: 0xE6 (Command)
Byte 1: Current temperature (high byte, signed, 0.5°C units)
Byte 2: Current temperature (low byte)
Byte 3: Target temperature (high byte)
Byte 4: Target temperature (low byte)
```

**Direction:** Module → Controller

**Node-RED:** Received by **Temperature node**

**Temperature Encoding:** 
- Value in 0.5°C units (e.g., 21.5°C = 43 = 0x2B)
- Negative temperatures use two's complement

---

### COMMAND_TEMPERATURE_SENSOR_SET_TEMPERATURE (0xE4)
Set target temperature for thermostat.

**Data Format:**
```
Byte 0: 0xE4 (Command)
Byte 1: Target temperature (high byte, 0.5°C units)
Byte 2: Target temperature (low byte)
```

**Node-RED:** Used by **Temperature node**

---

### COMMAND_TEMPERATURE_SENSOR_TEMPERATURE_REQUEST (0xE5)
Request current temperature reading.

**Data Format:**
```
Byte 0: 0xE5 (Command)
```

Response: COMMAND_TEMPERATURE_SENSOR_TEMPERATURE (0xE6)

---

### COMMAND_TEMPERATURE_SENSOR_COMFORT_MODE (0xDB)
Set thermostat to comfort mode.

**Data Format:**
```
Byte 0: 0xDB (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_DAY_MODE (0xDC)
Set thermostat to day mode.

**Data Format:**
```
Byte 0: 0xDC (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_NIGHT_MODE (0xDD)
Set thermostat to night mode.

**Data Format:**
```
Byte 0: 0xDD (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_SAFE_MODE (0xDE)
Set thermostat to safe mode (frost protection).

**Data Format:**
```
Byte 0: 0xDE (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_COOLING_MODE (0xDF)
Enable cooling mode.

**Data Format:**
```
Byte 0: 0xDF (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_HEATING_MODE (0xE0)
Enable heating mode.

**Data Format:**
```
Byte 0: 0xE0 (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_LOCK (0xE1)
Lock temperature sensor controls.

**Data Format:**
```
Byte 0: 0xE1 (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_UNLOCK (0xE2)
Unlock temperature sensor controls.

**Data Format:**
```
Byte 0: 0xE2 (Command)
```

---

### COMMAND_TEMPERATURE_SENSOR_STATUS (0xEA)
Temperature sensor status report.

**Data Format:**
```
Byte 0: 0xEA (Command)
Byte 1: Mode (0x00=safe, 0x01=day, 0x02=night, 0x03=comfort)
Byte 2: Status flags
```

**Direction:** Module → Controller

---

### COMMAND_TEMPERATURE_SENSOR_REQUEST_SETTINGS (0xE7)
Request temperature sensor settings.

**Data Format:**
```
Byte 0: 0xE7 (Command)
```

Responses: 
- COMMAND_TEMPERATURE_SENSOR_SETTINGS_PART1 (0xE8)
- COMMAND_TEMPERATURE_SENSOR_SETTINGS_PART2 (0xE9)
- COMMAND_TEMPERATURE_SETTINGS_PART3 (0xC6)

---

## Module Discovery and Configuration

### COMMAND_MODULE_TYPE (0xFF)
Module type identification response.

**Data Format:**
```
Byte 0: 0xFF (Command)
Byte 1: Module type ID (see module table)
Byte 2: (Optional) High address byte for multi-address modules
Byte 3: (Optional) Low address byte for multi-address modules
Byte 4: (Optional) Build year
Byte 5: (Optional) Build week
```

**Direction:** Module → Controller

**Usage:** Received during module discovery after bus scan

---

### COMMAND_MODULE_STATUS_REQUEST (0xFA)
Request module to report its current status.

**Data Format:**
```
Byte 0: 0xFA (Command)
Byte 1: (Optional) Channel number
```

**Response:** Module sends appropriate status command(s) based on its type

---

### COMMAND_MODULE_SUBTYPE (0xB0)
Module subtype information.

**Data Format:**
```
Byte 0: 0xB0 (Command)
Byte 1: Subtype code
Byte 2-7: Additional info
```

**Direction:** Module → Controller

---

### COMMAND_MODULE_NAME_REQUEST (0xEF)
Request module or channel name.

**Data Format:**
```
Byte 0: 0xEF (Command)
Byte 1: Channel number or bitmask (module-dependent)
```

**Response:** Module sends name in parts:
- COMMAND_MODULE_NAME_PART1 (0xF0)
- COMMAND_MODULE_NAME_PART2 (0xF1)
- COMMAND_MODULE_NAME_PART3 (0xF2)

---

### COMMAND_MODULE_NAME_PART1 (0xF0)
First part of module/channel name.

**Data Format:**
```
Byte 0: 0xF0 (Command)
Byte 1: Channel number
Byte 2-7: Name characters (ASCII)
```

**Direction:** Module → Controller

---

### COMMAND_MODULE_NAME_PART2 (0xF1)
Second part of module/channel name.

**Data Format:**
```
Byte 0: 0xF1 (Command)
Byte 1: Channel number
Byte 2-7: Name characters (ASCII)
```

**Direction:** Module → Controller

---

### COMMAND_MODULE_NAME_PART3 (0xF2)
Third part of module/channel name.

**Data Format:**
```
Byte 0: 0xF2 (Command)
Byte 1: Channel number
Byte 2-7: Name characters (ASCII, terminated with 0xFF)
```

**Direction:** Module → Controller

---

## Memory Operations

### COMMAND_READ_MEMORY_BLOCK (0xC9)
Read a block of memory from module.

**Data Format:**
```
Byte 0: 0xC9 (Command)
Byte 1: Memory address (high byte)
Byte 2: Memory address (low byte)
```

**Response:** COMMAND_MEMORY_BLOCK (0xCC)

**Usage:** Reading module names, configuration data

---

### COMMAND_WRITE_MEMORY_BLOCK (0xCA)
Write data to module memory.

**Data Format:**
```
Byte 0: 0xCA (Command)
Byte 1: Memory address (high byte)
Byte 2: Memory address (low byte)
Byte 3-6: Data bytes to write
```

---

### COMMAND_MEMORY_BLOCK (0xCC)
Memory block data response.

**Data Format:**
```
Byte 0: 0xCC (Command)
Byte 1: Memory address (high byte)
Byte 2: Memory address (low byte)
Byte 3-6: Data bytes from memory
```

**Direction:** Module → Controller

---

### COMMAND_MEMORY_DUMP_REQUEST (0xCB)
Request full memory dump from module.

**Data Format:**
```
Byte 0: 0xCB (Command)
```

**Response:** Multiple COMMAND_MEMORY_BLOCK packets

---

### COMMAND_READ_EEPROM_DATA (0xFD)
Read from module EEPROM.

**Data Format:**
```
Byte 0: 0xFD (Command)
Byte 1: EEPROM address (high byte)
Byte 2: EEPROM address (low byte)
```

**Response:** COMMAND_EEPROM_DATA_STATUS (0xFE)

---

### COMMAND_WRITE_EEPROM_DATA (0xFC)
Write to module EEPROM.

**Data Format:**
```
Byte 0: 0xFC (Command)
Byte 1: EEPROM address (high byte)
Byte 2: EEPROM address (low byte)
Byte 3: Data byte to write
```

---

### COMMAND_EEPROM_DATA_STATUS (0xFE)
EEPROM data response.

**Data Format:**
```
Byte 0: 0xFE (Command)
Byte 1: EEPROM address (high byte)
Byte 2: EEPROM address (low byte)
Byte 3: Data byte read
```

**Direction:** Module → Controller

---

## Real-Time Clock

### COMMAND_REAL_TIME_CLOCK (0xD8)
Real-time clock data (broadcast to all modules).

**Data Format:**
```
Byte 0: 0xD8 (Command)
Byte 1: Day of week (0=Mon, 6=Sun)
Byte 2: Hour (0-23)
Byte 3: Minute (0-59)
```

**Example:** Set Wednesday 14:30
```
Data: D8 03 0E 1E
```

**Node-RED:** Used by **Send Raw Bytes node** with clock template

---

### COMMAND_REAL_TIME_CLOCK_REQUEST (0xD7)
Request current time from a module.

**Data Format:**
```
Byte 0: 0xD7 (Command)
```

**Response:** COMMAND_REAL_TIME_CLOCK (0xD8)

---

### COMMAND_SET_REALTIME_DATE (0xB7)
Set date on modules (extended format).

**Data Format:**
```
Byte 0: 0xB7 (Command)
Byte 1: Day of week
Byte 2: Hour
Byte 3: Minute
Byte 4: (Optional) Year
Byte 5: (Optional) Month
Byte 6: (Optional) Day
```

---

## LED and Backlight Control

### COMMAND_SET_LED (0xF6)
Turn on LED for a channel.

**Data Format:**
```
Byte 0: 0xF6 (Command)
Byte 1: LED bitmask (which LEDs to turn on)
```

---

### COMMAND_CLEAR_LED (0xF5)
Turn off LED for a channel.

**Data Format:**
```
Byte 0: 0xF5 (Command)
Byte 1: LED bitmask (which LEDs to turn off)
```

---

### COMMAND_SLOW_BLINKING_LED (0xF7)
Set LED to slow blink.

**Data Format:**
```
Byte 0: 0xF7 (Command)
Byte 1: LED bitmask
```

---

### COMMAND_FAST_BLINKING_LED (0xF8)
Set LED to fast blink.

**Data Format:**
```
Byte 0: 0xF8 (Command)
Byte 1: LED bitmask
```

---

### COMMAND_VERY_FAST_BLINKING_LED (0xF9)
Set LED to very fast blink.

**Data Format:**
```
Byte 0: 0xF9 (Command)
Byte 1: LED bitmask
```

---

### COMMAND_UPDATE_LED_STATUS (0xF4)
Request LED status update.

**Data Format:**
```
Byte 0: 0xF4 (Command)
```

---

### COMMAND_SET_BACKLIGHT (0xF3)
Set backlight level.

**Data Format:**
```
Byte 0: 0xF3 (Command)
Byte 1: Backlight level (0-255)
```

---

### COMMAND_SET_PUSHBUTTON_BACKLIGHT (0xD4)
Set pushbutton backlight level.

**Data Format:**
```
Byte 0: 0xD4 (Command)
Byte 1: Channel bitmask
Byte 2: Backlight level (0-255)
```

---

### COMMAND_RESET_BACKLIGHT (0xD2)
Reset backlight to default.

**Data Format:**
```
Byte 0: 0xD2 (Command)
```

---

### COMMAND_RESET_PUSHBUTTON_BACKLIGHT (0xD3)
Reset pushbutton backlight to default.

**Data Format:**
```
Byte 0: 0xD3 (Command)
Byte 1: Channel bitmask
```

---

### COMMAND_BACKLIGHT_STATUS_REQUEST (0xD5)
Request backlight status.

**Data Format:**
```
Byte 0: 0xD5 (Command)
```

**Response:** COMMAND_BACKLIGHT (0xD6)

---

### COMMAND_BACKLIGHT (0xD6)
Backlight status report.

**Data Format:**
```
Byte 0: 0xD6 (Command)
Byte 1: Backlight level (0-255)
```

**Direction:** Module → Controller

---

## LCD Display

### COMMAND_LCD_LINE_TEXT_PART1 (0xCD)
First part of LCD text line.

**Data Format:**
```
Byte 0: 0xCD (Command)
Byte 1: Line number (1-based)
Byte 2-7: Text characters (ASCII)
```

---

### COMMAND_LCD_LINE_TEXT_PART2 (0xCE)
Second part of LCD text line.

**Data Format:**
```
Byte 0: 0xCE (Command)
Byte 1: Line number
Byte 2-7: Text characters
```

---

### COMMAND_LCD_LINE_TEXT_PART3 (0xCF)
Third part of LCD text line.

**Data Format:**
```
Byte 0: 0xCF (Command)
Byte 1: Line number
Byte 2-7: Text characters (terminated with 0xFF)
```

---

### COMMAND_LCD_LINE_TEXT_REQUEST (0xD0)
Request LCD line text.

**Data Format:**
```
Byte 0: 0xD0 (Command)
Byte 1: Line number
```

**Response:** LCD_LINE_TEXT_PART1/2/3 messages

---

## Firmware Operations

### COMMAND_FIRMWARE_UPDATE_REQUEST (0x60)
Request firmware update information.

**Data Format:**
```
Byte 0: 0x60 (Command)
```

**Response:** COMMAND_FIRMWARE_INFO (0x61)

---

### COMMAND_FIRMWARE_INFO (0x61)
Firmware version information.

**Data Format:**
```
Byte 0: 0x61 (Command)
Byte 1-7: Firmware version data
```

**Direction:** Module → Controller

---

### COMMAND_ENTER_FIRMWARE_UPGRADE (0x62)
Put module into firmware upgrade mode.

**Data Format:**
```
Byte 0: 0x62 (Command)
```

**Response:** COMMAND_FIRMWARE_UPGRADE_STARTED (0x65)

---

### COMMAND_ABORT_FIRMWARE_UPGRADE (0x63)
Cancel firmware upgrade process.

**Data Format:**
```
Byte 0: 0x63 (Command)
```

---

### COMMAND_EXIT_FIRMWARE_UPGRADE (0x64)
Exit firmware upgrade mode.

**Data Format:**
```
Byte 0: 0x64 (Command)
```

---

### COMMAND_FIRMWARE_UPGRADE_STARTED (0x65)
Confirmation that firmware upgrade mode is active.

**Data Format:**
```
Byte 0: 0x65 (Command)
```

**Direction:** Module → Controller

---

### COMMAND_WRITE_FIRMWARE_MEMORY (0x66)
Write firmware data to module memory.

**Data Format:**
```
Byte 0: 0x66 (Command)
Byte 1: Address (high byte)
Byte 2: Address (low byte)
Byte 3-6: Firmware data bytes
```

**Response:** COMMAND_FIRMWARE_MEMORY_WRITE_CONFIRMED (0x68)

---

### COMMAND_FIRMWARE_MEMORY (0x67)
Firmware memory data.

**Data Format:**
```
Byte 0: 0x67 (Command)
Byte 1: Address (high byte)
Byte 2: Address (low byte)
Byte 3-6: Memory data
```

**Direction:** Module → Controller

---

### COMMAND_FIRMWARE_MEMORY_WRITE_CONFIRMED (0x68)
Confirmation of firmware write.

**Data Format:**
```
Byte 0: 0x68 (Command)
Byte 1: Address (high byte)
Byte 2: Address (low byte)
```

**Direction:** Module → Controller

---

### COMMAND_READ_FIRMWARE_MEMORY (0x69)
Read firmware memory for verification.

**Data Format:**
```
Byte 0: 0x69 (Command)
Byte 1: Address (high byte)
Byte 2: Address (low byte)
```

**Response:** COMMAND_FIRMWARE_MEMORY (0x67)

---

## Bus Management

### COMMAND_BUS_OFF (0x09)
Notification that bus is going offline.

**Data Format:**
```
Byte 0: 0x09 (Command)
```

---

### COMMAND_BUS_ACTIVE (0x0A)
Notification that bus is active.

**Data Format:**
```
Byte 0: 0x0A (Command)
```

---

### COMMAND_RS232_BUFFER_FULL (0x0B)
RS232 interface buffer is full.

**Data Format:**
```
Byte 0: 0x0B (Command)
```

---

### COMMAND_RS232_BUFFER_EMPTY (0x0C)
RS232 interface buffer is empty.

**Data Format:**
```
Byte 0: 0x0C (Command)
```

---

### COMMAND_INTERFACE_STATUS_REQUEST (0x0E)
Request interface status.

**Data Format:**
```
Byte 0: 0x0E (Command)
```

---

## Statistics and Diagnostics

### COMMAND_STATISTICS_REQUEST (0xC7)
Request module statistics.

**Data Format:**
```
Byte 0: 0xC7 (Command)
```

**Response:** COMMAND_STATISTICS (0xC8)

---

### COMMAND_STATISTICS (0xC8)
Module statistics data.

**Data Format:**
```
Byte 0: 0xC8 (Command)
Byte 1-7: Statistics data
```

**Direction:** Module → Controller

---

### COMMAND_ERROR_COUNT_REQUEST (0xD9)
Request error counter values.

**Data Format:**
```
Byte 0: 0xD9 (Command)
```

**Response:** COMMAND_ERROR_COUNT (0xDA)

---

### COMMAND_ERROR_COUNT (0xDA)
Error counter report.

**Data Format:**
```
Byte 0: 0xDA (Command)
Byte 1-7: Error counts
```

**Direction:** Module → Controller

---

## Special Commands

### COMMAND_IR_RECIEVER_STATUS (0xEB)
Infrared receiver status.

**Data Format:**
```
Byte 0: 0xEB (Command)
Byte 1-7: IR data
```

**Direction:** Module → Controller

---

### COMMAND_ENABLE_TIMER_CHANNELS (0xD1)
Enable or disable timer channels.

**Data Format:**
```
Byte 0: 0xD1 (Command)
Byte 1: Channel bitmask (enabled channels)
```

---

### COMMAND_SET_DEFAULT_SLEEP_TIMER (0xE3)
Set default sleep timer value.

**Data Format:**
```
Byte 0: 0xE3 (Command)
Byte 1: Time low byte (units: minutes)
Byte 2: Time high byte
```

---

## Implementation Reference

All commands are defined in `velbus/const.js`:

```javascript
const constants = {
    commands: {
        COMMAND_SWITCH_STATUS: 0x00,
        COMMAND_SWITCH_RELAY_OFF: 0x01,
        COMMAND_SWITCH_RELAY_ON: 0x02,
        // ... (full list in const.js)
    }
};
```

### Using Commands in Code

```javascript
const Packet = require('./velbus/packet');
const constants = require('./velbus/const');

// Create a packet to turn on relay
let packet = new Packet(0x05, Packet.PRIORITY_HIGH);
packet.setDataBytes([
    constants.commands.COMMAND_SWITCH_RELAY_ON,
    0x01  // Channel 1
]);
packet.pack();
```

## Related Documentation

- [Packet Structure](02-packet-structure.md) - How commands fit into packets
- [Checksum and Encoding](03-checksum-and-encoding.md) - Data encoding details
- [Node-RED Mapping](06-node-red-mapping.md) - How commands map to Node-RED nodes

## Source References

- Command definitions: `velbus/const.js` in this repository
- Protocol specification: https://github.com/velbus/packetprotocol
- Module manuals: https://github.com/velbus/moduleprotocol
