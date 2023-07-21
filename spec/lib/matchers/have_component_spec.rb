# frozen_string_literal: true

require 'spec_helper'

require 'taksi/matchers'

RSpec.describe ::Taksi::Matchers::HaveComponent do
  subject { described_class.new(definition) }

  let(:definition) { DummyComponent }
  let(:interface) { DummyInterface.new }

  before do
    class DummyOtherComponent
      include ::Taksi::Component.new('dummy/other_component')

      content do
        field :title, Taksi::Dynamic
      end
    end

    class DummyComponent
      include ::Taksi::Component.new('dummy/component')

      content do
        field :title, Taksi::Dynamic
      end
    end

    class DummyInterface
      include ::Taksi::Interface.new('dummy-interface', '~> 1.0')

      add DummyComponent, with: :dummy_data

      def dummy_data
        {title: 'dummy_value'}
      end
    end
  end

  context 'when interface includes the component' do
    it 'matches' do
      expect(subject).to be_matches(interface)
    end

    context 'when component cannot be found' do
      let(:definition) { DummyOtherComponent }

      it 'gives an error failure_message' do
        expect(subject).not_to be_matches(interface)

        expect(subject.failure_message).to eq(<<~MESSAGE)
          Expected component DummyOtherComponent ('dummy/other_component') but it couldn't be found on interface DummyInterface.
        MESSAGE
      end
    end

    context 'when matching the content' do
      before do
        subject.with_content(title: 'dummy_value')
      end

      it 'matches' do
        expect(subject).to be_matches(interface)
      end
    end

    context 'when has component with different contents' do
      before do
        subject.with_content(wrong_field: 'dummy_value')
      end

      it 'gives an error failure_message' do
        expect(subject).not_to be_matches(interface)

        expect(subject.failure_message.gsub(/\e\[(\d+)m/, '')).to eq(<<~MESSAGE)
          Expected component DummyComponent ('dummy/component') was found but with different contents:

          Content diff for component 'component$0' ('dummy/component'):
          \s\s
          @@ -1 +1 @@
          -:wrong_field => "dummy_value",
          +:title => "dummy_value",


        MESSAGE
      end
    end
  end
end
