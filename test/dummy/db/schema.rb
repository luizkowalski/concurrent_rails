# frozen_string_literal: true

ActiveRecord::Schema[7.0].define(version: 20_210_508_215_129) do
  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
