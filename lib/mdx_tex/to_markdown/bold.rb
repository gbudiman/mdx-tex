# frozen_string_literal: true

module MdxTex
  class ToMarkdown
    # Converts Textile bold syntax to Markdown bold syntax.
    # Textile bold is *text* with non-whitespace immediately inside both asterisks;
    # whitespace-padded asterisks are not bold (and are typically list markers).
    #
    # | Input (Textile)   | Output (Markdown) |
    # |-------------------|-------------------|
    # | *hello*           | **hello**         |
    # | *a* and *b*       | **a** and **b**   |
    # | *  hello  *       | *  hello  *       |
    module Bold
      # Matches a Textile bold span: *...*
      #   \*                opening literal *
      #   (                 capture the content
      #     [^\s*]          first char must be non-whitespace and non-*
      #                     (Textile rule: no padding inside the asterisks;
      #                     also keeps us from matching list markers like `* item`)
      #     (?:             optional trailing run, present only for 2+ char content
      #       [^*]*?        any chars except *, non-greedy so we stop at the
      #                     nearest closing * rather than spanning into another span
      #       [^\s*]        last char must also be non-whitespace and non-*
      #     )?              optional, so single-char bold like *a* still matches
      #   )
      #   \*                closing literal *
      PATTERN = /\*([^\s*](?:[^*]*?[^\s*])?)\*/.freeze

      def self.execute(line)
        line.gsub(PATTERN, '**\1**')
      end
    end
  end
end
