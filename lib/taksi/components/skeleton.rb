# frozen_string_literal: true

module Taksi
  module Components
    class Skeleton
      attr_reader :parent, :name, :content

      def initialize(parent, name, &block)
        @parent = parent
        @name = name

        raise 'To build a component you need to provide a `content` block' unless block_given?

        @content = ::Taksi::Components::Field.new(self, :content, &block)
      end

      def id
        parent.id_of(self)
      end

      def fields
        content.fields
      end

      def dynamic?
        @content.dynamic?
      end

      def as_json
        {
          name: name,
          identifier: id,
          requires_data: dynamic?
        }.tap do |json|
          json.merge!(content.as_json)
        end
      end
    end
  end
end
