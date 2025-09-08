# frozen_string_literal: true

require_relative "file_handler"
require_relative "javascript_linter"

module Ccru
  # JavaScript-specific linter methods
  module JavaScriptLinterRunner
    include FileHandler

    def run_javascript_linter_file(path)
      content = safe_read_file(path)
      return 0 unless content

      js_linter = JavaScriptLinter.new
      offenses = js_linter.lint_file(content)
      return 0 if offenses.empty?

      print_offenses(path, offenses)
      1
    end

    def run_javascript_linter_filtered(path, meta)
      content = safe_read_file(path)
      return 0 unless content && meta[:lines].any?

      linter = JavaScriptLinter.new
      offenses = linter.lint_filtered(content, meta[:lines])
      return 0 if offenses.empty?

      print_offenses(path, offenses)
      1
    end
  end
end
