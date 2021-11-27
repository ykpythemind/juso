class PostsController < ApplicationController
  def index
    render json: Juso.generate([])
  end
end

