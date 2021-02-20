class WordnotesController < Base
  before_action :access_check, only: %i[show]

  def show
    @user = User.find(params[:user_id])
    @wordnote = @user.wordnotes.find(params[:id])
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

  def download_csv
    @user = User.find(params[:user_id])
    @wordnote = @user.wordnotes.find(params[:wordnote_id])
    explain_str = '#このファイルをアップロードする場合、IDが一致している単語はその単語を修正します。answerとquestionの組み合わせがすでに存在する単語ペアはアップロードされません。この行は削除しないでください。'
    dl_data = CSV.generate do |csv|
      csv <<  ['id', 'question', 'answer', 'hint', explain_str]
      @wordnote.tangos.each do |tango|
        csv << [tango.id, tango.question, tango.answer, tango.hint]
      end
    end
    send_data(dl_data, filename: "#{@wordnote.name + '-' + @wordnote.subject}.csv")
  end

  def upload_csv
    return @no_file_error = true if params[:csv_file].nil?
    return @file_size_error = true if params[:csv_file].size > 500000

    wordnote = @current_user.wordnotes.find(params[:wordnote_id])
    @tangos = wordnote.tangos

    new_tangos = []
    update_tangos = []
    now = Time.current

    CSV.foreach(params[:csv_file].path, headers: true, encoding: 'utf-8') do |row|
      new_tangos << { id: row['id'].to_i, wordnote_id: wordnote.id, answer: row['answer'], question: row['question'], hint: row['hint'], created_at: now, updated_at: now }
    end

    new_tangos.delete_if do |new_tango|
      delete_flag = false
      @tangos.each do |old_tango|
        if old_tango.id == new_tango[:id]
          delete_flag = true
          unless old_tango.answer == new_tango[:answer] \
              && old_tango.question == new_tango[:question] \
              && old_tango.hint == new_tango[:hint]
            update_tangos << new_tango
          end
          break
        elsif old_tango.answer == new_tango[:answer] \
            && old_tango.question == new_tango[:question]
          delete_flag = true
          break
        end
      end
      delete_flag # ここがtrueなら削除
    end
    new_tangos.map { |t| t.delete(:id) }

    begin
      @tangos.insert_all new_tangos if new_tangos.empty? == false
      @tangos.upsert_all update_tangos if update_tangos.empty? == false
    rescue StandardError => e
      @error = e.class.to_s.split('::').last
      render action: 'upload_csv'
    end
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
