# frozen_string_literal: true

# models/location.rb

require 'sequel'

module AIPersuasion
  # class to store the messages between the user and the bot
  class Message < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    many_to_one :chat, class: :'AIPersuasion::Chat'

    def attributes
      {
        id:,
        chat_id:,
        role:,
        response:,
        prompt_time:
      }
    end
  end
end
