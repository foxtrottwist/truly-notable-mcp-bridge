# TrulyNotable MCP Bridge

MCP bridge connecting TrulyNotable's HTTP server to STDIO-based clients like Claude Desktop.

## Usage

```bash
mcp-bridge --port 3001 --host 127.0.0.1
```

## Options

- `--port, -p`: TrulyNotable server port (default: 3001)
- `--host, -h`: TrulyNotable server host (default: 127.0.0.1)  
- `--verbose`: Enable verbose logging
- `--help`: Show help information

## Requirements

- macOS 26.0+
- TrulyNotable app running with MCP server enabled

## License

MIT License - see [LICENSE](LICENSE) for details.
