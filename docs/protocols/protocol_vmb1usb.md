# VMB1USB Interface Module Protocol (Edition 1, Rev 2)

## Module Overview
- USB-to-Velbus bridge that tunnels Velbus CAN frames over a simple framed serial protocol (page 1).
- Provides status notifications for bus-off, bus-active, receive-buffer overflow, and receive-ready conditions (page 1).
- Does not originate application-level Velbus commands; it transparently forwards frames between USB and the bus (page 2).

## Message Formats
- Host link uses 8-bit framed packets: `<STX><111110-SID10-SID9><SID8..SID1><SID0-RTR-0-0-DLC3..0><data0..data7><CHECKSUM><ETX>` (page 1).
- `STX = 0x0F`, `ETX = 0x04`; checksum byte is appended after the data payload (page 1).
- `RTR` and `DLC` mirror the standard Velbus CAN layout; unused data slots are omitted when `DLC < 8` (page 1).

## Transmitted Messages
- **Bus-Off**: `<STX><F8><00><01><0x09><CHECKSUM><ETX>` informs the host that the CAN controller entered bus-off (page 1).
- **Bus-Active**: `<STX><F8><00><01><0x0A>...` indicates recovery from bus-off (page 1).
- **Receive Buffer Full**: `<STX><F8><00><01><0x0B>...` warns that no additional frames can be queued; no interface status follows while full (page 1).
- **Receive Ready**: `<STX><F8><00><01><0x0C>...` signals the buffer has capacity again (page 1).

## Accepted Commands
- **Interface Status Request**: host sends `<STX><F8><00><01><0x0E><CHECKSUM><ETX>` to poll interface state; no response is returned if the receive buffer remains full (page 1).
- **Velbus Frame Forwarding**: any Velbus CAN frame encapsulated via the host format is injected on the bus; inverse mapping applies for frames received from the bus (page 2).

## Message Formats (Velbus Side)
- Native Velbus frames follow `<SOF SID10..0 RTR IDE r0 DLC3..0 DATA CRC ACK EOF IFS>` as defined by the base protocol (page 2).

## Conversion Notes
- OCR misreadings (e.g. `Binairy`) were normalised; the framing bytes were verified against the scanned table (page 1).
- The document contains no memory map or application commands; consult general Velbus protocol documentation for CAN-level frame semantics (page 2).
