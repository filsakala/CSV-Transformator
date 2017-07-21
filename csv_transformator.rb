require 'csv'
require 'rubygems'
require 'active_support/core_ext/hash/keys' # symbolize_keys

# Load all subfolders to this project (without tests)
(Dir[File.join(".", "**/*.rb")] - [File.join(".", "/csv_transformator.rb")] - Dir[File.join(".", "data/*.rb")] - Dir[File.join(".", "tests/*.rb")]).each do |f|
  require f
end

class CsvTransformator
  attr_accessor :database, :other

  def initialize
    @database        = load_csv('data/organizations.csv')
    @other           = load_csv('data/other.csv')
    @result_filename = 'data/create_script.rb'
  end

  def load_csv(filename)
    data = CSV.foreach(filename, headers: true, col_sep: "\t")
             .collect { |row| row.to_hash }
    remove_nulls(data)
  end

  # Remove "NULL" values from data (insert "" instead)
  def remove_nulls(data)
    data.each do |row|
      row.each do |key, value|
        row[key] = "" if value == "NULL"
      end
    end
    data
  end

  # Returns [Organization]
  def find_organization_by_name(organizations, name)
    found = []
    organizations.each do |o|
      found << o if o.name.to_s.downcase.strip == name.to_s.downcase.strip
    end
    found
  end

  # Identify organizations
  # @returns Array of Organizations to create & update
  def identify_organizations
    organizations = @database.collect { |row| Organization.new(row.symbolize_keys) }
    result        = { create: [], update: [] }
    @other.each do |row|
      found = find_organization_by_name(organizations, row["Organizácia "])
      case found.size
        when 0
          Logger.info("Nothing found for organization #{row["Organizácia "]}. Will be created.")
          result[:create] << row
        when 1
          result[:update] << { to_update: found[0], row: row }
        else
          Logger.error("#{found.size} results found for organization #{row["Organizácia "]}")
      end
    end
    result
  end

  def self.join_descriptions(row)
    (0..10).collect { |i| row["Popis_#{i}"] }.reject(&:nil?).join("\n")
  end

  def create_organizations(rows)
    File.open(@result_filename, "w") do |file|
      rows.each do |row|
        file.puts Organization.new({ name: row["Organizácia "], description: CsvTransformator.join_descriptions(row), country: row["Krajina"], code: row["CODE"] })
                    .to_create
        file.puts Contact.new(name: "Incoming", surname: row["Acronym"], organization_id: "ORG", mail: row["Workcamps, Incoming e-mail"], other_contacts: row["Popis_Contact"]).to_create
        file.puts Contact.new(name: "Outgoing", surname: row["Acronym"], organization_id: "ORG", mail: row["Workcamps, Outgoing e-mail"], other_contacts: row["Popis_Contact"]).to_create
      end
    end
  end

  def update_organizations(organizations_with_rows)
    File.open(@result_filename, "a") do |file|
      organizations_with_rows.each do |owr|
        row = owr[:row]
        file.puts owr[:to_update].update(row).to_update
        file.puts Contact.new(name: "Incoming", surname: row["Acronym"], organization_id: owr[:to_update].id, mail: row["Workcamps, Incoming e-mail"], other_contacts: row["Popis_Contact"]).to_create
        file.puts Contact.new(name: "Outgoing", surname: row["Acronym"], organization_id: owr[:to_update].id, mail: row["Workcamps, Outgoing e-mail"], other_contacts: row["Popis_Contact"]).to_create
      end
    end
  end

  def run
    identified_organizations = identify_organizations
    create_organizations(identified_organizations[:create])
    update_organizations(identified_organizations[:update])
  end

end

CsvTransformator.new.run