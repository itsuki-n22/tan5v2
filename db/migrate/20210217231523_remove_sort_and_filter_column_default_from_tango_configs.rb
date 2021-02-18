class RemoveSortAndFilterColumnDefaultFromTangoConfigs < ActiveRecord::Migration[6.0]
  def up
    change_column_default :tango_configs, :sort, nil
    change_column_default :tango_configs, :filter, nil
  end

  def down
    change_column_default :tango_configs, :sort, from: nil, to: "asc"
    change_column_default :tango_configs, :filter, from: nil, to: "none"
  end
end
