# frozen_string_literal: true

require 'mdx_tex/to_markdown/bold'
require 'mdx_tex/to_markdown/header'
require 'mdx_tex/to_markdown/unordered_list'
require 'mdx_tex/to_markdown/ordered_list'

module MdxTex
  # Converts Textile to Markdown.
  #
  # The base list depth is auto-detected per document (smallest asterisks/hashes
  # count across all list lines) so that input with inconsistent base
  # indentation still produces a clean depth-1 Markdown list. Ordered list
  # items are numbered with incrementing per-depth counters that reset on
  # blank lines or any non-ordered-list line.
  class ToMarkdown
    def execute(input)
      return nil if input.nil?

      lines = input.to_s.split("\n", -1)
      @unordered_base, @ordered_base = detect_bases(lines)
      @counters = {}

      lines.map { |line| convert_line(line) }.join("\n")
    end

    private

    # Single pass over the document:
    # - every line is matched against the list patterns once,
    #   and the smallest marker run seen for each kind becomes the depth-1 base.
    # - Falls back to 1 when no list of that kind is present
    #   (the value is irrelevant in that case — no line will match for conversion).
    def detect_bases(lines)
      unordered_counts = []
      ordered_counts = []
      lines.each do |line|
        if (m = line.match(UnorderedList::PATTERN))
          unordered_counts << m[1].length
        elsif (m = line.match(OrderedList::PATTERN))
          ordered_counts << m[1].length
        end
      end
      [unordered_counts.min || 1, ordered_counts.min || 1]
    end

    def convert_line(line)
      # List conversion must run before Bold (and before Header for symmetry):
      # - Textile uses `*` for both unordered list markers and inline bold.
      #   A line like `*** *foo*` is a depth-3 list item containing the bold word "foo".
      # - If Bold ran first, the leading `*` characters would be eaten by its
      #   regex and the list structure would be lost.
      #   Converting lists first rewrites the leading markers to Markdown `-`/`1.`,
      #   leaving only the inline `*foo*` for Bold to handle on the next pass.
      line = convert_ordered_and_unordered_list(line)
      line = Header.execute(line)
      Bold.execute(line)
    end

    def convert_ordered_and_unordered_list(line)
      match = line.match(OrderedList::PATTERN)
      if match
        # Ordered-list line: bump the counter at this depth
        # (which also drops any deeper counters so they restart fresh next time we descend).
        depth = match[1].length - @ordered_base + 1
        number = bump_counter(depth)
        OrderedList.execute(line, base_list_depth: @ordered_base, number: number)
      else
        # Anything else (blank line, unordered item, header, paragraph)
        # ends the current run of ordered items, so all ordered counters reset.
        # The next `# foo` encountered will start over at 1.
        @counters.clear
        UnorderedList.execute(line, base_list_depth: @unordered_base)
      end
    end

    # Increment the counter at +depth+ and drop any deeper-depth counters.
    # So the next time we descend to those depths they start fresh at 1.
    def bump_counter(depth)
      @counters[depth] = (@counters[depth] || 0) + 1
      @counters.delete_if { |d, _| d > depth }
      @counters[depth]
    end
  end
end
