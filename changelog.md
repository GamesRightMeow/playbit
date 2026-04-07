# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- #23: Added automated test framework. See [Contributing doc](/docs/contributing.md) for details on use.
- Added automated tests for implemented methods/systems.

### Fixed
- Fixed `playdate.graphics.getFont()` not returning null when not set.
- Fixed `playdate.graphics.getTextSize()` calling wrong method on font instance.