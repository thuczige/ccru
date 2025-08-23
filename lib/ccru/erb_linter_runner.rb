# frozen_string_literal: true

require_relative "erb_linter"
require_relative "file_handler"
require_relative "offense_printer"

module Ccru
  # ERB linter runner methods
  module ErbLinterRunner
    include FileHandler
    include OffensePrinter

    def run_erb_linter_file(path)
      content = safe_read_file(path)
      return 0 unless content

      erb_linter = ErbLinter.new
      offenses = erb_linter.lint_file(content)
      return 0 if offenses.empty?

      print_offenses(path, offenses)
      1
    end

    def run_erb_linter_filtered(path, meta)
      content = safe_read_file(path)
      return 0 unless content && meta[:lines].any?

      erb_linter = ErbLinter.new
      offenses = erb_linter.lint_filtered(content, meta[:lines])
      return 0 if offenses.empty?

      print_offenses(path, offenses)
      1
    end
  end
end
