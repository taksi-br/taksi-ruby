# frozen_string_literal: true

module Taksi
  module Values
    class Dynamic
      attr_reader :component, :name, :field

      def initialize(component, name, field = nil)
        @component = component
        @name = name
        @field = field
      end

      def path
        return field if field

        "#{component.id}.#{name}"
      end

      def as_json
        nil
      end

      def dynamic?
        true
      end

      def static?
        false
      end
    end
  end

  # Just a shortcut for ::Taksi::Values::Static
  Dynamic = Values::Dynamic
end
