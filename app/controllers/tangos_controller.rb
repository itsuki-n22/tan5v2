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

  def import
    return @no_file_error = true if params[:csv_file].nil?
    return @file_size_error = true if params[:csv_file].size > 500000
    wordnote = @current_user.wordnotes.find(params[:wordnote_id])
    wordnote.import_tangos(params[:csv_file])
  end

  def create
    wordnote = @current_user.wordnotes.find(tango_params[:wordnote_id])
    wordnote.tangos.new(tango_params).save
    @wordnotes = @current_user.wordnotes.all
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
