# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex do
  describe '.to_textile' do
    it 'converts markdown using default configuration' do
      expect(described_class.to_textile(markdown: '# Heading')).to eq('h3. Heading')
    end

    it 'accepts per-call header_level override' do
      expect(described_class.to_textile(markdown: '# Heading', header_level: 'h1')).to eq('h1. Heading')
    end

    it 'accepts per-call list_depth override' do
      expect(described_class.to_textile(markdown: '- item', list_depth: 1)).to eq('* item')
    end
  end

  describe '.to_markdown' do
    it 'converts a Textile heading' do
      expect(described_class.to_markdown(textile: 'h3. Heading')).to eq('### Heading')
    end

    it 'returns nil for nil input' do
      expect(described_class.to_markdown(textile: nil)).to be_nil
    end
  end

  describe 'round-trip conversion (Markdown -> Textile -> Markdown)' do
    # Inputs that round-trip cleanly need to use the canonical forms that .to_textile emits:
    # - header depth matches the configured header_level (h3 by default, so `###`)
    # - bold uses ** (not __)
    # - unordered lists begin at depth 1 (matching list_depth: 3)
    # - ordered list are 1-indexed and increment for each siblings
    it 'preserves the input through Markdown -> Textile -> Markdown' do
      markdown = <<~MD
        ### **Title**

        - item one with **bold word** in the middle
        - **item two**
          - nested A
          - nested B with **emphasis** inline
        - item three

        1. **first**
        2. second with a **bold span** mid-sentence
          1. sub one
          2. sub two
        3. third
      MD

      textile = described_class.to_textile(markdown: markdown)
      round_tripped = described_class.to_markdown(textile: textile)

      expect(round_tripped).to eq(markdown)
    end
  end

  describe '.configure' do
    after { described_class.configuration = nil }

    before do
      described_class.configure do |config|
        config.header_level = 'h1'
        config.list_depth = 1
      end
    end

    it 'applies configured header_level globally' do
      expect(described_class.to_textile(markdown: '# Heading')).to eq('h1. Heading')
    end

    it 'applies configured list_depth globally' do
      expect(described_class.to_textile(markdown: '- item')).to eq('* item')
    end

    it 'allows per-call header_level to override global config' do
      expect(described_class.to_textile(markdown: '# Heading', header_level: 'h2')).to eq('h2. Heading')
    end

    it 'allows per-call list_depth to override global config' do
      expect(described_class.to_textile(markdown: '- item', list_depth: 2)).to eq('** item')
    end
  end

  describe MdxTex::Configuration do
    subject(:config) { described_class.new }

    it 'defaults header_level to h3' do
      expect(config.header_level).to eq('h3')
    end

    it 'defaults list_depth to 3' do
      expect(config.list_depth).to eq(3)
    end

    it 'allows header_level to be changed' do
      config.header_level = 'h1'
      expect(config.header_level).to eq('h1')
    end

    it 'allows list_depth to be changed' do
      config.list_depth = 1
      expect(config.list_depth).to eq(1)
    end

    it 'raises InvalidHeaderLevelError for an invalid header_level' do
      expect { config.header_level = 'h7' }.to raise_error(MdxTex::ToTextile::InvalidHeaderLevelError)
    end

    it 'raises InvalidHeaderLevelError for a non-string header_level' do
      expect { config.header_level = 3 }.to raise_error(MdxTex::ToTextile::InvalidHeaderLevelError)
    end

    it 'raises InvalidListDepthError for zero list_depth' do
      expect { config.list_depth = 0 }.to raise_error(MdxTex::ToTextile::InvalidListDepthError)
    end

    it 'raises InvalidListDepthError for a non-integer list_depth' do
      expect { config.list_depth = 'x' }.to raise_error(MdxTex::ToTextile::InvalidListDepthError)
    end

    it 'defaults enable_string_extension to false' do
      expect(config.enable_string_extension).to be(false)
    end
  end

  describe '.load_string_extension!' do
    before { described_class.load_string_extension! }

    it 'adds #to_textile to String' do
      expect('# Heading'.to_textile).to eq('h3. Heading')
    end

    it 'forwards options to MdxTex.to_textile' do
      expect('# Heading'.to_textile(header_level: 'h1')).to eq('h1. Heading')
    end

    it 'adds #to_markdown to String' do
      expect('h3. Heading'.to_markdown).to eq('### Heading')
    end
  end
end
