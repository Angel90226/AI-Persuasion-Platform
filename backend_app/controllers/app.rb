# frozen_string_literal: true

require 'roda'
require 'json'
require 'net/http'
require 'uri'
require_relative '../lib/prompts'

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

    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to the study' }.to_json
      end

      r.get 'random-condition' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        queue = RandomQueue.new(Api.config)
        queue.random_condition
      end

      r.post 'update_user' do
        user_id = r.params['user_id'] || 'anonymous'
        power_condition = r.params['power_condition'] || 'none'
        presence_condition = r.params['presence_condition'] || 'none'
        print 'power_condition:', power_condition
        print 'presence_condition:', presence_condition
        user = User.first(user_id: user_id)
        if user.nil?
          user = User.create(user_id:, power_condition:, presence_condition: )
          Chat.create(user_id: user.id)
        end
        response.status = 201
        { success: true, message: 'User (and chat) updated/created' }.to_json
      end

      r.get 'messages' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        user = User.first(user_id: user_id)
        if user.nil?
          Errorlog.create(user_id: user_id, error_message: "User not found in GET /messages")
          return [].to_json
        end
        chat = Chat.first(user_id: user.id)
        Message.where(chat_id: chat.id).map(&:values).to_json
      end

      r.post 'error-log' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)
        chat = Chat.first(user_id: user.id)
        error_log = Errorlog.create(chat_id: chat.id, error_message: data['error_message'])
        response.status = 201
        error_log.attributes.to_json
      end

      # streaming with openAI api in frontend assign prompt
      r.post 'openAI-streaming' do
        response['Content-Type'] = 'text/event-stream'
        response['Cache-Control'] = 'no-cache'
        response['Connection'] = 'keep-alive'

        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)

        temp = data['temp'] || 0.7
        user = User.first(user_id: user_id)
        chat = Chat.first(user_id: user.id)

        # Select prompt based on user's power condition
        base_prompt = if user && user.power_condition == 'high'
                       Prompts::HIGH_POWER_PROMPT
                     else
                       Prompts::LOW_POWER_PROMPT
                     end
        history_messages = Message.where(chat_id: chat.id).map(&:values).map do |item|
          {
            'role' => item[:role],
            'content' => item[:response]
          }
        end
        streaming_gpt = ChatGptStreaming.new(base_prompt, history_messages, temp)
        stream do |out|
          streaming_gpt.streaming.each { |message| out << message }
          sleep 0.1
        end
      end

      r.post 'message' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        print 'data to store:', data
        role = data['role'] || 'user'
        user = User.first(user_id: user_id)
        chat = Chat.first(user_id: user.id)
        Message.create(chat_id: chat.id, role:, response: data['response'], start_time: data['start_time'], send_time: data['send_time'])
        Message.where(chat_id: chat.id).map(&:values).to_json
      end

      r.get 'manipulation-check/status' do
        response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        user = User.first(user_id: user_id)

        if user.nil?
          response.status = 404
          return { status: 'error', message: 'User not found' }.to_json
        end

        check = ManipulationCheck.first(user_id: user.id)

        if check
          response.status = 200
          { status: 'completed' }.to_json
        else
          response.status = 200
          { status: 'pending' }.to_json
        end
      end

      r.post 'manipulation-check' do
        response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)
        
        if user.nil?
          response.status = 404
          { success: false, message: 'User not found' }.to_json
        else
          manipulation_check = ManipulationCheck.first(user_id: user.id)
          
          if manipulation_check
            # Update existing record
            manipulation_check.update(
              question_1: data['question_1'],
              question_2: data['question_2'],
              question_3: data['question_3'],
              question_4: data['question_4']
            )
            response.status = 200 # OK
            manipulation_check.attributes.to_json
          else
            # Create new record
            manipulation_check = ManipulationCheck.create(
              user_id: user.id,
              question_1: data['question_1'],
              question_2: data['question_2'],
              question_3: data['question_3'],
              question_4: data['question_4']
            )
            response.status = 201 # Created
            manipulation_check.attributes.to_json
          end
        end
      end

      r.post 'submit-first-selection' do
        response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)
        selection= Selection.create(user_id: user.id, first_selection: data['firstSelection'], first_selection_time: data['firstSelectionTime'], printer_order: data['printerOrder'])
        response.status = 201
        selection.attributes.to_json
      end

      r.post 'submit-final-selection' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)

        if user.nil?
          response.status = 404
          return { success: false, message: 'User not found' }.to_json
        end

        selection = Selection.first(user_id: user.id)

        if selection.nil?
          response.status = 404
          return { success: false, message: 'No selection to update' }.to_json
        end

        selection.update(final_selection: data['finalSelection'], final_selection_time: Time.now)
        print 'data:', data
        RandomQueue.new(Api.config).finish_task(data['condition']) if data['condition']
        return selection.attributes.to_json
      end

      r.get 'task-finished' do
        response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        user = User.first(user_id: user_id)
        if user.nil?
          response.status = 404
          return { taskFinished: false, message: 'User not found' }.to_json
        end

        selection= Selection.first(user_id: user.id)
        if selection.nil?
          response.status = 404
          return { taskFinished: false, message: 'selection not found' }.to_json
        end

        if selection.final_selection.nil?
          response.status = 200
          { taskFinished: false }.to_json
        else
          conditions = r.params['conditions']
          RandomQueue.new(Api.config).finish_task(conditions) if conditions
          response.status = 200
          { taskFinished: true }.to_json
        end
      end
    
      # test Queue
      r.get 'queue' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        print('test:', Api.config)
        RandomQueue.new(Api.config).queue_attributes.to_json
      end

      r.get 'reset-queue' do
        num_of_task = r.params['num'].to_i || 400
        queue = RandomQueue.new(Api.config)
        queue.clear_queue
        response['Content-Type'] = 'application/json'
        response.status = 200
        queue.fill_task(num_of_task).to_json
      end

      r.post 'reset-queue-imbalance' do
        data = JSON.parse(r.body.read)

        TASK_TYPES.each do |task|
          next unless data[task].nil? || data[task].to_i < 0

          response['Content-Type'] = 'application/json'
          response.status = 500
          { success: false, message: 'Invalid type given' }.to_json
          break
        end
        queue = RandomQueue.new(Api.config)
        queue.clear_queue
        response['Content-Type'] = 'application/json'
        response.status = 200
        queue.fill_task_imbalance(data).to_json
      end

      r.get 'clear-queue' do
        queue = RandomQueue.new(Api.config)
        queue.clear_queue
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Queue cleared' }.to_json
      end

      r.get 'post-survey-url' do
        response['Content-Type'] = 'application/json'
        { post_survey_url: ENV['POST_SURVEY_URL'] }.to_json
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
