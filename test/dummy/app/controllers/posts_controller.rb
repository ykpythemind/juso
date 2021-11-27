class PostsController < ApplicationController
  def index
    posts = Post.all
    render json: Juso.generate(posts)
  end
end

