class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  has_many :friendships
  has_many :friends, -> { where(friendships: {status: 'accepted' }) },
           through: :friendships
  # # has_many :friends, through: :friendships do
  #   def status
  #     where("friendships.status = ?", 'accepted')
  #   end
  # end
  has_many :requested_friends, -> { where(friendships: {status: 'requested'}) },
           through: :friendships, source: :friend

  has_many :pending_friends, -> { where(friendships: {status: 'pending'}) },
           through: :friendships, source: :friend
  has_many :posts
  has_many :likes
  has_many :comments

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
    end
  end
end
