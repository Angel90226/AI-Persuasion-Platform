# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  # class to store the users
  class User < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    one_to_many :chats, class: :'AIPersuasion::Chat'
    one_to_one :manipulation_checks, class: :'AIPersuasion::ManipulationCheck'
    one_to_many :errorlogs, class: :'AIPersuasion::Errorlog'

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
