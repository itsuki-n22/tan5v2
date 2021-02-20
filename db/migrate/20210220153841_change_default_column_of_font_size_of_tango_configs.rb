class ChangeDefaultColumnOfFontSizeOfTangoConfigs < ActiveRecord::Migration[6.0]
  def change
    change_column_default :tango_configs, :font_size, from: nil, to: 32
    TangoConfig.where(font_size: nil).update_all(font_size: 32)
  end
end
