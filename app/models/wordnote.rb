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
  has_many :tango_configs, dependent: :destroy
  has_many :favorites, dependent: :destroy

  def tangos_csv
    explain_str = '#このファイルをアップロードする場合、IDが一致している単語はその単語を修正します。answerとquestionの組み合わせがすでに存在する単語ペアはアップロードされません。この行は削除しないでください。'
    dl_data = CSV.generate do |csv|
      csv <<  ['id', 'question', 'answer', 'hint', explain_str]
      tangos.each do |tango|
        csv << [tango.id, tango.question, tango.answer, tango.hint]
      end
    end
  end

  def import_tangos(import_path)
    new_tangos = []
    update_tangos = []
    now = Time.current

    CSV.foreach(import_path, headers: true, encoding: 'utf-8') do |row|
      new_tangos << { id: row['id'].to_i, wordnote_id: id, answer: row['answer'], question: row['question'], hint: row['hint'], created_at: now, updated_at: now }
    end

    new_tangos.delete_if do |new_tango|
      delete_flag = false
      tangos.each do |old_tango|
        if old_tango.id == new_tango[:id]
          delete_flag = true
          unless old_tango.answer == new_tango[:answer] \
              && old_tango.question == new_tango[:question] \
              && old_tango.hint == new_tango[:hint]
            update_tangos << new_tango
          end
          break
        elsif old_tango.answer == new_tango[:answer] \
            && old_tango.question == new_tango[:question]
          delete_flag = true
          break
        end
      end
      delete_flag # ここがtrueなら削除
    end
    new_tangos.map { |t| t.delete(:id) }

    begin
      tangos.insert_all new_tangos if new_tangos.empty? == false
      tangos.upsert_all update_tangos if update_tangos.empty? == false
    rescue StandardError => e
      @error = e.class.to_s.split('::').last
      render action: 'upload_tangos_csv.js.erb'
    end
  end
end
