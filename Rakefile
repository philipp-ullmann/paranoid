require 'rake/rdoctask'
require "spec"
require "spec/rake/spectask"

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
    s.add_dependency('activerecord', '>= 3.0.0.beta')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Paranoid"
  rdoc.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.template = ENV['template'] ? "#{ENV['template']}.rb" : './rdoc/template.rb'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

task :default  => :spec