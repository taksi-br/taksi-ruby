require 'spec_helper'

RSpec.describe ::Taksi::Widgets::ContentKey do
  subject { described_class.new(skeleton, key, *argument) }

  let(:screen_skeleton) { ::Taksi::Screens::Skeleton.new }
  let(:skeleton) { screen_skeleton.create_widget('dummy_widget') }
  let(:key) { :dummy }

  context 'when with static fields' do
    let(:argument) { [::Taksi::Static, 'Static Random Value'] }

    context '#as_json' do
      it 'serializes correctly' do
        expect(subject.as_json).to eq({
          dummy: { type: 'static', value: 'Static Random Value' }
        })
      end
    end
  end

  context 'when with dynamic fields' do
    let(:argument) { [::Taksi::Dynamic, 'dynamic_path'] }

    context '#as_json' do
      it 'serializes correctly' do
        expect(subject.as_json).to eq({
          dummy: { type: 'dynamic', value: 'dynamic_path' }
        })
      end

      context 'with empty path' do
        let(:argument) { [::Taksi::Dynamic] }

        it 'creates a parameter path' do
          expect(subject.as_json).to eq({
            dummy: { type: 'dynamic', value: 'widget$0.dummy' }
          })
        end
      end
    end
  end
end
