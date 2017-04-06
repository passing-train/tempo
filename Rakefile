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
  app.name = 'WassUp'
  app.icon = "AppIcon2.icns"
  app.identifier = 'com.lingewoud.wassup'
end


desc "installapp"
task :installapp do
  path = 'build/MacOSX-10.12-Development/wassup.app'
  system "cp -av '#{path}' '/Applications/'"
end
