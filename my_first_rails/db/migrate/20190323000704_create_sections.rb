class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.string :name
      t.datetime :date_time

      t.timestamps
    end
  end
end
