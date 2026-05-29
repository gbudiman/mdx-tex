# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::UnorderedList, 'statefulness' do
  subject(:converter) { MdxTex::ToMarkdown.new }

  describe 'unordered list base auto-detection' do
    it 'treats a *** base as depth 1' do
      input = <<~TEXTILE
        *** a
        *** b
      TEXTILE
      output = <<~MD
        - a
        - b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'treats a **** base as depth 1' do
      input = <<~TEXTILE
        **** a
        **** b
      TEXTILE
      output = <<~MD
        - a
        - b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'treats a single-* base as depth 1' do
      input = <<~TEXTILE
        * a
        ** b
      TEXTILE
      output = <<~MD
        - a
          - b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'preserves depth gaps between the detected base and deeper items' do
      input = <<~TEXTILE
        *** a
        ***** deep
      TEXTILE
      output = <<~MD
        - a
            - deep
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'detects the minimum across non-contiguous list lines' do
      input = <<~TEXTILE
        ***** deep

        *** shallow
        **** middle
      TEXTILE
      output = <<~MD
            - deep

        - shallow
          - middle
      MD
      expect(converter.execute(input)).to eq(output)
    end
  end
end
