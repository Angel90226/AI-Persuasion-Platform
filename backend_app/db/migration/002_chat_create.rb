# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:chats) do
      primary_key :id
      foreign_key :user_id, :users, null: false, unique: true
      DateTime :created_at
      DateTime :updated_at
    end
    add_index :chats, :user_id, unique: true
  end
end
