# Note: this module isn't actually used in the main implementation. I wrote it to practice/test out the code used in the following sql_object file. -TB

module AttrAccessible
  def self.my_attr_accessor(*names)
    names.each do |name|
      attr_sym = "@#{name}".to_sym

      define_method(name) { self.instance_variable_get(attr_sym) }

      define_method("#{name}=") do
        |argument| self.instance_variable_set(attr_sym, argument)
      end
    end
  end
end
