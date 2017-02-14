require 'mongoid'

module MongoidColoredLogger
  class LoggerDecorator
    WHITE = "\e[37m"
    CYAN = "\e[36m"
    MAGENTA = "\e[35m"
    BLUE = "\e[34m"
    YELLOW = "\e[33m"
    GREEN = "\e[32m"
    RED = "\e[31m"
    BLACK = "\e[30m"
    BOLD = "\e[1m"
    CLEAR = "\e[0m"

    def initialize(logger)
      raise ArgumentError, "The logger must respond to the #add method" unless logger.respond_to?(:add)
      @logger = logger
    end

    colorize_method = Mongoid::VERSION.to_f >= 3.0 ? :colorize_message : :colorize_legacy_message

    %w[debug info warn error fatal unknown].each.with_index do |method, severity|
      define_method(method) do |message = nil, progname = nil, &block|
        message = block.call if message.nil? and block
        message = self.send(colorize_method, message.to_s)

        @logger.add(severity, message, progname, &block)
      end
    end

    # Proxy everything else to the logger instance
    def respond_to?(method)
      super || @logger.respond_to?(method)
    end

  private
    def method_missing(method, *args, &block)
      @logger.send(method, *args, &block)
    end

    def color(text, color, bold=false)
      color = self.class.const_get(color.to_s.upcase) if color.is_a?(Symbol)
      bold  = bold ? BOLD : ""
      "#{bold}#{color}#{text}#{CLEAR}"
    end

    # Used for Mongoid < 3.0
    def colorize_legacy_message(message)
      message.sub('MONGODB', color('MONGODB', odd? ? CYAN : MAGENTA)).
        sub(%r{(?<=\[')([^']+)}) {|m| color(m, BLUE)}.
        sub(%r{(?<=\]\.)\w+}) {|m| color(m, YELLOW)}
    end

    # Used for Mongoid >= 3.0
    def colorize_message(message)
      message = message.sub('MONGODB', color('MONGODB', odd? ? CYAN : MAGENTA)).
        sub(%r{(?<=\[')([^']+)}) {|m| color(m, BLUE)}.
        sub(%r{(?<=\]\.)\w+}) {|m| color(m, YELLOW)}
      message.sub('MOPED:', color('MOPED:', odd? ? CYAN : MAGENTA)).
        sub(/\{.+?\}\s/) { |m| color(m, BLUE) }.
        sub(/COMMAND|QUERY|KILL_CURSORS|INSERT|DELETE|UPDATE|GET_MORE/) { |m| color(m, YELLOW) }.
        sub(/[\d\.]+ms/) { |m| color(m, GREEN) }
    end

    def odd?
      @odd_or_even = ! @odd_or_even
    end
  end
end
