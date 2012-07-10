require 'log4r/argparser/argparser'
require 'log4r/logevent'
module Log4r
  class ExceptionParser < ArgParser
    def parse(args,context)
      #This is so we only handle things that are args and exceptions
      exceptions = []

      return nil unless args.inject(true){|r,arg|exceptions << arg if Exception===arg; r and (Exception===arg or String===arg)}
      # We don't know what to do with multiple exceptions
      return nil unless exceptions.size<=1

      msg = args.inject('') do |e,arg|
        if Exception===arg 
          e + arg.message
        else
          e + arg
        end
      end 
      logevent = log_event_class.create_from_context(msg,context) 
      logevent[:log_data] = msg
      return logevent if exceptions.empty?
      exceptions.each do |exp|
        if exp.is_a?(Exception)
          logevent[:backtrace] = exp.backtrace if exp.backtrace
        else
          raise([:cannot_log_error, args.inspect])
        end
      end
      logevent
    end
  end
end
