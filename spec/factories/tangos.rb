FactoryBot.define do
  factory :tango do
    answer { 'this is answer' }
    question { 'this is question' }
    hint { 'this is hint' }
    wordnote { FactoryBot.create :wordnote }
  end
end
