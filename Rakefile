require 'opal'
require 'opal-jquery'

desc "Build our app to 2048.js"
task :build do
  Opal.append_path "."
  File.binwrite "2048.js", Opal::Builder.build("2048.rb").to_s
end
