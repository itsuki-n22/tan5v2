# == Schema Information
#
# Table name: tango_data
#
#  id         :bigint           not null, primary key
#  star       :integer          default(0)
#  trial_num  :integer          default(0)
#  wrong_num  :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tango_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_tango_data_on_tango_id              (tango_id)
#  index_tango_data_on_user_id               (user_id)
#  index_tango_data_on_user_id_and_tango_id  (user_id,tango_id) UNIQUE
#
FactoryBot.define do
  factory :tango_datum do
    user
    wordnote
    tango
  end
end
