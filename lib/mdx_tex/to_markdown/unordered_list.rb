# frozen_string_literal: true

module MdxTex
  class ToMarkdown
    # Converts a Textile unordered list item to a Markdown unordered list item.
    # Depth is derived from the leading-asterisk count minus +base_list_depth+
    # (the smallest asterisk count seen anywhere in the document, detected by
    # the coordinator). Markdown indents 2 spaces per depth level.
    #
    # | Input (Textile) | base_list_depth | Output (Markdown) |
    # |-----------------|-----------------|-------------------|
    # | *** item        | 3               | - item            |
    # | **** nested     | 3               |   - nested        |
    # | ***** deep      | 3               |     - deep        |
    # | * item          | 1               | - item            |
    # | ** nested       | 1               |   - nested        |
    module UnorderedList
      INDENT_SIZE = 2

      # Matches a Textile unordered list line: optional leading whitespace, a run
      # of asterisks, a mandatory space, and at least one content character.
      #   \A          start of line
      #   \s*         tolerate leading whitespace (not preserved in the output)
      #   (\*+)       capture the run of asterisks (depth indicator)
      #   \s+         one or more whitespace chars
      #               (required: this is what distinguishes a list marker from
      #               inline bold like `*foo*` or a bare `*`)
      #   (.+)        capture the item content
      #   \z          end of line
      PATTERN = /\A\s*(\*+)\s+(.+)\z/.freeze

      def self.execute(line, base_list_depth:)
        line.sub(PATTERN) do
          depth = ::Regexp.last_match(1).length - base_list_depth + 1
          indent = ' ' * ((depth - 1) * INDENT_SIZE)
          "#{indent}- #{::Regexp.last_match(2)}"
        end
      end
    end
  end
end
