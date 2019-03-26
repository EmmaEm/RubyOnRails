class RemoveDatetimeFromSections < ActiveRecord::Migration[5.2]
  def change
    remove_column :sections, :datetime
  end
end
