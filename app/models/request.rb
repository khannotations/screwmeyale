class Request < ActiveRecord::Base
  belongs_to :to, :class_name => "Screwconnector"
  belongs_to :from, :class_name => "Screwconnector"

  validates :to_id, :presence => "true"
  validates :from_id, :presence => "true"

  
end
