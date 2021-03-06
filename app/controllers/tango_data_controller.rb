class TangoDataController < Base

  def update
    unless tango_datum = current_user.tango_data.find_by(tango_id: data_params[:tango_id])
      tango_datum = current_user.tango_data.build(tango_id: data_params[:tango_id])
    end

    tango_datum.wrong_num += 1 if data_params[:wrong_num]
    tango_datum.trial_num += 1 if data_params[:trial_num]
    tango_datum.star = data_params[:star].to_i if data_params[:star]
    tango_datum.save
  end

  def show
    @trial_count = 0
    @correct_ratio = 0
    @star = nil
    if tango_datum = current_user.tango_data.find_by(tango_id: params[:tango_id])
      @trial_count = tango_datum.trial_num
      @correct_ratio = 1 - (tango_datum.wrong_num.to_f / tango_datum.trial_num) if tango_datum.trial_num > 0
      @correct_ratio = (@correct_ratio * 100).round(2)
      @star = tango_datum.star
    end
  end

  private

  def data_params
    params.permit(:tango_id, :trial_num, :wrong_num, :star, :id)
  end
end
