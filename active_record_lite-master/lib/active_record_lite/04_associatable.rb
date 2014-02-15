require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :class_name => name.to_s.classify,
      :foreign_key => name.to_s.foreign_key.to_sym,
      :primary_key => :id
    }

    options = defaults.merge(options)

    options.each do |field, value|
      self.instance_variable_set("@#{field}".to_sym, value)
    end
  end
end

class HasManyOptions < AssocOptions

  def initialize(name, self_class_name, options = {})
    defaults = {
      :class_name => name.to_s.classify,
      :foreign_key => self_class_name.to_s.foreign_key.to_sym,
      :primary_key => :id
    }

    options = defaults.merge(options)

    options.each do |field, value|
      self.instance_variable_set("@#{field}".to_sym, value)
    end
  end
end

module Associatable
  # Phase IVb
  #this method will become a class method
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    # An instance will call this method
    define_method(name) do
      associated_table = options.table_name
      our_value = self.send(options.foreign_key)

      results = DBConnection.execute(<<-SQL, our_value )
      SELECT *
      FROM #{associated_table}
      WHERE
      #{options.primary_key} = ?
      SQL
      options.model_class.parse_all(results).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      associated_table = options.table_name
      our_value = self.send(options.primary_key)

      query = <<-SQL
      SELECT *
      FROM #{associated_table}
      WHERE
      #{options.foreign_key} = ?
      SQL

      results = DBConnection.execute(query, our_value )

      options.model_class.parse_all(results)
    end
  end

  def assoc_options
    @assoc_params ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end

