class TangosController < Base

  def index
    respond_to do |format|
      format.csv do 
        wordnote = Wordnote.find(params[:wordnote_id])
        send_data(wordnote.tangos_csv, filename: "#{wordnote.name + '-' + wordnote.subject}.csv")
      end
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

  def import
    return @no_file_error = true if params[:csv_file].nil?
    return @file_size_error = true if params[:csv_file].size > 500000
    wordnote = @current_user.wordnotes.find(params[:wordnote_id])
    wordnote.import_tangos(params[:csv_file])
  end

  def create
    case params[:commit]
    when '単語を登録'
      wordnote = @current_user.wordnotes.find(tango_params[:wordnote_id])
      wordnote.tangos.new(tango_params).save
      @wordnotes = @current_user.wordnotes.all
    when '登録'
      @wordnote = @current_user.wordnotes.find(params[:wordnote_id])
      @tango = @wordnote.tangos.new(tango_params)
      if tango_params[:question] == '' || tango_params[:answer] == ''
        render action: 'notice_form_error'
      else
        @tango.save
        render action: 'create_on_wordnote_show'
      end
    end
  end

  def destroy
    wordnote_id = Tango.find(params[:tangos].first).wordnote_id
    @delete_tangos = @current_user.wordnotes.find(wordnote_id).tangos.find(params[:tangos])
    @tango_json = @delete_tangos.to_json.html_safe
    @delete_tangos.each { |tango| tango.destroy }
  end

  private

    def tango_params
      params.require(:tango).permit(:wordnote_id, :question, :answer, :hint)
    end

end
