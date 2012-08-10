require 'mongoid_colored_logger/logger_decorator'

module MongoidColoredLogger

  class Railtie < Rails::Railtie
    initializer 'logger_decorator', :after => :initialize_logger do
      config.mongoid.logger = MongoidColoredLogger::LoggerDecorator.new(Rails.logger)
    end

    # Make it output to STDERR in console
    console do |app|
      config.mongoid.logger = MongoidColoredLogger::LoggerDecorator.new(Logger.new(STDERR))
    end
  end

end
