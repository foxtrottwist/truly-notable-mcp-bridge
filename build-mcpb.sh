#!/bin/bash
# build-mcpb.sh - Build Truly Notable MCP Bridge Bundle

set -e

echo "Building Truly Notable MCP Bridge Bundle..."

# Validate manifest first
echo "Validating manifest.json..."
if command -v mcpb &> /dev/null; then
    mcpb validate manifest.json
    if [ $? -ne 0 ]; then
        echo "Error: Manifest validation failed"
        exit 1
    fi
    echo "Manifest validation passed!"
else
    echo "Warning: mcpb CLI not found. Install with: npm install -g @anthropic-ai/mcpb"
    echo "Continuing without validation..."
fi

VERSION=${1:-"1.0.0"}
BUILD_DIR="temp-mcpb-build"
BUNDLE_NAME="truly-notable-mcp-bridge-${VERSION}.mcpb"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build Swift bridge executable
echo "Building Swift bridge executable..."
swift build -c release --product mcp-bridge

# Copy bridge executable to root of bundle (as specified in manifest entry_point)
cp .build/release/mcp-bridge "$BUILD_DIR/mcp-bridge"

# Make executable
chmod +x "$BUILD_DIR/mcp-bridge"

# Copy manifest 
cp manifest.json "$BUILD_DIR/"

# Create README for bundle users
cat > "$BUILD_DIR/README.md" << 'EOF'
# Truly Notable MCP Bridge

Connects Claude to your local Truly Notable app for AI-powered note management.

## Setup

1. Install and open Truly Notable app
2. Go to Settings > MCP Server  
3. Enable "Auto-start MCP server"
4. Install this bundle in Claude

## Available Tools

- **create_note** - Create new notes with AI metadata
- **get_note** - Retrieve note content and metadata
- **search_notes** - AI-aware note search
- **get_note_metadata** - View extracted entities, tasks, relationships
- **list_recent_notes** - Recent notes with metadata indicators

The bridge connects to your local Truly Notable server at http://127.0.0.1:3001
EOF

# Create the bundle
echo "Creating .mcpb bundle..."
cd "$BUILD_DIR"
zip -r "../${BUNDLE_NAME}" .
cd ..

# Cleanup
rm -rf "$BUILD_DIR"

echo "Bundle created: ${BUNDLE_NAME}"

# Test executable
if [ -f "${BUNDLE_NAME}" ]; then
    echo "Bundle contents:"
    unzip -l "${BUNDLE_NAME}"
    echo ""
    echo "Bridge bundle ready for distribution!"
else
    echo "Error: Bundle creation failed"
    exit 1
fi
