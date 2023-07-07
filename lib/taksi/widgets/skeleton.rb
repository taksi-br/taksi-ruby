# frozen_string_literal: true

module Taksi
  module Widgets
    class Skeleton
      attr_reader :parent, :identifier, :content

      def initialize(parent, identifier, &block)
        @parent = parent
        @identifier = identifier

        @content = ::Taksi::Widgets::ContentKey.new(self, :content, &block)
      end

      def id
        parent.id_of(self)
      end

      def keys
        content.keys
      end

      def as_json
        {identifier: identifier}.tap do |json|
          json.merge!(content.as_json)
        end
      end
    end
  end
end
