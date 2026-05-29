# frozen_string_literal: true

module MdxTex
  class ToMarkdown
    # Converts a Textile ordered list item to a Markdown ordered list item.
    # Depth is derived from the leading-hash count minus +base_list_depth+
    # (the smallest hash count seen anywhere in the document, detected by the
    # coordinator). Markdown indents 2 spaces per depth level. The +number+
    # is supplied by the coordinator, which maintains per-depth counters.
    #
    # | Input (Textile) | base_list_depth | number | Output (Markdown) |
    # |-----------------|-----------------|--------|-------------------|
    # | # item          | 1               | 1      | 1. item           |
    # | # item          | 1               | 5      | 5. item           |
    # | ## nested       | 1               | 1      |   1. nested       |
    # | ## item         | 2               | 1      | 1. item           |
    module OrderedList
      INDENT_SIZE = 2

      # Matches a Textile ordered list line: optional leading whitespace, a run
      # of hashes, a mandatory space, and at least one content character.
      #   \A          start of line
      #   \s*         tolerate leading whitespace (not preserved in the output)
      #   (#+)        capture the run of hashes (depth indicator)
      #   \s+         one or more whitespace chars
      #               (required: distinguishes a list marker from things like
      #               `#foo` which is not a Textile ordered list item)
      #   (.+)        capture the item content
      #   \z          end of line
      PATTERN = /\A\s*(#+)\s+(.+)\z/.freeze

      def self.execute(line, base_list_depth:, number:)
        line.sub(PATTERN) do
          depth = ::Regexp.last_match(1).length - base_list_depth + 1
          indent = ' ' * ((depth - 1) * INDENT_SIZE)
          "#{indent}#{number}. #{::Regexp.last_match(2)}"
        end
      end
    end
  end
end
