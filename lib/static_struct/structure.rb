require 'set'

module StaticStruct
  class Structure
    attr_reader :static_methods

    def initialize(hash)
      @static_methods = SortedSet.new
      define_structure(self, hash)
    end

    def to_s
      joined_line = [self.class, current_state].map(&:to_s).select do |str|
        str.size > 0
      end.join(' ')

      "#<#{joined_line}>"
    end

    def ==(other)
      current_state == other.current_state
    end

    protected

    def current_state
      static_methods.map do |method|
        "#{method} = #{public_send(method)}"
      end.join(' ')
    end

    private

    def define_structure(parent, hash)
      Hash(hash).each do |key, val|
        safe_define_method(parent, key, val)
      end
    end

    def safe_define_method(object, method, return_value)
      if object.respond_to?(method)
        fail MethodAlreadyDefinedError, "`#{method}' is already defined for #{object}"
      end

      object.static_methods.add(method.to_sym)
      case
      when return_value.is_a?(Array)
        object.define_singleton_method(method) do
          return_value.map do |array_value|
            if array_value.respond_to?(:to_hash)
              Structure.new(array_value)
            else
              array_value
            end
          end
        end
      when return_value.is_a?(Hash)
        object.define_singleton_method(method) { Structure.new(return_value) }
      when return_value.respond_to?(:to_hash)
        object.define_singleton_method(method) { Structure.new(Hash(return_value)) }
      else
        object.define_singleton_method(method) { return_value }
      end
    end
  end
end
