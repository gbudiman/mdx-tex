# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::Header do
  it 'converts h1 to a single hash' do
    expect(described_class.execute('h1. Heading')).to eq('# Heading')
  end

  it 'converts h2 to two hashes' do
    expect(described_class.execute('h2. Heading')).to eq('## Heading')
  end

  it 'converts h3 to three hashes' do
    expect(described_class.execute('h3. Heading')).to eq('### Heading')
  end

  it 'converts h6 to six hashes' do
    expect(described_class.execute('h6. Heading')).to eq('###### Heading')
  end

  it 'requires a space after hN. to match' do
    expect(described_class.execute('h3.Heading')).to eq('h3.Heading')
  end

  it 'leaves invalid header levels unchanged' do
    expect(described_class.execute('h7. Heading')).to eq('h7. Heading')
  end

  it 'leaves h0 unchanged' do
    expect(described_class.execute('h0. Heading')).to eq('h0. Heading')
  end

  it 'leaves non-header lines unchanged' do
    expect(described_class.execute('plain text')).to eq('plain text')
  end

  it 'leaves a line that only mentions a header tag mid-string unchanged' do
    expect(described_class.execute('see h2. for details')).to eq('see h2. for details')
  end
end
