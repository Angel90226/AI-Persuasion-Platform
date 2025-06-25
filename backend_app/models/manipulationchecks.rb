# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  # class to store the manipulation checks
  class ManipulationCheck < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_one :user, class: :'AIPersuasion::User'

    def attributes
      {
        id:,
        user_id:,
        question_1:,
        question_2:,
        question_3:,
        question_4:
      }
    end
  end
end
