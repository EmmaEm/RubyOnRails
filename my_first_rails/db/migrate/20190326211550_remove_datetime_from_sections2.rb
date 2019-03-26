class RemoveDatetimeFromSections2 < ActiveRecord::Migration[5.2]
  def change
    remove_column :sections, :date_time
  end
end
