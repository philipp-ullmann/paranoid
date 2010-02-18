$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
require 'paranoid'
require 'yaml'
require 'spec'

def connect(environment)
  conf = YAML::load(File.open(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.establish_connection(conf[environment])
end

# Open ActiveRecord connection
connect('test')

original_stdout = $stdout
$stdout = StringIO.new

begin
  load(File.dirname(__FILE__) + "/schema.rb")
ensure
  $stdout = original_stdout
end