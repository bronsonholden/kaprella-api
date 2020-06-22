class CreateTrademarkNames < ActiveRecord::Migration[6.0]
  def change
    create_table :trademark_names do |t|
      t.string :authority, null: false
      t.string :title, null: false
      t.string :mark, null: false
      t.date :grant_date, null: false
      t.date :renewal_date, null: false
      t.references :subject, foreign_key: { to_table: :plant_varieties }, index: { unique: true }
      t.timestamps
    end
  end
end
