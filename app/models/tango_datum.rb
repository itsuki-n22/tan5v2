# == Schema Information
#
# Table name: tango_data
#
#  id          :bigint           not null, primary key
#  star        :integer
#  trial_num   :integer
#  wrong_num   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tango_id    :bigint           not null
#  user_id     :bigint           not null
#  wordnote_id :bigint           not null
#
# Indexes
#
#  index_tango_data_on_tango_id                              (tango_id)
#  index_tango_data_on_user_id                               (user_id)
#  index_tango_data_on_user_id_and_wordnote_id_and_tango_id  (user_id,wordnote_id,tango_id) UNIQUE
#  index_tango_data_on_wordnote_id                           (wordnote_id)
#
class TangoDatum < ApplicationRecord
  belongs_to :user
  belongs_to :wordnote
  belongs_to :tango
end
