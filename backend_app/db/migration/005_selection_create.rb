# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:selections) do
      primary_key :id
      foreign_key :user_id, :users, null: false, unique: true
      String :first_selection, null: false
      DateTime :first_selection_time, null: false
      String :final_selection
      DateTime :final_selection_time
      String :printer_order, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end