# frozen_string_literal: true

module Taksi
  class Screen < ::Module
    attr_reader :page_name, :version_pattern, :alternatives

    def self.find(name, version, alternative: nil)
      ::Taksi::Registry.find(name, version, alternative)
    end

    def initialize(name, version_pattern = nil, alternatives: nil)
      @page_name = name
      @version_pattern = ::Gem::Requirement.new(version_pattern)
      @alternatives = alternatives
    end

    def included(klass)
      klass.extend(ClassMethods)
      klass.include(InstanceMethods)

      klass.initiate(self)

      ::Taksi::Registry.add(klass, page_name)
    end

    module ClassMethods
      attr_reader :widgets, :skeleton

      def find(version, alternative = nil)
        ::Taksi::Registry.find(page_name, version, alternative)
      end

      def initiate(screen_definition)
        @widgets = []
        @screen_definition = screen_definition
        @skeleton = ::Taksi::Screens::Skeleton.new
      end

      def add(widget_class, with: nil)
        @widgets << widget_class.new(self, with: with)
      end

      def widgets
        @widgets.each
      end

      def version_pattern
        @screen_definition.version_pattern
      end

      def alternatives
        @screen_definition.alternatives
      end
    end

    module InstanceMethods
      def skeleton
        self.class.skeleton
      end

      def data
        self.class.widgets.each_with_object({}) do |widget, obj|
          obj.merge!(widget.data_for(self).as_json)
        end
      end
    end
  end
end
