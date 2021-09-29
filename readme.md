# VS Code extensions
* [Local Lua Debugger](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode) by Tom Blind
* [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) by sumneko
* [Love2D Support](https://marketplace.visualstudio.com/items?itemName=pixelbyte-studios.pixelbyte-love2d) by Pixelbyte Studios

# Debugger config
```
{
  "name": "Debug LOVE",
  "type": "lua-local",
  "request": "launch",
  "program":
  {
    "command": "lovec"
  },
  "args": 
  [
    "${workspaceFolder}"
  ],
  "scriptRoots": [
    "${workspaceFolder}"
  ]
}
```

# Building
* Lua files need to be parsed by [preprocess](http://luapreprocess.refreezed.com/docs/) before actually running
* Preprocess does not support the comment style, so comments are removed in the build step prior to preprocess.
* Preprocessors in comments fixes vscode linting issues since its not standard lua

## Love
1. `lua .\build-example.lua love`
1. `love _dist`

## Playdate
TODO: playdate build docs

# TODO Tree support
`"todo-tree.regex.regex": "$\\s*--\\s*($TAGS)",`