# :include: rdoc/yamlconfigurator
#
# == Other Info
#
# Version: $Id$

require "log4r/logger"
require "log4r/outputter/staticoutputter"
require "log4r/logserver"
require "log4r/outputter/remoteoutputter"
require 'log4r/log4r_hash'
require 'yaml'

module Log4r
  # Gets raised when Configurator encounters bad YAML.
  class ConfigError < Exception
  end

  # See log4r/yamlconfigurator.rb
  class YamlConfigurator
    @@params = Log4rHash.new
    # Get a parameter's value
    def self.[](param); @@params[param] end
    # Define a parameter with a value
    def self.[]=(param, value)  @@params[param] = value end


    def self.custom_levels( levels)
      return Logger.root if levels.size == 0
      for i in 0...levels.size
        name = levels[i].to_s
        if name =~ /\s/ or name !~ /^[A-Z]/
          raise TypeError, "#{name} is not a valid Ruby Constant name"
        end
      end
      Log4r.define_levels *levels
    end

    # Given a filename, loads the YAML configuration for Log4r.
    def self.load_yaml_file( filename)
      actual_load( File.open( filename))
    end

    # You can load a String YAML configuration instead of a file.
    def self.load_yaml_string( string)
      actual_load( string)
    end

    #######
    private
    #######

    def self.actual_load( yaml_docs)
      log4r_config = nil
      YAML.load_documents( yaml_docs){ |doc|
        doc.has_key?( 'log4r_config') and log4r_config = doc['log4r_config'] and break
      }
      if log4r_config.nil?
        raise ConfigError, 
        "Key 'log4r_config:' not defined in yaml documents"
      end
      decode_yaml(Log4r.log4r_config( log4r_config))
    end
    def self.hash_to_array(hsh)
      return hsh unless Hash===hsh
      hsh.map{|(k,v)| raise "Expecting hash of hashes" unless Hash===v; v.merge({'name' => k})}
    end 
    def self.decode_yaml( cfg)
      decode_pre_config( cfg['pre_config'])
      decode_log_event_class((cfg['log_event_class']))
      hash_to_array(cfg['parsers']).each{ |p| decode_parser( p)} if cfg['parsers']
      Logger.finalize_parsers!
      hash_to_array(cfg['outputters']).each{ |op| decode_outputter( op)}
      hash_to_array(cfg['loggers']).each{ |lo| decode_logger( lo)}
      hash_to_array(cfg['logserver']).each{ |lo| decode_logserver( lo)} unless cfg['logserver'].nil?
    end
    def self.decode_parser(p)
      require p[:require_file] if p[:require_file]
      parser_class = Log4r.find_const(p[:class])
      Logger.parsers << parser_class.new(p) 
    end
    def self.decode_log_event_class(lec)
      return if lec.nil?
      Logger.log_event_class=lec['log_event_class']
    end
    def self.decode_pre_config( pre)
      return Logger.root if pre.nil?
      Logger.strict_file_names = pre['strict_file_names']

      decode_custom_levels( pre['custom_levels'])
      global_config( pre['global'])
      global_config( pre['root'])
      decode_parameters( pre['parameters'])
    end

    def self.decode_custom_levels( levels)
      return Logger.root if levels.nil?
      begin custom_levels( levels)
      rescue TypeError => te
        raise ConfigError, te.message
      end
    end
    
    def self.global_config( e)
      return if e.nil?
      globlev = e['level']
      return if globlev.nil?
      lev = LNAMES.index(globlev)     # find value in LNAMES
      Log4rTools.validate_level(lev, 4)  # choke on bad level
      Logger.global.level = lev
    end

    def self.decode_parameters( params)
      if Hash===params
        @@params.merge!(params)
        return
      end
      params.each{ |p| @@params[p['name']] = p['value']} unless params.nil?
    end

    def self.decode_outputter( op)
      # fields
      name = op['name']
      type = op['type']
      level = op['level']
      only_at = op['only_at']
      # validation
      raise ConfigError, "Outputter missing name" if name.nil?
      raise ConfigError, "Outputter missing type" if type.nil?
      Log4rTools.validate_level(LNAMES.index(level)) unless level.nil?
      only_levels = []
      unless only_at.nil?
        for lev in only_at
          alev = LNAMES.index(lev)
          Log4rTools.validate_level(alev, 3)
          only_levels.push alev
        end
      end
      formatters = Hash===op['formatter'] ? [op['formatter']] : op['formatter']
      formatters.map!{|fmt|decode_formatter(fmt)} if formatters
      outputter_hash = decode_hash_params(op) 
      outputter_hash[:level]=LNAMES.index(level) unless level.nil?
      outputter_hash[:formatter]=formatters unless formatters.nil?
      require outputter_hash[:require_file] if outputter_hash[:require_file]
      Outputter[name]=Log4r.find_const(type).new(name,outputter_hash) 
      Outputter[name].only_at( *only_levels) if only_levels.size > 0
      Outputter[name]
    end

    def self.decode_formatter( fo)
      return nil if fo.nil?
      require fo['require_file'] if fo['require_file']
      type = fo['type'] 
      raise ConfigError, "Formatter missing type" if type.nil?
      cl = Log4r.find_const(type)
      z=Log4r.find_const(type).new decode_hash_params( fo)
      z
    end

    ExcludeParams = %w{formatter level name type only_at}

    # Does the fancy parameter to hash argument transformation
    def self.decode_hash_params( ph)
      buff = Log4rHash.new 
      ph.each{ |name, value| 
        next if ExcludeParams.include? name
        buff[name]=paramsub(value)
      }
      buff
    end
    
    # Substitues any #{foo} in the YAML with Parameter['foo']
    def self.paramsub( str)
      return nil if str.nil?
      return nil if str.class != String
      @@params.each {|param, value|
        str.sub!( '#{' + param + '}', value)
      }
      str
    end

    def self.decode_logger( lo)
      l = Logger.new lo['name']
      decode_logger_common( l, lo)
    end

    def self.decode_logserver( lo)
      name = lo['name']
      uri  = lo['uri']
      l = LogServer.new name, uri
      decode_logger_common(l, lo)
    end

    def self.decode_logger_common( l, lo)
      level    = lo['level']
      additive = lo['additive']
      trace    = lo['trace']
      l.level    = LNAMES.index( level) unless level.nil?
      l.additive = additive unless additive.nil?
      l.trace    = trace unless trace.nil?
      # and now for outputters
      outs = lo['outputters']
      outs.each {|n| l.add n.strip} unless outs.nil?
    end
  end
end

