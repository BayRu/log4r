# :nodoc:
module Log4r
  class ArgParser 
    #ArgParser#parse MUST return one of the following:
    #  nil:  This indicates no progress was made
    #  [LogEvents], :done    : This indicates processing is done, send to no one else, log these
    #  [LogEvents], :fork    : This indicates you should log these event, AND SEND THE ORIGINAL
                            #    args and context to the next function in the chain. 
    #  [LogEvents], :next    : This indicates you should log these events to the next ite in the chain.
    attr_accessor :accept_anything, :log_event_class
    def log_event_class
      @log_event_class||=(Logger.log_event_class||::Log4r::LogEvent)
    end
    def initialize hsh={}
      self.accept_anything=hsh[:accept_anything]
      @log_event_class = hsh[:log_event_class]
      self
    end
    def parse args, context
      ret = args.map { |arg|
        if String===arg or (self.accept_anything and arg.respond_to?(:to_s))
          Logger.log_event_class.create_from_context(args.to_s,context)
        else
          nil
        end
      }
      ret.include?(nil) ? nil : ret 
    end
  end
end
