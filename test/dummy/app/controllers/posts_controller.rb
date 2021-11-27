class PostsController < ApplicationController
  def index
    posts = Post.all
    render json: Juso.generate(posts)
  end

  def show
    post = Post.find(params[:id])
    render json: Juso.generate(Juso.wrap(post, PostOneSerializer))
  end
end

