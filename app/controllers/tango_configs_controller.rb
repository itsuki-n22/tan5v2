class TangoConfigsController < Base

  def change
    unless @tango_config = @current_user.tango_config.find_by(wordnote_id: tango_config_params[:wordnote_id])
      @tango_config = @current_user.tango_config.build(wordnote_id: tango_config_params[:wordnote_id])
    end
    @tango_config.attributes = tango_config_params
    @tango_config.save
  end

  private

  def tango_config_params
    params.require(:tango_config).permit(:wordnote_id, :sort, :clicked_num, :continue, :filter, :font_size, :timer, :last_question)
  end
end
