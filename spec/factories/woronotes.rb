FactoryBot.define do
  factory :wordnote do
    sequence(:name) {|n| "name#{n}" }
    sequence(:subject) {|n| "subject#{n}" }
    is_open { true }
    user { FactoryBot.create :user }
  end
end
