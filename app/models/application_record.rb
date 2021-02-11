class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true #modelはapplicationRecordを継承するの。abstract_class = true でない場合、modelのインスタンスが生成された場合に継承元の名前のテーブルを自動で探してしまう。なので、sessionコントローラを自前で作った場合、sessionに関連するメソッドが呼ばれるとrecordがないとエラーがでるのでこれが必要
end
