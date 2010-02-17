require "spec"
require "spec/rake/spectask"
require 'lib/paranoid.rb'

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{paranoid}
    s.summary = %q{Enable soft delete of ActiveRecord records. Based off defunct ActsAsParanoid and IsParanoid}
    s.email = %q{github@xspond.com}
    s.homepage = %q{http://github.com/xspond/paranoid/}
    s.description = ""
    s.authors = ["David Genord II"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :default  => :spec