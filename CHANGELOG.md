# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-08-29

### Added
- **JavaScript ES6 Syntax Checking**: New feature to detect ES6+ syntax violations in JavaScript files
- **Multi-language Support**: Now supports both Ruby (.rb) and JavaScript (.js) files
- **File Type Detection**: Automatic detection of file types and appropriate linter selection
- **ES6 Violation Rules**: Built-in detection for:
  - Arrow functions (`=>`)
  - const/let declarations
  - Template literals (`` `string ${var}` ``)
  - Destructuring assignments
  - Spread operator (`...`)
  - ES6 classes
  - ES6 modules (import/export)
  - Default parameters
  - Rest parameters
- **JavaScript Code Quality Rules**: Comprehensive code quality checking including:
  - **Code Style & Formatting**:
    - Trailing whitespace detection
    - Missing final newline detection
    - Line length checking (120 characters)
  - **Best Practices**:
    - Console statement warnings (console.log, console.debug, etc.)
    - Eval usage errors (security risk)
    - With statement errors (deprecated)
    - Document write warnings (performance/security)
  - **Potential Bug Detection**:
    - Loose equality warnings (== vs ===, allows == null/undefined)
    - Loose inequality warnings (!= vs !==)
    - Unused variable detection
    - Missing semicolon detection (with smart detection)
    - Inline comment warnings
  - **Performance & Security**:
    - innerHTML usage warnings (XSS risk)
    - Global variable pollution warnings
- **ERB Template Support**: Custom ERB linter for convention checking:
  - Proper spacing validation (`<% code %>` vs `<%code%>`)
  - Comment format validation (`<%# comment %>` vs `<% # comment %>`)
  - Output spacing validation (`<%= code %>` vs `<%=code%>`)
- **Enhanced CLI Options**: Support for RuboCop options via `--` separator
- **Improved Output Format**: Consistent violation reporting across all linters

### Changed
- **Architecture Refactor**: Restructured code to support multiple linters
- **Module Organization**: Clean separation of concerns with dedicated modules:
  - `LinterRunner`: Main orchestration module
  - `RuboCopRunner`: Ruby file processing
  - `JavaScriptLinterRunner`: JavaScript file processing
  - `ErbLinterRunner`: ERB template processing
- **Git Diff Enhancement**: Extended to detect and process multiple file types
- **Violation Formatting**: Unified output format for all linter types

### Technical Improvements
- **Modular Design**: Clean separation of concerns with dedicated modules
- **Extensible Architecture**: Easy to add support for new file types and linters
- **Backward Compatibility**: Existing Ruby-only functionality preserved
- **Performance**: Maintains the same fast git-diff-based approach
- **Error Handling**: Improved error handling and file reading safety

### New Command Line Options
- Support for passing RuboCop options: `bundle exec ccru -- --auto-correct`

### Notes
- Staged changes support is implemented in the code but not exposed via command line options
- Base branch can only be specified via environment variable `CCRU_BASE`

## [0.1.0] - 2024-12-19

### Added
- Initial release
- RuboCop integration for Ruby files
- Git diff-based change detection
- Line-level filtering for modified files
- Base branch specification via environment variable
- Basic file handling and offense printing
