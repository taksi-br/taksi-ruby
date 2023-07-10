# frozen_string_literal: true

module Taksi
  module Values
    class Static
      attr_reader :component, :name, :value

      def initialize(component, name, value)
        @component = component
        @name = name
        @value = value
      end

      def as_json
        value
      end

      def dynamic?
        false
      end

      def static?
        true
      end
    end
  end

  # Just a shortcut for ::Taksi::Values::Static
  Static = Values::Static
end
