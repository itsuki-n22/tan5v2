class RemoveWordnoteIdFromTangoDatum < ActiveRecord::Migration[6.0]
  def change
    remove_column :tango_data, :wordnote_id, :bigint
  end
end
