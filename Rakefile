$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'motion-fileutils'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Whazzup'
  app.icon = "AppIcon.icns"
  app.identifier = 'com.cyberfox.whazzup'
end


desc "installapp"
task :installapp do
  path = 'build/MacOSX-10.12-Development/Whazzup.app'
  system "cp -av '#{path}' '/Applications/'"
end
