require 'opal'
#require 'opal-jquery'
require 'opal-browser'
require 'paggio'

desc "Build our app to 2048.js"
task :buildOLD do
  Opal.append_path "."
  # File.binwrite "2048.js", Opal::Builder.build("2048.rb").to_s
  File.binwrite "demo.js", Opal::Builder.build("demo.rb").to_s
end

# adapted from http://opalrb.com/docs/guides/v1.0.0/jquery.html
task :build do
  Opal.append_path "."
  #Opal.append_path "opal-browser"
  #File.binwrite "demo.js", Opal::Builder.build("demo.rb").to_s

  builder = Opal::Builder.new
  #builder.build('opal')
  #builder.build('opal-jquery')
  builder.build('demo.rb')

  File.write('demo.js', builder.to_s)
end
