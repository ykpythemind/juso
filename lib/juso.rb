# frozen_string_literal: true

require_relative "juso/version"

require 'json'

module Juso
  class Error < StandardError; end

  module Serializable
    def juso_json(_)
      nil
    end
  end

  # Juso Context is serializer context
  # xxxxx
  class Context
    def initialize(options: nil)
      @options = options
    end
  end

  def self.generate(object, context: Context.new)
    JSON.fast_generate(_generate(object, context))
  end

  # generate returns hash (as json)
  def self._generate(object, context)
    case object
    when nil, Numeric, String
      return object
    when Array
      return object.map { |o| _generate(o, context) }
    when Hash
      return object.each_with_object({}) do |(k, v), acc|
        acc[k] = _generate(v, context)
      end
    when Serializable
      # class比較するの遅い？
      return _generate(object.juso_json(context), context)
    else
      # puts object
      # binding.irb
      raise Error.new("cannot serialize object: #{object}. you must include Juso::Serializable")
    end
  end
end
