# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :user_id, null: false
      String :power_condition
      String :presence_condition
      DateTime :created_at
    end
  end
end
