class Base < ApplicationController
  before_action :current_user
  before_action :set_search_users_form

  private 

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def require_login
      redirect_to :root if @current_user.nil?
    end

    def set_search_users_form
      @search_form = SearchUsersForm.new(search_users_params)
    end
   
    def search_users_params
      params.fetch(:q, {}).permit(:search_word)
    end

   
end
