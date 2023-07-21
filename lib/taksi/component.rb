# frozen_string_literal: true

module Taksi
  # A custom module to turn a class into a component on taksi protocol
  #
  # ```ruby
  #   class CustomComponent
  #     include Taksi::Component.new('customs/component_name')
  #
  #     content do
  #       field_name Taksi::Static
  #     end
  #   end
  # ```
  #
  class Component < ::Module
    attr_reader :component_name

    def initialize(component_name)
      @component_name = component_name
      super()
    end

    def included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)

      klass.definition = self
    end

    module ClassMethods
      attr_reader :content_builder

      def definition=(component_definition)
        @component_definition = component_definition
      end

      def component_name
        @component_definition.component_name
      end

      def content(&block)
        @content_builder = block
        self
      end
    end

    module InstanceMethods
      attr_reader :interface_definition, :datasource, :skeleton

      def initialize(interface_definition, with: nil)
        @interface_definition = interface_definition
        @datasource = with
        @skeleton = @interface_definition.skeleton.create_component(self.class.component_name,
                                                                    &self.class.content_builder)
        super()
      end

      def name
        self.class.component_name
      end

      def identifier
        @skeleton.id
      end

      def content_for(interface)
        data = interface.send(datasource)

        fetch(data)
      end

      def fetch(data)
        skeleton.content.fetch({content: data})
      end
    end
  end
end
