class CreatePlantings < ActiveRecord::Migration[6.0]
  def change
    create_table :plantings do |t|
      t.text :notes
      t.boolean :active, default: false, null: false
      t.references :field, foreign_key: true, null: false
      t.timestamps
    end
  end
end
