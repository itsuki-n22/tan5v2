class WordnotesController < Base
  before_action :access_check, only: %i[show]

  def show
    @wordnote = Wordnote.find(params[:id])
    @user = User.find(@wordnote.user_id)
    unless @tango_config = @current_user.tango_configs.find_by(wordnote_id: params[:id])
      @tango_config = @current_user.tango_configs.build(wordnote_id: params[:id])
    end

    @tango_config.clicked_num += 1
    @tango_config.save

    @tangos = @tango_config.tangos_by_config
    if @tangos.size == 0 && @tango_config.filter.to_i > 0 # フィルターの設定で単語が表示されなくなる場合の対策
      @tango_config.update_attribute(:filter, 0)
      @tangos = @tango_config.sorted_tangos 
    end

    if @tangos.size == 0
      flash[:success] = '表示できる単語がありません。'
      redirect_back(fallback_location: root_path) #前見ていたページにを表示する
    end
  end

  def create
    @wordnote = @current_user.wordnotes.new(wordnote_params)
    @user = @current_user
    @wordnotes = @user.wordnotes.all if @wordnote.save
  end

  def update
    @wordnote = @current_user.wordnotes.find(params[:id])
    @wordnote.attributes = wordnote_params
    @wordnote.save
  end

  def destroy
    @wordnote = current_user.wordnotes.find(params[:id])
    @wordnote.destroy
    flash[:success] = '単語帳を削除しました'
    redirect_to :root, status: 303
  end

  private 

    def wordnote_params
      params.require(:wordnote).permit(:name, :subject, :is_open)
    end

    def access_check
      wordnote = Wordnote.find(params[:id])
      if !wordnote.is_open? && wordnote.user_id != @current_user.id
        flash[:danger] = 'アクセス権がありません'
        redirect_to :root 
      end
    end

end
