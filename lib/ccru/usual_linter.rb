# frozen_string_literal: true

module Ccru
  # Handles execution of different linters (RuboCop for Ruby, custom for JavaScript, ERB parsing)
  module UsualLinter
    USUAL_VIOLATIONS = {
      # Trailing whitespace
      trailing_whitespace: {
        pattern: /\s+$/,
        message: "Remove trailing whitespace",
        cop_name: "TrailingWhitespace",
        severity: "warning"
      },
      # Missing final newline
      missing_final_newline: {
        pattern: /[^\n]$/,
        message: "Add final newline at end of file",
        cop_name: "MissingFinalNewline",
        severity: "warning"
      }
    }.freeze

    def check_trailing_whitespace(content)
      content.lines.each_with_index do |line_content, index|
        line_number = index + 1
        check_line_trailing_whitespace(line_content, line_number)
      end
    end

    def check_final_newline(content)
      return if content.empty? || content.end_with?("\n")

      rule_name = :missing_final_newline
      rule = USUAL_VIOLATIONS[rule_name]
      add_offense(rule_name, rule, "End of file", content.lines.count)
    end

    def check_line_trailing_whitespace(line_content, line_number)
      rule_name = :trailing_whitespace
      rule = USUAL_VIOLATIONS[rule_name]
      return if line_content.match(rule[:pattern]).nil? || line_content.gsub("\n", "")[-1] != " "

      add_offense(rule_name, rule, line_content, line_number)
    end

    def add_offense(rule_name, violation, line_content, line_number)
      @offenses << {
        "rule" => rule_name,
        "line_content" => line_content,
        "message" => violation[:message],
        "severity" => violation[:severity],
        "cop_name" => violation[:cop_name],
        "location" => { "line" => line_number, "column" => 1 }
      }
    end
  end
end
