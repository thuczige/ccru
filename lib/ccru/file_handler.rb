# frozen_string_literal: true

module Ccru
  # Handles file operations for RuboCop
  module FileHandler
    def safe_read_file(path)
      File.read(path)
    rescue StandardError
      nil
    end
  end
end
