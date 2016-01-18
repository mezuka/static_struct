module StaticStruct
  class Structure
    attr_reader :static_methods

    def initialize(hash)
      @static_methods = []
      define_structure(self, hash)
    end

    def inspect
      methods = static_methods.sort.each_with_object({}) do |method, result|
        result[method] = public_send(method)
      end
      "#<#{self.class} #{methods}>"
    end

    def ==(other)
      inspect == other.inspect
    end

    private

    def define_structure(parent, hash)
      Hash(hash).each do |key, val|
        safe_define_method(parent, key, val)
      end
    end

    def safe_define_method(object, method, return_value)
      if object.respond_to?(method)
        fail MethodAlreadyDefinedError, "`#{method}' is already defined for #{object.inspect}"
      end

      object.static_methods.push(method.to_sym)
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
