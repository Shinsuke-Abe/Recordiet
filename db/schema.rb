# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121106155257) do

  create_table "milestones", :force => true do |t|
    t.float    "weight"
    t.date     "date"
    t.text     "reward"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "milestones", ["user_id"], :name => "index_milestones_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "mail_address"
    t.string   "display_name"
    t.string   "password"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "weight_logs", :force => true do |t|
    t.date     "measured_date"
    t.float    "weight"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "weight_logs", ["user_id"], :name => "index_weight_logs_on_user_id"

end
