# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MdxTex::ToMarkdown::Bold do
  it 'converts *text*' do
    expect(described_class.execute('*bold*')).to eq('**bold**')
  end

  it 'converts a single-character bold span' do
    expect(described_class.execute('*a*')).to eq('**a**')
  end

  it 'converts multiple bold spans on one line' do
    expect(described_class.execute('*a* and *b*')).to eq('**a** and **b**')
  end

  it 'converts bold embedded in surrounding text' do
    expect(described_class.execute('foo *bar* baz')).to eq('foo **bar** baz')
  end

  it 'preserves a single space inside bold' do
    expect(described_class.execute('*hello world*')).to eq('**hello world**')
  end

  it 'preserves multiple spaces inside bold' do
    expect(described_class.execute('*hello  world*')).to eq('**hello  world**')
  end

  it 'does not treat whitespace-padded asterisks as bold' do
    expect(described_class.execute('*  hello  *')).to eq('*  hello  *')
  end

  it 'does not treat a leading-space-padded asterisk as bold' do
    expect(described_class.execute('* hello*')).to eq('* hello*')
  end

  it 'does not treat a trailing-space-padded asterisk as bold' do
    expect(described_class.execute('*hello *')).to eq('*hello *')
  end

  it 'leaves plain text unchanged' do
    expect(described_class.execute('plain text')).to eq('plain text')
  end

  it 'leaves a lone asterisk unchanged' do
    expect(described_class.execute('lone * asterisk')).to eq('lone * asterisk')
  end

  it 'leaves an unclosed bold span unchanged' do
    expect(described_class.execute('*unclosed')).to eq('*unclosed')
  end
end
