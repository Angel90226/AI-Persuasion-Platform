# frozen_string_literal: true

require 'sequel'
require 'figaro'
require 'roda'
require 'logger'
module AIPersuasion
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # load config secrets into local environment variables (ENV)
    Figaro.application = Figaro::Application.new(
      environment: environment, # rubocop:disable Style/HashSyntax
      path: File.expand_path('backend_app/environments/secrets.yml')
    )
    Figaro.load

    # Make the environment variables accessible to other classes
    def self.config = Figaro.env
    db_url = ENV['DATABASE_URL']
    puts "Connecting to database at #{db_url}"
    if environment == :development
      # @db = Sequel.connect(db_url, logger: Logger.new($stderr))
      @db = Sequel.connect(db_url)
    else
      @db = Sequel.connect(db_url)
    end
    def self.db = @db # rubocop:disable Style/TrivialAccessors
  end
end
