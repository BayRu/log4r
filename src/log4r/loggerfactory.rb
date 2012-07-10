# :nodoc:
# Version:: $Id$

require "log4r/base"
require "log4r/repository"
require 'log4r/logevent'

module Log4r
class Logger
  class LoggerFactory #:nodoc:

    # we want to log iff root.lev <= lev && logger.lev <= lev
    # BTW, root is guaranteed to be defined by this point
    def self.define_methods(logger)
      return if logger.is_root?
      undefine_methods(logger)
      globlev = Repository['root'].level
      return if logger.level == OFF or globlev == OFF
      toggle_methods(globlev, logger)
    end

    # set logging methods to null defaults
    def self.undefine_methods(logger)
      for lname in LNAMES
        next if lname == 'OFF'|| lname == 'ALL'
        unset_log(logger, lname)
        set_false(logger, lname)
      end
      set_false(logger, 'all')
      set_true(logger, 'off')
    end
    
    # toggle methods >= globlev that are also >= level
    def self.toggle_methods(globlev, logger)
      for lev in globlev...LEVELS # satisfies >= globlev
        next if lev < logger.level # satisfies >= level
        next if LNAMES[lev] == 'OFF'
        next if LNAMES[lev] == 'ALL'
        set_log(logger, LNAMES[lev])
        set_true(logger, LNAMES[lev])
      end
      if logger.level == ALL
        set_true(logger, 'all')
      end
      if logger.level != OFF && globlev != OFF
        set_false(logger, 'off')
      end
    end

    # And now, the weird dynamic method definitions! :)
  
    def self.unset_log(logger, lname)
      mstr="def logger.#{lname.downcase}(data=nil, propagated=false); end"
      module_eval mstr
    end
    
    # Logger logging methods are defined here.
    def self.set_log(logger, lname) 
      # invoke caller iff the logger invoked is tracing
      tracercall = (logger.trace ? "caller" : "nil")
      # maybe pass parent a logevent. second arg is the switch
      if logger.additive && !logger.parent.is_root?
        parentcall = "puts 'propogating to parent!'\n@parent.propogated_#{lname.downcase}(events)"

        parentcall = "STDOUT.puts 'propogating to parent!'\n@parent.propogated_#{lname.downcase}(events)"
      end
      mstr = %-
        def logger.propagated_#{lname.downcase}(*events)
          @outputters.each {|o| events.flatten.each{|event| o.log_level(event) } }
          #{parentcall}
          true 
        end

        def logger.#{lname.downcase}(*data)
          src = :inline
          if block_given?
            data = [yield].flatten
            src  = :block
          end
          context ={  :logger_level => #{lname}, :logger => self, :backtrace => #{tracercall}, :source =>  src}
          event_parsers = Logger.parsers
          events = event_parsers.inject(nil)do |ret,p|
            ret or p.parse(data,context)
          end
          events = [events] unless Array===events
          events.compact!
          if events.nil? or events.length==0
            raise "No parser for event found! \#{data.inspect}"
          end
          @outputters.each {|o| events.each{|e|o.log_level(e) } }
          #{parentcall}
          true 
        end
      -
      module_eval mstr
    end
    
    def self.set_false(logger, lname)
      module_eval "def logger.#{lname.downcase}?; false end"
    end

    def self.set_true(logger, lname)
      module_eval "def logger.#{lname.downcase}?; true end"
    end

  end
end
end
