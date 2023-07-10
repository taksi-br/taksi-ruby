# frozen_string_literal: true

module Taksi
  module Interfaces
    class Skeleton
      class ComponentNotFoundError < StandardError; end

      def initialize
        @component_skeletons = []
      end

      def create_component(identifier, &block)
        ::Taksi::Components::Skeleton.new(self, identifier, &block).tap do |component|
          add(component)
        end
      end

      def add(component_skeleton)
        @component_skeletons << component_skeleton
        self
      end

      def id_of(component)
        index = @component_skeletons.index(component)

        raise ComponentNotFoundError unless index

        "component$#{index}"
      end

      def as_json(*)
        {components: @component_skeletons.map(&:as_json)}
      end
    end
  end
end
