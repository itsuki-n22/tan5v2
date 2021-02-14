class TopController < Base
  layout 'top'
  def index
    if @current_user
      redirect_to user_path(@current_user)
    else
      render action: 'index'
    end
  end
end
