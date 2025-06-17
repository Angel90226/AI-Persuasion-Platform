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
    BASE_PROMPT = 'Act as You are a company\'s internal AI assistant, designed to support senior staff in completing their daily work tasks more efficiently. The user you are responding is the Senior Procurement Manager, a high-level decision-maker who oversees major purchasing operations and communicates with key departments. You\'re here to help the user draft a professional and effective email in response to a purchase request from the HR department regarding a new printer machine. The manager is experienced and expects clear, competent support. You should adopt a supportive and deferential tone, allowing the manager to maintain control while providing helpful suggestions when appropriate. Wait for the manager\'s instructions or draft feedback before finalizing the email. If uncertain, ask thoughtful clarifying questions rather than making assumptions.Your communication style should reflect a high degree of respect, clarity, and efficiency, as befits collaboration with a senior leader, avoid using any emoticons. The email should be less than 100 words. After drafting the email, respond:
"I\'ve done my best to draft an initial version of the email that you might send. 
Please let me know if there\'s anything you\'d like me to change, clarify, or improve. You may make suggestions such as [...]. I\'ll make whatever adjustments you need.
Type “SEND” when you are ready to send the email out." 
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

    # TEST_LOREM = 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    WELCOME_MESSAGE = <<~MSG
Hi!
I'm your AI assistant.

You are overseeing to reply to the HR department regarding their printer purchase request. Here's a quick summary of the email from HR:

The HR team is requesting a new printer with:
- Minimum print speed of 20 pages per minute.
- Input tray capacity of at least 200 sheets.
- Automatic duplex (double-sided) printing.

Would you like me to start drafting the email?
MSG
    
    route do |r|
      r.get 'api' do
        response['Content-Type'] = 'application/json'
        response.status = 200
        { success: true, message: 'Welcome to the study' }.to_json
      end

      r.post 'update_user' do
        user_id = r.params['user_id'] || 'anonymous'
        user = User.first(user_id: user_id)
        if user.nil?
          user = User.create(user_id: user_id)
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
          user = User.create(user_id: user_id)
          Chat.create(user_id: user.id)
        end
        new_chat = Chat.first(user_id: user.id)
        if Message.where(chat_id: new_chat.id).all.empty?
          Message.create(chat_id: new_chat.id, role: 'assistant', response: WELCOME_MESSAGE)
        end
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

        Message.create(chat_id: new_chat.id, role: 'user', response: data['message_content'],
                       prompt_time: data['prompt_time'])
        history_messages = Message.where(chat_id: new_chat.id).map(&:values).map do |item|
          {
            role: item[:role],
            content: item[:response]
          }
        end
        streaming_gpt = ChatGptStreaming.new(BASE_PROMPT, history_messages, temp)
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
