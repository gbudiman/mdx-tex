# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown do
  subject(:converter) { described_class.new }

  let(:input) do
    <<~TEXTILE
      h3. *Title*

      *** item one
      *** *item two*
      **** nested A
      **** nested B
      *** item three

      # *first*
      # second
      ## sub one
      ## sub two
      # third
    TEXTILE
  end

  let(:output) do
    <<~MD
      ### **Title**

      - item one
      - **item two**
        - nested A
        - nested B
      - item three

      1. **first**
      2. second
        1. sub one
        2. sub two
      3. third
    MD
  end

  it 'returns nil for nil input' do
    expect(converter.execute(nil)).to be_nil
  end

  it 'coerces non-string input to string' do
    expect(converter.execute(42)).to eq('42')
  end

  it 'converts bold inside a list item' do
    expect(converter.execute('*** *bold* text')).to eq('- **bold** text')
  end

  it 'converts bold inside a header' do
    expect(converter.execute('h2. *Important*')).to eq('## **Important**')
  end

  it 'converts a full document' do
    expect(converter.execute(input)).to eq(output)
  end

  describe 'documents without lists' do
    it 'converts headers and bold with no list items present' do
      input = <<~TEXTILE
        h1. Title

        some *bold* text
      TEXTILE
      output = <<~MD
        # Title

        some **bold** text
      MD
      expect(converter.execute(input)).to eq(output)
    end
  end

  describe 'whitespace and blank lines' do
    it 'preserves blank lines' do
      input = <<~TEXTILE
        h1. A

        h2. B
      TEXTILE
      output = <<~MD
        # A

        ## B
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'preserves trailing newline' do
      expect(converter.execute("h1. A\n")).to eq("# A\n")
    end
  end
end
