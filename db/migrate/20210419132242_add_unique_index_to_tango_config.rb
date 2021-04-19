class AddUniqueIndexToTangoConfig < ActiveRecord::Migration[6.0]
  def change
    add_index :tango_configs, [:user_id, :wordnote_id], unique: true
  end
end
