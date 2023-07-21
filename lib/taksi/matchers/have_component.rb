# frozen_string_literal: true

module Taksi
  module Matchers
    class HaveComponent
      def initialize(definition)
        @definition = definition

        @found_contents = []
      end

      def matches?(interface)
        @interface = interface

        interface.components.any? do |component|
          next unless component.is_a?(@definition)
          next unless matches_content?(component, interface)

          true
        end
      end

      def with_content(**content)
        @content = content
        self
      end

      def failure_message
        return other_contents_found_failure if @found_contents.size.positive?

        no_components_found_failure
      end

      private

      def matches_content?(_component, interface)
        return true if @content.nil?

        interface.components.any? do |interface_component|
          interface_component_content = interface_component.content_for(interface)

          return true if @content == interface_component_content

          @found_contents << [interface_component, interface_component_content]
          false
        end
      end

      def no_components_found_failure
        <<~MESSAGE
          Expected component #{@definition.name} ('#{@definition.component_name}') but it couldn't be found on interface #{@interface.class.name}.
        MESSAGE
      end

      def other_contents_found_failure
        <<~MESSAGE
          Expected component #{@definition.name} ('#{@definition.component_name}') was found but with different contents:\n
          #{each_found_contents_diff_for_failure}
        MESSAGE
      end

      def each_found_contents_diff_for_failure
        @found_contents.map do |tuple|
          component, content = tuple

          <<~MESSAGE
            Content diff for component '#{component.identifier}' ('#{component.name}'):
              #{hash_differ.diff_as_object(content, @content)}
          MESSAGE
        end.join
      end

      def hash_differ
        ::RSpec::Support::Differ.new(
          object_preparer: lambda { |object|
                             RSpec::Matchers::Composable.surface_descriptions_in(object)
                           },
          color: ::RSpec::Matchers.configuration.color?
        )
      end
    end
  end
end
