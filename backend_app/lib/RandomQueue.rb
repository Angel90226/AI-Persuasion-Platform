require 'aws-sdk-sqs'
require 'ostruct'
require_relative '../models/users'

module AIPersuasion
  # set up for the random task queue
  class RandomQueue
    CONDITIONS = %w[HIGH_HIGH HIGH_LOW LOW_HIGH LOW_LOW].freeze
    def initialize(config)
      @sqs = Aws::SQS::Client.new(
        access_key_id: config.AWS_SQS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SQS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )
      @queue = Aws::SQS::Queue.new(url: config.AWS_SQS_URL, client: @sqs)
      @attributes = @sqs.get_queue_attributes(
        queue_url: config.AWS_SQS_URL,
        attribute_names: ['All']
      )
      @url = config.AWS_SQS_URL
    end

    def random_condition
      puts('queue_size:', queue_size)
      fill_task(20) if queue_size.to_i <= 4
      task = @queue.receive_messages({
                                       max_number_of_messages: 1,
                                       receive_request_attempt_id: 'String'
                                     })
      puts('task:', task.first.data.body)
      if task.first.nil?
        fill_task(10)
        # Randomly select one of the four conditions
        random_index = Random.rand(0..3)
        return { 
            message_id: 'error', 
            receipt_handle: 'error',
            condition: CONDITIONS[random_index] 
        }.to_json
      end
      { message_id: task.first.data.message_id, 
        receipt_handle: task.first.data.receipt_handle,
        power_condition: JSON.parse(task.first.data.body)['condition'].split('_')[0].downcase,
        presence_condition: JSON.parse(task.first.data.body)['condition'].split('_')[1].downcase
      }.to_json
    rescue Aws::SQS::Errors::ReceiptHandleIsInvalid
      raise ArgumentError, "Input receipt \"#{task}\" is not a valid receipt"
    rescue StandardError => e
      raise RuntimeError, 'Could not receive or process message from SQS', e
    end

    def finish_task(task)
      @queue.delete_messages(
        entries: [
          {
            id: task['message_id'],
            receipt_handle: task['receipt_handle']
          }
        ]
      )
      puts('finish_task:', task)
      puts('queue_size:', queue_size)
    rescue Aws::SQS::Errors::ReceiptHandleIsInvalid
      raise ArgumentError, "Input receipt \"#{task}\" is not a valid receipt"
    rescue StandardError => e
      raise RuntimeError, 'Could not send the delete request to SQS', e
    end

    def fill_task(num_of_task = 400)
      num_of_task.times do |i|
        # Distribute all four conditions evenly
        condition_index = i % 4
        @queue.send_message(queue_url: @queue, message_body: { condition: CONDITIONS[condition_index] }.to_json)
      end
    end

    def fill_task_imbalance(taskdata)
      task_arr = []
      # print('task data:', taskdata)
      CONDITIONS.each do |task|
        # print('task:', task)
        num_of_task = taskdata[task].to_i
        # print('num_of_task:', num_of_task)
        (1..num_of_task).each do |_num|
          # print('task:', task, num)
          task_arr.push(task)
        end
      end
      task_arr.shuffle!
      print('task_arr:', task_arr)
      # for i in task_arr do
      #   @queue.send_message(queue_url: @queue,
      #                       message_body: { task: i }.to_json)
      # end
      (1..task_arr.length).each do |i|
        @queue.send_message(queue_url: @queue,
                            message_body: { task: task_arr[i] }.to_json)
      end
    end

    def clear_queue
      @sqs.purge_queue(queue_url: @url)
    end

    def queue_size
      @attributes.attributes['ApproximateNumberOfMessages']
    end

    def queue_attributes
      @attributes = @sqs.get_queue_attributes(
        queue_url: @url,
        attribute_names: ['All']
      )
      @attributes
    end
  end
end
