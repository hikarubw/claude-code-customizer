#!/bin/bash

# Claude Code Resume Extension Generator
# Universal script that can download from npm or use local VSIX files

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORK_DIR="temp_extension_work"
OUTPUT_DIR="claude-code-resume-output"
NPM_PACKAGE="@anthropic-ai/claude-code"
VSIX_LOCATION_IN_PACKAGE="vendor/claude-code.vsix"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to show help
show_help() {
    echo "Claude Code Resume Extension Generator"
    echo "====================================="
    echo ""
    echo "This script creates a resume version of Claude Code extension that uses 'claude --resume'"
    echo ""
    echo "Usage:"
    echo "  $0 [options] [vsix-file]"
    echo ""
    echo "Options:"
    echo "  -v, --version <version>  Download specific version from npm"
    echo "  -l, --latest            Download latest version from npm (default if no file specified)"
    echo "  -o, --output <dir>      Output directory (default: claude-code-resume-output)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Download and modify latest version"
    echo "  $0 -v 1.0.24                         # Download and modify version 1.0.24"
    echo "  $0 ~/Downloads/claude-code.vsix      # Modify local VSIX file"
    echo "  $0 -o my-output ~/Downloads/code.vsix # Modify local file with custom output dir"
    echo ""
}

# Function to extract version from npm
get_latest_version() {
    npm view "$NPM_PACKAGE" version 2>/dev/null
}

# Function to download npm package
download_npm_package() {
    local version=$1
    
    npm pack "$NPM_PACKAGE@$version" >/dev/null 2>&1
    
    # The npm pack command outputs the filename, we need to find it
    local tarball_name=""
    
    # Try different possible names
    for name in "anthropic-ai-claude-code-${version}.tgz" "claude-code-${version}.tgz" "@anthropic-ai-claude-code-${version}.tgz"; do
        if [ -f "$name" ]; then
            tarball_name="$name"
            break
        fi
    done
    
    echo "$tarball_name"
}

# Function to modify package.json
modify_package_json() {
    print_info "Modifying package.json..."
    
    # Change name and display name
    sed -i '' 's/"name": "claude-code"/"name": "claude-code-resume"/' package.json
    sed -i '' 's/"displayName": "Claude Code"/"displayName": "Claude Code Resume"/' package.json
    sed -i '' 's/"description": "Claude Code for VS Code[^"]*"/"description": "Modified Claude Code extension that automatically resumes your last session"/' package.json
    
    # Change publisher to avoid conflicts
    sed -i '' 's/"publisher": "Anthropic"/"publisher": "claude-code-custom"/' package.json
    
    # Update all command IDs
    sed -i '' 's/claude-code\./claude-code-resume./g' package.json
    
    # Update command titles
    sed -i '' 's/"Run Claude Code"/"Run Claude Code (Resume)"/g' package.json
    sed -i '' 's/"Fix with Claude Code"/"Fix with Claude Code (Resume)"/g' package.json
    
    # Remove metadata section if it exists
    sed -i '' '/"__metadata":/,/^[[:space:]]*}/d' package.json
    
    # Fix any trailing comma issues (macOS compatible)
    perl -i -pe 's/,(\s*\n\s*})/\1/g' package.json
    
    # Simplify scripts section
    cat > temp_scripts.json << 'EOF'
	"scripts": {
		"vscode:prepublish": "echo 'Extension already built'",
		"package": "vsce package --no-git-tag-version --no-update-package-json --no-dependencies --skip-license"
	},
EOF
    
    # Replace scripts section
    awk '
    /"scripts": {/,/^[[:space:]]*}/ {
        if (/"scripts": {/) {
            system("cat temp_scripts.json")
            in_scripts = 1
        } else if (/^[[:space:]]*}/ && in_scripts) {
            in_scripts = 0
            next
        } else if (in_scripts) {
            next
        }
    }
    !in_scripts { print }
    ' package.json > package.json.temp && mv package.json.temp package.json
    
    rm -f temp_scripts.json
}

# Function to modify extension.js
modify_extension_js() {
    print_info "Modifying extension.js..."
    
    # Change command execution to use --resume
    sed -i '' 's/executeCommand("claude")/executeCommand("claude --resume")/g' dist/extension.js
    sed -i '' 's/sendText("claude")/sendText("claude --resume")/g' dist/extension.js
    
    # Update command IDs to match package.json
    sed -i '' 's/claude-code\./claude-code-resume./g' dist/extension.js
}

# Function to create README
create_readme() {
    local version=$1
    print_info "Creating README.md..."
    
    cat > README.md << EOF
# Claude Code Resume Extension for VS Code

A modified version of the official [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code) VSCode extension (v${version}) that automatically resumes your last session.

## What's Different?

This extension runs \`claude --resume\` instead of just \`claude\`, which means:
- Your previous Claude Code session will be resumed
- Context from your last conversation is maintained
- You can continue where you left off

## Features

All the original Claude Code features are preserved:
- Auto-installation: When you launch Claude Code from within VSCode's terminal, it automatically detects and installs the extension
- Selection context: Selected text in the editor is automatically added to Claude's context
- Diff viewing: Code changes can be displayed directly in VSCode's diff viewer instead of the terminal
- Keyboard shortcuts: Support for shortcuts like Alt+Cmd+K to push selected code into Claude's prompt
- Tab awareness: Claude can see which files you have open in the editor

## Installation

1. Download the \`.vsix\` file
2. In VS Code, open the Command Palette (\`Cmd+Shift+P\` or \`Ctrl+Shift+P\`)
3. Type "Install from VSIX" and select "Extensions: Install from VSIX..."
4. Select the downloaded \`.vsix\` file
5. Restart VS Code

## Usage

Use the same keyboard shortcuts as the original:
- **Cmd+Escape** (Mac) / **Ctrl+Escape** (Windows/Linux) - Run Claude Code with resume

## Requirements

- VS Code 1.94.0 or higher
- Claude Code CLI installed (\`npm install -g @anthropic-ai/claude-code\`)

## Version

This extension is based on Claude Code v${version}.

## Credits

This is a modified version of the official Claude Code extension by Anthropic. All original functionality and code belong to Anthropic.
EOF
}

# Function to create installation script
create_install_script() {
    local version=$1
    cat > install.sh << EOF
#!/bin/bash
# Installation script for Claude Code Resume Extension v${version}

VSIX_FILE="claude-code-resume-${version}.vsix"

if [ ! -f "\$VSIX_FILE" ]; then
    echo "Error: \$VSIX_FILE not found in current directory"
    exit 1
fi

echo "Installing Claude Code Resume Extension v${version}..."

if command -v cursor &> /dev/null; then
    cursor --install-extension "\$VSIX_FILE"
elif command -v code &> /dev/null; then
    code --install-extension "\$VSIX_FILE"
else
    echo "Error: Neither 'cursor' nor 'code' command found"
    echo "Please install manually through the IDE"
    exit 1
fi

echo "Installation complete! Please restart your IDE."
EOF
    chmod +x install.sh
}

# Parse command line arguments
SPECIFIC_VERSION=""
USE_LATEST=false
LOCAL_VSIX=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            SPECIFIC_VERSION="$2"
            shift 2
            ;;
        -l|--latest)
            USE_LATEST=true
            shift
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # Assume it's a file path
            LOCAL_VSIX="$1"
            shift
            ;;
    esac
done

# Header
echo ""
echo "Claude Code Resume Extension Generator"
echo "====================================="
echo ""

# Determine mode of operation
if [ -n "$LOCAL_VSIX" ]; then
    # Local VSIX mode
    if [ ! -f "$LOCAL_VSIX" ]; then
        print_error "File not found: $LOCAL_VSIX"
        exit 1
    fi
    print_info "Using local VSIX file: $LOCAL_VSIX"
    MODE="local"
elif [ -n "$SPECIFIC_VERSION" ]; then
    # Specific version download mode
    print_info "Will download version: $SPECIFIC_VERSION"
    MODE="download"
    VERSION="$SPECIFIC_VERSION"
else
    # Latest version download mode
    print_info "Will download latest version from npm"
    MODE="download"
    USE_LATEST=true
fi

# Clean up any previous work
print_info "Cleaning up previous work directories..."
rm -rf "$WORK_DIR" "$OUTPUT_DIR"
rm -f *-claude-code-*.tgz anthropic-ai-claude-code-*.tgz claude-code-*.tgz

# Create directories
mkdir -p "$WORK_DIR"
mkdir -p "$OUTPUT_DIR"

# Handle download mode
if [ "$MODE" = "download" ]; then
    # Determine version
    if [ "$USE_LATEST" = true ]; then
        print_info "Fetching latest version information..."
        VERSION=$(get_latest_version)
        if [ -z "$VERSION" ]; then
            print_error "Could not fetch version information"
            exit 1
        fi
        print_success "Latest version: $VERSION"
    fi
    
    # Download the npm package
    print_info "Downloading $NPM_PACKAGE@$VERSION..."
    TARBALL=$(download_npm_package "$VERSION")
    if [ -z "$TARBALL" ]; then
        print_error "Failed to download npm package"
        exit 1
    fi
    print_success "Downloaded: $TARBALL"
    
    # Extract the npm package
    print_info "Extracting npm package..."
    tar -xzf "$TARBALL" -C "$WORK_DIR"
    
    # Check if VSIX exists in the package
    VSIX_PATH="$WORK_DIR/package/$VSIX_LOCATION_IN_PACKAGE"
    if [ ! -f "$VSIX_PATH" ]; then
        print_error "VSIX file not found at $VSIX_LOCATION_IN_PACKAGE"
        echo "Package contents:"
        find "$WORK_DIR/package" -name "*.vsix" -type f
        rm -rf "$WORK_DIR"
        rm -f "$TARBALL"
        exit 1
    fi
    
    # Extract the VSIX
    print_info "Extracting Claude Code extension..."
    unzip -q "$VSIX_PATH" -d "$WORK_DIR/vsix"
    
    # Clean up tarball
    rm -f "$TARBALL"
    
    # Set extension directory
    EXT_DIR="$WORK_DIR/vsix/extension"
    
else
    # Local VSIX mode
    # Extract version from filename if possible
    VERSION=$(echo "$LOCAL_VSIX" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -z "$VERSION" ]; then
        VERSION="unknown"
        print_warning "Could not determine version from filename"
    else
        print_info "Detected version: $VERSION"
    fi
    
    # Extract the VSIX
    print_info "Extracting VSIX file..."
    unzip -q "$LOCAL_VSIX" -d "$WORK_DIR/vsix"
    
    # Set extension directory
    EXT_DIR="$WORK_DIR/vsix/extension"
fi

# Navigate to extension directory
cd "$EXT_DIR"

# Verify we have the required files
if [ ! -f "package.json" ] || [ ! -f "dist/extension.js" ]; then
    print_error "Required files not found in extension"
    cd "$SCRIPT_DIR"
    rm -rf "$WORK_DIR"
    exit 1
fi

# If version is still unknown, try to get it from package.json
if [ "$VERSION" = "unknown" ]; then
    VERSION=$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4)
    print_info "Version from package.json: $VERSION"
fi

# Backup original files
cp package.json package.json.backup
cp dist/extension.js dist/extension.js.backup

# Perform modifications
modify_package_json
modify_extension_js
create_readme "$VERSION"

# Go back to original directory
cd "$SCRIPT_DIR"

# Check if vsce is installed
if ! command -v vsce &> /dev/null; then
    print_info "Installing vsce..."
    npm install -g @vscode/vsce >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_warning "Failed to install vsce globally, trying locally..."
        cd "$EXT_DIR"
        npm install @vscode/vsce --no-save >/dev/null 2>&1
        cd "$SCRIPT_DIR"
    fi
fi

# Package the extension
print_info "Packaging modified extension..."
cd "$EXT_DIR"
VSIX_OUTPUT="$SCRIPT_DIR/$OUTPUT_DIR/claude-code-resume-${VERSION}.vsix"
if command -v vsce &> /dev/null; then
    vsce package --no-dependencies --no-git-tag-version --no-update-package-json -o "$VSIX_OUTPUT" 2>/dev/null
else
    # Try with npx
    npx vsce package --no-dependencies --no-git-tag-version --no-update-package-json -o "$VSIX_OUTPUT" 2>/dev/null
fi

if [ $? -ne 0 ]; then
    print_error "Failed to package extension"
    cd "$SCRIPT_DIR"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Go back and create install script
cd "$SCRIPT_DIR"
cd "$OUTPUT_DIR"
create_install_script "$VERSION"
cd ..

# Clean up
rm -rf "$WORK_DIR"

# Final output
echo ""
print_success "Extension created successfully!"
echo ""
echo "📦 Output files in ${BLUE}$OUTPUT_DIR/${NC}:"
echo "   • claude-code-resume-${VERSION}.vsix (the extension)"
echo "   • install.sh (installation helper)"
echo ""
echo "📥 To install:"
echo "   ${BLUE}cd $OUTPUT_DIR && ./install.sh${NC}"
echo ""
echo "Or manually:"
echo "   ${BLUE}code --install-extension $OUTPUT_DIR/claude-code-resume-${VERSION}.vsix${NC}"
echo "   ${BLUE}cursor --install-extension $OUTPUT_DIR/claude-code-resume-${VERSION}.vsix${NC}"
echo ""