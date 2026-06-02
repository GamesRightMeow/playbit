# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- #23: Added automated test framework. See [Contributing doc](/docs/contributing.md) for details on use.
- Added automated tests for implemented methods/systems.
- #62: Implemented `tilemap:getSize()`
- #62: Implemented `tilemap:getPixelSize()`.
- #62: Implemented `tilemap:draw()`'s x and y parameters.

### Fixed
- Fixed `playdate.graphics.getFont()` not returning null when not set.
- Fixed `playdate.graphics.getTextSize()` calling wrong method on font instance.
- #62: Fixed tilemap zero value tile indices not being treated as `nil`.
- #62: Fixed `tilemap:setTiles()` not setting tilemap height.
- #62: Fixed `tilemap:getTileAtPosition()` returning invalid tile.
- #62: Fixed `tilemap:getTileAtPosition()` not returning `nil` when x or y are out of bounds.