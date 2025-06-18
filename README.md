# Claude Code Interactive Extension

Create an interactive version of the Claude Code VSCode extension with customizable startup options.

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

This repository provides a tool to create an interactive version of the Claude Code extension that allows you to:
- Choose startup options interactively with a dialog picker
- Configure custom options via VSCode settings
- Resume your last conversation with `claude --resume`
- Continue from your last conversation in the current directory with `claude --continue`
- Skip permissions for faster startup
- Use any custom CLI options

## 🚀 Quick Start
```bash
# Download and customize with settings-configurable dialog
./create-claude-interactive.sh

# Install the generated extension
cd claude-code-interactive-output
./install.sh
```


## 📦 What's in This Repository

### Script
- **`create-claude-interactive.sh`** - Creates an interactive extension with configurable options via VSCode settings

### Documentation
- **[Script Usage Guide](docs/SCRIPTS_README.md)** - Detailed guide for using the scripts
- **[Customization Guide](docs/CUSTOMIZATION_GUIDE.md)** - Technical details about the modifications
- **[Extension Analysis](docs/EXTENSION_ANALYSIS.md)** - Deep dive into the extension architecture
- **[Examples](docs/EXAMPLES.md)** - Various customization examples

### Reference
- **`reference/`** - Original extension code for comparison (if available)

## 🔧 How It Works

The `create-claude-interactive.sh` script modifies the Claude Code extension by:
1. Injecting a dialog picker function that shows startup options
2. Replacing command execution with user-selected options
3. Supporting options like `--resume`, `--continue`, `--dangerously-skip-permissions`, or custom input
4. Adding VSCode settings configuration for custom options
5. Supporting user-defined startup options via settings.json
6. Options to remember last choice and set default behavior
7. Updating the extension ID and name to avoid conflicts

## 📋 Usage Examples
```bash
# Create from latest version with settings support
./create-claude-interactive.sh

# Create from specific version
./create-claude-interactive.sh -v 1.0.24

# Create from local VSIX file
./create-claude-interactive.sh ~/Downloads/claude-code.vsix

# Configure in VSCode settings.json:
{
  "claude-code-interactive.startupOptions": [
    {
      "label": "Work Mode",
      "description": "Resume with work directory",
      "value": "--resume --add-dir ~/work"
    },
    {
      "label": "Personal Project",
      "description": "Continue in current directory with Opus",
      "value": "--continue --model opus"
    }
  ],
  "claude-code-interactive.showDefaultOptions": true,
  "claude-code-interactive.defaultOption": "--continue",
  "claude-code-interactive.rememberLastChoice": true
}
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