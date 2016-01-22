require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_string = params.keys.join(" = ? and ").concat(" = ?")

    data = DBConnection.execute2(<<-SQL, *params.values).drop(1)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{where_string}
    SQL

    parse_all(data)
  end
end

class SQLObject
  extend Searchable
end
