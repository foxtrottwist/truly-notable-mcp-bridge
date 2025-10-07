# Truly Notable MCP Bridge

A Swift MCP bridge that connects stdio-based MCP clients like Claude Desktop to your local [Truly Notable](https://trulynotable.app) note-taking app.

## Features

- **Create and manage notes** with AI-extracted metadata
- **Intelligent search** across note content and metadata  
- **Real-time synchronization** with your note library
- **Privacy-first architecture** - all processing stays local
- **High-performance Swift bridge** for reliable connectivity

## Installation

### Option 1: MCP Bundle (.mcpb) - Recommended for Claude Desktop

**Note**: The `.mcpb` bundle format is specific to Claude Desktop. Other MCP clients should use Option 2 below.

1. Download the latest `.mcpb` file from [Releases](https://github.com/foxtrottwist/truly-notable-mcp-bridge/releases)
2. Double-click the .mcpb file or drag it onto Claude Desktop
3. Click "Install" in the Claude Desktop UI
4. Restart Claude Desktop

### Option 2: Manual Build

```bash
git clone https://github.com/foxtrottwist/truly-notable-mcp-bridge.git
cd trulynotable-mcp-bridge
swift build -c release --product TrulyNotableMCPBridge
./build-mcpb.sh
```

Add to your MCP client configuration:

```json
{
  "mcpServers": {
    "trulynotable": {
      "command": "/path/to/mcp-bridge",
      "args": ["--port", "3001", "--host", "127.0.0.1"]
    }
  }
}
```

## Prerequisites

1. **Truly Notable app** installed and running
2. **MCP server enabled** in Truly Notable Settings > MCP Server
3. **macOS 26+** (Tahoe or later)

## Setup

1. Open Truly Notable app
2. Navigate to Settings > MCP Server
3. Enable "Auto-start MCP server" 
4. Install this bridge bundle in your MCP client
5. The bridge connects automatically to `http://127.0.0.1:3001`

## Available Tools

### `create_note`
Create new notes with optional content. AI metadata extraction happens automatically.

```
Create a note titled "Meeting Notes" with content about project updates
```

### `get_note` 
Retrieve full note content and metadata by ID.

```
Get the contents of note ID abc-123
```

### `search_notes`
AI-aware search across note content and extracted metadata.

```
Search for notes about "budget planning" or "financial projections"
```

### `get_note_metadata`
View AI-extracted entities, relationships, tasks, and dates from a specific note.

```
Show me the metadata for my "Project Planning" note
```

### `list_recent_notes`
List recently modified notes with metadata indicators.

```
Show my recent notes from the past week
```

## Configuration

The bridge accepts command-line arguments:

- `--port` - Truly Notable server port (default: 3001)
- `--host` - Server host address (default: 127.0.0.1) 
- `--verbose` - Enable debug logging (use only when troubleshooting outside of MCP clients, as logging output disrupts stdio communication)

## Architecture

```
MCP Client ←→ MCP Bridge ←→ HTTP Client ←→ Truly Notable App
```

The Swift bridge:
1. Connects to MCP clients via stdio MCP protocol
2. Forwards tool calls to Truly Notable's HTTP server
3. Returns responses with proper error handling
4. Maintains session state and connection pooling

## Troubleshooting

**Bridge won't connect:**
- Ensure Truly Notable app is running
- Check MCP server is enabled in Settings
- Verify port 3001 is available

**Permission errors:**
- Grant necessary permissions to MCP client
- Check firewall settings for localhost connections

**Tool calls failing:**
- Restart both Truly Notable and MCP client
- Check client console for error messages

## Development

```bash
# Build executable
swift build -c release --product TrulyNotableMCPBridge

# Run tests
swift test

# Create bundle
./build-mcpb.sh 1.0.0
```

## Compatibility

- **macOS**: 26.0+ (Tahoe and later)
- **Architecture**: arm64
- **MCP Clients**: Claude Desktop 0.10.0+, LM Studio 0.3.27+, or any stdio-based MCP client
- **Truly Notable**: 1.0.0+

## Privacy

All note processing happens locally within the Truly Notable app. The bridge facilitates communication between MCP clients and your Truly Notable app using localhost connections only.

**Important**: When using MCP clients like Claude Desktop or LM Studio, your interactions with those clients fall under their respective privacy policies. Data you share with AI assistants through these clients may be transmitted to external services according to their terms. The bridge itself transmits no data externally - it only connects your local MCP client to your local Truly Notable app.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Law Horne**
- Website: [lawrencehorne.com](https://lawrencehorne.com)
- Email: [hello@foxtrottwist.com](mailto:hello@foxtrottwist.com)

---

*Part of the [Model Context Protocol](https://modelcontextprotocol.io) ecosystem*
