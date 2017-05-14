# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "punchcard"

Gem::Specification.new do |s|
  s.name                  = 'punched'
  s.version               = PunchCard::VERSION
  s.authors               = ["Philipp Staender"]
  s.email                 = ["philipp.staender@gmail.com"]
  s.homepage              = 'https://github.com/pstaender/punchcard'
  s.summary               = 'Punchcard Timetracker'
  s.description           = 'Minimal time tracking tool for cli'
  s.license               = 'GPL-3.0'
  s.executables           = ['punched']
  s.default_executable    = 'punched'
  s.rubyforge_project     = 'punched'
  s.require_paths         = ["lib"]
  s.required_ruby_version = '>= 2.0'
  s.files                 = `git ls-files`.split("\n")
end
