# frozen_string_literal: true

require_relative "usual_linter"

module Ccru
  # JavaScript linter that checks for ES6+ syntax violations and basic code quality
  class JavaScriptLinter
    include UsualLinter

    def initialize
      @offenses = []
    end

    DEFAULT_PARAMS_PATTERN = Regexp.new(
      [
        # function f(a = 1) {}
        '(?:\b(?:async\s+)?function\b[^(]*\([^)]*=[^)]*\))',
        # (a = 1) => ...
        '(?:\b(?:async\s*)?\([^)]*=[^)]*\)\s*=>)',
        # method m(a = 1) { ... }
        '(?:(?:^|\{|;)\s*(?:async\s+)?(?:get|set\s+)?' \
        '(?!if\b|for\b|while\b|switch\b|catch\b)' \
        '[A-Za-z_$][\w$]*\s*\([^)]*=[^)]*\)\s*\{)'
      ].join("|"),
      Regexp::MULTILINE
    )

    # ES6+ syntax violations
    ES6_VIOLATIONS = {
      arrow_functions: {
        pattern: /=>/,
        message: "Arrow functions (ES6) are not allowed. Use function() syntax instead.",
        cop_name: "ArrowFunctions",
        severity: "error"
      },
      const_let: {
        pattern: /\b(const|let)\b/,
        message: "const/let (ES6) are not allowed. Use var instead.",
        cop_name: "ConstLet",
        severity: "error"
      },
      template_literals: {
        pattern: /`[^`]*\$\{[^}]*\}[^`]*`/,
        message: "Template literals (ES6) are not allowed. Use string concatenation instead.",
        cop_name: "TemplateLiterals",
        severity: "error"
      },
      destructuring: {
        pattern: /\{[^}]*\s*=\s*[^}]*\}/,
        message: "Destructuring assignment (ES6) is not allowed.",
        cop_name: "Destructuring",
        severity: "error"
      },
      spread_operator: {
        pattern: /\.\.\./,
        message: "Spread operator (ES6) is not allowed.",
        cop_name: "SpreadOperator",
        severity: "error"
      },
      classes: {
        pattern: /\bclass\s+\w+/,
        message: "ES6 classes are not allowed. Use function constructors instead.",
        cop_name: "Classes",
        severity: "error"
      },
      modules: {
        pattern: /\b(import|export)\b/,
        message: "ES6 modules (import/export) are not allowed. Use traditional script loading.",
        cop_name: "Modules",
        severity: "error"
      },
      default_parameters: {
        pattern: DEFAULT_PARAMS_PATTERN,
        message: "Default parameters (ES6) are not allowed.",
        cop_name: "DefaultParameters",
        severity: "error"
      },
      rest_parameters: {
        pattern: /\.\.\.\w+/,
        message: "Rest parameters (ES6) are not allowed.",
        cop_name: "RestParameters",
        severity: "error"
      }
    }.freeze

    # Basic code quality rules
    CODE_QUALITY_RULES = {
      multiple_empty_lines: {
        pattern: /\n\s*\n/,
        message: "Multiple consecutive empty lines found. Use maximum 1 empty lines.",
        cop_name: "MultipleEmptyLines",
        severity: "warning"
      },
      line_too_long: {
        pattern: /^.{121,}$/,
        message: "Line is too long (over 120 characters). Consider breaking it into multiple lines.",
        cop_name: "LineTooLong",
        severity: "warning"
      },
      console_statements: {
        pattern: /\bconsole\.(log|debug|info|warn|error)\s*\(/,
        message: "Console statements should not be left in production code. Remove or use proper logging.",
        cop_name: "ConsoleStatements",
        severity: "warning"
      },
      no_inline_comment: {
        pattern: %r{[^\s].*//.+},
        message: "Avoid inline comments at the end of code lines.",
        cop_name: "InlineComment",
        severity: "warning"
      },
      eval_usage: {
        pattern: /\beval\s*\(/,
        message: "eval() is dangerous and should not be used. Use safer alternatives.",
        cop_name: "EvalUsage",
        severity: "error"
      },
      with_statement: {
        pattern: /\bwith\s*\(/,
        message: "with statement is deprecated and can cause scope confusion. Avoid using it.",
        cop_name: "WithStatement",
        severity: "error"
      },
      document_write: {
        pattern: /\bdocument\.write\s*\(/,
        message: "document.write() can cause performance issues and security risks. Use DOM manipulation instead.",
        cop_name: "DocumentWrite",
        severity: "warning"
      },
      loose_equality: {
        pattern: /==(?!\s*null|\s*undefined)/,
        message: "Use strict equality (===) instead of loose equality (==) to avoid type coercion issues.",
        cop_name: "LooseEquality",
        severity: "warning"
      },
      loose_inequality: {
        pattern: /!=(?!\s*null|\s*undefined)/,
        message: "Use strict inequality (!==) instead of loose inequality (!=) to avoid type coercion issues.",
        cop_name: "LooseInequality",
        severity: "warning"
      },
      unused_variables: {
        pattern: /\bvar\s+([a-zA-Z_$][a-zA-Z0-9_$]*)\s*=/,
        message: "Variable is declared but may not be used. Consider removing if unused.",
        cop_name: "UnusedVariables",
        severity: "warning"
      },
      missing_semicolon: {
        pattern: /[^;{}]\s*$/,
        message: "Missing semicolon at end of statement. Add semicolon for consistency.",
        cop_name: "MissingSemicolon",
        severity: "warning"
      },
      innerhtml_usage: {
        pattern: /\.innerHTML\s*=/,
        message: "innerHTML can cause XSS vulnerabilities. Use textContent or proper sanitization.",
        cop_name: "InnerhtmlUsage",
        severity: "warning"
      },
      global_variables: {
        pattern: /^[a-zA-Z_$][a-zA-Z0-9_$]*\s*=/,
        message: "Global variable declaration detected. Consider using var to avoid global scope pollution.",
        cop_name: "GlobalVariables",
        severity: "warning"
      }
    }.freeze

    def lint_file(content)
      check_final_newline(content)
      check_js_conventions(content)
      check_trailing_whitespace(content)

      @offenses
    end

    def lint_filtered(content, changed_lines)
      @current_code = content.lines

      changed_lines.each do |line_number|
        line_content = content.lines[line_number - 1]
        next unless line_content

        check_js_conventions_for_line(line_content, line_number)
        check_line_trailing_whitespace(line_content, line_number)
      end

      @offenses
    end

    def check_js_conventions(content)
      @current_code = content.lines

      @current_code.each_with_index do |line_content, index|
        next if line_content.strip.empty?

        line_number = index + 1

        next if commment?(line_content, line_number)

        check_line_conventions(line_content, line_number)
      end
    end

    def check_js_conventions_for_line(line_content, line_number)
      return if line_content.strip.empty?
      return if commment?(line_content, line_number)

      check_line_conventions(line_content, line_number)
    end

    # rubocop:disable Metrics
    def check_line_conventions(line_content, line_number)
      ES6_VIOLATIONS.merge(CODE_QUALITY_RULES).each do |rule_name, rule|
        next if line_content.match(rule[:pattern]).nil?
        next if rule_name == :missing_semicolon && no_need_semicolon?(line_content)
        next if rule_name == :unused_variables && used_variable?(line_content, line_number)
        next if rule_name == :loose_equality && (line_content.include?("===") || line_content.include?("!=="))
        next if rule_name == :loose_inequality && line_content.include?("!==")

        add_offense(rule_name, rule, line_content, line_number)
        break
      end
    end
    # rubocop:enable Metrics

    def used_variable?(line_content, line_number)
      # Extract variable name from var declaration
      match = line_content.match(/\bvar\s+([a-zA-Z_$][a-zA-Z0-9_$]*)\s*=/)
      return false unless match

      variable_name = match[1]

      count_occurrences(variable_name, line_number) > 0
    end

    def count_occurrences(variable_name, line_number)
      # Count occurrences of the variable name
      # Exclude the declaration line itself
      total_occurrences = 0

      @current_code.each_with_index do |code_line, index|
        # Skip the declaration line
        next if index <= line_number - 1
        next if code_line.match(/(?<![A-Za-z0-9_])#{Regexp.escape(variable_name)}(?![A-Za-z0-9_])/).nil?

        total_occurrences += 1
        break
      end

      total_occurrences
    end

    # rubocop:disable Metrics
    def no_need_semicolon?(line_content)
      line = line_content.strip
      return true if line.empty?

      # Already have ; no need to check
      return true if line.end_with?(";") || line.end_with?(",")

      # End with { or } (block, function, class, etc.)
      return true if line.end_with?("{") || line == "}"

      # Open or close array/object literal, grouping
      return true if line.match(/[\[\(]\s*$/) || line.match(/^[\])]\s*$/)

      # Control statements don't need ;
      return true if line.match(/^(if|else|for|while|switch|try|catch|finally)\b/)

      # function / class declaration
      return true if line.match(/^function\b/) || line.match(/^class\b/)

      # Control flow keywords (return, break, continue, throw)
      # Actually, it may be necessary to have ; if the expression behind starts with ( or [
      # but JS ASI will handle it, I consider it unnecessary
      return true if line.match(/^(return|break|continue|throw)\b/)

      # Object/array literal properties and elements don't need semicolons
      return true if in_object_or_array_literal?(line_content)

      false
    end

    def in_object_or_array_literal?(line_content)
      return false unless @current_code

      line_number = @current_code.index(line_content) + 1
      return false unless line_number

      # Check if we're inside an object or array literal
      brace_count = 0
      bracket_count = 0
      in_object = false
      in_array = false

      @current_code.each_with_index do |code_line, index|
        break if index >= line_number

        # Check for braces and brackets
        code_line.each_char do |char|
          case char
          when "{"
            brace_count += 1
            in_object = true if brace_count == 1
          when "}"
            brace_count -= 1
            in_object = false if brace_count.zero?
          when "["
            bracket_count += 1
            in_array = true if bracket_count == 1
          when "]"
            bracket_count -= 1
            in_array = false if bracket_count.zero?
          end
        end
      end

      in_object || in_array
    end
    # rubocop:enable Metrics

    def commment?(line_content, line_number)
      line = line_content.strip
      return true if line.start_with?("//") || line.start_with?("/*") || line.end_with?("*/")

      in_block_comment?(line_number)
    end

    def in_block_comment?(line_number)
      in_block = false

      @current_code.each_with_index do |code_line, idx|
        in_block = true if code_line.strip.start_with?("/*")
        return true if in_block && idx == line_number - 1

        in_block = false if code_line.strip.end_with?("*/")
      end

      false
    end
  end
end
