# :nodoc:
module Log4r

  ##
  # LogEvent wraps up all the miscellaneous data associated with a logging
  # statement. It gets passed around to the varied components of Log4r and
  # should be of interest to those creating extensions.
  #
  # Data contained: 
  #
  # [level]    The integer level of the log event. Use LNAMES[level]
  #            to get the actual level name.
  # [tracer]   The execution stack returned by <tt>caller</tt> at the
  #            log event. It is nil if the invoked Logger's trace is false.
  # [data]     The object that was passed into the logging method.
  # [name]     The name of the logger that was invoked.
  # [fullname] The fully qualified name of the logger that was invoked.
  #
  # Note that creating timestamps is a task left to formatters.

  class LogEvent2
    ContextOrder =   [:logger_level,:logger,:backtrace]
    AttrAlias = {:tracer => :backtrace, :level => :logger_level, :data => :log_data}
    unless const_defined? :LogEventAttr
      LogEventAttr = [ :level, :tracer, :data, :name, :fullname]
      LogEventAttr << [:loan_id, :customer_id, :person_id,:logger]
      LogEventAttr.flatten!
    end
    attr_accessor *LogEventAttr
    def to_hsh
      hsh={}
      LogEventAttr.each do |k|
        hsh[k]=self[k]
      end
      hsh[:backtrace]=@tracer.join("\n")
      hsh[:tracer]=@tracer.join("\n")
      hsh[:log_data]=hsh[:data]
#      AttrAlias.each_pair{|k,v|hsh[v]||=self[v]; self[v]||=hsh[v]}
      hsh
    end
    def initialize(level, logger, tracer, data)
      @level, @tracer, @data = level, tracer, data
      @name, @fullname = logger.name, logger.fullname
    end
    def backtrace; self.tracer; end
    def backtrace=(x); self.tracer=x; end

    def self.create_from_context(data,context)
      new_le = self.allocate
      context_order.map{|i|new_le[i]=context[i]}
      new_le[:data] = data 
      new_le[:tracer] ||=  context[:backtrace]
      new_le[:name]||=context[:name]
      new_le[:level]||=context[:logger_level]
      new_le[:fullname]||=context[:fullname]
      new_le
    end

    def self.log_event_alias
      self.const_get('LogEventAttr')
    end
    def self.attr_alias
      self.const_get('AttrAlias')
    end
    def self.context_order
      self.const_get('ContextOrder')
    end

    def self.parse args, context
      if logevent.data.is_a?(String)
        data[:log_data] = logevent.data
      elsif logevent.data.is_a?(CnuException)
        err = logevent.data
        data[:log_data] = err.message
        data[:backtrace] = logevent.data.backtrace.join("\n") if logevent.data.backtrace
        [:loan_id, :customer_id, :person_id].each do |attr|
          data[attr] = err.send(attr) if err.respond_to?(attr)
        end
      elsif logevent.data.is_a?(Exception)
        data[:log_data] = logevent.data.message
        data[:backtrace] = logevent.data.backtrace.join("\n") if logevent.data.backtrace
      else
        raise exception([:cannot_log_error, data.to_s])
      end

      self.new context[:logger_level],context[:logger],context[:backtrace],args.first
    end
    def [] el
      el = self.class.attr_alias.invert[el] if self.class.attr_alias.invert[el]
      return(send(el)) if LogEventAttr.include?(el.to_sym)
      raise "uknown symbol, #{el}"
    end 
    def []= el, val
      el = self.class.attr_alias.invert.invert[el] if self.class.attr_alias.invert.invert[el]
      return(send("#{el}=".to_sym,val)) if LogEventAttr.include?(el.to_sym)
      raise "uknown symbol, #{el}"
    end 
     
  end
end
