# Getting started

## Prerequisite knowledge
This documentation assumes you're familiar with the following:

* [Playdate Lua API](https://sdk.play.date/Inside%20Playdate.html)
* [Love2D](https://love2d.org/)
* [Lua](https://lua.org)
* [Github](https://docs.github.com/)
* [git](https://git-scm.com/)

## Dependencies
### Required
Install the following dependencies:
* [Latest Playdate SDK](https://play.date/dev/)
* [Lua 5.3+](http://luabinaries.sourceforge.net/)
  * NOTE: Playbit runs Lua via `lua` at the command line. Depending on your platform and installation method, you may need to rename the binary e.g. rename `lua54.exe` to `lua.exe`.
* [Love2D 11.x](https://love2d.org/)

Add `love.exe` and `lua.exe` to your `PATH` variable
* [Windows instructions](https://www.howtogeek.com/787217/how-to-edit-environment-variables-on-windows-10-or-11/)
  * Check your installation with `where love` and `where lua` in a Command Prompt.
* [macOS and Linux instructions](https://www.howtogeek.com/658904/how-to-add-a-directory-to-your-path-in-linux/#how-to-permanently-add-something-to-path)
  * Check your installation with `which love` and `which lua` from the command line.

### Optional
The following are not required for _general_ use of Playbit, but required if you use the related features:
* [Aseprite](https://www.aseprite.org/) for .ASEPRITE export during build-time. For more information, see [Aseprite file processor](file-processors.md#aseprite).
* [FFmpeg](https://ffmpeg.org/) for automatic conversion of audio to the Playdate supported format at build-time. For more information, see [Wave file processor](file-processors.md#wave).

## Setup your environment
1. Add the `PLAYDATE_SDK_PATH` to your environment variables. For more information, see Panic's documentation on how to [set the Playdate SDK variable](https://sdk.play.date/Inside%20Playdate.html#_set_playdate_sdk_path_environment_variable).
2. Add Lua to your `Path` environment variable.
3. Add Love2d to your `Path` environment variable.

If you're using any [optional dependencies](#optional) you'll also need to add them to your `Path` environment variable, unless you specify the path to the executable when setting up [file processors](file-processors.md).

## Next steps
1. [Read about Playbit's limitations](limitations.md)
2. [Learn about core concepts](core-concepts.md)
3. [Add Playbit to your project](add-playbit.md)
4. [Add metadata to your fonts](modify-fonts.md)
5. [Configure build scripts](build-scripts.md)
6. [Build & run your project](build-and-run.md)

## Get help
If you find a bug, missing documentation, or have trouble setting up playbit, [open an issue](https://github.com/GamesRightMeow/playbit/issues).