# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Interface do
  subject { DummyInterface.new }

  before do
    class DummyComponent
      include ::Taksi::Component.new('dummy/component')

      content do
        title Taksi::Dynamic
      end
    end

    class DummyInterface
      include ::Taksi::Interface.new('dummy-interface', '> 1.0')

      add DummyComponent, with: :dummy_data

      def dummy_data
        {title: 'dummy_value'}
      end
    end
  end

  after do
    Object.send(:remove_const, :DummyInterface)
    Object.send(:remove_const, :DummyComponent)
  end

  describe '.find' do
    it 'finds a interface by its name and version' do
      expect(described_class.find('dummy-interface', '1.2')).to eq(DummyInterface)
    end

    context 'when interface do not exists' do
      it 'raises an error' do
        expect { described_class.find('dummy-interface', '0.3') }.to raise_error(Taksi::Registry::InterfaceNotFoundError)
      end
    end
  end

  describe '#skeleton' do
    it 'returns the interface skeleton' do
      skeleton = subject.skeleton

      expect(skeleton).to be_kind_of(Taksi::Interfaces::Skeleton)
      expect(skeleton.as_json).to eq({
                                       components: [
                                         {
                                           name: 'dummy/component',
                                           identifier: 'component$0',
                                           requires_data: true,
                                           content: {
                                             title: nil
                                           }
                                         }
                                       ]
                                     })
    end
  end

  describe '#data' do
    it 'returns the interface data' do
      interface_data = subject.data

      expect(interface_data).to eq([
        {
          identifier: 'component$0',
          content: {
            title: 'dummy_value'
          }
        }
      ])
    end
  end
end
