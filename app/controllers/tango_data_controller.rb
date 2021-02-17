class TangoDataController < Base

  def change
    unless tango_datum = @current_user.tango_data.find_by(tango_id: data_params[:id])
      tango_datum = @current_user.tango_data.build(tango_id: data_params[:id], wrong_num: 0, trial_num: 0, star: 0)
    end
    wrong_num = tango_datum.wrong_num
    trial_num = tango_datum.trial_num
    star = tango_datum.star

    wrong_num += 1 if data_params[:wrong_num]
    trial_num += 1 if data_params[:trial_num]
    star = data_params[:star].to_i if data_params[:star]
    change_data = { wrong_num: wrong_num, trial_num: trial_num, star: star }

    if tango_datum.id.nil?
      tango_datum.attributes = change_data
      tango_datum.save
    else
      tango_datum.update_columns(change_data)
    end
  end

  def get_tango_data
    @trial_count = 0
    @correct_ratio = 0
    @star = nil
    if tango_datum = @current_user.tango_data.find_by(tango_id: params[:id])
      @trial_count = tango_datum.trial_num
      @correct_ratio = 1 - (tango_datum.wrong_num.to_f / tango_datum.trial_num) if tango_datum.trial_num > 0
      @correct_ratio = (@correct_ratio * 100).round(2)
      @star = tango_datum.star
    end
  end

  private

  def data_params
    params.permit(:id, :trial_num, :wrong_num, :star)
  end
end
