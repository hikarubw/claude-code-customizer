#!/bin/bash

# Claude Code Interactive Extension Generator - GLOBAL SCOPE VERSION
# This version properly makes the dialog function available globally

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR="$SCRIPT_DIR/temp_extension_work"
OUTPUT_DIR="$SCRIPT_DIR/claude-code-interactive-output"
NPM_PACKAGE="@anthropic-ai/claude-code"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Clean up
rm -rf "$WORK_DIR" "$OUTPUT_DIR"
mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

print_info "Fetching latest version..."
VERSION=$(npm view "$NPM_PACKAGE" version 2>/dev/null)
print_success "Latest version: $VERSION"

print_info "Downloading package..."
cd "$WORK_DIR"
npm pack "$NPM_PACKAGE@$VERSION" >/dev/null 2>&1
TARBALL=$(ls anthropic-ai-claude-code-*.tgz)
tar -xzf "$TARBALL"

print_info "Extracting VSIX..."
unzip -q "package/vendor/claude-code.vsix" -d vsix

cd vsix/extension

# Backup original files
cp package.json package.json.backup
cp dist/extension.js dist/extension.js.backup

# Modify package.json with proper IDs
print_info "Modifying package.json..."
python3 -c "
import json

with open('package.json', 'r') as f:
    data = json.load(f)

# Change extension identity
data['name'] = 'claude-code-interactive'
data['displayName'] = 'Claude Code Interactive'
data['publisher'] = 'claude-code-community'
data['description'] = 'Claude Code with interactive startup options'

# Update ALL command references
def update_commands(obj):
    if isinstance(obj, dict):
        for key, value in obj.items():
            if isinstance(value, str) and 'claude-code.' in value:
                obj[key] = value.replace('claude-code.', 'claude-code-interactive.')
            elif isinstance(value, (dict, list)):
                update_commands(value)
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            if isinstance(item, str) and 'claude-code.' in item:
                obj[i] = item.replace('claude-code.', 'claude-code-interactive.')
            elif isinstance(item, (dict, list)):
                update_commands(item)

update_commands(data)

# Add configuration
if 'contributes' not in data:
    data['contributes'] = {}

data['contributes']['configuration'] = {
    'title': 'Claude Code Interactive',
    'properties': {
        'claude-code-interactive.startupOptions': {
            'type': 'array',
            'default': [],
            'description': 'Custom startup options to show in the picker dialog',
            'items': {
                'type': 'object',
                'properties': {
                    'label': {
                        'type': 'string',
                        'description': 'The label shown in the picker'
                    },
                    'description': {
                        'type': 'string',
                        'description': 'Optional description shown in the picker'
                    },
                    'value': {
                        'type': 'string',
                        'description': 'The CLI options to use (e.g., \"--resume\", \"--model opus\")'
                    }
                },
                'required': ['label', 'value']
            }
        },
        'claude-code-interactive.showDefaultOptions': {
            'type': 'boolean',
            'default': True,
            'description': 'Show the default options (Resume, Continue, Skip permissions) in the picker'
        },
        'claude-code-interactive.defaultOption': {
            'type': 'string',
            'default': '',
            'description': 'Default CLI option to use if dialog is cancelled (empty for fresh start)'
        },
        'claude-code-interactive.skipDialog': {
            'type': 'boolean',
            'default': False,
            'description': 'Skip the dialog and use the default option directly'
        }
    }
}

# Remove prepublish script
if 'scripts' in data and 'vscode:prepublish' in data['scripts']:
    del data['scripts']['vscode:prepublish']

with open('package.json', 'w') as f:
    json.dump(data, f, indent=2)
"

# Modify extension.js
print_info "Modifying extension.js..."

# Find vscode variable
VSCODE_VAR=$(grep -o '[A-Za-z0-9_]*=.*require("vscode")' dist/extension.js | head -1 | cut -d'=' -f1 || echo "vscode")
print_info "Found vscode variable: $VSCODE_VAR"

# Create modified version
cp dist/extension.js dist/extension.js.tmp

# 1. Update ALL command/context references first
print_info "Updating all command and context references..."
sed -i '' 's/"claude-code\./"claude-code-interactive./g' dist/extension.js.tmp
sed -i '' "s/'claude-code\./'claude-code-interactive./g" dist/extension.js.tmp
sed -i '' 's/`claude-code\./`claude-code-interactive./g' dist/extension.js.tmp

# 2. Create a wrapper around the entire extension code
print_info "Creating global dialog function..."
cat > wrapper_start.js << 'EOF'
(function() {
// Global dialog function accessible throughout the extension
const selectClaudeOptions = async function() {
    try {
        const vscode = require("vscode");
        const config = vscode.workspace.getConfiguration('claude-code-interactive');
        const skipDialog = config.get('skipDialog', false);
        const defaultOption = config.get('defaultOption', '');
        
        if (skipDialog) {
            return defaultOption;
        }
        
        const customOptions = config.get('startupOptions', []);
        const showDefaultOptions = config.get('showDefaultOptions', true);
        
        const defaultOptions = [
            { label: 'Start Fresh', description: 'Start a new Claude conversation', value: '' },
            { label: 'Resume Last Session', description: 'Continue your previous conversation', value: ' --resume' },
            { label: 'Continue in Directory', description: 'Load the most recent conversation in this directory', value: ' --continue' },
            { label: 'Skip Permissions', description: 'Skip all permission prompts - use with caution', value: ' --dangerously-skip-permissions' },
            { label: 'Custom...', description: 'Enter your own Claude CLI options', value: 'custom' }
        ];
        
        let options = [];
        
        if (customOptions && customOptions.length > 0) {
            options = options.concat(customOptions.map(opt => ({
                label: opt.label,
                description: opt.description || '',
                value: opt.value
            })));
            
            if (showDefaultOptions && options.length > 0) {
                options.push({ label: '', kind: vscode.QuickPickItemKind.Separator });
            }
        }
        
        if (showDefaultOptions) {
            options = options.concat(defaultOptions);
        }
        
        if (options.length === 0) {
            options = defaultOptions;
        }
        
        const selected = await vscode.window.showQuickPick(options, {
            placeHolder: 'How would you like to start Claude?',
            title: 'Claude Code Startup Options'
        });
        
        if (!selected) {
            return defaultOption;
        }
        
        if (selected.value === 'custom') {
            const customOptions = await vscode.window.showInputBox({
                prompt: 'Enter custom Claude CLI options',
                placeHolder: 'e.g., --model opus --resume',
                title: 'Claude Code - Custom Options'
            });
            
            return customOptions || defaultOption;
        }
        
        return selected.value;
    } catch (error) {
        console.error('Error in selectClaudeOptions:', error);
        return '';
    }
};

// Original extension code follows
EOF

cat > wrapper_end.js << 'EOF'

})();
EOF

# Wrap the entire extension
cat wrapper_start.js dist/extension.js.tmp wrapper_end.js > dist/extension.js.tmp2
mv dist/extension.js.tmp2 dist/extension.js.tmp

# 3. Now modify the command execution points
print_info "Modifying command execution..."

# First make setTimeout callbacks async
sed -i '' 's/setTimeout(()=>{/setTimeout(async()=>{/g' dist/extension.js.tmp

# Then add dialog to command execution - without any parameters
sed -i '' 's/executeCommand("claude")/executeCommand("claude"+(await selectClaudeOptions()||""))/g' dist/extension.js.tmp
sed -i '' 's/sendText("claude")/sendText("claude"+(await selectClaudeOptions()||""))/g' dist/extension.js.tmp

# Move modified file back
mv dist/extension.js.tmp dist/extension.js

# Clean up
rm -f wrapper_start.js wrapper_end.js

# Create README
print_info "Creating README..."
cat > README.md << EOF
# Claude Code Interactive Extension

A modified version of Claude Code (v${VERSION}) with an interactive startup dialog.

## Features
- Interactive dialog when launching Claude
- Can be installed alongside the original Claude Code
- Customizable startup options

## Installation
1. Install the VSIX file through VSCode/Cursor
2. Restart your editor
3. Click the Claude icon or use Cmd+Shift+Escape

## Configuration

You can customize the options through VSCode settings:

### Settings
- \`claude-code-interactive.startupOptions\` - Array of custom startup options
- \`claude-code-interactive.showDefaultOptions\` - Show/hide the default options (default: true)
- \`claude-code-interactive.defaultOption\` - Default CLI option if dialog is cancelled
- \`claude-code-interactive.skipDialog\` - Skip the dialog and use default option directly

### Example Configuration
Add this to your VSCode settings.json:

\`\`\`json
{
  "claude-code-interactive.startupOptions": [
    {
      "label": "Work Mode",
      "description": "Resume with work directory context",
      "value": " --resume --add-dir ~/work"
    },
    {
      "label": "Opus Model",
      "description": "Start with Opus model",
      "value": " --model opus"
    }
  ],
  "claude-code-interactive.showDefaultOptions": true,
  "claude-code-interactive.defaultOption": "",
  "claude-code-interactive.skipDialog": false
}
\`\`\`

## Troubleshooting
If the dialog doesn't appear:
1. Make sure you've restarted VSCode after installation
2. Check the Developer Console for errors (Help > Toggle Developer Tools)
3. Try using the keyboard shortcut: Cmd+Shift+Escape
EOF

# Package the extension
cd "$SCRIPT_DIR"
print_info "Packaging extension..."
cd "$WORK_DIR/vsix/extension"

if command -v vsce &> /dev/null; then
    vsce package --skip-license --no-dependencies --no-yarn -o "$OUTPUT_DIR/claude-code-interactive-${VERSION}.vsix" 2>&1
else
    npx vsce package --skip-license --no-dependencies --no-yarn -o "$OUTPUT_DIR/claude-code-interactive-${VERSION}.vsix" 2>&1
fi

# Create install script
cd "$OUTPUT_DIR"
cat > install.sh << EOF
#!/bin/bash
VSIX_FILE="claude-code-interactive-${VERSION}.vsix"

if [ ! -f "\$VSIX_FILE" ]; then
    echo "Error: \$VSIX_FILE not found"
    exit 1
fi

echo "Installing Claude Code Interactive Extension..."

if command -v cursor &> /dev/null; then
    cursor --install-extension "\$VSIX_FILE"
elif command -v code &> /dev/null; then
    code --install-extension "\$VSIX_FILE"
else
    echo "Error: Neither cursor nor code command found"
    exit 1
fi

echo "Installation complete! Please restart your editor."
echo ""
echo "The dialog should appear when you:"
echo "1. Click the Claude icon in the editor tab"
echo "2. Use the keyboard shortcut Cmd+Shift+Escape"
echo ""
echo "If the dialog doesn't appear, check Developer Tools Console for errors."
EOF
chmod +x install.sh

# Clean up
cd "$SCRIPT_DIR"
rm -rf "$WORK_DIR"

print_success "Extension created successfully!"
echo ""
echo "📦 Output: $OUTPUT_DIR/claude-code-interactive-${VERSION}.vsix"
echo ""
echo "To install:"
echo "  cd $OUTPUT_DIR && ./install.sh"
echo ""
echo "🎯 The dialog will appear when you click the Claude button!"