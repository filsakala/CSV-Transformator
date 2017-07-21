require 'test/unit'

# Load all subfolders to this project (without tests)
(Dir[File.join(".", "**/*.rb")] - Dir[File.join(".", "tests/*/*.rb")]).each do |f|
  require f
end

class MyTest < Test::Unit::TestCase

  def test_data_loading
    csvt = CsvTransformator.new
    data = csvt.load_csv('data/organizations.csv')
    data.each do |row|
      row.each do |_, value|
        assert_not_equal value, "NULL"
      end
    end
    data = csvt.load_csv('data/other.csv')
    data.each do |row|
      row.each do |_, value|
        assert_not_equal value, "NULL"
      end
    end
  end

  def test_remove_nulls
    csvt = CsvTransformator.new
    data = [{a: "a", b: "b", null: "NULL"}, {d: "d", null: "NULL", e: ""}]
    updated_data = csvt.remove_nulls(data)
    assert_equal updated_data, [{a: "a", b: "b", null: ""}, {d: "d", null: "", e: ""}]
  end
end