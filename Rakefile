require './lib/redmoon'
require 'rubygems'
require 'bundler'

Bundler.require

namespace :static do
  desc 'compile all'
  task :compile do
    app = RedMoon.new
    app.compile
  end

  desc 'remove compiled site'
  task :clear do
    app = RedMoon.new
    app.clear_static
  end

end