# frozen_string_literal: true

module Taksi
  module Components
    class Field
      attr_reader :skeleton, :name, :value, :parent

      def initialize(skeleton, name, *args, parent: nil, &block)
        @skeleton = skeleton
        @name = name.to_sym
        @parent = parent

        raise <<~MESSAGE unless args.size.positive? || block_given?
          You must provide a value or a block definition to build field
        MESSAGE

        @value = args.shift.new(skeleton, name, *args) if args.size.positive?
        @nested_fields = []

        instance_exec(&block) if block_given?
      end

      def key
        return name if parent.nil? || parent.root?

        "#{parent.key}.#{name}"
      end

      # Fetches the data for in `data` for the current field
      # @return any
      def fetch_from(data)
        return value.as_json if value&.static?

        return data[name] if parent.nil? || parent.root?

        parent.fetch_from(data)[name]
      rescue NoMethodError
        raise NameError, "Couldn't fetch #{name.inspect} from data: #{data.inspect}"
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

      def field(name, *args, &block)
        self.class.new(skeleton, name, *args, parent: self, &block).tap do |new_field|
          @nested_fields << new_field
        end
      end

      def nested(name, &block)
        field(name, &block)
      end

      def static(name, value)
        field(name, ::Taksi::Values::Static, value)
      end

      def dynamic(name)
        field(name, ::Taksi::Values::Dynamic)
      end
    end
  end
end
