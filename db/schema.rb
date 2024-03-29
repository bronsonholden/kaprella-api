# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_05_195340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "farmers", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "fields", force: :cascade do |t|
    t.string "name", null: false
    t.geography "boundary", limit: {:srid=>4326, :type=>"multi_polygon", :geographic=>true}
    t.integer "srid"
    t.bigint "farmer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["farmer_id"], name: "index_fields_on_farmer_id"
  end

  create_table "licensors", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "patents", force: :cascade do |t|
    t.string "patent_number", null: false
    t.text "title", null: false
    t.date "expiration_date", null: false
    t.text "authority", null: false
    t.bigint "assignee_id"
    t.bigint "subject_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignee_id"], name: "index_patents_on_assignee_id"
    t.index ["subject_id"], name: "index_patents_on_subject_id", unique: true
  end

  create_table "plant_varieties", force: :cascade do |t|
    t.string "genus", null: false
    t.text "denomination", null: false
    t.text "breeder_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "plantings", force: :cascade do |t|
    t.text "notes"
    t.boolean "active", default: false, null: false
    t.bigint "field_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["field_id"], name: "index_plantings_on_field_id"
  end

  create_table "trademark_names", force: :cascade do |t|
    t.string "authority", null: false
    t.string "title", null: false
    t.string "mark", null: false
    t.date "grant_date", null: false
    t.date "renewal_date", null: false
    t.bigint "subject_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_trademark_names_on_subject_id", unique: true
  end

  add_foreign_key "fields", "farmers"
  add_foreign_key "patents", "licensors", column: "assignee_id"
  add_foreign_key "patents", "plant_varieties", column: "subject_id"
  add_foreign_key "plantings", "fields"
  add_foreign_key "trademark_names", "plant_varieties", column: "subject_id"
end
