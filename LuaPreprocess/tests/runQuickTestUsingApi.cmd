@ECHO OFF
CD /D "%~dp0.."

IF NOT EXIST local  MD local

lua tests/runQuickTestUsingApi.lua

IF %ERRORLEVEL% EQU 0  lua -e"io.stdout:setvbuf'no'" -e"io.stderr:setvbuf'no'" tests/quickTest.lua
