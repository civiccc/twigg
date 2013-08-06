require 'spec_helper'

describe Twigg::PairMatrix do
  subject { described_class.new(commit_set) }

  describe '#[]' do
    context 'with an empty matrix' do
      let(:commit_set) { [] }

      it 'returns zero for solo commits' do
        expect(subject['Royce Royson']['Royce Royson']).to be_zero
      end

      it 'returns zero for pair commits' do
        expect(subject['Lee Hwang']['Rooptag Googliogg']).to be_zero
      end
    end

    context 'for a (non-)contributor who has not made any commits' do
      let(:commit_set) do
        Twigg::CommitSet.new([
          build(:commit, author: 'Guybrush Threepwood'),
          build(:commit, author: 'Jake Stalin & Guybrush Threepwood'),
        ])
      end

      it 'returns zero solo commits' do
        expect(subject['John Nobody']['John Nobody']).to be_zero
      end

      it 'returns zero commits as pairer' do
        expect(subject['John Nobody']['Guybrush Threepwood']).to be_zero
      end

      it 'returns zero commits as pairee' do
        expect(subject['Guybrush Threepwood']['John Nobody']).to be_zero
      end
    end

    context 'for a contributor who has made only solo commits' do
      let(:commit_set) do
        Twigg::CommitSet.new([
          build(:commit, author: 'Ruth Billington & Corriander Febblewobble'),
          build(:commit, author: 'Old Greg'),
          build(:commit, author: 'Old Greg'),
        ])
      end

      it 'returns the count of solo commits' do
        expect(subject['Old Greg']['Old Greg']).to eq(2)
      end

      it 'returns zero commits as pairer' do
        expect(subject['Old Greg']['Ruth Billington']).to be_zero
      end

      it 'returns zero commits as pairee' do
        expect(subject['Ruth Billington']['Old Greg']).to be_zero
      end
    end

    context 'for a contributor who has made only pair commits' do
      let(:commit_set) do
        Twigg::CommitSet.new([
          build(:commit, author: 'Xavier Minniecon & Sylvia Smith'),
          build(:commit, author: 'Xavier Minniecon + Sylvia Smith'),
          build(:commit, author: 'Jeeves Sumner, Xavier Minniecon and Kyle Largs'),
          build(:commit, author: 'Douglas K Eckthorpe'),
        ])
      end

      it 'returns the count of pair commits as pairer' do
        expect(subject['Xavier Minniecon']['Sylvia Smith']).to eq(2)
        expect(subject['Xavier Minniecon']['Jeeves Sumner']).to eq(1)
        expect(subject['Xavier Minniecon']['Kyle Largs']).to eq(1)
        expect(subject['Xavier Minniecon']['Douglas K Eckthorpe']).to be_zero
      end

      it 'returns the count of pair commits as pairee' do
        expect(subject['Sylvia Smith']['Xavier Minniecon']).to eq(2)
        expect(subject['Jeeves Sumner']['Xavier Minniecon']).to eq(1)
        expect(subject['Kyle Largs']['Xavier Minniecon']).to eq(1)
        expect(subject['Douglas K Eckthorpe']['Xavier Minniecon']).to be_zero
      end

      it 'returns zero solo commits' do
        expect(subject['Xavier Minniecon']['Xavier Minniecon']).to be_zero
      end
    end

    context 'for a contributor who has made both solo and pair commits' do
      let(:commit_set) do
        Twigg::CommitSet.new([
          build(:commit, author: 'Kim Mason'),
          build(:commit, author: 'Kim Mason'),
          build(:commit, author: 'Kim Mason and Nebs Petrovic'),
          build(:commit, author: 'Nebs Petrovic & Tony Wooster'),
        ])
      end

      it 'returns the count of pair commits as pairer' do
        expect(subject['Kim Mason']['Nebs Petrovic']).to eq(1)
        expect(subject['Kim Mason']['Tony Wooster']).to be_zero
      end

      it 'returns the count of pair commits as pairee' do
        expect(subject['Nebs Petrovic']['Kim Mason']).to eq(1)
        expect(subject['Tony Wooster']['Kim Mason']).to be_zero
      end

      it 'returns the count of solo commits' do
        expect(subject['Kim Mason']['Kim Mason']).to eq(2)
      end
    end
  end
end
