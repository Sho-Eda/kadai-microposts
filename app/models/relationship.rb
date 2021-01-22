class Relationship < ApplicationRecord
  belongs_to :user
  # followはクラスがないため、Userクラスを参照するものだと明示する。class_name: "User"
  belongs_to :follow, class_name: 'User'
end
