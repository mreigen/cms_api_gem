
# -*- encoding: utf-8 -*-
$:.push('lib')
lib = File.expand_path('lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "cms_api/version"

Gem::Specification.new do |s|
  s.name     = "cms_api"
  s.version  = CmsApi::VERSION.dup
  s.date     = "2014-09-14"
  s.summary  = "blah: Summary of project"
  s.email    = "blah@project.com"
  s.homepage = "http://blah.project.com/"
  s.authors  = ['Me blah']

  s.description = <<-EOF
blah: Long description
EOF

  dependencies = [
    # Examples:
    # [:runtime,     "rack",  "~> 1.1"],
    # [:development, "rspec", "~> 2.1"],
  ]

  s.files         = Dir['**/*']
  s.test_files    = Dir['test/**/*'] + Dir['spec/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]


  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "2.2.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version

  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
