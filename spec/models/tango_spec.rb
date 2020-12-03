require 'rails_helper'
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
