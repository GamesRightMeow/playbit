# Automated tests

Playbit uses a bespoke system for running tests. This is primarily because a large portion of Playbit is recreating the visual output of the Playdate SDK, so most tests are screenshot tests which compare the output on Playdate vs Love2d/Playbit.

This is accomplished by first running tests in the Playdate Simulator and saving screenshots. These are considered the _expected_ results. Then tests are run in Love2d and also saving screenshots. These are considered the _actual_ results. Then these two sets of screenshots are compared for differences to determine wether each test passes or fails.

For areas of the SDK that are not visual, the test system also supports unit tests.

## Running tests

### Run tests with VS Code
The `tasks.json` contains a task called `! run tests`. Running this will automatically build and run the tests and output the results to the terminal in VS Code.

### Run tests manually
You can manually run tests by following the steps below. You can also use these as a reference to hook tests up to your own automated tooling.

1. Build the test project for Playdate by running `playdate-build-tests.lua`. This will create a `_tests_pdx` folder at the project root.
2. Build the test project for Love2d by running `love2d-build-tests.lua`. This will create a `_tests_love2d` folder at the project root.
3. Compile the `_tests_pdx` folder by using `pdc _tests_pdx _tests.pdx`
4. Run the compiled PDX in the Playdate Simulator using `PlaydateSimulator _tests.pdx` or by manually loading it into the simulator.
5. When the tests finish running on Playdate, the simulator will close and you should have screenshots in `tests/src/images/expected/` and test results in `<PLAYDATE_SDK>/Disk/Data/com.gamesrightmeow.playbit-tests/playdate_log.txt`.
6. Run the Love2d game using `love _tests_love2d`.
7. When the tests finish running in Love2d, the application will close and log test results to console.

## Adding Tests
The `tests/src` folder contains a Playbit project (aka the test project) that is runnable on both Playdate and Love2d. Deeper in this folder is the subfolder `tests/src/suites` which contains the actual test suites. New files added to this folder will automatically be run by the test system.

Tests are separated into suites to logically group tests e.g. all APIs in `Corelibs/graphics` are in the `playdate_graphics` suite.

Suites should be prefixed with either `playdate_` to indicate a Playdate API or `playbit_` to indicate an method/feature introduced by Playbit.

Tests should be written to follow the typical Arrange Act and Assert (AAA) pattern.

Use assertion methods in `pbassert`.

Test method names should generally includes what's being tested and the expected outcome.