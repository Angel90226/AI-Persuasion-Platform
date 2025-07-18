# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'dotenv'

# Module to interact with OpenAI's API
module AIPersuasion
  # Class for interfacing with ChatGPT API
  class ChatGptStreaming
    Dotenv.load
    API_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
    API_KEY = ENV['OPENAI_API_KEY']

    def initialize(system_content, history_messages, temperature)
      @uri = URI.parse(API_ENDPOINT)
      @requests = build_request(@uri, system_content, history_messages, temperature)
    end

    def streaming
      Enumerator.new do |out|
        Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: true) do |http|
          http.request @requests do |response|
            response.read_body do |chunk|
              out << chunk
            end
          end
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def build_request_body(system_content, history_messages, temperature)
      JSON.dump(
        {
          'model' => 'gpt-4o',
          'temperature' => temperature || 0.6,
          'stream' => true,
          'messages' =>
            history_messages.unshift({
                                       'role' => 'system',
                                       'content' => system_content
                                     })
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    def build_request(uri, system_content, history_messages, temperature)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      # request.content_type = 'text/event-stream'
      request['Authorization'] = "Bearer #{API_KEY}"
      request.body = build_request_body(system_content, history_messages, temperature)
      request
    end

    def handle_errors(response)
      raise HTTP_ERROR[response.code.to_i], response.message if HTTP_ERROR.keys.include?(response.code.to_i)
    end
  end
end
