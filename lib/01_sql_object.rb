require_relative 'db_connection'
require 'active_support/inflector'

class MassObject

  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end
end


class SQLObject < MassObject

  def self.columns
    names = DBConnection.execute2("SELECT * FROM #{self.table_name}").first

    names.each do |name|
        define_method(name) { self.attributes[name.to_sym] }
        define_method("#{name}=") { |value| self.attributes[name.to_sym] = value}
    end

    names.map!(&:to_sym)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    query = <<-SQL
    SELECT *
    FROM #{self.table_name}
    SQL

    results = DBConnection.execute(query)
    self.parse_all(results)
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, :id => id)
    SELECT *
    FROM #{self.table_name}
    WHERE id = :id
    SQL

    self.new(result.first)
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    query = <<-SQL
    INSERT INTO
      #{self.class.table_name} (#{self.attributes.keys.join(", ")} )
    VALUES
      (#{ (["?"] * attributes.length).join(", ") })
    SQL

    DBConnection.execute(query, *self.attribute_values)

    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    column_names = self.class.columns
    params.each do |attribute, value|
      if column_names.include?(attribute.to_sym)
        self.attributes[attribute.to_sym] = value
      else
        raise "Incorrect column value type"
      end
    end
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    set_line = self.attributes.map{ |att_name, att_value| "#{att_name} = ?"}

    query = <<-SQL
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line.join(", ")}
    WHERE
      id = ?
    SQL

    DBConnection.execute(query, *self.attribute_values, self.id)
  end

  def attribute_values
    self.attributes.values
  end
end
