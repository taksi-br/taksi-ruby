# frozen_string_literal: true

module Taksi
  class Component < ::Module
    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
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

      def identifier
        @component_definition.identifier
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
        @skeleton = @interface_definition.skeleton.create_component(self.class.identifier,
                                                                    &self.class.content_builder)
        super()
      end

      def id
        @skeleton.id
      end

      def content_for(interface)
        data = interface.send(datasource)

        skeleton.fields.each_with_object({}) do |field, obj|
          load_data_from_key_to_object(data, field, obj)
        end
      end

      private

      def load_data_from_key_to_object(data, field, obj)
        splitted_full_path = field.key.to_s.split('.')
        setter_key = splitted_full_path.pop
        splitted_full_path.shift # remove content root key, as it makes no sense in data object

        relative_object = splitted_full_path.reduce(obj) do |memo, path_part|
          memo[path_part.to_sym] ||= {}
        end

        relative_object[setter_key.to_sym] = field.fetch_from(data)
      end
    end
  end
end
