class CreatePlantVarieties < ActiveRecord::Migration[6.0]
  def change
    create_table :plant_varieties do |t|
      t.string :genus, null: false
      t.text :denomination, null: false
      t.text :breeder_number
      t.timestamps
    end
  end
end
