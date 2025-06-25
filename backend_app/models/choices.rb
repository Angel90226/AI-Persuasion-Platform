# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  # class to store the first and final choices
  class Choice < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_one :user, class: :'AIPersuasion::User'
    
    def attributes
      {
        id:,
        user_id:,
        first_choice:,
        first_choice_time:,
        final_choice:,
        final_choice_time:
      }
    end
  end
end
