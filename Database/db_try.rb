require "sequel"


Sequel::Model.plugin :schema

DB = Sequel.sqlite('test2.db')

# DB.create_table :items do
#   primary_key :id
#   String :bin_data
# end

items = DB[:items]

# puts DB.table_exists?(:items)

test_bin = ["asdf", "fdas"].to_s
 items.insert(:bin_data => test_bin)
# items.insert(:name => 'abc', :price => rand * 100)
# items.insert(:name => 'def', :price => rand * 100)
# items.insert(:name => 'ghi', :price => rand * 100)

# puts "Item count: #{items.count}"

puts "The average price is: #{items.first}"

# items.each {|row| p row}