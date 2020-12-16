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
RSpec.describe Tango, type: :model do
  describe 'バリデーション' do

    example 'answerが存在すること' do
      tango = build(:tango, answer: nil)
      tango.valid?
      expect( tango.errors[:answer] ).to include('を入力してください')
    end

    example 'questionが存在すること' do
      tango = build(:tango, question: nil)
      tango.valid?
      expect( tango.errors[:question] ).to include('を入力してください')
    end

    example 'questionが3000文字以下であること' do
      tango = build(:tango, question: 'x' * 3001)
      tango.valid?
      expect( tango.errors[:question] ).to include('は3000文字以内で入力してください')
    end

    example 'answerが3000文字以下であること' do
      tango = build(:tango, answer: 'x' * 3001)
      tango.valid?
      expect( tango.errors[:answer] ).to include('は3000文字以内で入力してください')
    end

    example 'hintが3000文字以下であること' do
      tango = build(:tango, hint: 'x' * 3001)
      tango.valid?
      expect( tango.errors[:hint] ).to include('は3000文字以内で入力してください')
    end

  end
end
