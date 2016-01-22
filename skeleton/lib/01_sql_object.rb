require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end

  def self.finalize!
    columns.each do |attr_name|
      define_method("#{attr_name}=") do |attr_value|
        attributes[attr_name] = attr_value
      end

      define_method("#{attr_name}") do
        attributes[attr_name]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= to_s.underscore.pluralize
  end

  def self.all
    data = DBConnection.execute2(<<-SQL).drop(1)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |row|
      new(row)
    end
  end

  def self.find(id)
    data = DBConnection.execute2(<<-SQL, id).drop(1)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    parse_all(data).first
  end

  def initialize(params = {})
    params.each do |attr_name, attr_value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include? attr_name
        raise ArgumentError, "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name}=", attr_value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.join(", ").delete(":")
    question_marks = (%w(?) * cols.length).join(", ")

    DBConnection.execute2(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns
    col_names = cols.join(" = ?, ").delete(":").concat(" = ?")

    DBConnection.execute2(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
       #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    saved? ? update : insert
  end

  def saved?
    !id.nil?
  end
end
