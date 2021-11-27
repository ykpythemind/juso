# frozen_string_literal: true

require_relative "juso/version"

require 'json'
require 'date'

module Juso
  class Error < StandardError; end

  module Serializable
    def juso(_)
      nil
    end
  end

  # Juso::Context is serializer context
  class Context
    def initialize(serializer: :default, options: {})
      @serializer = serializer
      @options = options
    end

    attr_reader :serializer, :options
  end

  # Juso.generate generates json string
  def self.generate(object, context: Context.new)
    JSON.fast_generate(_g(object, context))
  end

  # generate returns hash (as json)
  def self._g(object, context)
    case object
    when nil, Numeric, String
      return object
    when Hash
      return object.each_with_object({}) do |(k, v), acc|
        acc[k] = _g(v, context)
      end
    when Serializable
      # respond_to?(:juso) のほうが良い可能性ある？
      return _g(object.juso(context), context)
    when *collection_classes
      return object.to_a.map { |o| _g(o, context) }
    when *date_classes
      return object.iso8601
    else
      # TODO: fallback to respond_to?(:juso) and warn?

      raise Error.new("cannot serialize object: #{object}. you must include Juso::Serializable")
    end
  end

  # Juso.wrap is utility for wrapping object with Juso::Serializable class
  def self.wrap(object, klass)
    if collection_classes.any? { |arrayish| object.is_a?(arrayish) }
      object.to_a.map { |o| klass.new(o) }
    else
      klass.new(object)
    end
  end

  def self.collection_classes
    @collection_classes ||= default_collection_classes
  end

  def self.default_collection_classes
    if defined?(ActiveRecord)
      [Array, ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy]
    else
      [Array]
    end
  end

  def self.date_classes
    @date_classes ||= default_date_classes
  end

  def self.default_date_classes
    if defined?(ActiveSupport::TimeWithZone)
      [Date, DateTime, ActiveSupport::TimeWithZone]
    else
      [Date, DateTime]
    end
  end

  private_class_method :default_collection_classes, :default_date_classes, :_g
end
