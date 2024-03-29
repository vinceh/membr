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

ActiveRecord::Schema.define(:version => 20130806071237) do

  create_table "admins", :force => true do |t|
    t.string   "email",               :default => "", :null => false
    t.string   "encrypted_password",  :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true

  create_table "beta", :force => true do |t|
    t.string   "full_name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "organization"
    t.string   "job_title"
    t.integer  "number_of_members"
    t.string   "location"
    t.string   "existing_solution"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "creatables", :force => true do |t|
    t.string   "token"
    t.string   "email"
    t.integer  "membership_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "member_id"
    t.string   "stripe_charge_id"
    t.integer  "amount"
    t.integer  "stripe_fee"
    t.boolean  "paid_out",         :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "membership_id"
    t.string   "email"
    t.string   "full_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zipcode"
    t.string   "phone"
    t.boolean  "developer"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "stripe_customer_id"
    t.boolean  "paid",                 :default => false
    t.datetime "paid_time"
    t.boolean  "active",               :default => true,  :null => false
    t.datetime "plan_ending_date"
    t.boolean  "cancel_at_period_end", :default => false
    t.string   "organization"
    t.string   "title"
    t.string   "work_number"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "is_private"
    t.integer  "fee"
    t.integer  "renewal_period"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "archived",       :default => false, :null => false
  end

  create_table "paymenters", :force => true do |t|
    t.string   "token"
    t.integer  "member_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "usercharges", :force => true do |t|
    t.integer  "user_id"
    t.string   "stripe_charge_id"
    t.integer  "amount"
    t.integer  "stripe_fee"
    t.integer  "number_of_members"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",               :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "organization",        :default => "", :null => false
    t.string   "country"
    t.string   "stripe_account_id"
    t.string   "currency"
    t.string   "stripe_public_key"
    t.boolean  "charge_enabled"
    t.string   "stripe_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
