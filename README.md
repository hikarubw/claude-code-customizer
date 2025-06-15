# Claude Code Extension Customizer

Tools and scripts to customize the official Claude Code VSCode extension to automatically resume your last session.

## 📑 Table of Contents
- [Purpose](#-purpose)
- [Quick Start](#-quick-start)
- [What's Included](#-whats-in-this-repository)
- [How It Works](#-how-it-works)
- [Usage Examples](#-usage-examples)
- [Requirements](#-requirements)
- [Creating Custom Extensions](#-creating-your-own-customizations)
- [License](#️-license)
- [Contributing](#-contributing)

## 🎯 Purpose

This repository provides tools to modify the Claude Code extension to run `claude --resume` instead of `claude`, allowing you to:
- Continue from your last conversation
- Maintain context between sessions
- Work more efficiently with Claude Code

## 🚀 Quick Start

### Option 1: Create a Custom Extension
```bash
# Download and customize the latest version
./create-claude-resume.sh

# Install the generated extension
cd claude-code-resume-output
./install.sh
```


## 📦 What's in This Repository

### Scripts
- **`create-claude-resume.sh`** - Main script to create customized extensions

### Documentation
- **[Script Usage Guide](docs/SCRIPTS_README.md)** - Detailed guide for using the scripts
- **[Customization Guide](docs/CUSTOMIZATION_GUIDE.md)** - Technical details about the modifications
- **[Extension Analysis](docs/EXTENSION_ANALYSIS.md)** - Deep dive into the extension architecture
- **[Examples](docs/EXAMPLES.md)** - Various customization examples

### Examples & Reference
- **`examples/resume-extension/`** - Example of a customized extension
- **`reference/`** - Original extension code for comparison

## 🔧 How It Works

The scripts modify the Claude Code extension by:
1. Changing `executeCommand("claude")` → `executeCommand("claude --resume")`
2. Changing `sendText("claude")` → `sendText("claude --resume"`
3. Updating the extension ID and name to avoid conflicts

## 📋 Usage Examples

### Create from Latest Version
```bash
./create-claude-resume.sh
```

### Create from Specific Version
```bash
./create-claude-resume.sh -v 1.0.30
```

### Create from Local VSIX File
```bash
./create-claude-resume.sh ~/Downloads/claude-code-1.0.30.vsix
```


## 🛠 Requirements

- macOS or Linux (Windows users can use WSL)
- Node.js and npm
- VS Code or Cursor
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

## 📝 Creating Your Own Customizations

The scripts in this repository serve as examples. You can modify them to:
- Change different command parameters
- Add new functionality
- Create variations for different workflows

See [Customization Guide](docs/CUSTOMIZATION_GUIDE.md) for technical details.

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Important:** The Claude Code extension itself is property of Anthropic, PBC. This repository only provides tools to modify the extension for personal use.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your own customizations

## ⚠️ Disclaimer

This is an unofficial tool. Use at your own risk. Always backup your extensions before modifying them.