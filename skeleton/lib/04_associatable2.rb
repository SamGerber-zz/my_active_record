require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name]
    through_table = through_options.model_class.table_name
    source_table  = source_options.model_class.table_name
    target_class = source_options.model_class

    define_method(name) do
      value_of_primary_key = self.send(through_options.foreign_key)
      data = DBConnection.execute2(<<-SQL, value_of_primary_key).drop(1)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_options.foreign_key} =
            #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = ?
      SQL

      target_class.parse_all(data).first
    end
  end
end
