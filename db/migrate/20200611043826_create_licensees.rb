class CreateLicensees < ActiveRecord::Migration[6.0]
  def change
    create_table :licensees do |t|
      t.text :name, null: false
      t.string :account_id, null: false, unique: true
      t.string :country, limit: 2, null: false
      t.timestamps
    end
  end
end
