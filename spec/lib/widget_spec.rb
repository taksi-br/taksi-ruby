require 'spec_helper'

RSpec.describe ::Taksi::Widget do
  subject { DummyWidget.new(page) }

  let(:page) { DummyScreen.new }

  before do
    class DummyWidget
      include ::Taksi::Widget.new('dummy/widget')
    end

    class DummyScreen
      include ::Taksi::Screen.new('dummy/screen')
    end
  end

  after do
    Object.send(:remove_const, :DummyScreen)
    Object.send(:remove_const, :DummyWidget)
  end

  context 'on class definition' do
    subject { DummyWidget }

    it 'set ups right readers' do
      expect(subject.identifier).to eq('dummy/widget')
    end
  end

  context 'on empty widget' do
    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Widgets::Skeleton)
      expect(subject.skeleton.as_json).to eq({
        identifier: 'dummy/widget',
        content: {}
      })
    end
  end

  context 'on widget with multiple contents' do
    before do
      class DummyWidget
        content do
          type ::Taksi::Static, 'dummy_static_value'
          title ::Taksi::Dynamic, 'dynamic_value.path'
          # value ::Taksi::Parameter, 'dummy_parameter'
        end
      end
    end

    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Widgets::Skeleton)
      expect(subject.skeleton.as_json).to eq({
        identifier: 'dummy/widget',
        content: {
          type: { type: 'static', value: 'dummy_static_value' },
          title: { type: 'dynamic', value: 'dynamic_value.path' },
          # value: { type: 'parameter', value: 'dummy_parameter' },
        }
      })
    end
  end

  context 'on widget with nested content' do
    before do
      class DummyWidget
        content do
          title ::Taksi::Dynamic, 'dynamic_value.path'

          nested do
            type ::Taksi::Static, 'dummy_static_value'
            title ::Taksi::Dynamic, 'dynamic_value.path'
            # value ::Taksi::Parameter, 'dummy_parameter'
          end
        end
      end
    end

    it 'builds up a serializable skeleton' do
      expect(subject.skeleton).to be_kind_of(::Taksi::Widgets::Skeleton)
      expect(subject.skeleton.as_json).to eq({
        identifier: 'dummy/widget',
        content: {
          title: { type: 'dynamic', value: 'dynamic_value.path' },
          nested: {
            type: { type: 'static', value: 'dummy_static_value' },
            title: { type: 'dynamic', value: 'dynamic_value.path' },
            # value: { type: 'parameter', value: 'dummy_parameter' },
          }
        }
      })
    end
  end
end
