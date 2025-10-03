# Agent Onboarding Guide for node-red-contrib-velbus

## Repository Summary

This is a **Node-RED plugin** for integrating Velleman Velbus home automation systems with Node-RED. It provides custom nodes for communicating with Velbus hardware modules via a TCP socket connection to a Velbus server (e.g., VelServ).

### High-Level Details

- **Type**: Node-RED contribution module (npm package)
- **Language**: JavaScript (ES6+)
- **Size**: ~5,100 lines of code across 14 JavaScript files
- **Runtime**: Node.js (tested with v20.19.5+)
- **Dependencies**: Minimal - only `events` and `mustache` packages
- **No Build System**: This is a pure JavaScript project with no compilation/transpilation needed
- **No Tests**: There is no test infrastructure in this repository
- **No Linting**: There are no configured linters (no .eslintrc, .jshintrc, etc.)

## Build and Validation Instructions

### Installation

**ALWAYS run `npm install` before making any changes:**
```bash
npm install
```

This installs the two dependencies (`events` and `mustache`). Installation typically takes less than 10 seconds.

### Available Scripts

Only one script is defined in package.json:
```bash
npm run run  # Starts Node-RED (requires Node-RED to be installed)
```

**Important**: There are NO build, test, or lint scripts configured. Do not attempt to run:
- `npm test` (will fail with "Missing script: test")
- `npm run build` (will fail with "Missing script: build")
- `npm run lint` (will fail with "Missing script: lint")

### Validation Steps

Since there are no automated tests or linters, validation must be done manually:

1. **Syntax Check**: Ensure JavaScript files are syntactically valid:
   ```bash
   node --check velbus/velbus.js
   node --check node-red/velbus-connector.js
   # etc. for files you modify
   ```

2. **Module Loading Test**: Verify the module can be loaded by Node.js:
   ```bash
   node -e "require('./velbus/const.js')"
   node -e "require('./velbus/packet.js')"
   ```

3. **Integration Testing**: If you need to test the actual Node-RED integration, you must:
   - Have Node-RED installed globally or locally
   - Run `node-red` and manually verify nodes appear in the palette
   - Requires actual Velbus hardware or a VelServ TCP server to test fully

## Project Layout and Architecture

### Directory Structure

```
/
├── node-red/          # Node-RED node implementations
│   ├── icons/         # SVG icons for nodes in Node-RED palette
│   ├── *.js           # Node logic (7 node types)
│   └── *.html         # Node UI definitions and help text
├── velbus/            # Core Velbus protocol implementation
│   ├── const.js       # Module metadata and command constants
│   ├── packet.js      # Velbus packet encoding/decoding
│   └── velbus.js      # Main Velbus TCP client and event handler
├── info/              # Protocol and command metadata
│   ├── commandInfo.js # Command parameter descriptions
│   ├── moduleInfo.js  # Module type metadata
│   ├── protocol.js    # Protocol JSON loader
│   ├── protocol.json  # Full protocol specification (large file)
│   └── utils.js       # Utility functions
├── readme-assets/     # Documentation images and command reference
├── package.json       # NPM package definition
└── README.md          # User-facing documentation
```

### Architectural Components

#### 1. Node-RED Nodes (node-red/)

Seven custom node types are defined, each with paired .js (logic) and .html (UI) files:

- **velbus-connector.js/html**: Configuration node for TCP connection to Velbus server
- **velbus-send-raw-bytes.js/html**: Send raw Velbus protocol commands
- **velbus-receive-raw-bytes.js/html**: Receive and filter Velbus messages
- **velbus-switch.js/html**: Button/switch input handling
- **velbus-dimmer.js/html**: Dimmer control and status
- **velbus-relay.js/html**: Relay control and status
- **velbus-temperature.js/html**: Temperature sensor data

All nodes follow the Node-RED conventions:
- Use `RED.nodes.createNode(this, config)` pattern
- Emit `input` events for incoming messages
- Call `this.send(msg)` to output messages
- Use `this.status()` to show node status in UI

#### 2. Velbus Core (velbus/)

- **velbus.js**: Main class that manages TCP socket connection to Velbus server, handles reconnection logic, module discovery, and message parsing/routing
- **packet.js**: Velbus packet construction/parsing with checksums, STX/ETX framing
- **const.js**: Contains `moduleMetaData` array (56+ Velbus module types with capabilities) and command constants (0x00-0xFF range)

#### 3. Protocol Information (info/)

- **protocol.json**: Large (~5000 lines) JSON file with complete protocol specification
- **commandInfo.js**: Export array with command parameter descriptions for UI
- **moduleInfo.js**: Maps module types to protocol documentation files
- **utils.js**: Utility functions (bit manipulation, hex conversion)

### Key Files and Their Purposes

1. **package.json**: Defines the Node-RED nodes via the `node-red.nodes` section. Any new node must be registered here.

2. **velbus/const.js**: Central configuration for:
   - Module metadata (types, button/relay/dimmer counts, temperature sensors)
   - Command codes (0x00-0xFF)
   - Priority levels (PRIO_HI: 0xF8, PRIO_LOW: 0xFB)

3. **velbus/velbus.js**: Event emitter that:
   - Manages socket connection lifecycle
   - Auto-reconnects on connection loss (3-second interval)
   - Discovers modules on the bus
   - Parses incoming packets and emits events

4. **.gitignore**: Excludes node_modules, .DS_Store, dist, log files, and "exported flows.txt"

### Dependencies

- **Runtime**: Node.js 20.19.5+ (earlier versions likely work but untested)
- **NPM**: 10.8.2+
- **Node-RED**: Not included - must be installed separately by users
- **External Hardware**: Requires Velbus USB interface (VMB1USB/VMBRSUSB) and VelServ TCP server

### GitHub Workflows

**No GitHub Actions or CI/CD pipelines are configured.** There is no .github/ directory in the repository.

### Common Pitfalls and Important Notes

1. **No Build Step Required**: This is pure JavaScript. Don't try to compile or transpile anything.

2. **Module Metadata**: When adding support for new Velbus modules, update the `moduleMetaData` array in `velbus/const.js` with correct counts for buttons, relays, dimmers, and temperature sensor capability.

3. **Constants Are Frozen**: The constants object in `velbus/const.js` is frozen via `Object.freeze()` to prevent modification at runtime.

4. **Socket Connection Pattern**: The velbus.js file uses Node.js `net.Socket()` for TCP communication. Connection errors trigger auto-reconnect logic.

5. **Event Emitter Pattern**: Velbus core uses Node.js EventEmitter extensively. Maximum listeners is set to 100 globally.

6. **No TypeScript**: This is plain JavaScript with no type definitions.

7. **HTML Files**: The .html files in node-red/ contain both UI templates (JavaScript) and help documentation (HTML). They're loaded by Node-RED at runtime.

8. **Mustache Dependency**: The `mustache` package was moved from devDependencies to dependencies (see commit 2020/04/13 in README history) - don't move it back.

### Files in Repository Root

- README.md (118 lines) - User documentation with history, examples, contact info
- package.json (40 lines) - NPM package definition
- package-lock.json - Dependency lock file
- .gitignore (23 lines) - Git ignore patterns
- old-flows.json (21KB) - Example Node-RED flows (legacy)

### Making Changes

When implementing changes:

1. **For New Modules**: Add entry to `velbus/const.js` moduleMetaData array
2. **For New Commands**: Add to `velbus/const.js` commands object and optionally to `info/commandInfo.js`
3. **For New Nodes**: Create paired .js/.html files in node-red/ and register in package.json
4. **For Protocol Changes**: Update velbus/packet.js or velbus/velbus.js as needed

### Reference Information

- **Velbus Forum**: https://forum.velbus.eu/t/node-red-integration/15632
- **VelServ TCP Server**: https://github.com/jeroends/velserv
- **Original Author**: Gert Stalpaert (@gertst)
- **Issue Tracker**: https://github.com/gertst/node-red-contrib-velbus/issues

### Important: Trust These Instructions

The information in this guide has been verified against the actual repository structure and is accurate. Only perform additional searching if:
- You need to understand specific implementation details not covered here
- You encounter errors that suggest the information is outdated
- You're working with code paths not described in this guide

For most changes, the information provided here should be sufficient to locate the right files and understand the project structure without extensive exploration.
