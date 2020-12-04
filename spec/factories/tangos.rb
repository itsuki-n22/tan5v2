# == Schema Information
#
# Table name: tangos
#
#  id          :bigint           not null, primary key
#  answer      :string           not null
#  hint        :string
#  question    :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  wordnote_id :bigint           not null
#
# Indexes
#
#  index_tangos_on_created_at                  (created_at)
#  index_tangos_on_wordnote_id_and_created_at  (wordnote_id,created_at)
#
FactoryBot.define do
  factory :tango do
    answer { 'this is answer' }
    question { 'this is question' }
    hint { 'this is hint' }
    wordnote { FactoryBot.create :wordnote }
  end
end
