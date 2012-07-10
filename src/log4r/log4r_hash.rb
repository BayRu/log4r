module Log4r
  def log4r_config o
    case o
    when Hash then Log4rHash.convert_to_log4r(o)
    when Array then Log4rArray.convert_to_log4r(o)
    else o
    end
  end
  module_function :log4r_config
  class Log4rHash < Hash
    def self.convert_to_log4r(o)
      t={}
      o.each_pair{|k,v|t[k]=Log4r.log4r_config(v)}
      Log4rHash[t]
    end
    def [] *args
      args.inject(nil){|r,k|r or super(k.to_s) or super(k.to_sym)}
    end
  end
  class Log4rArray < Array
    def self.convert_to_log4r(o)
      Log4rArray.new(o.map{|v|Log4r.log4r_config(v)})
    end
  end
end
