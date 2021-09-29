@ECHO OFF
CD /D "%~dp0.."

IF NOT EXIST local  MD local

lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --handler=tests/quickTestHandler.lua tests/quickTest.lua2p
REM lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --handler=tests/quickTestHandler.lua --outputpaths tests/quickTest.lua2p local/quickTest.output.lua

IF %ERRORLEVEL% EQU 0  lua -e"io.stdout:setvbuf'no'" -e"io.stderr:setvbuf'no'" tests/quickTest.lua
