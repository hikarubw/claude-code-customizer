# Customization Examples

This document shows various ways you can customize the Claude Code extension beyond just adding `--resume`.

## 📝 Basic Modifications

### 1. Always Resume Last Session (Default)
```bash
# This is what the main script does
executeCommand("claude --resume")
```

### 2. Always Start Fresh
```bash
# Force new session every time
executeCommand("claude --new")
```

### 3. Custom Model Selection
```bash
# Always use a specific model
executeCommand("claude --model claude-3-opus-20240229")
```

### 4. Multiple Parameters
```bash
# Combine multiple options
executeCommand("claude --resume --model claude-3-opus-20240229")
```

## 🛠 Advanced Modifications

### Creating Your Own Script

1. **Copy the base script:**
```bash
cp create-claude-resume.sh create-claude-custom.sh
```

2. **Modify the command in your new script:**
```bash
# Find this line:
sed -i '' 's/executeCommand("claude")/executeCommand("claude --resume")/g' dist/extension.js

# Change to your preference:
sed -i '' 's/executeCommand("claude")/executeCommand("claude --your-flags")/g' dist/extension.js
```

### Example: Create a "Claude Debug Mode" Extension

```bash
#!/bin/bash
# create-claude-debug.sh

# ... (copy most of the original script) ...

# In the modify_extension_js function:
modify_extension_js() {
    print_info "Modifying extension.js for debug mode..."
    
    # Add debug flag
    sed -i '' 's/executeCommand("claude")/executeCommand("claude --debug")/g' dist/extension.js
    sed -i '' 's/sendText("claude")/sendText("claude --debug")/g' dist/extension.js
    
    # Update command IDs
    sed -i '' 's/claude-code\./claude-code-debug./g' dist/extension.js
}

# Update package.json modifications too
modify_package_json() {
    # ... existing modifications ...
    
    # Change to debug-specific names
    sed -i '' 's/"name": "claude-code"/"name": "claude-code-debug"/' package.json
    sed -i '' 's/"displayName": "Claude Code"/"displayName": "Claude Code Debug"/' package.json
}
```

## 🎨 UI Customizations

### Change Extension Icon
1. Replace `resources/claude-logo.png` and `resources/claude-logo.svg` with your own icons
2. Keep the same filenames or update references in `package.json`

### Change Display Name
In `package.json`:
```json
"displayName": "Claude Code - Your Custom Version"
```

### Change Keyboard Shortcuts
In `package.json`, find the keybindings section:
```json
"keybindings": [
    {
        "command": "claude-code-resume.runClaude.keyboard",
        "key": "cmd+shift+c",  // Your custom shortcut
        "mac": "cmd+shift+c",
        "win": "ctrl+shift+c",
        "linux": "ctrl+shift+c"
    }
]
```

## 🔄 Workflow-Specific Extensions

### 1. Project-Specific Extension
Create different extensions for different project types:
- `claude-code-web` - For web development (could add `--context web`)
- `claude-code-data` - For data science (could add `--context data`)
- `claude-code-mobile` - For mobile development

### 2. Time-Based Behavior
Modify the script to check time and adjust behavior:
```javascript
// In extension.js modification
const hour = new Date().getHours();
const command = hour < 12 ? "claude --new" : "claude --resume";
executeCommand(command);
```

## 💡 Tips

1. **Test First**: Always test your modifications on a copy first
2. **Keep Backups**: The scripts create backups, but make your own too
3. **Version Control**: Track your custom scripts in git
4. **Document**: Add comments explaining your customizations
5. **Share**: If you create something useful, consider sharing it!

## 🚀 Advanced Ideas

- Add environment variable support
- Create a configuration file reader
- Add conditional logic based on workspace
- Integrate with other tools
- Create a GUI for customization

Remember: The extension architecture is quite flexible. These examples just scratch the surface of what's possible!