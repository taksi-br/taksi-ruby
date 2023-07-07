module Taksi
  module Widgets
    class ContentKey
      attr_reader :skeleton, :key, :value, :parent

      def initialize(skeleton, key, *args, parent: nil, &block)
        @skeleton = skeleton
        @key = key.to_sym
        @parent = parent

        @value = args.shift.new(skeleton, full_key, *args) if args.size > 0
        @nested_keys = []

        instance_exec(&block) if block_given?
        @defined = true
      end

      def full_key
        return key if parent.nil? || parent.root?

        "#{parent.full_key}.#{key}"
      end

      def fetch_from(data)
        return data[key]  if parent.nil? || parent.root?

        parent.fetch_from(data)[key]
      rescue NoMethodError
        raise NameError, "Couldn't fetch #{key.inspect} from data: #{data.inspect}"
      end

      def as_json
        return { key => @nested_keys.map(&:as_json).inject({}, &:merge) } if nested?

        { key => value.as_json }
      end

      def keys
        Enumerator.new do |yielder|
          @nested_keys.each do |key|
            if key.nested?
              key.keys.each(&yielder)
            else
              yielder << key
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

      def method_missing(name, *args, &block)
        return super if @defined

        @nested_keys << self.class.new(skeleton, name, *args, parent: self, &block)
      end
    end
  end
end
