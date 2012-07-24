# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'faker'
user_id = User.last.id
50.times do
  Phone.create({:name => Faker::Name.name, :number => Faker::PhoneNumber.phone_number, :user_id => user_id}, :without_protection => true)
end
