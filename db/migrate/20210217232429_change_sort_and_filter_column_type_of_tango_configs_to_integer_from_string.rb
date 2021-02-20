class ChangeSortAndFilterColumnTypeOfTangoConfigsToIntegerFromString < ActiveRecord::Migration[6.0]
  def up
    TangoConfig.where(sort: "asc").update_all(sort: 0 )
    TangoConfig.where(sort: "desc").update_all(sort: 1 )
    TangoConfig.where(sort: "random").update_all(sort: 2 )
    TangoConfig.where(filter: "0").update_all(filter: 0 )
    TangoConfig.where(filter: "1").update_all(filter: 1 )
    TangoConfig.where(filter: "2").update_all(filter: 2 )
    TangoConfig.where(filter: "3").update_all(filter: 3 )
    TangoConfig.where(filter: "4").update_all(filter: 4 )
    TangoConfig.where(filter: "5").update_all(filter: 5 )
    change_column :tango_configs, :sort, 'integer USING CAST(sort AS integer)'
    change_column :tango_configs, :sort, :integer, default: 0
    change_column :tango_configs, :filter, 'integer USING CAST(filter AS integer)'
    change_column :tango_configs, :filter, :integer, default: 0
  end

  def down
    TangoConfig.where(sort: 0).update_all(sort: "asc" )
    TangoConfig.where(sort: 1).update_all(sort: "desc" )
    TangoConfig.where(sort: 2).update_all(sort: "random" )
    TangoConfig.where(filter: 0).update_all(filter: "0" )
    TangoConfig.where(filter: 1).update_all(filter: "1" )
    TangoConfig.where(filter: 2).update_all(filter: "2" )
    TangoConfig.where(filter: 3).update_all(filter: "3" )
    TangoConfig.where(filter: 4).update_all(filter: "4" )
    TangoConfig.where(filter: 5).update_all(filter: "5" )
    change_column :tango_configs, :sort, :string, default: nil
    change_column :tango_configs, :filter, :string, default: nil
  end
end
