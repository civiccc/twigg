require 'spec_helper'

describe Twigg::Util do
  include described_class

  describe '#pluralize' do
    context 'with a count of 0' do
      it 'returns the plural form' do
        expect(pluralize 0, 'thing').to eq('0 things')
      end
    end

    context 'with a count of 1' do
      it 'returns the singular form' do
        expect(pluralize 1, 'thing').to eq('1 thing')
      end
    end

    context 'with a count of 2' do
      it 'returns the plural form' do
        expect(pluralize 2, 'thing').to eq('2 things')
      end
    end

    context 'with a custom inflection' do
      it 'returns the correct forms' do
        expect(pluralize 0, 'story', 'stories').to eq('0 stories')
        expect(pluralize 1, 'story', 'stories').to eq('1 story')
        expect(pluralize 2, 'story', 'stories').to eq('2 stories')
      end

      it 'stores custom inflection' do
        expect(pluralize 5, 'die', 'dice').to eq('5 dice')
        expect(pluralize 5, 'die').to eq('5 dice')
      end

      it 'shares custom inflection information across instances' do
        # first, register a custom inflection
        expect(pluralize 3, 'index', 'indices').to eq('3 indices')

        # then, exercise it in a distinct context
        klass = Class.new { include Twigg::Util }
        expect(klass.new.send :pluralize, 5, 'index').to eq('5 indices')
      end

      it 'allows multiple custom inflections to work' do
        expect(pluralize 5, 'open story', 'open stories').to eq('5 open stories')
        expect(pluralize 5, 'started story', 'started stories').to eq('5 started stories')
      end
    end
  end
end
