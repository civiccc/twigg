require 'spec_helper'

describe Twigg::Settings do
  subject { described_class.new(contents) }

  context 'with a hash' do
    let(:contents) do
      { a: 1, b: 'foo' }
    end

    it 'provides method-based access' do
      subject.a.should == 1
      subject.b.should == 'foo'
    end

    it 'returns `nil` for unset keys' do
      subject.c.should be_nil
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
      subject.a.b.should == 1
      subject.c.d.e.should == 2
    end

    it 'returns `nil` for nested unset keys' do
      subject.a.blah.should be_nil
    end
  end

  context 'with a setting that provides a default value' do
    context 'when the value is missing' do
      let(:contents) do
        {}
      end

      it 'uses the default' do
        subject.default_days.should == 7
      end
    end

    context 'when the value is present' do
      let(:contents) do
        { default_days: 10 }
      end

      it 'uses the set value' do
        subject.default_days.should == 10
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
        subject.repositories_directory.should == __dir__
      end
    end
  end

  context 'with a setting that performs validation' do
    context 'when the validation is satisfied' do
      let(:contents) do
        { repositories_directory: __dir__ }
      end

      it 'uses the set value' do
        subject.repositories_directory.should == __dir__
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
