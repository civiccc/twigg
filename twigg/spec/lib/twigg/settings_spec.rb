require 'spec_helper'

describe Twigg::Settings do
  subject { described_class.new(contents) }

  context 'with a hash' do
    let(:contents) do
      { a: 1, b: 'foo' }
    end

    it 'provides method-based access' do
      expect(subject.a).to eq(1)
      expect(subject.b).to eq('foo')
    end

    it 'returns `nil` for unset keys' do
      expect(subject.c).to be_nil
    end
  end

  context 'with a nested hash' do
    let(:contents) do
      {
        a: { b: 1 },
        c: {
          d: { e: 2 },
        },
      }
    end

    it 'provides multi-level traversal' do
      expect(subject.a.b).to eq(1)
      expect(subject.c.d.e).to eq(2)
    end

    it 'returns `nil` for nested unset keys' do
      expect(subject.a.blah).to be_nil
    end
  end

  context 'with a setting that provides a default value' do
    context 'when the value is missing' do
      let(:contents) do
        {}
      end

      it 'uses the default' do
        expect(subject.default_days).to eq(7)
      end
    end

    context 'when the value is present' do
      let(:contents) do
        { default_days: 10 }
      end

      it 'uses the set value' do
        expect(subject.default_days).to eq(10)
      end
    end
  end

  context 'with a setting that is required' do
    context 'when the value is missing' do
      let(:contents) do
        {}
      end

      it 'complains' do
        expect { subject.repositories_directory }.
          to raise_error(ArgumentError, /not set/i)
      end
    end

    context 'when the value is present' do
      let(:contents) do
        { repositories_directory: __dir__ }
      end

      it 'uses the set value' do
        expect(subject.repositories_directory).to eq(__dir__)
      end
    end
  end

  context 'with a setting that performs validation' do
    context 'when the validation is satisfied' do
      let(:contents) do
        { repositories_directory: __dir__ }
      end

      it 'uses the set value' do
        expect(subject.repositories_directory).to eq(__dir__)
      end
    end

    context 'when the validation is not satisfied' do
      let(:contents) do
        { repositories_directory: __FILE__ }
      end

      it 'complains' do
        expect { subject.repositories_directory }.
          to raise_error(ArgumentError, /not a directory/i)
      end
    end
  end
end
