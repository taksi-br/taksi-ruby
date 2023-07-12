# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Components::Field do
  subject { described_class.new(skeleton, key, *argument) }

  let(:interface_skeleton) { ::Taksi::Interfaces::Skeleton.new }
  let(:skeleton) { interface_skeleton.create_component('dummy_component') {  } }
  let(:key) { :dummy }

  context 'when with static fields' do
    let(:argument) { [::Taksi::Static, 'Static Random Value'] }

    context '#as_json' do
      it 'serializes correctly' do
        expect(subject.as_json).to eq({dummy: 'Static Random Value'})
      end
    end

    context '#fetch_from' do
      it 'returns the static data' do
        expect(subject.fetch_from({})).to eq('Static Random Value')
      end
    end
  end

  context 'when with dynamic fields' do
    let(:argument) { [::Taksi::Dynamic, 'dynamic_path'] }

    context '#as_json' do
      it 'serializes correctly' do
        expect(subject.as_json).to eq({dummy: nil})
      end

      context 'with empty path' do
        let(:argument) { [::Taksi::Dynamic] }

        it 'creates a parameter path' do
          expect(subject.as_json).to eq({dummy: nil})
        end
      end
    end

    context '#fetch_from' do
      let(:data) { {dummy: 'the_right_data'} }

      it 'return the related data to the key' do
        expect(subject.fetch_from(data)).to eq('the_right_data')
      end
    end
  end
end
