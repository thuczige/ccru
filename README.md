# ccru – Code Changed Rules (RuboCop + ES6 Syntax + ERB Checker)

RuboCop on diff for Ruby files + ES6 syntax checker for JavaScript files + ERB template support: lint only what's new/changed

## Install

```ruby
group :development, :test
  gem 'ccru', require: false
end
```

## Usage

### Basic Usage

```bash
# Commit your code
git add some_files
git commit -m "commit message"

# Check changed Ruby, JavaScript, and ERB files in git diff (compared to merge-base)
bundle exec ccru

# Check specific files (No need commit)
bundle exec ccru path/to/file.rb path/to/script.js path/to/template.erb
```

### Environment Variables

```bash
# Set default base branch for git diff comparison
export CCRU_BASE=develop
bundle exec ccru
```

## Supported File Types

- **Ruby files**: `.rb` - Checked with RuboCop
- **JavaScript files**: `.js` - Checked for ES6 syntax violations + code quality
- **ERB templates**: `.erb` - Checked with custom ERB linter for conventions

## ERB Template Support

### Ruby ERB Templates (`.erb`)
- Automatically checks ERB conventions and formatting
- Validates proper spacing: `<% code %>` instead of `<%code%>`
- Checks comment format: `<%# comment %>` instead of `<% # comment %>`
- Ensures proper output spacing: `<%= code %>` instead of `<%=code%>`
- Maps violations back to original ERB line numbers

## JavaScript ES6 Violations Checked

The following ES6+ syntax patterns are detected and flagged as errors:

- **Arrow functions**: `=>` syntax
- **const/let**: `const` and `let` declarations
- **Template literals**: `` `string ${variable}` ``
- **Destructuring**: `{ prop } = obj` assignments
- **Spread operator**: `...` syntax
- **ES6 classes**: `class` declarations
- **ES6 modules**: `import`/`export` statements
- **Default parameters**: `function(param = value)`
- **Rest parameters**: `function(...args)`

## JavaScript Code Quality Rules

### Code Style & Formatting
- **Trailing whitespace**: Detects spaces at end of lines
- **Missing final newline**: Ensures files end with newline
- **Line length**: Maximum line length checking (120 characters)

### Best Practices
- **Console statements**: Warns about `console.log`, `console.debug`, etc.
- **Eval usage**: Errors on dangerous `eval()` calls
- **With statement**: Errors on deprecated `with` statements
- **Document write**: Warns about `document.write()` usage

### Potential Bugs
- **Loose equality**: Warns about `==` vs `===` usage (allows `== null` and `== undefined`)
- **Loose inequality**: Warns about `!=` vs `!==` usage
- **Unused variables**: Detects potentially unused variable declarations
- **Missing semicolons**: Identifies missing semicolons (with smart detection)
- **Inline comments**: Warns about inline comments at end of code lines

### Performance Issues
- **innerHTML usage**: Warns about potential XSS vulnerabilities
- **Global variables**: Warns about global scope pollution

## License

This project is licensed under the MIT License.
