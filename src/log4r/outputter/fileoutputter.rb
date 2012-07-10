# :nodoc:
# Version:: $Id$

require "log4r/outputter/iooutputter"
require "log4r/staticlogger"

module Log4r

  # Convenience wrapper for File. Additional hash arguments are:
  #
  # [<tt>:filename</tt>]   Name of the file to log to.
  # [<tt>:trunc</tt>]      Truncate the file?
  class FileOutputter < IOOutputter
    attr_reader :trunc, :filename

    def initialize(_name, hash=Log4rHash.new)
      super(_name, nil, hash)

      @trunc = Log4rTools.decode_bool(hash, :trunc, false)
      _filename = (hash[:filename])
      @create = Log4rTools.decode_bool(hash, :create, true)
      if _filename.class != String
        raise TypeError, "Argument 'filename' must be a String"
      end

      # file validation
      if FileTest.exist?( _filename )
        if not FileTest.file?( _filename )
          raise StandardError, "'#{_filename}' is not a regular file"
        elsif not FileTest.writable?( _filename )
          raise StandardError, "'#{_filename}' is not writable!"
        end
      else # ensure directory is writable
        dir = File.dirname( _filename )
        if not FileTest.writable?( dir )
          raise StandardError, "'#{dir}' is not writable!"
        end
      end
      @filename = _filename
      @out=reopen unless hash[:defer_file_creation] or hash['defer_file_creation']
    end
    def file_access_bits
      @file_access_bits ||=begin 
       z=File::WRONLY|File::APPEND|File::CREAT
       z = z |File::TRUNC if @trunc
       z 
      end
    end
    def reopen
      if ( @create == true ) then
	t = File.new(@filename, file_access_bits) 
	Logger.log_internal {
	  "FileOutputter '#{@name}' writing to #{@filename}"
	}
      else
	Logger.log_internal {
	  "FileOutputter '#{@name}' called with :create == false, #{@filename}"
	}
      end
      t
    end

  end
  
end
