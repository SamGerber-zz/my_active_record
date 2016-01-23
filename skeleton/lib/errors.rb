class Errors
  def initialize
    @errors = Hash.new { |hash, key| hash[key] = [] }
  end

  def messages
    errors
  end

  def [](attribute)
    errors[attribute]
  end

  def []=(attribute = :base, message)
    errors[attribute] << message
  end

  def add(attribute = :base, message)
    errors[attribute] << message unless errors[attribute].include? message
  end

  def clear
    errors.clear
  end

  def size
    errors.values.flatten.length
  end

  def to_s
    errors.keys.map do |attribute|
      message = errors[attribute].join(", ")
      attribute.to_s.concat(": #{message}")
    end.join("; ")
  end

  def empty?
    errors.empty?
  end

  private

  attr_reader :errors
end
