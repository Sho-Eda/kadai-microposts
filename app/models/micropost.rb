class Micropost < ApplicationRecord
  belongs_to :user
  has_many :favorites
  has_many :users, through: :favorites, source: :user
  
  # micropost.users というメソッドを用いると、 micropostが中間テーブルfavoritesを取得し、
  # その1つ1つのfavoritesのuser_id から 自分（投稿）をお気に入り登録しているユーザを取得するという処理が可能になります。
  
  validates :content, presence: true, length:{maximum: 255}
end
