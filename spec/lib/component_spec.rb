# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Component do
  subject { DummyComponent.new(interface) }

  let(:interface) { DummyInterface.new }

  before do
    class DummyComponent
      include ::Taksi::Component.new('dummy/component')

      content { }
    end

    class DummyInterface
      include ::Taksi::Interface.new('dummy/interface')
    end
  end

  after do
    Object.send(:remove_const, :DummyInterface)
    Object.send(:remove_const, :DummyComponent)
  end

  context 'on class definition' do
    subject { DummyComponent }

    it 'set ups right readers' do
      expect(subject.identifier).to eq('dummy/component')
    end
  end

  context 'on empty component' do
    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Components::Skeleton)
      expect(subject.skeleton.as_json).to eq({
                                               name: 'dummy/component',
                                               identifier: 'component$0',
                                               requires_data: false,
                                               content: {}
                                             })
    end
  end

  context 'on component with multiple contents' do
    before do
      class DummyComponent
        content do
          type ::Taksi::Static, 'dummy_static_value'
          title ::Taksi::Dynamic, 'dynamic_value.path'
          # value ::Taksi::Parameter, 'dummy_parameter'
        end
      end
    end

    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Components::Skeleton)
      expect(subject.skeleton.as_json).to eq({
                                               name: 'dummy/component',
                                               identifier: 'component$0',
                                               requires_data: true,
                                               content: {
                                                 type: 'dummy_static_value',
                                                 title: nil
                                               }
                                             })
    end
  end

  context 'on component with nested content' do
    before do
      class DummyComponent
        content do
          title ::Taksi::Dynamic, 'dynamic_value.path'

          nested do
            type ::Taksi::Static, 'dummy_static_value'
            title ::Taksi::Dynamic, 'dynamic_value.path'

            too_nested do
              again ::Taksi::Static, 'dummy_static_value'
            end
          end
        end
      end
    end

    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Components::Skeleton)
      expect(subject.skeleton.as_json).to eq({
                                               name: 'dummy/component',
                                               identifier: 'component$0',
                                               requires_data: true,
                                               content: {
                                                 title: nil,
                                                 nested: {
                                                   type: 'dummy_static_value',
                                                   title: nil,
                                                   too_nested: {
                                                    again: 'dummy_static_value',
                                                   }
                                                 }
                                               }
                                             })
    end
  end
end
