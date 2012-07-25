class Phone < ActiveRecord::Base
  attr_accessible :name, :number

  belongs_to :user

  # FIXME the name should be unique

  validates :name, :number, :presence => true

  # FIXME method seems unfinished
  def create_or_update_from_csv(row)
    csv_name, csv_number = row
    phone = Phone.find_by_name()


  end
end
