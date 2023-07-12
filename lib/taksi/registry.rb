# frozen_string_literal: true

module Taksi
  class Registry
    include ::Singleton

    NAME_REGEX = /^[a-z\-\_\/]{1,80}$/i

    class << self
      extend ::Forwardable

      def_delegators :instance, :find, :add, :clear!
    end

    class InterfaceNotFoundError < ::StandardError; end
    class InterfaceAltenativeNotFoundError < ::StandardError; end

    def initialize
      clear!
    end

    def add(klass, name)
      raise StandardError, "Invalid interface name '#{name}', it must to match regex '#{NAME_REGEX.inspect}'" unless name.to_s.match?(NAME_REGEX)

      sym_name = name.to_sym

      @interfaces[sym_name] ||= []
      @interfaces[sym_name] << klass
    end

    def clear!
      @interfaces = {}
    end

    def find(name, version, alternative = nil)
      interfaces_from_name = @interfaces[name.to_sym]

      raise InterfaceNotFoundError if interfaces_from_name.nil?

      parsed_version = ::Gem::Version.new(version)

      found_interface = interfaces_from_name.find do |interface|
        next false unless interface.version_pattern.satisfied_by?(parsed_version)

        next true if alternative.nil?

        next true if interface.alternatives.nil?

        next true if interface.alternatives.include?(alternative)

        false
      end

      raise InterfaceNotFoundError if found_interface.nil?

      found_interface
    end
  end
end
