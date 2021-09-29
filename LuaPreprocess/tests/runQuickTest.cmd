@ECHO OFF
CD /D "%~dp0.."

IF NOT EXIST local  MD local

lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --data="Hello, world!" tests/quickTest.lua2p
REM lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --data="Hello, world!" tests/quickTest.lua2p --backtickstrings
REM lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --data="Hello, world!" tests/quickTest.lua2p --linenumbers

REM lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --data="Hello, world!" --outputpaths tests/quickTest.lua2p local/quickTest.output.lua
REM lua ./preprocess-cl.lua --debug --saveinfo=local/info.lua --data="Hello, world!" --outputpaths tests/quickTest.lua2p local/quickTest.output.lua --linenumbers

IF %ERRORLEVEL% EQU 0  lua -e"io.stdout:setvbuf'no'" -e"io.stderr:setvbuf'no'" tests/quickTest.lua
