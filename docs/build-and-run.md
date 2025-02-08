# Build and run your project

## Visual Studio Code

The [Playbit template](https://github.com/GamesRightMeow/playbit-template) comes with pre-configured tasks for building and running your project which are accessible from [VSCode's command palette](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette):
- **love2d: build** - runs the Love2d build script.
- **love2d: run** - runs your project in Love2d.
- **love2d: build & run** - builds _and_ runs your project in Love2d.
- **playdate: build** - runs the Playdate build script.
- **playdate: compile** - compiles your project with `pdc` to create a `pdx`.
- **playdate: run** - runs your `pdx` in the Playdate simulator.
- **playdate: build & run** - builds, compiles, and runs your project in the Playdate Simulator.

You can add, remove, and modify these tasks in `.vscode/tasks.json`.

### Keyboard shortcuts

You can [bind tasks to keyboard shortcuts](https://code.visualstudio.com/docs/editor/tasks#_binding-keyboard-shortcuts-to-tasks) for faster access. For example, add the following to your [keybindings.json](https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization):

```json
// build and run love2d
{
  "key": "ctrl+f1",
  "command": "workbench.action.tasks.runTask",
  "args": "! love2d: build & run" // args need to match the task.label exactly
},
// build and run playdate
{
  "key": "ctrl+f2",
  "command": "workbench.action.tasks.runTask",
  "args": "! playdate: build & run"
},
// build and run both debug
{
  "key": "ctrl+f4",
  "command": "workbench.action.tasks.runTask",
  "args": "! all: debug"
}
```

<!-- TODO: when nova configs are added, mention them here -->
<!-- ## Nova -->

## Manually

You can manually build and run your project from the command line, or run these commands in another tool:

### Love2d

1. Build: `lua build-love2d.lua`.
1. Run: `love _love2d`.

### Playdate

1. Build: `lua build-playdate.lua`.
1. Compile: `pdc _pdx YourProjectName.pdx`.
1. Run: `PlaydateSimulator YourProjectName.pdx`.