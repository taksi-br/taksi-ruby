# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Interface do
  subject { DummyInterface.new }

  before do
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

    context 'when using interface shortcut' do
      before do
        class DummyInterfaceV2
          include ::Taksi::Interface.new('dummy-interface', '~> 2.0')

          add DummyComponent, with: :dummy_data

          def dummy_data
            {title: 'dummy_value'}
          end
        end
      end

      after do
        Object.send(:remove_const, :DummyInterfaceV2)
      end

      it 'finds same interface but in other version' do
        expect(DummyInterface.find('2.3')).to eq(DummyInterfaceV2)
        expect(described_class.find('dummy-interface', '2.3')).to eq(DummyInterfaceV2)
      end
    end

    context 'when looking for an alternative' do
      before do
        class DummyInterfaceV2
          include ::Taksi::Interface.new('dummy-interface', '~> 2.0', alternatives: %w[A B])

          add DummyComponent, with: :dummy_data

          def dummy_data
            {title: 'dummy_value'}
          end
        end

        class DummyInterfaceV2Other
          include ::Taksi::Interface.new('dummy-interface', '~> 2.0', alternatives: ['C'])

          add DummyComponent, with: :dummy_data

          def dummy_data
            {title: 'dummy_value'}
          end
        end
      end

      after do
        Object.send(:remove_const, :DummyInterfaceV2)
        Object.send(:remove_const, :DummyInterfaceV2Other)
      end

      it 'finds same interface but in other version' do
        expect(DummyInterface.find('2.3', 'A')).to eq(DummyInterfaceV2)
        expect(described_class.find('dummy-interface', '2.3', alternative: 'A')).to eq(DummyInterfaceV2)
        expect(DummyInterfaceV2Other.find('2.3', 'A')).to eq(DummyInterfaceV2)
        expect(DummyInterfaceV2.find('2.3', 'C')).to eq(DummyInterfaceV2Other)
        expect(DummyInterface.find('2.3', 'C')).to eq(DummyInterfaceV2Other)
        expect(described_class.find('dummy-interface', '2.3', alternative: 'C')).to eq(DummyInterfaceV2Other)
      end

      context 'when interface has no alternative' do
        it 'fits any alternative' do
          expect(described_class.find('dummy-interface', '1.3', alternative: 'A')).to eq(DummyInterface)
          expect(DummyInterface.find('1.3', alternative: 'ANY')).to eq(DummyInterface)
        end
      end

      context 'when alternative cannot be found' do
        it 'raises an error' do
          expect { described_class.find('dummy-interface', '2.3', alternative: 'ANY') }.to raise_error(Taksi::Registry::InterfaceNotFoundError)
        end
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

    context 'when pass options to interface' do
      subject { DummyInterface.new(**options) }

      let(:options) { {custom_option_data: 'custom_option_data_value'} }

      before do
        class DummyInterface
          def dummy_data
            {title: options[:custom_option_data]}
          end
        end
      end

      it 'returns the interface data' do
        interface_data = subject.data

        expect(interface_data).to eq([
          {
            identifier: 'component$0',
            content: {
              title: 'custom_option_data_value'
            }
          }
        ])
      end
    end
  end
end
