require 'spec_helper'
require 'tmpdir'

describe Twigg::Repo do
  describe '#initialize' do
    subject { described_class.new(repo) }

    context 'with a valid repo' do
      let(:repo) { scratch_repo }

      it 'returns a working instance' do
        subject.should be_a(Twigg::Repo)
      end
    end

    context 'with an invalid "repo"' do
      let(:repo) { Dir.mktmpdir }

      it 'complains' do
        expect { subject }.to raise_error(Twigg::Repo::InvalidRepoError)
      end
    end

    context 'with a non-directory path' do
      let(:repo) { File.expand_path(__FILE__) }

      it 'complains' do
        expect { subject }.to raise_error(Twigg::Repo::InvalidRepoError)
      end
    end

    context 'with a non-existent path' do
      let(:repo) { File.join(Dir.mktmpdir, 'non-existent') }

      it 'complains' do
        expect { subject }.to raise_error(Twigg::Repo::InvalidRepoError)
      end
    end
  end

  describe '#commits' do
    subject { described_class.new(repo).commits }

    context 'with an empty commit message' do
      let(:repo) do
        scratch_repo do
          `echo foo > bar`
          `git add bar`
          `git commit --allow-empty-message -m ''`
        end
      end

      it 'includes the commit with the empty message' do
        subject.length.should == 1
        subject.first.should be_a(Twigg::Commit)
      end
    end

    context 'with an empty commit' do
      let(:repo) do
        scratch_repo do
          `git commit --allow-empty -m 'Empty'`
        end
      end

      it 'includes the empty commit' do
        subject.length.should == 1
        subject.first.should be_a(Twigg::Commit)
        subject.first.subject.should == 'Empty'
      end
    end

    context 'with an empty commit with an empty message' do
      let(:repo) do
        scratch_repo do
          `git commit --allow-empty --allow-empty-message -m ''`
        end
      end

      it 'includes the empty commit with the empty message' do
        subject.length.should == 1
        subject.first.should be_a(Twigg::Commit)
      end
    end
  end
end
