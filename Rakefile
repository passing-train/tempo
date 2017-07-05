$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'motion-fileutils'
require 'motion-markdown-it'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'WassUp'
  app.copyright ="Copyright © 2017 MunsterMade. All rights reserved."
  app.deployment_target = "10.10"
  app.version = "1.0"
  app.icon = "AppIcon.icns"

  app.frameworks << 'webkit'
  app.identifier = 'com.lingewoud.wassup'
  app.codesign_certificate = '3rd Party Mac Developer Application: Lingewoud (3WQRKDPTP8)'

  app.entitlements['com.apple.security.app-sandbox'] = true
end

desc "installapp"
task :installapp do
  path = `find build -name "#{App.config.name}.app"|grep Development`.strip
  system "cp -av '#{path}' '/Applications/'"
end
task :"build:simulator" => :"schema:build"
