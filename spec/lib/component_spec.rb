# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Taksi::Component do
  subject { DummyComponent.new(interface) }

  let(:interface) { DummyInterface }

  before do
    class DummyComponent
      include ::Taksi::Component.new('dummy/component')

      content {}
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
          field :type, ::Taksi::Static, 'dummy_static_value'
          field :title, ::Taksi::Dynamic, 'dynamic_value.path'
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
          field :title, ::Taksi::Dynamic

          field :first_level do
            field :type, ::Taksi::Static, 'dummy_static_value'
            field :title, ::Taksi::Dynamic

            field :second_level do
              static :again, 'dummy_static_value'
              dynamic :other
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
                                                 first_level: {
                                                   type: 'dummy_static_value',
                                                   title: nil,
                                                   second_level: {
                                                     again: 'dummy_static_value',
                                                     other: nil
                                                   }
                                                 }
                                               }
                                             })
    end

    context 'when fetching data' do
      subject { DummyComponent.new(interface, with: :datasource) }

      before do
        class DummyInterface
          def datasource
            {
              first_level: {
                title: 'Dynamic data',
                second_level: {
                  other: 'More dynamic data'
                }
              }
            }
          end
        end
      end

      it 'fetches data correctly' do
        expect(subject.content_for(interface.new)).to eq({
          title: nil,
          first_level: {
            type: 'dummy_static_value',
            title: 'Dynamic data',
            second_level: {
              again: 'dummy_static_value',
              other: 'More dynamic data'
            }
          }
        })
      end
    end
  end
end
