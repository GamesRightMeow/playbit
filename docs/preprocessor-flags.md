# Preprocessor flags

To learn more about preprocessor flags, see [Core Concepts](core-concepts.md#preprocessor-flags).

## PLAYDATE

Evaluates to `true` when `platform` in your build script is set to `playdate`. Use this to write metaprogram statements for code that should only be included in Playdate builds.

## LOVE2D

Evaluates to `true` when `platform` in your build script is set to `love2d`. Use this to write metaprogram statements for code that should only be included in Love2d builds.

## DEBUG

Evaluates to `true` when `debug` in your build script is set to `true`. Use this to write metaprogram statements for code that should only included in debug builds. Useful for removing debugging or development tools from release builds.

## PROFILER

Evaluates to `true` when `profiler` in your build script is set to `true`. This is primarily used to conditionally include/exclude macros in [playbit.perf](../playbit/perf.lua) but you may use this to conditionally include/exclude your own code.

## Add your own
Use the `env` property in your build scripts to define custom preprocessor flags. 

For more information, refer to the [env property](build-scripts.md#env).