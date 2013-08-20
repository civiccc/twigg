require 'spec_helper'

describe Twigg::Config do
  describe 'Initialization' do
    subject { Twigg::Config.new(twiggrc: config_file) }

    context 'with the example twiggrc.yml file' do
      let(:config_file) { 'templates/twiggrc.yml' }

      before { stub(File).world_readable?(config_file) { false } }

      it 'specifies teams' do
        expect(subject.teams).to be_an(OpenStruct)
      end

      it 'has a Red Team' do
        expect(subject.teams['Red Team']).to be_an(Array)
      end

      it 'has a Red Team with 2 developers' do
        expect(subject.teams['Red Team'].length).to be(2)
      end
    end
  end
end
