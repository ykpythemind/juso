class PostOneSerializer
  include Juso::Serializable

  def initialize(post)
    @post = post
  end

  attr_reader :post

  def juso(context)
    {
      id: post.id,
      user: Juso.wrap(post.user, UserSerializer),
      comments: post.comments,
      created_at: post.created_at,
      updated_at: post.updated_at,
    }
  end
end
