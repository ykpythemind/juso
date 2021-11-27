class User < ApplicationRecord
  include Juso::Serializable

  has_many :posts
  has_many :comments

  validates :name, presence: true
  validates :email, presence: true

  def juso(context)
    {
      id: id,
      name: name,
    }
  end
end

