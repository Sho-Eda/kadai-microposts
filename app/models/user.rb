class User < ApplicationRecord
    before_save { self.email.downcase! }
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
# 自分がフォローしているUserへの参照
  has_many :relationships
# has_many :followings という関係を新しく命名して『フォローしているUser達』を表現している。
# 中間テーブルを経由して相手の情報を取得できるようにするためには through を使用する。
  has_many :followings, through: :relationships, source: :follow
  # 自分をフォローしているUserへの参照
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  
  
  # ------
  
  # 「自分がお気に入りしているMicropost」への参照を表している。
  has_many :favorites
  # 中間テーブルを経由して相手の情報を取得できるようにするためには through を使用する。
  has_many :likes, through: :favorites, source: :micropost
  
  # user.bookmarks というメソッドを用いると、 userが中間テーブルfavoritesを取得し、
  # その1つ1つのfavoritesのmicropost_id から 自分がお気に入り登録しているメッセージを取得するという処理が可能になります。
  
  # -------
  
  # -------
  
  # お気に入り係を手軽に作成したり外したり出来るメソッド
  
  def like(micropost)
    # unless self == micropostによってお気に入りしようとしているmicropost が自分自身ではないかを検証している。
    # 実行した User のインスタンスが self
    unless self == micropost
    # 既にフォローされている場合にフォローが重複して保存されることがなくなる。
      self.favorites.find_or_create_by(micropost_id: micropost.id)
    end
  end

  def unlike(micropost)
    favorite = self.favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end
  
  
  def like?(micropost) 
    self.likes.include?(micropost) #self.bookmarksで登録しているお気に入りを取得。include?(other_user) によって other_user が含まれていないかを確認しています。
  end
    
  # ------

  
  
  def follow(other_user)
    # unless self == other_userによってフォローしようとしているother_user が自分自身ではないかを検証している。
    # 実行した User のインスタンスが self
    unless self == other_user
    # 既にフォローされている場合にフォローが重複して保存されることがなくなる。
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    # self.followings によりフォローしている User 達を取得。
    # include?(other_user) によって other_user が含まれていないかを確認しています。含まれている場合には、true を返し、含まれていない場合には、false を返します。
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    # Micropost.where(user_id: フォローユーザ + 自分自身)
    Micropost.where(user_id: self.following_ids + [self.id])
  end

end
