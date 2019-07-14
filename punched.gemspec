$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'punchcard'

Gem::Specification.new do |s|
  s.name                  = 'punched'
  s.version               = PunchCard::VERSION
  s.authors               = ['Philipp Staender']
  s.email                 = ['pstaender@mailbox.org']
  s.homepage              = 'https://github.com/pstaender/punchcard'
  s.summary               = 'Punchcard Timetracker'
  s.description           = 'Minimal time tracking tool for cli'
  s.license               = 'GPL-3.0'
  s.executables           = ['punched']
  s.require_paths         = ['lib']
  s.required_ruby_version = '>= 2.1'
  s.files                 = `git ls-files`.split("\n")

  s.add_dependency 'markdown-tables', '~> 1.0.2'
end
