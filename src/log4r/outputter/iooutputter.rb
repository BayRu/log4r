# :nodoc:
require "log4r/outputter/outputter"
require "log4r/staticlogger"

module Log4r
  
  ##
  # IO Outputter invokes print then flush on the wrapped IO
  # object. If the IO stream dies, IOOutputter sets itself to OFF
  # and the system continues on its merry way.
  #
  # To find out why an IO stream died, create a logger named 'log4r'
  # and look at the output.

  class IOOutputter < Outputter

    # IOOutputter needs an IO object to write to.
    def initialize(_name, _out, hash=Log4rHash.new)
      super(_name, hash)
      @out = _out
    end
    def out
      @out||=begin
        reopen
      end
    end
    def reopen
      nil
    end
    def close
      @out.close if @out and not @out.closed?
      @out=nil
    end
    def disabled?
      @disabled
    end

    # Close the IO and sets level to OFF
    def disable
      out.disable unless out.nil?
      @level = OFF
      @disabled=true
      OutputterFactory.create_methods(self)
      Logger.log_internal {"Outputter '#{@name}' disabled IO and set to OFF"}
    end

    #######
    private
    #######
    
    # perform the write
    def write(data)
      if disabled?
        Logger.log_internal "trying to log to a disabled outputter!" 
        return
      end
      begin
        out.print data
        out.flush
      rescue IOError => ioe # recover from this instead of crash
        Logger.log_internal(3) {"IOError in Outputter '#{@name}'!"}
        Logger.log_internal(3) {ioe}
        disable
      rescue NameError => ne
        Logger.log_internal(3) {"Outputter '#{@name}' IO is #{out.class}!"}
        Logger.log_internal(3) {ne}
        disable
      end
    end
  end
end
