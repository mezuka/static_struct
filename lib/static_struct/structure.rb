require 'set'

module StaticStruct
  class Structure
    attr_reader :static_methods

    def initialize(hash)
      @static_methods = SortedSet.new
      define_structure(hash)
    end

    def to_s
      joined_line = [self.class, current_state].map(&:to_s).select do |str|
        str.size > 0
      end.join(' ')

      "#<#{joined_line}>"
    end

    def inspect
      to_s
    end

    def ==(other)
      current_state == other.current_state
    end

    def each
      static_methods.each do |m|
        yield m, public_send(m)
      end
    end

    protected

    def current_state
      static_methods.map do |method|
        "#{method}=#{public_send(method)}"
      end.join(' ')
    end

    private

    def define_structure(hash)
      Hash(hash).each do |key, val|
        safe_define_method(key, val)
      end
    end

    def safe_define_method(method, return_value)
      if respond_to?(method)
        fail MethodAlreadyDefinedError, "`#{method}' is already defined for #{self}"
      end

      static_methods.add(method.to_s)
      case
      when return_value.is_a?(Array)
        define_singleton_method(method) do
          return_value.map do |array_value|
            if array_value.respond_to?(:to_hash)
              Structure.new(array_value)
            else
              array_value
            end
          end
        end
      when return_value.is_a?(Hash)
        define_singleton_method(method) { Structure.new(return_value) }
      when return_value.respond_to?(:to_hash)
        define_singleton_method(method) { Structure.new(Hash(return_value)) }
      else
        define_singleton_method(method) { return_value }
      end
    end
  end
end
