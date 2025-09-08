class Microposts < ActiveRecord::Base
  belongs_to :user
  attr_accessible :content
end
