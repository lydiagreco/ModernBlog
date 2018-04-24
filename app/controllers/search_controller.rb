class SearchController < ApplicationController
  def search
    if params[:q].nil?
      @blogs = []
    else
      @blogs = Blog.search params[:q]
    end
  end
end
