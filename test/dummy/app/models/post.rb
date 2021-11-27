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
      comment_count: comment_count,
    }
  end

  def comment_count
    comments.count
  end
end
