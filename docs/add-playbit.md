# Adding Playbit to your project

## For new projects
For new projects it's recommended that you create a repo from the [Playbit project template](https://github.com/GamesRightMeow/playbit-template).

## For existing projects

This section will guide you through adding Playbit to an existing project. You can also follow this section if you want to manually add Playbit to a new project.

1. Add Playbit to your project by adding it as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (recommended!) or copying it manually into your project folder.
   - If you copy Playbit manually, make sure you also copy Playbit's submodules.
2. In your `main.lua` file, add `@@"playbit/header.lua"` to the top of the file.
   - Learn more about the Playbit header in [Core concepts](core-concepts.md#playbit-header).

