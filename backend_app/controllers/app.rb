# frozen_string_literal: true

require 'roda'
require 'json'
require 'net/http'
require 'uri'

module AIPersuasion
  # Backend web app controller
  class App < Roda
    # api using
    plugin :all_verbs
    plugin :public, root: 'dist'
    plugin :render
    plugin :halt
    plugin :streaming
    # PRACTICAL_TASK = 'practical'
    # CREATVIE_TASK = 'creative'
    # TASK_TYPES = %w[CREATIVE PRACTICAL].freeze
    # BASE_PROMPT = 'Act as a travel advisor and provide technical insight on travel aspect suggestions. Write in active voice to make sentences more engaging and easier to follow. The user you are responding to needs to complete a writing task about airports. As the strict advisor, you must keep your replies less than 100 words and briefer is better.'
    # TEST_LOREM = 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'

    # WELCOME_MESSAGE = 'Hello, I am your AI assistant. I have abundant traveling experiences and knowledge. How can I help you today?'
    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to the study' }.to_json
      end
      # frontend api
      r.public
      r.root do
        File.read(File.join('dist', 'index.html'))
      end

      r.get [String, true], [String, true], [true] do |_parsed_request|
        File.read(File.join('dist', 'index.html'))
      end
    end
  end
end
