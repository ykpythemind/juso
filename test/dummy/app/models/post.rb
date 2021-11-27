class Post < ApplicationRecord
  include Juso::Serializable

  belongs_to :user
  has_many :comments

  validates :title, presence: true

  def juso(context)
    {
      id: id,
      title: title,
      user: user,
      comments: comments,
      created_at: created_at,
    }
  end
end
