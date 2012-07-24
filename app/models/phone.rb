class Phone < ActiveRecord::Base
  attr_accessible :name, :number

  belongs_to :user

  validates :name, :number, :presence => true

  def create_or_update_from_csv(row)
    csv_name, csv_number = row
    phone = Phone.find_by_name()

  end
end