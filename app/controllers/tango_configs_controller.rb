class TangoConfigsController < Base

  def update
    @tango_config = @current_user.tango_configs.find(params[:id])
    @tango_config.attributes = tango_config_params
    @tango_config.save
  end

  private

  def tango_config_params
    params.require(:tango_config).permit(:sort, :clicked_num, :continue, :filter, :font_size, :timer, :last_question)
  end
end
