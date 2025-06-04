# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:choices) do
      primary_key :id
      foreign_key :user_id, :users, null: false
      String :first_choice, null: false
      DateTime :first_choice_time, null: false
      String :final_choice, null: false
      DateTime :final_choice_time, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end