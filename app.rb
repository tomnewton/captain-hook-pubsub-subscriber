require 'google/cloud/pubsub'
require 'google/cloud/logging'
require 'sinatra/base'

class App < Sinatra::Base
    def initialize
        super
        logging = Google::Cloud::Logging.new
        resource = logging.resource "gae_app",
                            module_id: ENV["GAE_SERVICE"],
                            version_id: ENV["GAE_VERSION"]
        @logger = logging.logger "my_app_log", resource, env: :production
        @@thread = nil
    end

    def pull
        logger = Thread.current["logger"]
        pubsub = Google::Cloud::PubSub.new
        sub = pubsub.subscription "webhook-subscription"
        while true do
            logger.info 'awake...'
            received_messages = sub.pull max: 5
            logger.info "pulled #{received_messages.length} messages"
            sub.acknowledge received_messages
            logger.info "ack'd"
            sleep 5
        end
    end

    get '/_ah/start' do
        @logger.info "Starting up..."
        @@thread = Thread.new {Thread.current["logger"] = @logger;  pull}
        status 200
    end

    get '/_ah/stop' do 
        @@thread.kill if @@thread
    end

    get '/readiness_check' do
        status 200
    end

    get '/liveness_check' do 
        status 200
    end

    run!
end

