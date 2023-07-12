# frozen_string_literal: true

module Taksi
  module Components
    class Field
      attr_reader :skeleton, :name, :value, :parent

      def initialize(skeleton, name, *args, parent: nil, &block)
        @skeleton = skeleton
        @name = name.to_sym
        @parent = parent

        raise 'You must provide a value or a block definition to build field' unless args.size.positive? || block_given?

        @value = args.shift.new(skeleton, name, *args) if args.size.positive?
        @nested_fields = []

        instance_exec(&block) if block_given?
        @defined = true
      end

      def key
        return name if parent.nil? || parent.root?

        "#{parent.name}.#{name}"
      end

      # Fetches the data for in `data` for the current field
      # @return any
      def fetch_from(data)
        return value.as_json if value.static?

        return data[name] if parent.nil? || parent.root?

        parent.fetch_from(data)[name]
      rescue NoMethodError
        raise NameError, "Couldn't fetch #{key.inspect} from data: #{data.inspect}"
      end

      # Turns the field into his json representation
      # The returned hash is compatible with the skeleton json specification
      # @return Hash
      def as_json
        return {name => @nested_fields.map(&:as_json).inject({}, &:merge)} if nested?

        {name => value.as_json}
      end

      # Builds up a interator over all fields included nested ones
      # @returns Enumerable
      def fields
        Enumerator.new do |yielder|
          @nested_fields.each do |field|
            if field.nested?
              field.fields.each(&yielder)
            else
              yielder << field
            end
          end
        end
      end

      def nested?
        @value.nil?
      end

      def root?
        @parent.nil?
      end

      def dynamic?
        return @nested_fields.any?(&:dynamic?) if @value.nil?

        @value.dynamic?
      end

      def method_missing(name, *args, &block)
        return super if @defined

        @nested_fields << self.class.new(skeleton, name, *args, parent: self, &block)
      end

      def respond_to_missing?(name, *)
        return super if @defined

        true
      end
    end
  end
end
