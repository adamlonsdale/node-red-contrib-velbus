# Contributing to Velbus Documentation

Thank you for your interest in improving the Velbus documentation for this Node-RED integration! This guide explains how to contribute to both packet protocol and module-specific documentation.

## Types of Contributions

### 1. Protocol Documentation
- Clarifications and corrections to packet protocol docs
- Additional examples and use cases
- Node-RED integration patterns
- Implementation details

### 2. Module Documentation
- OCR conversion of PDF manuals to Markdown
- Proofreading and correction of existing OCR documents
- Image extraction and diagram documentation
- Module-specific command examples

### 3. General Improvements
- Fixing typos and formatting
- Adding cross-references
- Improving navigation
- Updating outdated information

## Getting Started

### Prerequisites

**For Protocol Documentation:**
- Basic understanding of Velbus protocol
- Familiarity with Markdown
- Node.js knowledge (for code examples)

**For Module Documentation:**
- OCR tools (see [OCR Tools](#ocr-tools) below)
- Image editing software (for diagrams)
- PDF viewer
- Text editor with Markdown support

### Repository Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/node-red-contrib-velbus.git
   cd node-red-contrib-velbus
   ```

2. **Create a branch for your changes**
   ```bash
   git checkout -b docs/add-vmb4ryld-manual
   ```

3. **Make your changes** (see guidelines below)

4. **Commit and push**
   ```bash
   git add docs/
   git commit -m "Add OCR documentation for VMB4RYLD"
   git push origin docs/add-vmb4ryld-manual
   ```

5. **Create Pull Request** on GitHub

## Module Documentation Guidelines

### Finding Source Material

1. **Visit official repository**: https://github.com/velbus/moduleprotocol
2. **Locate module PDF**: Look for `protocol_[MODULE].txt` or `.pdf` files
3. **Download PDF**: Save to your local machine
4. **Check for updates**: Ensure you have the latest version

### OCR Tools

#### Recommended Tools

**1. Tesseract OCR (Open Source)**
```bash
# Install on Ubuntu/Debian
sudo apt-get install tesseract-ocr

# Install on macOS
brew install tesseract

# Use with OCRmyPDF
pip install ocrmypdf
ocrmypdf input.pdf output.pdf
```

**2. Adobe Acrobat Pro**
- Commercial tool with high accuracy
- Built-in OCR functionality
- Good for complex layouts

**3. Online Services**
- https://www.onlineocr.net/
- https://www.pdftotext.com/
- Free for small documents

**4. Python Tools**
```bash
# Install Python OCR libraries
pip install pdf2image pytesseract pillow

# Example script
python extract_manual.py protocol_vmb4ryld.pdf
```

### OCR Process

1. **Prepare PDF**
   - Check PDF quality (300+ DPI recommended)
   - Rotate pages if needed
   - Remove blank pages

2. **Run OCR**
   ```bash
   # Using OCRmyPDF
   ocrmypdf --force-ocr --output-type pdf protocol_vmb4ryld.pdf output.pdf
   
   # Extract text
   pdftotext output.pdf module_text.txt
   ```

3. **Extract Images**
   ```bash
   # Using pdfimages
   pdfimages -png protocol_vmb4ryld.pdf images/vmb4ryld
   ```

4. **Convert to Markdown**
   - Copy OCR text to Markdown editor
   - Format headers, lists, tables
   - Insert image references
   - Add frontmatter (see template below)

### Markdown Template

Create file: `docs/velbus-module-protocol/VMB4RYLD.md`

```markdown
---
module_name: VMB4RYLD
module_id: 0x10
description: 4-Channel Relay Module with Direct Load Connections
edition: Edition 5
channels: 4
capabilities:
  - relays: 4
  - virtual_relay: 1
  - buttons: 0
  - dimmers: 0
  - temperature: false
source_pdf: protocol_vmb4ryld.txt
source_url: https://github.com/velbus/moduleprotocol/blob/master/protocol_vmb4ryld.txt
ocr_tool: Tesseract 5.0.0
ocr_date: 2024-01-15
proofreading_status: Complete
proofreader: your-github-username
---

# VMB4RYLD - 4-Channel Relay Module with Direct Load Connections

## Overview

The VMB4RYLD is a 4-channel relay module designed for direct load connections. Each relay channel can switch up to 16A resistive load.

![Module Front](images/vmb4ryld-front.png)

## Technical Specifications

| Specification | Value |
|---------------|-------|
| Module Type ID | 0x10 |
| Channels | 4 physical + 1 virtual |
| Maximum Load | 16A per channel |
| Contact Type | Direct load, changeover |
| Power Supply | 12V DC via Velbus bus |
| Power Consumption | XX mA |
| Bus Address | Configurable (0x01-0xFF) |
| Dimensions | XX x XX x XX mm |

## Features

- 4 independent relay channels
- Direct load connection (no external power supply needed)
- Changeover contacts (NO/NC)
- Virtual 5th relay for status indication
- LED status indicators
- Configurable via VelbusLink software
- Timer functions
- Scene support

## Physical Connections

### Relay Terminals

```
CH1-NO  CH1-COM  CH1-NC    CH2-NO  CH2-COM  CH2-NC
  ○       ○        ○         ○       ○        ○
  
CH3-NO  CH3-COM  CH3-NC    CH4-NO  CH4-COM  CH4-NC
  ○       ○        ○         ○       ○        ○
```

### Velbus Bus Connection

```
+12V  GND  DATA-  DATA+
 ○     ○     ○      ○
```

## Supported Commands

### Relay Control Commands

#### Switch Relay On (0x02)
Turn on one or more relay channels.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   CH    CRC  ETX
0F   F8   XX    02    02    YY    ZZ   04
```

Where:
- `XX` = Module address
- `YY` = Channel bitmask (0x01=CH1, 0x02=CH2, 0x04=CH3, 0x08=CH4, 0x10=Virtual)

**Example:** Turn on channel 1
```
0F F8 10 02 02 01 E9 04
```

**Node-RED:** Use **Relay node** with action "On"

#### Switch Relay Off (0x01)
Turn off one or more relay channels.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   CH    CRC  ETX
0F   F8   XX    02    01    YY    ZZ   04
```

**Example:** Turn off channel 2
```
0F F8 10 02 01 02 EA 04
```

#### Start Relay Timer (0x03)
Turn on relay for specified duration.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   CH    TIME_L TIME_H TYPE  CRC  ETX
0F   F8   XX    05    03    YY    TT     TT     00    ZZ   04
```

Where:
- `TIME_L`, `TIME_H` = Duration in seconds (16-bit little-endian)
- `TYPE` = 0x00 for off timer, 0x01 for on timer

**Example:** Turn on channel 1 for 60 seconds
```
0F F8 10 05 03 01 3C 00 00 XX 04
```

### Status Commands

#### Relay Status Request (0xFA)
Request current relay status.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   CRC  ETX
0F   FB   XX    01    FA    ZZ   04
```

**Response:** Module sends RELAY_SWITCH_STATUS (0xFB)

#### Relay Status Report (0xFB)
Module reports current relay states.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   STATUS  CRC  ETX
0F   F8   XX    02    FB    YY      ZZ   04
```

Where:
- `STATUS` = Bitmask of active relays (bit 0=CH1, bit 1=CH2, etc.)

**Example:** Channels 1 and 3 are on
```
0F F8 10 02 FB 05 XX 04
(0x05 = 0b00000101 = CH1 and CH3)
```

**Node-RED:** Received by **Relay node** or **Receive Raw Bytes node**

### Memory Commands

#### Read Memory Block (0xC9)
Read configuration from module memory.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   ADDR_H ADDR_L  CRC  ETX
0F   FB   XX    03    C9    AA     AA      ZZ   04
```

#### Write Memory Block (0xCA)
Write configuration to module memory.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   ADDR_H ADDR_L  DATA...  CRC  ETX
0F   FB   XX    07    CA    AA     AA      DD DD DD DD  ZZ   04
```

### Module Discovery

#### Module Type Request (0xFA)
Query module type.

**Packet Structure:**
```
STX  PRI  ADDR  SIZE  CMD   CRC  ETX
0F   FB   XX    01    FA    ZZ   04
```

**Response:** Module Type (0xFF)
```
STX  PRI  ADDR  SIZE  CMD   TYPE  BUILD... CRC  ETX
0F   F8   XX    06    FF    10    YY YY YY YY  ZZ   04
```

Where `TYPE` = 0x10 for VMB4RYLD

## Configuration

### Module Settings (via VelbusLink)

1. **Bus Address**
   - Range: 0x01 to 0xFF
   - Must be unique on bus
   - Configured via DIP switches or software

2. **Channel Names**
   - Up to 16 characters per channel
   - Stored in module memory
   - Retrieved via COMMAND_MODULE_NAME_REQUEST (0xEF)

3. **Timer Settings**
   - Default timer duration
   - Auto-off delays
   - Blink timing

4. **LED Feedback**
   - LED on/off behavior
   - Blink patterns

### Memory Map

| Address | Size | Description |
|---------|------|-------------|
| 0x0000 | 16 | Channel 1 name |
| 0x0010 | 16 | Channel 2 name |
| 0x0020 | 16 | Channel 3 name |
| 0x0030 | 16 | Channel 4 name |
| 0x0040 | 2 | Channel 1 timer setting |
| 0x0042 | 2 | Channel 2 timer setting |
| ... | ... | ... |

## Node-RED Integration

### Example 1: Simple On/Off Control

```
[Inject] --> [Relay Node] --> [Debug]
  true         Address: 0x10
               Channel: 1
               Action: On
```

### Example 2: Timed Relay

```
[Inject] --> [Function] --> [Send Raw Bytes] --> [Debug]
                             Address: 0x10
                             Data: 03 01 78 00 00
                             (Turn on CH1 for 120 seconds)
```

**Function node code:**
```javascript
msg.payload = {
    channel: 1,
    duration: 120  // seconds
};
return msg;
```

### Example 3: Status Monitoring

```
[Receive Raw Bytes] --> [Switch] --> [Relay Node]
  Filter Address: 0x10                (Update status)
  Filter Command: 0xFB
```

## Troubleshooting

### Common Issues

**1. Relay not responding**
- Check bus address configuration
- Verify power supply (12V DC)
- Check bus wiring (DATA+ and DATA-)
- Use VelbusLink to test module

**2. Status not updating in Node-RED**
- Ensure connector is connected
- Check filter settings in Receive Raw Bytes
- Verify module is sending status (0xFB command)

**3. Timer not working**
- Check timer configuration in VelbusLink
- Verify command format (duration in seconds)
- Ensure module firmware is up to date

## Wiring Diagrams

### Basic Wiring

![Wiring Diagram](images/vmb4ryld-wiring.png)

### Load Connection Examples

**Resistive Load (Lamp):**
```
L ────[Lamp]────┐
                │
            NO ─┤
               COM ── N
```

**Inductive Load (Motor):**
```
L ────[Motor]────┐
                 │
             NO ─┤
                COM ── N
```

(Add suppressor capacitor for inductive loads)

## Dimensions

![Dimensions](images/vmb4ryld-dimensions.png)

- Width: XX mm
- Height: XX mm
- Depth: XX mm
- DIN rail mounting: Yes

## LED Indicators

| LED | Description |
|-----|-------------|
| CH1-4 | Relay status (green = on) |
| BUS | Bus activity (flashes during communication) |
| PWR | Power indicator (red = powered) |

## Safety Information

⚠️ **WARNING**
- Installation by qualified electrician only
- Disconnect power before wiring
- Do not exceed maximum load ratings
- Follow local electrical codes
- Module must be installed in appropriate enclosure

## Firmware Updates

Firmware can be updated via Velbus protocol:
1. Enter firmware upgrade mode (0x62)
2. Write firmware blocks (0x66)
3. Exit firmware mode (0x64)

**Note:** Firmware updates typically done via VelbusLink software.

## OCR Notes

### Quality Assessment
- **Text accuracy**: 98%
- **Table formatting**: Good
- **Diagram quality**: Moderate (diagrams extracted as images)

### Known OCR Issues
- Some special characters may be incorrect
- Page numbers and headers removed
- Original PDF formatting may differ slightly

### Proofreading Status
- [x] Overview section reviewed
- [x] Technical specifications verified
- [x] Command tables checked against protocol.json
- [x] Examples tested
- [ ] Wiring diagrams need higher resolution images

## Related Documentation

- [Packet Protocol](../velbus-packet-protocol/README.md)
- [Module Reference](modules-and-ids.md)
- [Node-RED Integration](../velbus-packet-protocol/06-node-red-mapping.md)

## References

- **Source PDF**: protocol_vmb4ryld.txt (edition 5)
- **Official Repository**: https://github.com/velbus/moduleprotocol
- **Product Page**: https://www.velbus.eu/products/vmb4ryld/
- **Forum Support**: https://forum.velbus.eu/

---

*Document generated from OCR of official Velbus manual*
*Last updated: 2024-01-15*
*OCR tool: Tesseract 5.0.0*
*Proofread by: contributor-username*
```

### Image Files

Place extracted images in: `docs/velbus-module-protocol/images/`

Naming convention:
- `vmb4ryld-front.png` - Front view of module
- `vmb4ryld-wiring.png` - Wiring diagram
- `vmb4ryld-dimensions.png` - Dimension drawing
- `vmb4ryld-schematic-01.png` - Circuit diagrams (numbered if multiple)

### Proofreading Checklist

Before submitting:
- [ ] Module name and ID verified against `velbus/const.js`
- [ ] Command codes verified against `velbus/const.js`
- [ ] Tables properly formatted
- [ ] All images extracted and referenced
- [ ] Frontmatter complete and accurate
- [ ] OCR errors corrected
- [ ] Technical terms spelled correctly
- [ ] Cross-references working
- [ ] Code examples tested (if applicable)
- [ ] Related documentation links added

### Common OCR Errors to Watch For

1. **Number/Letter confusion**
   - `0` (zero) vs `O` (letter O)
   - `1` (one) vs `l` (lowercase L) vs `I` (uppercase i)
   - `5` vs `S`
   - `8` vs `B`

2. **Hex values**
   - `0xF8` vs `0xFS` (S instead of 8)
   - `0x0A` vs `0x0n` (n instead of A)

3. **Technical terms**
   - "Relay" not "Re lay"
   - "Channel" not "Channe l"
   - "Bitmask" not "Bit mask" or "Bit-mask"

4. **Table alignment**
   - Ensure columns line up
   - Check for missing pipe characters (`|`)
   - Verify header separators

5. **Special characters**
   - `°` (degree symbol) may become `o` or `°`
   - `μ` (micro) may become `u` or disappear
   - `±` (plus-minus) may become `+/-`

## Protocol Documentation Guidelines

### Adding Examples

When adding protocol examples:
1. Use real-world scenarios
2. Show complete packets with checksums
3. Include Node-RED implementation
4. Explain each field
5. Add comments for clarity

### Code Style

**JavaScript:**
```javascript
// Good: Clear variable names, comments
let channelBitmask = Math.pow(2, channel - 1);
let packet = new Packet(address, Packet.PRIORITY_HIGH);
packet.setDataBytes([
    constants.commands.COMMAND_SWITCH_RELAY_ON,
    channelBitmask
]);

// Avoid: Unclear, no comments
let c = 1 << (ch - 1);
let p = new Packet(addr, 0xF8);
p.setDataBytes([0x02, c]);
```

**Packet notation:**
```
Good:
0F F8 05 02 02 01 [checksum] 04
^  ^  ^  ^  ^  ^             ^
STX |  |  |  |  Channel      ETX
   Pri |  |  Command
      Addr |  Data size
          

Clear field labels help readers understand structure
```

### Markdown Style

- Use ATX headers (`#`, `##`, `###`)
- Code blocks with language tags (```javascript, ```bash)
- Tables for structured data
- Bullet lists for features
- Numbered lists for procedures
- Bold for **important** terms
- Italic for *emphasis*
- Code inline for `commands` and `variables`

## Branch Naming

Use descriptive branch names:
- `docs/add-vmb4ryld-manual` - Adding new module docs
- `docs/fix-relay-commands` - Fixing protocol docs
- `docs/improve-examples` - Enhancing examples
- `docs/proofread-vmb1dm` - Proofreading OCR output

## Commit Messages

Follow conventional commits:
```
docs: Add OCR documentation for VMB4RYLD

- Extract text from protocol_vmb4ryld.txt
- Create Markdown file with frontmatter
- Extract and include wiring diagrams
- Proofread for accuracy
```

Other examples:
- `docs: Fix checksum calculation examples`
- `docs: Improve Node-RED relay node documentation`
- `docs: Correct VMB1DM command codes`
- `docs: Add troubleshooting section to protocol docs`

## Pull Request Template

When submitting a pull request, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New module documentation
- [ ] Protocol documentation update
- [ ] OCR proofreading
- [ ] Fix errors/typos
- [ ] Add examples
- [ ] Improve formatting

## Module (if applicable)
- Module name: VMB4RYLD
- Module ID: 0x10
- OCR tool used: Tesseract 5.0.0
- Proofreading status: Complete

## Checklist
- [ ] Markdown properly formatted
- [ ] Images extracted and linked
- [ ] Frontmatter complete
- [ ] Cross-references working
- [ ] Spell-checked
- [ ] Technical terms verified
- [ ] Examples tested (if code)

## Notes
Any additional information or concerns
```

## Review Process

### What Reviewers Check

1. **Accuracy**
   - Command codes match `velbus/const.js`
   - Module IDs match `velbus/const.js`
   - Technical details correct

2. **Formatting**
   - Markdown renders correctly
   - Tables aligned
   - Code blocks formatted
   - Images display properly

3. **Completeness**
   - Frontmatter filled in
   - All sections present
   - OCR notes included
   - References added

4. **Quality**
   - Clear writing
   - Consistent style
   - Proper grammar
   - No obvious OCR errors

### Addressing Review Comments

- Be responsive to feedback
- Make requested changes promptly
- Ask questions if unclear
- Update PR description if scope changes

## Getting Help

### Resources

- **Repository README**: Main project documentation
- **AGENTS.md**: Developer onboarding guide
- **Existing docs**: Use as templates and examples
- **Source code**: `velbus/*.js` for implementation details

### Where to Ask Questions

- **GitHub Issues**: Technical questions about protocol
- **GitHub Discussions**: General documentation questions
- **Velbus Forum**: Module-specific questions
  https://forum.velbus.eu/

### Contact

- **Repository owner**: @adamlonsdale
- **Original author**: @gertst
- **Community**: Velbus forum users

## License

Documentation contributions are covered by the repository license. By contributing, you agree that your contributions will be licensed under the same terms as the project.

## Thank You!

Your contributions help make Velbus integration with Node-RED better for everyone. Whether you're fixing a typo, adding examples, or converting entire manuals, your efforts are appreciated!

---

*For questions about contributing, please open an issue on GitHub*
*Last updated: 2024*
