module Dione
  class NotFound < StandardError; end

  class ErrorHandler < Dione::Middleware
    priority 0

    def initialize(app)
      @app = app
    end

    if ['production', 'testing'].include? ENV['DIONE_ENVIRONMENT']
      def call(env)
        @app.call(env)
      rescue Dione::NotFound
        [404, { 'Content-Type' => 'text/plain' }, StringIO.new("Could not be found")]
      end
    else
      def call(env)
        @app.call(env)
      end
    end
  end
end
