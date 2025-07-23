# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  # class to store the first and final Selections
  class Selection < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_one :user, class: :'AIPersuasion::User'
    
    def attributes
      {
        id:,
        user_id:,
        first_selection:,
        first_selection_time:,
        final_selection:,
        final_selection_time:,
        printer_order:
      }
    end
  end
end
