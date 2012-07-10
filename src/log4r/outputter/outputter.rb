# :include: ../rdoc/outputter
#
# == Other Info
#
# Version:: $Id$
# Author:: Leon Torres <leon@ugcs.caltech.edu>

require "thread"

require "log4r/outputter/outputterfactory"
require "log4r/formatter/formatter"
require "log4r/staticlogger"


module Log4r

  class Outputter
    def log_level(event,opts=Log4rHash.new)
      if @only_at and not @only_at.include?(event.level)
        return
      elsif @level > event.level
        return
      end      
      canonical_log(event)
    end
    attr_reader :name, :level, :formatter
    @@outputters = Hash.new

    # An Outputter needs a name. RootLogger will be loaded if not already
    # done. The hash arguments are as follows:
    # 
    # [<tt>:level</tt>]       Logger level. Optional, defaults to root level
    # [<tt>:formatter</tt>]   A Formatter. Defaults to DefaultFormatter

    def initialize(_name, hash=Log4rHash.new)
      if _name.nil?
        raise ArgumentError, "Bad arguments. Name and IO expected.", caller
      end
      @name = _name
      validate_hash(hash)
      @@outputters[@name] = self
    end

    # dynamically change the level
    def level=(_level)
      Log4rTools.validate_level(_level)
      @level = _level
      OutputterFactory.create_methods(self)
      Logger.log_internal {"Outputter '#{@name}' level is #{LNAMES[_level]}"}
    end
    def log_output(level,log_event)

    end
    # Set the levels to log. All others will be ignored
    def only_at(*levels)
      raise ArgumentError, "Gimme some levels!", caller if levels.empty?
      raise ArgumentError, "Can't log only_at ALL", caller if levels.include? ALL
      levels.each {|level| Log4rTools.validate_level(level)}
      @only_at=levels
      @level = levels.sort.first
      OutputterFactory.create_methods self, levels
      Logger.log_internal {
        "Outputter '#{@name}' writes only on " +\
        levels.collect{|l| LNAMES[l]}.join(", ")
      }
    end

    # Dynamically change the formatter. You can just specify a Class
    # object and the formatter will invoke +new+ or +instance+
    # on it as appropriate.
 
    def formatter=(_formatter)
      _formatter=[_formatter] unless Array===_formatter
      @formatter=_formatter.map{|fmtr|
        if fmtr.kind_of?(Formatter)
          fmtr 
        elsif fmtr.kind_of?(Class) and fmtr <= Formatter
          if _formatter.respond_to? :instance
            fmtr.instance
          else
            fmtr.new
          end
        else
          raise TypeError, "Argument was not a Formatter!", caller
        end
      }
      Logger.log_internal {"Outputter '#{@name}' using #{@formatter.class}"}
    end

    # Call flush to force an outputter to write out any buffered
    # log events. Similar to IO#flush, so use in a similar fashion.

    def flush
    end

    #########
    protected
    #########

    # Validates the common hash arguments. For now, that would be
    # +:level+, +:formatter+ and the string equivalents
    def validate_hash(hash)
      @mutex = Mutex.new
      # default to root level and DefaultFormatter
      if hash.empty?
        self.level = Logger.root.level
        self.formatter = DefaultFormatter.new
        return
      end
      self.level = (hash[:level] or Logger.root.level)
      self.formatter = (hash[:formatter] or DefaultFormatter.new)
    end

    #######
    private
    #######

    # This method handles all log events passed to a typical Outputter. 
    # Overload this to change the overall behavior of an outputter. Make
    # sure that the new behavior is thread safe.

    def canonical_log(logevent)
      synch { write(format(logevent)) } 
    end

    # Common method to format data. All it does is call the resident
    # formatter's format method. If a different formatting behavior is 
    # needed, then overload this method.

    def format(logevent)
      # @formatter is guaranteed to be DefaultFormatter if no Formatter
      # was specified
      formatter.inject(logevent){|le,fmt|fmt.format(le)}
    end

    # Abstract method to actually write the data to a destination.
    # Custom outputters should overload this to specify how the
    # formatted data should be written and to where. 
   
    def write(data)
    end

    def synch; @mutex.synchronize { yield } end
    
  end

end
