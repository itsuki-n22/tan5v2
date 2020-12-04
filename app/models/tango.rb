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
class Tango < ApplicationRecord
  belongs_to :wordnote, class_name: 'Wordnote', foreign_key: 'wordnote_id'
  has_many :tango_datum, class_name: 'TangoDatum', dependent: :destroy

  validates :question, presence: true, length: {in: 1..3000}
  validates :answer, presence: true, length: {in: 1..3000}
  validates :hint, length: {in: 0..3000}

  scope :asc_with_datum, -> { order(id: :asc).includes(:tango_datum) }
  scope :desc_with_datum, -> { order(id: :desc).includes(:tango_datum) }
  scope :random_with_datum, -> { includes(:tango_datum).shuffle }
end
