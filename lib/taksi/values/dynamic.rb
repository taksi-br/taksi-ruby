# frozen_string_literal: true

module Taksi
  module Values
    class Dynamic
      attr_reader :widget, :name, :content_key

      def initialize(widget, name, content_key = nil)
        @widget = widget
        @name = name
        @content_key = content_key
      end

      def path
        return content_key if content_key

        "#{widget.id}.#{name}"
      end

      def as_json
        {type: 'dynamic', value: path}
      end

      def dynamic?
        true
      end
    end
  end

  # Just a shortcut for ::Taksi::Values::Static
  Dynamic = Values::Dynamic
end
