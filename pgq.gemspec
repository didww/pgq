# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + "/lib/pgq/version"

Gem::Specification.new do |s|
  s.name = %q{pgq}
  s.version = Pgq::VERSION

  s.authors = ["Makarchev Konstantin"]
  s.autorequire = %q{init}
  s.description = %q{Pgq}
  s.summary = %q{Pgq}
  s.email = %q{kostya27@gmail.com}
  s.homepage = %q{http://github.com/kostya/pgq}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', ">=2.3.2"  
  s.add_dependency 'activerecord', ">=2.3.2"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
end