require 'test_helper'

describe StaticStruct::Structure do
  class ImplicitHash
    def to_hash
      {foo: 'bar'}
    end
  end

  def assert_raises_exception_with_message(klass, message_regexp, &block)
    assert_match(message_regexp, assert_raises(klass, &block).message)
  end

  def create_struct(from)
    StaticStruct::Structure.new(from)
  end

  describe '#new' do
    describe 'plain Hash' do
      let(:from) { {foo: 'bar'} }
      let(:struct) { create_struct(from) }

      it 'defines readers for properties' do
        assert_equal 'bar', struct.foo
      end

      it 'does not define writes for properties' do
        assert_raises_exception_with_message(NoMethodError,
          /undefined method `foo=' for #<StaticStruct::Structure.+>/) do
          struct.foo = 'new bar'
        end
      end

      it 'does not respond to missing properties in the Hash' do
        assert_raises_exception_with_message(NoMethodError,
          /undefined method `foo_bar' for #<StaticStruct::Structure.+>/) do
          create_struct(from).foo_bar
        end
      end

      it 'does not break standard methods' do
        assert_raises_exception_with_message(StaticStruct::MethodAlreadyDefinedError,
          /`send' is already defined for #<StaticStruct::Structure>/) do
          create_struct(send: 'test')
        end
      end

      it 'does not effect the defined properties if change instance variables' do
        struct.instance_variable_set('@foo', 'new bar')
        assert_equal 'bar', struct.foo
      end

      it 'defines readers for properties with implicit convertion into Hash' do
        assert_equal 'bar', create_struct(ImplicitHash.new).foo
      end

      it 'does not accepts not a hash-like object' do
        assert_raises_exception_with_message(TypeError,
          /can't convert Object into Hash/) do
          create_struct(Object.new)
        end
      end

      it 'converts arrays to the own structure' do
        array = create_struct(foo: ['bar', ImplicitHash.new]).foo

        assert_equal 2, array.size
        assert_equal true, array.include?('bar')
        assert_equal true, array.include?(StaticStruct::Structure.new(foo: 'bar'))
      end

      it 'allows to define enumerable method #sum' do
        assert_equal 10, create_struct(sum: 10).sum
      end

      it 'allows to define enumerable method #count' do
        assert_equal 42, create_struct(count: 42).count
      end
    end

    describe 'nesting Hash' do
      let(:struct) { create_struct(foo: {foo: 'bar'}) }

      it 'defines readers for properties' do
        assert_equal 'bar', struct.foo.foo
      end

      it 'defines readers for properties with implicit convertion into Hash' do
        assert_equal 'bar', create_struct({foo: ImplicitHash.new}).foo.foo
      end
    end
  end

  describe '#to_s' do
    it 'is overriden' do
      assert_equal "#<StaticStruct::Structure foo=bar>", create_struct(foo: 'bar').to_s
    end
  end

  describe '#inspect' do
    it 'is overriden' do
      assert_equal "#<StaticStruct::Structure foo=bar>", create_struct(foo: 'bar').inspect
    end
  end

  describe '#each' do
    it 'is iterable method' do
      iterator = create_struct('A foo' => 'bar', 'A foo foo' => 'bar bar').enum_for(:each)
      map = iterator.map do |key, val|
        [key, val]
      end

      assert_equal [['A foo', 'bar'], ['A foo foo', 'bar bar']], map
    end

    it 'is iterable for nesting' do
      iterator = create_struct(foo: ImplicitHash.new).enum_for(:each)
      map = iterator.map do |key, val|
        [key, val]
      end

      assert_equal ["foo=bar"], map[0][1].map { |key, val| "#{key}=#{val}" }
    end
  end
end
