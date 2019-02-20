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
  app.name = 'Tempo'
  app.copyright ="Copyright © 2018 MunsterMade. All rights reserved."
  app.deployment_target = "10.9"
  app.version = "1.6.2.0"
  app.icon = "AppIcon.icns"

  app.frameworks << 'webkit'
  app.frameworks << 'Carbon'
  app.identifier = 'com.lingewoud.Tempo'
  app.codesign_certificate = '3rd Party Mac Developer Application: Lingewoud (3WQRKDPTP8)'

  app.entitlements['com.apple.security.app-sandbox'] = true
  app.entitlements['com.apple.security.files.user-selected.read-write'] = true

  app.pods do
   pod "SimpleHotKey"
   pod "XlsxReaderWriter", :git => 'https://github.com/charlymr/XlsxReaderWriter.git'
  end
end

desc "installapp"
task :installapp do
  Rake::Task["build:release"].execute
  path = `find build -name "#{App.config.name}.app"|grep Release`.strip
  system "rm -Rfv '/Applications/Tempo.app'"
  system "cp -av '#{path}' '/Applications/'"
end

desc "populateEntriesFromProd"
task :populateEntriesFromProd do
  system "cp -v '/Users/pim/Library/Containers/com.lingewoud.Tempo/Data/Documents/Tempo.sqlite' '/Users/pim/Documents/'"
  system "cp -v '/Users/pim/Library/Containers/com.lingewoud.Tempo/Data/Documents/Tempo.sqlite-shm' '/Users/pim/Documents/'"
  system "cp -v '/Users/pim/Library/Containers/com.lingewoud.Tempo/Data/Documents/Tempo.sqlite-wal' '/Users/pim/Documents/'"
end

task :"build:simulator" => :"schema:build"
