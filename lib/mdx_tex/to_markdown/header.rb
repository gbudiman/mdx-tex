# frozen_string_literal: true

module MdxTex
  class ToMarkdown
    # Converts a Textile heading to a Markdown heading.
    # The Textile tag's level determines the number of leading #s.
    # A space must follow the period for the line to be recognised as a heading.
    # Lines that do not match are returned unchanged.
    #
    # | Input (Textile)    | Output (Markdown)  |
    # |--------------------|--------------------|
    # | h1. Title          | # Title            |
    # | h3. Note           | ### Note           |
    # | h6. Tiny           | ###### Tiny        |
    # | h3.NoSpace         | h3.NoSpace         |
    # | h7. TooDeep        | h7. TooDeep        |
    module Header
      # Matches a Textile heading line: hN. content
      #   \A          anchor to start of line (no leading whitespace allowed)
      #   h           literal 'h'
      #   ([1-6])     capture the heading level digit, restricted to 1-6
      #               (Textile/HTML only have h1..h6)
      #   \.          literal period
      #   \s+         one or more whitespace chars
      #               (required: `h3.NoSpace` is not a heading)
      #   (.+)        capture the heading content (at least one char)
      #   \z          anchor to end of line
      PATTERN = /\Ah([1-6])\.\s+(.+)\z/.freeze

      def self.execute(line)
        line.sub(PATTERN) { "#{'#' * ::Regexp.last_match(1).to_i} #{::Regexp.last_match(2)}" }
      end
    end
  end
end
