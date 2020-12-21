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
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "user-#{n}" }
    sequence(:profile) { |n| "profile-#{n}" }
    password { 'password' }
    suspended { false }
  end
end
