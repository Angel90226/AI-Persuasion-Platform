# frozen_string_literal: true

require 'sequel'
module AIPersuasion
  class Chat < Sequel::Model
    # validation for the model
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    many_to_one :user, class: :'AIPersuasion::User'
    many_to_one :message, class: :'AIPersuasion::Message'
    one_to_one :manipulation_check, class: :'AIPersuasion::ManipulationCheck'
    one_to_one :selection, class: :'AIPersuasion::Selection'
    many_to_one :errorlog, class: :'AIPersuasion::Errorlog'

    def attributes
      {
        id:,
        user_id:
      }
    end
  end
end
