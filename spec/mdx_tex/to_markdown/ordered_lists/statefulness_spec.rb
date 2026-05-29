# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::OrderedList, 'statefulness' do
  subject(:converter) { MdxTex::ToMarkdown.new }

  describe 'base auto-detection' do
    it 'treats a # base as depth 1' do
      input = <<~TEXTILE
        # a
        # b
      TEXTILE
      output = <<~MD
        1. a
        2. b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'treats a ## base as depth 1' do
      input = <<~TEXTILE
        ## a
        ## b
      TEXTILE
      output = <<~MD
        1. a
        2. b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'preserves depth gaps between the detected base and deeper items' do
      input = <<~TEXTILE
        # a
        ### deep
      TEXTILE
      output = <<~MD
        1. a
            1. deep
      MD
      expect(converter.execute(input)).to eq(output)
    end
  end

  describe 'numbering' do
    it 'increments siblings at the same depth' do
      input = <<~TEXTILE
        # a
        # b
        # c
      TEXTILE
      output = <<~MD
        1. a
        2. b
        3. c
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'starts a deeper depth counter at 1' do
      input = <<~TEXTILE
        # a
        ## b
      TEXTILE
      output = <<~MD
        1. a
          1. b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'continues the parent counter after a deeper run' do
      input = <<~TEXTILE
        # a
        ## b
        ## c
        # d
      TEXTILE
      output = <<~MD
        1. a
          1. b
          2. c
        2. d
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'starts a fresh deeper counter on a new deeper run' do
      input = <<~TEXTILE
        # a
        ## x
        # b
        ## y
      TEXTILE
      output = <<~MD
        1. a
          1. x
        2. b
          1. y
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'resets counters on a blank line' do
      input = <<~TEXTILE
        # a
        # b

        # c
      TEXTILE
      output = <<~MD
        1. a
        2. b

        1. c
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'resets counters when an unordered list interrupts' do
      input = <<~TEXTILE
        # a
        * x
        # b
      TEXTILE
      output = <<~MD
        1. a
        - x
        1. b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'resets counters when a plain text line interrupts' do
      input = <<~TEXTILE
        # a
        # b
        break
        # c
      TEXTILE
      output = <<~MD
        1. a
        2. b
        break
        1. c
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'resets counters when a header interrupts' do
      input = <<~TEXTILE
        # a
        h3. break
        # b
      TEXTILE
      output = <<~MD
        1. a
        ### break
        1. b
      MD
      expect(converter.execute(input)).to eq(output)
    end

    it 'emits multi-digit numbers' do
      input = "#{(['# x'] * 12).join("\n")}\n"
      output = "#{(1..12).map { |i| "#{i}. x" }.join("\n")}\n"
      expect(converter.execute(input)).to eq(output)
    end
  end
end
