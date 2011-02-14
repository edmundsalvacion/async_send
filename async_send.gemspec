# -*- encoding: utf-8 -*-
require File.expand_path("../lib/async_send/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "async_send"
  s.version     = AsyncSend::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Edmund Salvacion"]
  s.email       = ["edmund.salvacion@gmail.com"]
  s.default_executable = 'async_send'
  s.homepage    = "http://edmundatwork.com"
  s.summary     = "A Beanstalkd powered asynchronous send"
  s.description = "A Beanstalkd powered asycnhronous send"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "async_send"

  s.add_dependency("beanstalk-client", ["~> 1.1.0"])
  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
