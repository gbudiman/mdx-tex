# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::OrderedList do
  it 'converts a depth-1 item with base 1 and number 1' do
    expect(described_class.execute('# item', base_list_depth: 1, number: 1)).to eq('1. item')
  end

  it 'emits the supplied number' do
    expect(described_class.execute('# item', base_list_depth: 1, number: 5)).to eq('5. item')
  end

  it 'emits a multi-digit number' do
    expect(described_class.execute('# item', base_list_depth: 1, number: 42)).to eq('42. item')
  end

  it 'converts a depth-2 item with base 1 (2-space indent)' do
    expect(described_class.execute('## nested', base_list_depth: 1, number: 1)).to eq('  1. nested')
  end

  it 'converts a depth-3 item with base 1 (4-space indent)' do
    expect(described_class.execute('### deep', base_list_depth: 1, number: 1)).to eq('    1. deep')
  end

  it 'converts a depth-1 item with base 2' do
    expect(described_class.execute('## item', base_list_depth: 2, number: 1)).to eq('1. item')
  end

  it 'converts a depth-2 item with base 2' do
    expect(described_class.execute('### nested', base_list_depth: 2, number: 1)).to eq('  1. nested')
  end

  it 'tolerates leading whitespace before the hashes' do
    expect(described_class.execute(' # item', base_list_depth: 1, number: 1)).to eq('1. item')
  end

  it 'leaves non-list lines unchanged' do
    expect(described_class.execute('plain text', base_list_depth: 1, number: 1)).to eq('plain text')
  end

  it 'leaves Textile header lines unchanged' do
    expect(described_class.execute('h3. Title', base_list_depth: 1, number: 1)).to eq('h3. Title')
  end

  it 'leaves a hash without a trailing space unchanged' do
    expect(described_class.execute('#foo', base_list_depth: 1, number: 1)).to eq('#foo')
  end
end
