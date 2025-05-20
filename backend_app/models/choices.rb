# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  class Choice < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    many_to_one :user, class: :'AIPersuasion::User'
    
    def attributes
      {
        id:,
        user_id:,
        phase:,
        choice:,
        duration_seconds:
      }
    end
  end
end
