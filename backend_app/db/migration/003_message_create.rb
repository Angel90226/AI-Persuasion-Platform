# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # Create messages table
    create_table(:messages) do
      primary_key :id
      foreign_key :chat_id, :chats # Links message to a specific chat
      String :role, null: false
      String :response, null: false
      DateTime :start_time # when the user or agent started to type the message
      DateTime :send_time # when the user or agent sent the message
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
