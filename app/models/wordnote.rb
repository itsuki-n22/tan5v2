# == Schema Information
#
# Table name: wordnotes
#
#  id         :bigint           not null, primary key
#  is_open    :boolean          default(TRUE)
#  name       :string           not null
#  subject    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
class Wordnote < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, length: { maximum: 50 }
  validates :subject, presence: true, length: { maximum: 50 }
  has_many :tangos, dependent: :destroy
  has_many :tango_config, dependent: :destroy
  has_many :favorite, dependent: :destroy
end
