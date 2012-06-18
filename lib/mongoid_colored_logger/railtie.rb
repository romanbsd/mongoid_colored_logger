require 'mongoid_colored_logger/logger_decorator'

module MongoidColoredLogger

  class Railtie < Rails::Railtie
    initializer 'logger_decorator', :after => :initialize_logger do
      if Rails.env.development?
        logger = MongoidColoredLogger::LoggerDecorator.new(Rails.logger)
        if Mongoid::VERSION.to_f >= 3.0
          Moped.logger = logger
        else
          config.mongoid.logger = logger
        end
      end
    end

    # Make it output to STDERR in console
    console do |app|
      logger = MongoidColoredLogger::LoggerDecorator.new(Logger.new(STDERR))
      if Mongoid::VERSION.to_f >= 3.0
        Moped.logger = logger
      else
        config.mongoid.logger = logger
      end
    end
  end

end
