# frozen_string_literal: true

require 'forwardable'
module Taksi
  class Registry
    include ::Singleton

    class << self
      extend ::Forwardable

      def_delegators :instance, :find, :add, :clear!
    end

    class ScreenNotFoundError < ::StandardError; end
    class ScreenAltenativeNotFoundError < ::StandardError; end

    def initialize
      clear!
    end

    def add(klass, name)
      sym_name = name.to_sym

      @screens[sym_name] ||= []
      @screens[sym_name] << klass
    end

    def clear!
      @screens = {}
    end

    def find(name, version, alternative = nil)
      screens_from_name = @screens[name.to_sym]

      raise ScreenNotFoundError if screens_from_name.blank?

      parsed_version = ::Gem::Version.new(version)

      screen = screens_from_name.find do |screen|
        next false unless screen.version_pattern.satisfied_by?(parsed_version)

        next true if alternative.blank?

        next true if screen.alternatives.blank?

        next true if screen.alternatives.include?(alternative)

        false
      end

      raise ScreenNotFoundError if screen.blank?

      screen
    end
  end
end
