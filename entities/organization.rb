class Organization
  attr_accessor :id, :name, :description, :country, :code

  def initialize(**args)
    args.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def instance_variables_to_s
    string_variables = []
    instance_variables.each do |var|
      string_variables << "#{var.to_s[1..-1]}: \"#{instance_variable_get(var)}\""
    end
    string_variables.join(', ')
  end

  def fix_code(code1, code2)
    if !code1.to_s.empty? && !code2.to_s.empty?
      "#{code1}/#{code2}"
    elsif !code1.to_s.empty?
      code1
    elsif !code2.to_s.empty?
      code2
    else
      ""
    end
  end

  # Row values to update in this organization
  def update(row)
    @params = {
      description: @description.to_s + "\n" + CsvTransformator.join_descriptions(row),
      country:     @country,
      code:        fix_code(@code, row["CODE"])
    }
    self
  end

  def to_create
    "o = Organization.create(#{instance_variables_to_s})\n"
  end

  def to_update
    "Organization.find(#{@id}).update(#{@params})\n"
  end
end
