# = DateFileOutputter
#
# Subclass of FileOutputter that changes the log file daily. When a new
# day begins, a new file is created with the date included in the name.
#
# == Usage
#
#   df_out = DateFileOutputter.new('name',
#              :dirname="/tmp", :date_pattern=>"%m-%d" 
#            )
#
# == Rate of Change
#
# A new logfile is created whenever the current time as formatted by the date
# pattern no longer matches the previous time. (This is a simple String 
# comparison.) So, in order to change the frequency of the rollover, just
# alter the date pattern to match how fast the files should be generated. 
# For instance, to generate files by the minute,
#
#   df_out.date_pattern = "%M"
#
# This causes the following files to show up one minute apart, asuming the
# script starts at the 4th minute of the hour:
#
#   file_04.rb
#   file_05.rb
#   file_06.rb
#   ...
#
# The only limitation of this approach is that the precise time cannot be
# recorded as the smallest time interval equals the rollover period for this
# system.

require "log4r/outputter/fileoutputter"
require "log4r/staticlogger"

module Log4r

  # Additional hash arguments are:
  #
  # [<tt>:dirname</tt>]         Directory of the log file
  # [<tt>:date_pattern</tt>]    Time.strftime format string (default is "%Y-%m-%d")

  class DateFileOutputter < FileOutputter
    DEFAULT_DATE_FMT = "%Y-%m-%d"

    def initialize(_name, hash=Log4rHash.new)
      @orig_init_opts=hash
      @DatePattern = (hash[:date_pattern] or
                      DEFAULT_DATE_FMT)
      @DateStamp = Time.now.strftime( @DatePattern);
      _dirname = (hash[:dirname])
      # hash[:dirname] masks hash[:filename]
      if _dirname
        if not FileTest.directory?( _dirname)
          raise StandardError, "'#{_dirname}' must be a valid directory"
        end
      end
      _filename = (hash[:filename])
      if _filename.nil?
        @filebase = ''
        @filesuffix= '.log'
      else
        @filebase = File.basename(_filename) 
        @filesuffix= ''
      end
      @filename_pattern = File.join(_dirname,@filebase + @DateStamp + @filesuffix)
      # Get rid of the 'nil' in the path
      path = [_dirname, @filename_pattern].compact
      self.makeNewFilename
      hash[:filename] = hash['filename'] = @filename 
      
      super(_name, hash.merge(:no_file_mangling => true))
      @out,@DateStamp=nil,nil
    end

    # perform the write
    def write(data)
      change if requiresChange
      super
    end

    # construct a new filename from the DateStamp
    def makeNewFilename
        @DateStamp = Time.now.strftime( @DatePattern);
        @filename = Time.now.strftime(@filename_pattern) 

    end
    def out
      @out=reopen if requiresChange
      super
    end
    # does the file require a change?
    def requiresChange
      _DateStamp = Time.now.strftime( @DatePattern);
      if not _DateStamp == @DateStamp
        return true
      end
      false
    end

    # change the file 
    def change
      begin
        close
      rescue
        Logger.log_internal {
          "DateFileOutputter '#{@name}' could not close #{@filename}"
        }
      ensure
        @out=nil
      end
    end
    def reopen
      close
      makeNewFilename
      t = File.new(@filename, file_access_bits)
      Logger.log_internal {
        "DateFileOutputter '#{@name}' now writing to #{@filename}"
      }
      t
    end
  end

end
