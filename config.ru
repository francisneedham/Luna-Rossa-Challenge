require './lib/redmoon'
require 'rubygems'
require 'bundler'

Bundler.require

project_root = File.expand_path(File.dirname(__FILE__))
assets = Sprockets::Environment.new(project_root) do |env|
  env.logger = Logger.new(STDOUT)
end

compass_gem_root = Gem.loaded_specs['compass'].full_gem_path

assets.append_path(File.join(project_root, 'assets'))
assets.append_path(File.join(project_root, 'assets', 'javascripts'))
assets.append_path(File.join(project_root, 'assets', 'stylesheets'))
assets.append_path(File.join(project_root, 'public','images'))

Compass.configuration do |config|
  config.images_dir = 'public/images'
  config.sprite_engine = :chunky_png
end

use Rack::Static, :urls => ["/public"]

map "/assets" do
  run assets
end

run RedMoon.new