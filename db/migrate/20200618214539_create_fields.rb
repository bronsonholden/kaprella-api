class CreateFields < ActiveRecord::Migration[6.0]
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.multi_polygon :boundary, geographic: true
      t.integer :srid
      t.references :farmer, foreign_key: true, null: false
      t.timestamps
    end
  end
end
