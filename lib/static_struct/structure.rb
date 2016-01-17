module StaticStruct
  class Structure
    def initialize(hash)
      define_structure(self, hash)
    end

    private

    def define_structure(parent, hash)
      Hash(hash).each do |key, val|
        safe_define_method(parent, key, val)
      end
    end

    def safe_define_method(object, method, return_value)
      fail MethodAlreadyDefinedError, method if object.respond_to?(method)

      case
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
