$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'motion-fileutils'
require 'motion-markdown-it'
require "awesome_print_motion"

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'WassUp'
  app.copyright ="Copyright © 2017 MunsterMade. All rights reserved."
  app.deployment_target = "10.9"
  app.version = "1.5.0.1"
  app.icon = "AppIcon.icns"

  app.frameworks << 'webkit'
  app.frameworks << 'Carbon'
  app.identifier = 'com.lingewoud.wassup'
  app.codesign_certificate = '3rd Party Mac Developer Application: Lingewoud (3WQRKDPTP8)'

  app.entitlements['com.apple.security.app-sandbox'] = true
  app.pods do
   pod "SimpleHotKey"
  end

end


desc "installapp"
task :installapp do
  path = `find build -name "#{App.config.name}.app"|grep Development`.strip
  system "cp -av '#{path}' '/Applications/'"
end
task :"build:simulator" => :"schema:build"
