class Comment < ApplicationRecord
  include Juso::Serializable

  belongs_to :post
  belongs_to :user, optional: true

  validates :body, presence: true

  def juso(context)
    {
      id: id,
      body: body,
      user: user,
      post_id: post_id,
    }
  end
end
