# Claude Code Extension Customization Guide

## Overview
This guide provides technical details on how to customize the Claude Code VSCode extension to modify its behavior, such as changing command parameters or adding new functionality.

## Understanding the Extension Structure

The Claude Code extension consists of:
- **package.json** - Extension manifest and configuration
- **dist/extension.js** - Compiled JavaScript code
- **resources/** - Icons and assets

## Key Customization Points

## Files Modified
- `extension.js` - The main extension JavaScript file

## Changes Made

### 1. Command Execution via Shell Integration
Changed:
```javascript
a.shellIntegration.executeCommand("claude")
```
To:
```javascript
a.shellIntegration.executeCommand("claude --resume")
```

### 2. Fallback Command Execution
Changed:
```javascript
i.sendText("claude")
```
To:
```javascript
i.sendText("claude --resume")
```

## Installation Instructions

### Option 1: Direct File Replacement (Easiest)

1. **Locate your Claude Code extension directory:**
   - For VSCode: `~/.vscode/extensions/anthropic.claude-code-{version}/`
   - For Cursor: `~/.cursor/extensions/anthropic.claude-code-{version}/`

2. **Backup the original extension.js:**
   ```bash
   cp dist/extension.js dist/extension.js.backup
   ```

3. **Replace with the modified version:**
   ```bash
   cp /path/to/extension-modified.js dist/extension.js
   ```

4. **Restart VSCode/Cursor**

### Option 2: Manual Modification

1. **Open the extension.js file:**
   ```bash
   # For Cursor
   cd ~/.cursor/extensions/anthropic.claude-code-*/dist/
   # Make a backup
   cp extension.js extension.js.backup
   ```

2. **Edit the file and search for these two patterns:**
   - Search for: `executeCommand("claude")`
   - Replace with: `executeCommand("claude --resume")`
   
   - Search for: `sendText("claude")`
   - Replace with: `sendText("claude --resume")`

3. **Save the file and restart your IDE**

### Option 3: Using sed (Command Line)

```bash
# Navigate to extension directory
cd ~/.cursor/extensions/anthropic.claude-code-*/dist/

# Backup original
cp extension.js extension.js.backup

# Apply modifications
sed -i '' 's/executeCommand("claude")/executeCommand("claude --resume")/g' extension.js
sed -i '' 's/sendText("claude")/sendText("claude --resume")/g' extension.js
```

## Verification

After applying the changes:
1. Open VSCode/Cursor
2. Press `Cmd+Escape` (Mac) or `Ctrl+Escape` (Windows/Linux)
3. You should see Claude Code launching with the resume option

## Reverting Changes

To revert to the original behavior:
```bash
cd ~/.cursor/extensions/anthropic.claude-code-*/dist/
cp extension.js.backup extension.js
```

## Important Notes

1. **Updates**: When the Claude Code extension updates, you'll need to reapply these changes
2. **Version Compatibility**: These modifications were tested with version 1.0.24
3. **Alternative Approach**: You could also create a shell alias or wrapper script instead of modifying the extension

## Advanced Customization Ideas

You could further modify the extension to:
- Add a setting to toggle between `claude` and `claude --resume`
- Create separate commands for new session vs resume
- Add custom parameters based on context

## Troubleshooting

If the extension doesn't work after modification:
1. Check for syntax errors in the modified file
2. Restore from backup
3. Reinstall the extension if needed
4. Check the VSCode Developer Console for error messages (Help > Toggle Developer Tools)