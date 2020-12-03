FactoryBot.define do
  factory :wordnote do
    name { 'test1' }
    subject { 'English' }
    user { FactoryBot.create :user }
  end
end
