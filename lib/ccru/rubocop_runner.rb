# frozen_string_literal: true

require "json"
require "open3"

require_relative "file_handler"
require_relative "offense_printer"

module Ccru
  # RuboCop-specific linter methods
  module RuboCopRunner
    include FileHandler
    include OffensePrinter

    def run_rubocop_file(path)
      content = safe_read_file(path)
      return 0 unless content

      result = run_rubocop_and_parse(path, content)
      return result unless result.is_a?(Array)
      return 0 if result.empty?

      print_offenses(path, result)
      1
    end

    def run_rubocop_filtered(path, meta)
      content = safe_read_file(path)
      return 0 unless content && meta[:lines].any?

      result = run_rubocop_and_parse(path, content)
      return result unless result.is_a?(Array)
      return 0 if result.empty?

      offenses = filter_offenses_by_lines(result, meta[:lines])
      return 0 if offenses.empty?

      print_offenses(path, offenses)
      1
    end

    def run_rubocop_and_parse(path, content)
      out, = run_rubocop_json(path, content)
      data = safe_parse_json(path, out)
      return 1 unless data

      files = data["files"] || []
      (files.first && files.first["offenses"]) || []
    end

    def run_rubocop_json(path, content)
      cmd = ["rubocop", "--format", "json", "--force-exclusion", "--stdin", path]
      Open3.capture3(*cmd, stdin_data: content)
    end

    def safe_parse_json(path, out)
      JSON.parse(out)
    rescue StandardError
      warn("ccru: failed to parse rubocop json for #{path}")
      nil
    end

    def filter_offenses_by_lines(offenses, changed_lines)
      offenses.select { |offense| changed_lines.include?(offense["location"]["line"]) }
    end
  end
end
