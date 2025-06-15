# Example Output - Claude Code Resume Extension

This directory shows what the output looks like after running the customization script. This is an example of a modified Claude Code extension that automatically resumes your last session.

## Structure

```
example-output/
├── README.md           # This file
├── package.json        # Modified extension manifest
├── dist/
│   └── extension.js    # Modified extension code
└── resources/
    ├── claude-logo.png # Extension icon
    └── claude-logo.svg # Extension icon (SVG)
```

## Key Modifications

1. **package.json**
   - Name changed from `claude-code` to `claude-code-resume`
   - All command IDs prefixed with `claude-code-resume.`
   - Display name shows "Claude Code Resume"

2. **extension.js**
   - `executeCommand("claude")` → `executeCommand("claude --resume")`
   - `sendText("claude")` → `sendText("claude --resume")`
   - Command IDs updated to match package.json

## Note

This is just an example. When you run the script, it will generate a fresh version based on the latest Claude Code extension.
EOF < /dev/null