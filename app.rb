require 'google/cloud/pubsub'

def main 
    pubsub = Google::Cloud::PubSub.new
    sub = pubsub.subscription "webhooks"
    
    while true do
        puts 'awake...'
        received_messages = sub.pull max: 5
        received_messages.each do |message|
            message.acknowledge!
            puts 'ack!'
        end
        sleep 5
    end
end

if __FILE__ == $PROGRAM_NAME
    main()
end