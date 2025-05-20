# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:choices) do
      primary_key :id
      foreign_key :user_id, :users # Links choice to a specific user
      String :phase
      String :choice
      String :duration_seconds
      DateTime :created_at
    end
  end
end
