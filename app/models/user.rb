# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  admin           :boolean          default(FALSE)
#  email           :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  profile         :string
#  profile_image   :string
#  suspended       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_LOWER_email  (lower((email)::text)) UNIQUE
#  index_users_on_name         (name)
#
class User < ApplicationRecord
  has_secure_password
  paginates_per 20
  include StringNormalizer
  has_many :wordnotes, dependent: :destroy
  has_many :tango_data, dependent: :destroy
  has_many :tango_configs, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_wordnotes, through: :favorites, source: :wordnote
  mount_uploader :profile_image, ProfileImageUploader
  validate :profile_image_size

  before_validation do
    self.name = normalize_as_name(name)
    self.email = normalize_as_email(email)
  end
  validates :name, presence: true, length: { in: 1..24 }
  validates :email, presence: true, "valid_email_2/email": true,
                    uniqueness: true, length: { in: 1..48 }

  def unfavorite(wordnote)
    favorite_wordnotes.destroy(wordnote)
  end
 
  def favorite(wordnote)
    favorite_wordnotes << wordnote
  end

  def favorited?(wordnote)
    favorite_wordnotes.include?(wordnote)
  end

  private 

    def profile_image_size
      errors.add(:profile_image, 'should be less than 1MB') if profile_image.size > 1.megabytes
    end
end
