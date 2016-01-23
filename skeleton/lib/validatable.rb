class ValidatesOptions
  attr_accessor :validations, :column

  def initialize(column, options = {})
    @validations = Hash.new { |hash, key| hash[key] = false }

    options.each do |validation, status|
      validations[validation] = status
    end

    @column = column
  end
end

module Validatable
  def validates(column, options = {})
    self.validatable_options = ValidatesOptions.new(column, options)

    define_method("valid?") do
      self.class.validatable_options.validations.select { |_, v| v }.each do |validation, _|
        send(validation, column)
      end
      errors.empty?
    end
  end

  def validatable_options
    @validatable_options ||= {}
  end

  def validatable_options=(validatable_options)
    @validatable_options = validatable_options
  end
end

module ValidationHelpers
  def uniqueness(column)
    return if (self.class.where(column => send(column)).map(&:id) - [id]).empty?

    errors.add(column, "has already been taken")
  end

  def presence(column)
    return if send(column).present?

    errors.add(column, "must not be blank")
  end
end

class SQLObject
  extend Validatable
  include ValidationHelpers
end
