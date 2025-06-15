# Claude Code Resume Extension Script

A unified script to create resume versions of Claude Code extensions from any source.

## 🚀 Overview

The `create-claude-resume.sh` script can:
- Download and convert the latest Claude Code extension from npm
- Download and convert a specific version from npm
- Convert a locally downloaded VSIX file
- All in one convenient tool!

## 📋 Usage

### Basic Usage

```bash
# Download and convert latest version
./create-claude-resume.sh

# Download and convert specific version
./create-claude-resume.sh -v 1.0.25

# Convert local VSIX file
./create-claude-resume.sh ~/Downloads/claude-code-1.0.26.vsix
```

### Advanced Options

```bash
# Specify custom output directory
./create-claude-resume.sh -o my-output-dir

# Show help
./create-claude-resume.sh -h
```

### Command Line Options

- `-v, --version <version>` - Download specific version from npm
- `-l, --latest` - Download latest version (default if no file specified)
- `-o, --output <dir>` - Custom output directory (default: claude-code-resume-output)
- `-h, --help` - Show help message

## 🎯 Examples

### Example 1: Get Latest Version
```bash
$ ./create-claude-resume.sh
Claude Code Resume Extension Generator
=====================================

ℹ Will download latest version from npm
ℹ Fetching latest version information...
✓ Latest version: 1.0.24
ℹ Downloading @anthropic-ai/claude-code@1.0.24...
✓ Downloaded: anthropic-ai-claude-code-1.0.24.tgz
...
✓ Extension created successfully!

📦 Output files in claude-code-resume-output/:
   • claude-code-resume-1.0.24.vsix (the extension)
   • install.sh (installation helper)
```

### Example 2: Convert Local File
```bash
$ ./create-claude-resume.sh ~/Downloads/claude-code-1.0.30.vsix
Claude Code Resume Extension Generator
=====================================

ℹ Using local VSIX file: /Users/you/Downloads/claude-code-1.0.30.vsix
ℹ Detected version: 1.0.30
...
✓ Extension created successfully!
```

### Example 3: Get Specific Version
```bash
$ ./create-claude-resume.sh -v 1.0.20
Claude Code Resume Extension Generator
=====================================

ℹ Will download version: 1.0.20
...
```

## 📦 Output

The script creates an output directory containing:
```
claude-code-resume-output/
├── claude-code-resume-X.X.XX.vsix  # The modified extension
└── install.sh                       # Installation helper script
```

## 🔧 What the Script Does

1. **Accepts Input** from either npm or local file
2. **Extracts** the original Claude Code extension
3. **Modifies** the code:
   - Changes `executeCommand("claude")` → `executeCommand("claude --resume")`
   - Changes `sendText("claude")` → `sendText("claude --resume")`
4. **Updates** the extension identity:
   - Name: `claude-code` → `claude-code-resume`
   - Display Name: `Claude Code` → `Claude Code Resume`
   - All command IDs: `claude-code.*` → `claude-code-resume.*`
5. **Packages** everything as a new VSIX
6. **Creates** an installation helper script
7. **Cleans up** all temporary files

## 🏃 Quick Start for Updates

When Anthropic releases a new Claude Code version:

```bash
# Just run the script - it gets the latest automatically
./create-claude-resume.sh
cd claude-code-resume-output
./install.sh
```

## ⚙️ Requirements

- **bash** shell (macOS/Linux)
- **npm** (for downloading from registry)
- **unzip** command
- **sed** command
- **vsce** (auto-installed if missing)

## 🐛 Troubleshooting

### "Could not fetch version information"
- Check internet connection
- Verify npm is installed: `npm --version`
- Try specifying a version: `./create-claude-resume.sh -v 1.0.24`

### "File not found" for local VSIX
- Check the file path is correct
- Ensure the file has .vsix extension
- Use absolute path if relative path doesn't work

### sed errors on Linux
The script uses macOS sed syntax. For Linux, modify the script:
- Change `sed -i ''` to `sed -i`

### Extension doesn't work after installation
- Ensure Claude Code CLI is installed: `npm install -g @anthropic-ai/claude-code`
- Restart your IDE
- Check if original extension is conflicting (disable it)

## 🎨 Features

- **Color-coded output** for better readability
- **Automatic version detection** from filenames
- **Smart cleanup** of temporary files
- **Error handling** with helpful messages
- **Progress indicators** throughout the process

## 📝 Notes

- Works with compiled extension files (no source compilation needed)
- Original functionality is preserved
- Both original and resume versions can coexist
- The script is version-agnostic and should work with future updates