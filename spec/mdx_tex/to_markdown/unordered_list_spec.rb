# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::UnorderedList do
  it 'converts a depth-1 item with base 3' do
    expect(described_class.execute('*** item', base_list_depth: 3)).to eq('- item')
  end

  it 'converts a depth-2 item with base 3 (2-space indent)' do
    expect(described_class.execute('**** nested', base_list_depth: 3)).to eq('  - nested')
  end

  it 'converts a depth-3 item with base 3 (4-space indent)' do
    expect(described_class.execute('***** deep', base_list_depth: 3)).to eq('    - deep')
  end

  it 'converts a depth-1 item with base 1' do
    expect(described_class.execute('* item', base_list_depth: 1)).to eq('- item')
  end

  it 'converts a depth-2 item with base 1' do
    expect(described_class.execute('** nested', base_list_depth: 1)).to eq('  - nested')
  end

  it 'tolerates leading whitespace before the asterisks' do
    expect(described_class.execute(' *** item', base_list_depth: 3)).to eq('- item')
  end

  it 'treats a whitespace-padded asterisks line as a list item (Textile rule)' do
    expect(described_class.execute('*  hello  *', base_list_depth: 1)).to eq('- hello  *')
  end

  it 'leaves non-list lines unchanged' do
    expect(described_class.execute('plain text', base_list_depth: 3)).to eq('plain text')
  end

  it 'leaves inline bold unchanged' do
    expect(described_class.execute('*bold*', base_list_depth: 3)).to eq('*bold*')
  end

  it 'leaves a bare asterisk unchanged' do
    expect(described_class.execute('*', base_list_depth: 3)).to eq('*')
  end

  it 'leaves an asterisk run without a trailing space unchanged' do
    expect(described_class.execute('***foo', base_list_depth: 3)).to eq('***foo')
  end
end
