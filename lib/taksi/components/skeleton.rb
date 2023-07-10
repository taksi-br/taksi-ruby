# frozen_string_literal: true

module Taksi
  module Components
    class Skeleton
      attr_reader :parent, :name, :content

      def initialize(parent, name, &block)
        @parent = parent
        @name = name

        @content = ::Taksi::Components::Field.new(self, :content, &block)
      end

      def id
        parent.id_of(self)
      end

      def fields
        content.fields
      end

      def as_json
        {
          name: name,
          identifier: id
        }.tap do |json|
          json.merge!(content.as_json)
        end
      end
    end
  end
end
