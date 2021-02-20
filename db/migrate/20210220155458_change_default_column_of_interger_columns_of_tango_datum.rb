class ChangeDefaultColumnOfIntergerColumnsOfTangoDatum < ActiveRecord::Migration[6.0]
  def change
    change_column_default :tango_data, :trial_num, from: nil, to: 0
    change_column_default :tango_data, :wrong_num, from: nil, to: 0
    change_column_default :tango_data, :star, from: nil, to: 0
    TangoDatum.where(trial_num: nil).update_all(trial_num: 0)
    TangoDatum.where(wrong_num: nil).update_all(wrong_num: 0)
    TangoDatum.where(star: nil).update_all(star: 0)
  end
end
