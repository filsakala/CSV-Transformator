class Contact
  attr_accessor :name, :surname, :nickname, :mail, :phone, :other_conacts, :dept, :notes, :organization_id

  def initialize(**args)
    args.each { |key, value| instance_variable_set("@#{key}".to_sym, value) }
  end

  def instance_variables_to_s
    string_variables = []

    instance_variables.each do |var|
      if var != :@organization_id || @organization_id != 'ORG'
        string_variables << "#{var.to_s[1..-1]}: \"#{instance_variable_get(var)}\""
      else
        string_variables << "organization_id: o.id"
      end
    end
    string_variables.join(', ')
  end

  def to_create
    "Contact.create(#{instance_variables_to_s})\n"
  end
end