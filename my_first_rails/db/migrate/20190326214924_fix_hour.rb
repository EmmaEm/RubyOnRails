class FixHour < ActiveRecord::Migration[5.2]
  def change
    rename_column :sections, :hour, :section_time
  end
end
