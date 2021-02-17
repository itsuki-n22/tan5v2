# == Schema Information
#
# Table name: tango_data
#
#  id         :bigint           not null, primary key
#  star       :integer
#  trial_num  :integer
#  wrong_num  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tango_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_tango_data_on_tango_id  (tango_id)
#  index_tango_data_on_user_id   (user_id)
#
FactoryBot.define do
  factory :tango_datum do
    user
    wordnote
    tango
  end
end
