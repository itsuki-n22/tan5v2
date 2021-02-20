# == Schema Information
#
# Table name: tango_configs
#
#  id            :bigint           not null, primary key
#  clicked_num   :integer          default(0)
#  continue      :boolean          default(FALSE)
#  filter        :integer          default(0)
#  font_size     :integer          default(32)
#  last_question :integer
#  sort          :integer          default("asc")
#  timer         :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#  wordnote_id   :bigint           not null
#
# Indexes
#
#  index_tango_configs_on_user_id      (user_id)
#  index_tango_configs_on_wordnote_id  (wordnote_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (wordnote_id => wordnotes.id)
#
class TangoConfig < ApplicationRecord
  enum sort: [:asc, :desc, :random]
  belongs_to :user
  belongs_to :wordnote
  validates :user, presence: true
  validates :wordnote, presence: true

  def sorted_tangos
    case sort
    when 'desc'
      wordnote.tangos.desc_with_datum
    when 'random'
      wordnote.tangos.random_with_datum
    else
      wordnote.tangos.asc_with_datum
    end
  end

  def tangos_by_config
    sorted_tangos.reject do |tango|
      star = tango.tango_datum ? tango.tango_datum.star : 0
      star < filter
    end
  end
end
