# frozen_string_literal: true

module Ccru
  # Detects file types and determines which linter to use
  module FileTypeDetector
    SUPPORTED_EXTENSIONS = {
      ".rb" => :ruby,
      ".js" => :javascript,
      ".erb" => :erb
    }.freeze

    class << self
      def supported_file?(path)
        SUPPORTED_EXTENSIONS.key?(File.extname(path))
      end

      def file_type(path)
        extension = File.extname(path)
        SUPPORTED_EXTENSIONS[extension]
      end

      def ruby_file?(path)
        file_type(path) == :ruby
      end
    end
  end
end
