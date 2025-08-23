# frozen_string_literal: true

module Ccru
  # Handles printing of RuboCop offenses
  module OffensePrinter
    def print_offenses(path, offenses)
      offenses.each { |offense| print_single_offense(path, offense) }
    end

    def print_single_offense(path, offense)
      location = offense["location"]
      print_offense_summary(path, offense, location)
      print_offense_code(path, location)
    end

    def print_offense_summary(path, offense, location)
      line = location["line"]
      column = location["column"]
      severity_flag = offense["severity"][0].upcase
      cop_name = offense["cop_name"]
      message = offense["message"]
      puts "#{path}:#{line}:#{column}: #{severity_flag}: #{cop_name}: #{message}"
    end

    def print_offense_code(path, location)
      return unless File.exist?(path)

      code_lines = File.readlines(path)
      line_content = code_lines[location["line"] - 1]
      return unless line_content

      puts line_content.rstrip
      puts_target_flags(line_content, location)
    rescue StandardError
      # Skip if cannot read file
    end

    def puts_target_flags(line_content, location)
      return puts if location["column"] == 1

      target = "#{" " * (location["column"] - 1)}#{"^" * location["length"]}"
      puts target[0...line_content.length]
    end
  end
end
