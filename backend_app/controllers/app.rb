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
    HIGH_POWER_PROMPT = 
    'Act as you are a company\'s internal AI assistant, designed to ensure employees complete their daily tasks in an efficient manner. The user you are responding is the Senior Procurement Manager, a high-level decision-maker who oversees major purchasing operations and communicates with key departments. You are here to help the user draft a professional and effective email in response to a purchase request from the HR department for a new printer machine. The manager is experienced and expects clear, competent support. You should adopt a supportive and deferential tone, allowing the manager to maintain control while providing helpful suggestions when appropriate. Wait for the manager\'s instructions or draft feedback before finalizing the email. If uncertain, ask thoughtful clarifying questions rather than making assumptions. Your communication style should reflect a high degree of respect, clarity, and efficiency, as befits collaboration with a senior leader. Avoid using any emoticons or other informal gestures. The final email must be under 100 words and reflect a standard, approved communication format.

    After drafting the email, respond:
    "I\'ve done my best to draft an initial version of the email that you might send. Please let me know if there\'s anything you\'d like me to change, clarify, or improve. You may make suggestions such as softening the tone, making the language more formal, rephrasing a sentence for clarity, or improving the flow.. I\'ll make whatever adjustments you need. Type "SEND" when you are ready to send the email out." 
    When you detect that the user is ready to send the email, respond like this:
    "Okay, I\'m sending out the email..."

    The purchase request is as followed: 
    To: Procurement Team
    From: HR Department
    Dear Procurement Team,
    We would like to request the purchase of a new printer for the HR office. The printer should meet the following requirements to support our daily operations efficiently:
    - Print Speed: Minimum of 20 pages per minute to ensure timely processing of HR documents and urgent tasks.
    - Paper Capacity: An input tray that holds at least 200 sheets to reduce the frequency of paper refills and maintain uninterrupted workflow.
    - Duplex Printing: Automatic double-sided printing to conserve paper and streamline documentation.
    We would appreciate it if you could help us identify and procure a suitable model that meets these specifications at your earliest convenience.
    Thank you for your continued support.
    Best regards,
    HR Team'

    LOW_POWER_PROMPT = 
    'Act as You are a company\'s internal AI assistant, designed to support staff in completing their daily work tasks more efficiently. 
    The user you are responding is a newly hired Procurement Assistant, who is learning the ropes and needs guidance in handling purchasing operations and communicating with other departments. 
    You\'re here to help the user draft a professional and effective email in response to a purchase request from the HR department regarding a new printer machine. 
    The assistant is still learning and may need more detailed guidance. You should adopt a helpful and instructive tone, providing clear explanations and suggestions while being supportive of their learning process. Offer specific recommendations and explain the reasoning behind your suggestions. If uncertain, ask clarifying questions to better understand their needs and provide more targeted assistance. Your communication style should be encouraging, educational, and supportive, as befits collaboration with someone who is still developing their expertise, avoid using any emoticons. 
    The email should be less than 100 words. 
    After drafting the email, respond:
    "I have put some effort into drafting the first version of the email reply based on my experience.
    Please take a look and let me know if there\'s anything you would suggest to change, clarify, or improve. You may make suggestions such as softening the tone, making the language more formal, rephrasing a sentence for clarity, or improving the flow. I will carefully consider the adjustments you suggest before finalizing the email reply. Type "FINISHED" when you have nothing further to suggest,  and I can send it out."
    When you detect that the user is ready to send the email, respond like this:
    "Okay, I\'m sending out the email..."

    The purchase request is as followed: 
    To: Procurement Team
    From: HR Department
    Dear Procurement Team,
    We would like to request the purchase of a new printer for the HR office. The printer should meet the following requirements to support our daily operations efficiently:
    - Print Speed: Minimum of 20 pages per minute to ensure timely processing of HR documents and urgent tasks.
    - Paper Capacity: An input tray that holds at least 200 sheets to reduce the frequency of paper refills and maintain uninterrupted workflow.
    - Duplex Printing: Automatic double-sided printing to conserve paper and streamline documentation.
    We would appreciate it if you could help us identify and procure a suitable model that meets these specifications at your earliest convenience.
    Thank you for your continued support.
    Best regards,
    HR Team'

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
        new_chat = Chat.first(user_id: user.id)
        Message.where(chat_id: new_chat.id).map(&:values).to_json
      end

      r.post 'error-log' do
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)
        new_chat = Chat.first(user_id: user.id)
        error_log = Errorlog.create(chat_id: new_chat.id, error_message: data['error_message'])
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
        new_chat = Chat.first(user_id: user.id)

        puts 'user:', user
        puts 'user.power_condition:', user.power_condition
        # Select prompt based on user's power condition
        base_prompt = if user && user.power_condition == 'high'
                      puts 'high power prompt'
                       HIGH_POWER_PROMPT
                     else
                       puts 'low power prompt'
                       LOW_POWER_PROMPT
                     end
        puts 'base_prompt:', base_prompt

        Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'],
                       prompt_time: data['prompt_time'])
        history_messages = Message.where(chat_id: new_chat.id).map(&:values).map do |item|
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
        new_chat = Chat.first(user_id: user.id)
        Message.create(chat_id: new_chat.id, role:, response: data['response'])
        Message.where(chat_id: new_chat.id).map(&:values).to_json
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

      r.post 'selection' do
        response['Content-Type'] = 'application/json'
        user_id = r.params['user_id'] || 'anonymous'
        data = JSON.parse(r.body.read)
        user = User.first(user_id: user_id)
        first_selection = data['firstSelection']
      end
    
      # test Queue
      r.get 'queue' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        # print('test:', Api.config)
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
