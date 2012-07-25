class Phone < ActiveRecord::Base
  attr_accessible :name, :number

  belongs_to :user

  validates :name, :number, :presence => true, :uniqueness => {:scope => :user_id}

end