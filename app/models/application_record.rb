class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true #modelはapplicationRecordを継承するの。abstract_class = true でない場合、modelのインスタンスが生成された場合に継承元の名前のテーブルを自動で探してしまう。
end
