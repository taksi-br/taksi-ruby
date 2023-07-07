# frozen_string_literal: true

module Taksi
  module Values
    class Static
      attr_reader :widget, :name, :value

      def initialize(widget, name, value)
        @widget = widget
        @name = name
        @value = value
      end

      def as_json
        {type: 'static', value: value}
      end

      def dynamic?
        false
      end
    end
  end

  # Just a shortcut for ::Taksi::Values::Static
  Static = Values::Static
end
