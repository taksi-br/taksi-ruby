# frozen_string_literal: true

module Taksi
  module Screens
    class Skeleton
      class WidgetNotFoundError < StandardError; end

      def initialize
        @widget_skeletons = []
      end

      def create_widget(identifier, &block)
        ::Taksi::Widgets::Skeleton.new(self, identifier, &block).tap do |widget|
          add(widget)
        end
      end

      def add(widget_skeleton)
        @widget_skeletons << widget_skeleton
        self
      end

      def id_of(widget)
        index = @widget_skeletons.index(widget)

        raise WidgetNotFoundError unless index

        "widget$#{index}"
      end

      def as_json(*)
        {widgets: @widget_skeletons.map(&:as_json)}
      end
    end
  end
end
