#!/bin/bash

# Claude Code Extension Modifier Script
# This script modifies the Claude Code extension to use 'claude --resume' instead of 'claude'

echo "Claude Code Extension Modifier"
echo "=============================="
echo ""

# Function to find extension directory
find_extension_dir() {
    local ide=$1
    local base_dir=""
    
    case $ide in
        "vscode")
            base_dir="$HOME/.vscode/extensions"
            ;;
        "cursor")
            base_dir="$HOME/.cursor/extensions"
            ;;
        "code-insiders")
            base_dir="$HOME/.vscode-insiders/extensions"
            ;;
        *)
            echo "Unknown IDE: $ide"
            return 1
            ;;
    esac
    
    if [ ! -d "$base_dir" ]; then
        echo "Extension directory not found: $base_dir"
        return 1
    fi
    
    # Find Claude Code extension
    local ext_dir=$(ls -d "$base_dir"/anthropic.claude-code-* 2>/dev/null | head -1)
    
    if [ -z "$ext_dir" ]; then
        echo "Claude Code extension not found in $base_dir"
        return 1
    fi
    
    echo "$ext_dir"
    return 0
}

# Check command line arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vscode|cursor|code-insiders> [--revert]"
    echo ""
    echo "Examples:"
    echo "  $0 cursor          # Modify Cursor's Claude Code extension"
    echo "  $0 vscode          # Modify VSCode's Claude Code extension"
    echo "  $0 cursor --revert # Revert changes"
    exit 1
fi

IDE=$1
REVERT=${2:-""}

# Find extension directory
EXT_DIR=$(find_extension_dir "$IDE")
if [ $? -ne 0 ]; then
    exit 1
fi

echo "Found extension at: $EXT_DIR"

# Navigate to dist directory
DIST_DIR="$EXT_DIR/dist"
if [ ! -d "$DIST_DIR" ]; then
    echo "Error: dist directory not found"
    exit 1
fi

cd "$DIST_DIR"

# Check if extension.js exists
if [ ! -f "extension.js" ]; then
    echo "Error: extension.js not found"
    exit 1
fi

# Revert if requested
if [ "$REVERT" == "--revert" ]; then
    if [ -f "extension.js.backup" ]; then
        echo "Reverting to original..."
        cp extension.js.backup extension.js
        echo "✓ Successfully reverted to original"
    else
        echo "Error: No backup found to revert"
        exit 1
    fi
    exit 0
fi

# Create backup if it doesn't exist
if [ ! -f "extension.js.backup" ]; then
    echo "Creating backup..."
    cp extension.js extension.js.backup
    echo "✓ Backup created: extension.js.backup"
else
    echo "✓ Backup already exists"
fi

# Apply modifications
echo "Applying modifications..."

# Use different sed syntax based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's/executeCommand("claude")/executeCommand("claude --resume")/g' extension.js
    sed -i '' 's/sendText("claude")/sendText("claude --resume")/g' extension.js
else
    # Linux
    sed -i 's/executeCommand("claude")/executeCommand("claude --resume")/g' extension.js
    sed -i 's/sendText("claude")/sendText("claude --resume")/g' extension.js
fi

# Verify changes
EXEC_COUNT=$(grep -c 'executeCommand("claude --resume")' extension.js)
SEND_COUNT=$(grep -c 'sendText("claude --resume")' extension.js)

if [ $EXEC_COUNT -gt 0 ] || [ $SEND_COUNT -gt 0 ]; then
    echo "✓ Successfully modified extension.js"
    echo "  - executeCommand modifications: $EXEC_COUNT"
    echo "  - sendText modifications: $SEND_COUNT"
    echo ""
    echo "Please restart $IDE for changes to take effect"
    echo ""
    echo "To revert changes, run: $0 $IDE --revert"
else
    echo "⚠️  Warning: No modifications were applied"
    echo "The extension may already be modified or the format has changed"
fi