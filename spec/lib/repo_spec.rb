require 'spec_helper'

describe Twigg::Repo do
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
