# == Schema Information
#
# Table name: tango_configs
#
#  id            :bigint           not null, primary key
#  clicked_num   :integer          default(0)
#  continue      :boolean          default(FALSE)
#  filter        :string           default("none")
#  font_size     :integer
#  last_question :integer
#  sort          :string           default("asc")
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
require 'rails_helper'

RSpec.describe TangoConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
