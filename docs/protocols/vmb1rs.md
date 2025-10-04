# VMB1RS RS232 Interface Protocol (Edition 1, Rev 2)

## RS232C Frame Structure (page 1)
- Each serial message uses: `<STX><111110-SID10-SID9><SID8..SID1><SID0-RTR-00-DLC3..0>[DATA...]<CHECKSUM><ETX>`.
- `STX = 0x0F`, `ETX = 0x04`.
- `<111110-SID10-SID9>` carries the two most significant bits of the Velbus identifier plus framing marker.
- `<SID8..SID1>` and `<SID0>` complete the standard identifier; `RTR` is the Remote Transmit Request flag.
- `DLC3..0` encodes the number of data bytes (0-8).
- `CHECKSUM` is the two's complement of the sum of all preceding bytes in the frame.

## Serial Status Messages (page 1)
| Event | Payload | Command Byte |
| --- | --- | --- |
| Bus off | `<STX><0xF8><0x00><0x01><0x09><CHK><ETX>` | `COMMAND_BUS_OFF = 0x09` |
| Bus active | `<STX><0xF8><0x00><0x01><0x0A><CHK><ETX>` | `COMMAND_BUS_ACTIVE = 0x0A` |
| Receive buffer full | `<STX><0xF8><0x00><0x01><0x0B><CHK><ETX>` | `COMMAND_RX_BUFFER_FULL = 0x0B` |
| Receive ready | `<STX><0xF8><0x00><0x01><0x0C><CHK><ETX>` | `COMMAND_RX_READY = 0x0C` |
| Interface status request (host to module) | `<STX><0xF8><0x00><0x01><0x0E><CHK><ETX>` | `CMD_INTERFACE_STATUS_REQUEST = 0x0E` |

> When the receive buffer is full, the interface does not return additional status frames until space becomes available.

## Velbus CAN Frame Reference (page 2)
- Standard Velbus frame: `<SOF SID10..0 RTR IDE r0 DLC3..0 DATA[0..7] CRC15..1 CRCDEL ACK ACKDEL EOF7..1 IFS3..1>`.
- `SOF`: start of frame (dominant 0);
- `SID10..9`: priority bits (`00` highest, `11` lowest);
- `SID8..1`: module address;
- `SID0`: always 0; `RTR`: remote frame flag; `IDE`: 0 (standard ID); `r0`: reserved 0.
- `DLC3..0`: byte count (0-8 data bytes).
- Data bytes 1-8 carry the command and parameters.
- `CRC15..1`: 15-bit CRC; `CRCDEL`: recessive delimiter; `ACK`: slot (transmitter reads back 0 if acknowledged); `ACKDEL`: delimiter; `EOF7..1`: recessive end of frame; `IFS3..1`: inter-frame space (recessive).

## Operational Notes
- Host systems should monitor the RS232 status events to detect bus faults and buffer saturation before submitting additional frames.
- Always recompute the RS232 `CHECKSUM` as the two's complement of every byte between `STX` and the checksum field minus one.
- The RS232 wrapper preserves Velbus priority bits; use `<111110-SID10-SID9>` to embed the high-priority bits when transmitting onto the bus.
- Avoid issuing `CMD_INTERFACE_STATUS_REQUEST` when the interface reports the receive buffer is full; wait until a `COMMAND_RX_READY` frame arrives.
