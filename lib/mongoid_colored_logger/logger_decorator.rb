module MongoidColoredLogger
  class LoggerDecorator
    module Severity
      DEBUG   = 0
      INFO    = 1
      WARN    = 2
      ERROR   = 3
      FATAL   = 4
      UNKNOWN = 5
    end
    include Severity

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

    def add(severity, message = nil, progname = nil, &block)
      message = message.sub('MONGODB', color('MONGODB', odd? ? CYAN : MAGENTA)).
        sub(%r{(?<=\[')([^']+)}) {|m| color(m, BLUE)}.
        sub(%r{(?<=\]\.)\w+}) {|m| color(m, YELLOW)}
      @logger.add(severity, message, progname, &block)
    end

    %w[debug info warn error fatal unknown].each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{method}(message = nil, progname = nil, &block)  # def debug(message = nil, progname = nil, &block)
          add(#{method.upcase}, message, progname, &block)    #   add(DEBUG, message, progname, &block)
        end                                                   # end
      EOT
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

    def odd?
      @odd_or_even = ! @odd_or_even
    end

  end

end
