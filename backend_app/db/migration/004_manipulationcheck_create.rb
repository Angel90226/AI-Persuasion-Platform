# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:manipulation_checks) do
      primary_key :id
      foreign_key :user_id, :users, null: false, unique: true
      # Scores for each question (1-7 Likert scale)
      Integer :question_1, null: false
      Integer :question_2, null: false
      Integer :question_3, null: false
      Integer :question_4, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end 