# frozen_string_literal: true

require_relative "juso/version"

require 'json'
require 'date'

module Juso
  class Error < StandardError; end

  module Serializable
    def as_juso_json(_)
      nil
    end
  end

  # Juso Context is serializer context
  # xxxxx
  class Context
    def initialize(serializer_type: :default)
      @serializer_type = serializer_type.to_sym
    end

    attr_reader :serializer_type
  end

  def self.generate(object, context: Context.new)
    JSON.fast_generate(_generate(object, context))
  end

  # generate returns hash (as json)
  def self._generate(object, context)
    case object
    when nil, Numeric, String
      return object
    when Hash
      return object.each_with_object({}) do |(k, v), acc|
        acc[k] = _generate(v, context)
      end
    when Serializable
      # respond_to?(:as_juso_json) のほうが良い可能性ある？
      return _generate(object.as_juso_json(context), context)
    when *collection_classes
      return object.to_a.map { |o| _generate(o, context) }
    when *date_classes
      return object.iso8601
    else
      # TODO: fallback to respond_to?(:as_juso_json) and warn?

      raise Error.new("cannot serialize object: #{object}. you must include Juso::Serializable")
    end
  end

  def self.collection_classes
    @collection_classes
  end

  def self.reset_collection_classes
    @collection_classes =
      if defined?(ActiveRecord)
        [Array, ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy]
      else
        [Array]
      end
  end

  def self.date_classes
    # TODO: FIX / memorize
    if defined?(ActiveSupport::TimeWithZone)
      [Date, DateTime, ActiveSupport::TimeWithZone]
    else
      [Date, DateTime]
    end
  end

  reset_collection_classes
end
