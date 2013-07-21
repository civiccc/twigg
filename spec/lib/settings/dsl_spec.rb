require 'spec_helper'

describe Twigg::Settings::DSL do
  context 'with nested namespaces' do
    subject do
      Class.new(OpenStruct) do
        extend  Twigg::Settings::DSL::ClassMethods
        include Twigg::Settings::DSL::InstanceMethods

        namespace :foo do
          setting :color, default: 'red'

          namespace :bar do
            setting :volume, default: 100
          end
        end
      end.new
    end

    it 'handles top-level settings' do
      subject.foo.color.should == 'red'
    end

    it 'handles nested settings' do
      subject.foo.bar.volume.should == 100
    end
  end

  context 'when re-opening an existing namespace' do
    subject do
      Class.new(OpenStruct) do
        extend  Twigg::Settings::DSL::ClassMethods
        include Twigg::Settings::DSL::InstanceMethods

        namespace :jungle do
          setting :boogie, default: 'large'
        end

        namespace :jungle do
          setting :fever, default: true
        end
      end.new
    end

    it 'handles settings prepared prior to re-opening' do
      subject.jungle.boogie.should == 'large'
    end

    it 'handles settings prepared after re-opening' do
      subject.jungle.fever.should be_true
    end
  end

  context 'when exercising memoization' do
    subject do
      Class.new(OpenStruct) do
        extend  Twigg::Settings::DSL::ClassMethods
        include Twigg::Settings::DSL::InstanceMethods

        def self.validate; end # something we can mock

        setting :philotic, default: 'foo' do |name, value|
          validate
        end
      end.new
    end

    it 'sets an instance variable' do
      expect { subject.philotic }.
        to change { subject.instance_variables.count }.
        by(1)
    end

    it 'short-circuits after the first run' do
      mock(subject.class).validate.once
      2.times { subject.philotic }
    end

    it 'always returns the same value' do
      2.times.map { subject.philotic }.should == %w[foo foo]
    end
  end
end
