# :nodoc:
require "log4r/outputter/iooutputter"

module Log4r
  class ConsoleOutputter  < IOOutputter; end
  # Same as IOOutputter(name, $stdout)
  class StdoutOutputter < ConsoleOutputter
    def initialize(_name, hash=Log4rHash.new)
      super(_name, $stdout, hash)
    end
  end

  # Same as IOOutputter(name, $stderr)
  class StderrOutputter < ConsoleOutputter
    def initialize(_name, hash=Log4rHash.new)
      super(_name, $stderr, hash)
    end
  end
end
