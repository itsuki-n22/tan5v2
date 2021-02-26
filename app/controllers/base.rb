class Base < ApplicationController
  before_action :current_user

  def require_login
    redirect_to :root if @current_user.nil?
  end

  private 

    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

   
end
