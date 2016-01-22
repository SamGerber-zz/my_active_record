require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options.fetch(:foreign_key) { "#{name}_id".to_sym }
    @primary_key = options.fetch(:primary_key) { :id }
    @class_name  = options.fetch(:class_name)  { name.to_s.camelcase }
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options.fetch(:foreign_key) { "#{self_class_name.underscore}_id".to_sym }
    @primary_key = options.fetch(:primary_key) { :id }
    @class_name  = options.fetch(:class_name)  { name.to_s.camelcase.singularize }
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      value_of_foreign_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key => value_of_foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      value_of_primary_key = self.send(options.primary_key)
      target_class = options.model_class
      target_class.where(options.foreign_key => value_of_primary_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
