class TangosController < Base

  def index
    @user = User.find(params[:user_id])
    @tangos = @user.tangos.where(name: params[:key].first).where(subject: params[:key].last).order(created_at: :asc)
    if @tangos.size == 0
      flash[:danger] = '当該の単語帳はありません'
      redirect_to user_path(@current_user)
    end
  end

  def update
    @wordnote = @current_user.wordnotes.find(params[:wordnote_id])
    @tango = @wordnote.tangos.find(params[:id])
    if tango_params[:question] == '' || tango_params[:answer] == ''
      render action: 'notice_form_error'
    else
      @tango.update(tango_params)
    end
  end

  def create_on_list
    @user = User.find(params[:user_id])
    @wordnote = @user.wordnotes.find(params[:wordnote_id])
    @tango = @wordnote.tangos.new(tango_params)
    if tango_params[:question] == '' || tango_params[:answer] == ''
      render action: 'notice_form_error'
    else
      @tango.save
    end
  end

  def create
    @user = User.find(params[:user_id])
    @tango = @user.wordnotes.find(params[:wordnote_id]).tangos.new(tango_params)
    @wordnotes = @user.wordnotes.all
    @tango.save
  end

  def delete_checked_tangos
    @delete_tangos = @current_user.wordnotes.find(params[:wordnote_id]).tangos.find(params[:tangos])
    @tango_json = @delete_tangos.to_json.html_safe
    @delete_tangos.each { |tango| tango.destroy }
  end

  private

  def tango_params
    params.require(:tango).permit(:wordnote_id, :question, :answer, :hint)
  end
end
