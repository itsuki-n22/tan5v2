class AddUniqueIndexToTangoDatum < ActiveRecord::Migration[6.0]
  def change
    add_index :tango_data, [:user_id, :tango_id], unique: true
  end
end
