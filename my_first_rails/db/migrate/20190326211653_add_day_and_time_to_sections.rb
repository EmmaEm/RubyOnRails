class AddDayAndTimeToSections < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :weekday, :integer
    add_column :sections, :hour, :time
  end
end
