# frozen_string_literal: true

require_relative "rubocop_runner"
require_relative "erb_linter_runner"
require_relative "javascript_linter_runner"

module Ccru
  # Handles execution of different linters (RuboCop for Ruby, custom for JavaScript, ERB parsing)
  module LinterRunner
    include RuboCopRunner
    include ErbLinterRunner
    include JavaScriptLinterRunner

    def run_linter_file(path, meta)
      case meta[:file_type]
      when :ruby
        run_rubocop_file(path)
      when :javascript
        run_javascript_linter_file(path)
      when :erb
        run_erb_linter_file(path)
      else
        0
      end
    end

    def run_linter_filtered(path, meta)
      case meta[:file_type]
      when :ruby
        run_rubocop_filtered(path, meta)
      when :javascript
        run_javascript_linter_filtered(path, meta)
      when :erb
        run_erb_linter_filtered(path, meta)
      else
        0
      end
    end
  end
end
