# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    # Create behaviors table
    create_table(:errorlogs) do
      primary_key :id
      foreign_key :chat_id, :chats
      String :error_message
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
