# == Schema Information
#
# Table name: favorites
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#  wordnote_id :bigint           not null
#
# Indexes
#
#  index_favorites_on_user_id                  (user_id)
#  index_favorites_on_user_id_and_wordnote_id  (user_id,wordnote_id) UNIQUE
#  index_favorites_on_wordnote_id              (wordnote_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (wordnote_id => wordnotes.id)
#
require 'rails_helper'

RSpec.describe Favorite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
