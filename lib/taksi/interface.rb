# frozen_string_literal: true

module Taksi
  # A custom module that turns a class into a interface on taksi protocol
  #
  class Interface < ::Module
    attr_reader :interface_name, :version_pattern, :alternatives

    # Finds for a interface by its name and the current version
    # @param name [String]
    # @param version [String] just like '0.2.1'
    # @param alternatives: [Array]
    # @raises`::Taksi::Registry::InterfaceNotFoundError`
    # @return Class the class of interface
    def self.find(name, version, alternative: nil)
      ::Taksi::Registry.find(name, version, alternative)
    end

    def initialize(name, version_pattern = nil, alternatives: nil)
      @interface_name = name
      @version_pattern = ::Gem::Requirement.new(version_pattern)
      @alternatives = alternatives
      super()
    end

    def included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)

      klass.initiate(self)

      ::Taksi::Registry.add(klass, interface_name)
    end

    module ClassMethods
      attr_reader :skeleton

      def find(version, alternative = nil)
        ::Taksi::Registry.find(interface_name, version, alternative)
      end

      def initiate(interface_definition)
        @components = []
        @interface_definition = interface_definition
        @skeleton = ::Taksi::Interfaces::Skeleton.new
      end

      def add(component_class, with: nil)
        @components << component_class.new(self, with: with)
      end

      def components
        @components.each
      end

      def version_pattern
        @interface_definition.version_pattern
      end

      def alternatives
        @interface_definition.alternatives
      end
    end

    module InstanceMethods
      def skeleton
        self.class.skeleton
      end

      def data
        self.class.components.map do |component|
          {
            identifier: component.id,
            content: component.content_for(self)
          }
        end
      end
    end
  end
end
