# frozen_string_literal: true

module Taksi
  class Widget < ::Module
    attr_reader :identifier

    def initialize(identifier)
      @identifier = identifier
    end

    def included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)

      klass.definition = self
    end

    module ClassMethods
      attr_reader :content_builder

      def definition=(widget_definition)
        @widget_definition = widget_definition
      end

      def identifier
        @widget_definition.identifier
      end

      def content(&block)
        @content_builder = block
        self
      end
    end

    module InstanceMethods
      attr_reader :page_definition, :datasource, :skeleton

      def initialize(page_definition, with: nil)
        @page_definition = page_definition
        @datasource = with
        @skeleton = @page_definition.skeleton.create_widget(self.class.identifier,
                                                            &self.class.content_builder)
      end

      def data_for(page_instance)
        data = page_instance.send(datasource)

        skeleton.keys.each_with_object({}) do |content_key, obj|
          next unless content_key.value.dynamic?

          load_data_from_key_to_object(data, content_key, obj)
        end
      end

      private

      def load_data_from_key_to_object(data, content_key, obj)
        splitted_full_path = content_key.value.path.split('.')
        setter_key = splitted_full_path.pop

        relative_object = splitted_full_path.reduce(obj) do |memo, path_part|
          memo[path_part] ||= {}
        end

        relative_object[setter_key] = content_key.fetch_from(data)
      end
    end
  end
end
