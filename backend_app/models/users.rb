# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  class User < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_many :choices, class: :'AIPersuasion::Choice'
    
    def attributes
      {
        id:,
        user_id:,
        power_condition:,
        presence_condition:
      }
    end
  end
end
