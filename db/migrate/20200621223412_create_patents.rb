class CreatePatents < ActiveRecord::Migration[6.0]
  def change
    create_table :patents do |t|
      t.string :patent_number, null: false
      t.text :title, null: false
      t.date :expiration_date, null: false
      t.text :authority, null: false
      t.references :assignee, foreign_key: { to_table: :licensors }
      t.references :subject, foreign_key: { to_table: :plant_varieties }, index: { unique: true }
      t.timestamps
    end
  end
end
