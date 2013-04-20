# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "rstuk"
  s.version     = "0.0.1"
  s.date        = "2013-04-10"
  s.summary     = %q{Common library for kiwi_spec and studio_spec}
  s.description = %q{Common library for kiwi_spec and studio_spec}
  s.authors     = ["Yury Tsarev", "Theo Chatzimichos"]
  s.email       = ["ytsarev@suse.com", "tchatzimichos@suse.com"]

  s.rubyforge_project = "rstuk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'fuubar'
end
