# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "log4r"
  s.version = "1.1.8.2.jwl1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Colby Gutierrez-Kraybill"]
  s.date = "2012-07-09"
  s.description = "See also: http://logging.apache.org/log4j"
  s.email = "colby@astro.berkeley.edu"
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "LICENSE.LGPLv3", "README", "INSTALL", "Rakefile", "TODO", "doc/content", "doc/content/contact.html", "doc/content/contribute.html", "doc/content/index.html", "doc/content/license.html", "doc/content/manual.html", "doc/dev", "doc/dev/checklist", "doc/dev/README.developers", "doc/dev/things-to-do", "doc/images", "doc/images/log4r-logo.png", "doc/images/logo2.png", "doc/log4r.css", "doc/rdoc-log4r.css", "doc/templates", "doc/templates/main.html", "examples/ancestors.rb", "examples/chainsaw_settings.xml", "examples/customlevels.rb", "examples/filelog.rb", "examples/fileroll.rb", "examples/log4r_yaml.yaml", "examples/logclient.rb", "examples/logserver.rb", "examples/moderate.xml", "examples/moderateconfig.rb", "examples/myformatter.rb", "examples/outofthebox.rb", "examples/rdoc-gen", "examples/README", "examples/rrconfig.xml", "examples/rrsetup.rb", "examples/simpleconfig.rb", "examples/syslogcustom.rb", "examples/xmlconfig.rb", "examples/yaml.rb", "src/log4r", "src/log4r/argparser", "src/log4r/argparser/argparser.rb", "src/log4r/argparser/exception_parser.rb", "src/log4r/base.rb", "src/log4r/config.rb", "src/log4r/configurator.rb", "src/log4r/formatter", "src/log4r/formatter/formatter.rb", "src/log4r/formatter/log4jxmlformatter.rb", "src/log4r/formatter/patternformatter.rb", "src/log4r/GDC.rb", "src/log4r/lib", "src/log4r/lib/drbloader.rb", "src/log4r/lib/xmlloader.rb", "src/log4r/log4r_hash.rb", "src/log4r/logevent.rb", "src/log4r/logevent2.rb", "src/log4r/logger.rb", "src/log4r/loggerfactory.rb", "src/log4r/logserver.rb", "src/log4r/MDC.rb", "src/log4r/NDC.rb", "src/log4r/outputter", "src/log4r/outputter/consoleoutputters.rb", "src/log4r/outputter/datefileoutputter.rb", "src/log4r/outputter/emailoutputter.rb", "src/log4r/outputter/fileoutputter.rb", "src/log4r/outputter/iooutputter.rb", "src/log4r/outputter/outputter.rb", "src/log4r/outputter/outputterfactory.rb", "src/log4r/outputter/remoteoutputter.rb", "src/log4r/outputter/rollingfileoutputter.rb", "src/log4r/outputter/staticoutputter.rb", "src/log4r/outputter/syslogoutputter.rb", "src/log4r/outputter/udpoutputter.rb", "src/log4r/repository.rb", "src/log4r/staticlogger.rb", "src/log4r/yamlconfigurator.rb", "src/log4r.rb", "tests/README", "tests/testall.rb", "tests/testbase.rb", "tests/testchainsaw.rb", "tests/testconf.xml", "tests/testcustom.rb", "tests/testformatter.rb", "tests/testGDC.rb", "tests/testlogger.rb", "tests/testMDC.rb", "tests/testNDC.rb", "tests/testoutputter.rb", "tests/testpatternformatter.rb", "tests/testthreads.rb", "tests/testxmlconf.rb"]
  s.homepage = "http://log4r.rubyforge.org"
  s.require_paths = ["src"]
  s.rubyforge_project = "log4r"
  s.rubygems_version = "1.8.24"
  s.summary = "Log4r, logging framework for ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
