# frozen_string_literal: true

require_relative "usual_linter"

module Ccru
  # ERB linter that checks basic ERB conventions
  class ErbLinter
    include UsualLinter

    def initialize
      @offenses = []
    end

    # ERB convention violations
    ERB_VIOLATIONS = {
      # Bad comment format: <% # comment %> instead of <%# comment %>
      bad_comment_format: {
        pattern: /<%\s+#[^%]*%>/,
        message: "Use <%# comment %> instead of <% # comment %> for ERB comments",
        cop_name: "BadCommentFormat",
        severity: "error"
      },
      # Bad spacing: <%foo%> instead of <% foo %>
      bad_spacing: {
        pattern: /<%(?!=)[^\s#][^%]*%>/,
        message: "<% your_code %> for better readability",
        cop_name: "BadSpacing",
        severity: "warning"
      },
      # Bad output spacing: <%=foo%> instead of <%= foo %>
      bad_output_spacing: {
        pattern: /<%=[^\s][^%]*%>/,
        message: "<%= your_code %> for better readability",
        cop_name: "BadOutputSpacing",
        severity: "warning"
      },
      # Bad comment spacing: <%#foo%> instead of <%# foo %>
      bad_comment_spacing: {
        pattern: /<%#[^\s][^%]*%>/,
        message: "<%# your_comment %> for better readability",
        cop_name: "BadCommentSpacing",
        severity: "warning"
      }
    }.freeze

    def lint_file(content)
      check_final_newline(content)
      check_erb_conventions(content)
      check_trailing_whitespace(content)

      @offenses
    end

    def lint_filtered(content, changed_lines)
      changed_lines.each do |line_number|
        line_content = content.lines[line_number - 1]
        next unless line_content

        check_line_conventions(line_content, line_number)
      end

      @offenses
    end

    def check_erb_conventions(content)
      content.lines.each_with_index do |line_content, index|
        next if line_content.strip.empty?

        line_number = index + 1
        check_line_conventions(line_content, line_number)
      end
    end

    def check_line_conventions(line_content, line_number)
      ERB_VIOLATIONS.each do |rule_name, rule|
        next if line_content.match(rule[:pattern]).nil?

        add_offense(rule_name, rule, line_content, line_number)
        break
      end
    end
  end
end
