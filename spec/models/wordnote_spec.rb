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
require 'rails_helper'

RSpec.describe Wordnote, type: :model do
  describe 'バリデーション' do
    example 'nameが必須であること' do
      wordnote = build(:wordnote, name: nil)
      wordnote.valid?
      expect(wordnote.errors[:name]).to include('を入力してください')
    end

    example 'nameが50文字以下であること' do
      wordnote = build(:wordnote, name: 'x' * 51)
      wordnote.valid?
      expect(wordnote.errors[:name]).to include('は50文字以内で入力してください')
    end

    example 'subjectが必須であること' do
      wordnote = build(:wordnote, subject: nil)
      wordnote.valid?
      expect(wordnote.errors[:subject]).to include('を入力してください')
    end

    example 'subjectが50文字以下であること' do
      wordnote = build(:wordnote, subject: 'x' * 51)
      wordnote.valid?
      expect(wordnote.errors[:subject]).to include('は50文字以内で入力してください')
    end
  end
end
