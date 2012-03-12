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

class RedMoon
  attr_reader :data

  def project_root
    @project_root ||= File.expand_path(File.dirname(__FILE__))
  end

  def build_data
    @data = {}

    Dir.glob(project_root + '/data/*.yml').each do |name|
      name = name.gsub(/^.*\/(.+)\.yml$/){$1}
      @data[name] = YAML.load_file(File.expand_path(project_root + "/data/#{name}.yml"))
    end
  end

  def call(env)
    build_data

    request = Rack::Request.new(env)

    case request.path
    when /cane/
      [200, {'Content-Type' => 'text/plain'}, [Compass.configuration.inspect]]
    when /^\/?$/
      render_page
    when /^\/(.{2})\/?$/
      render_page $1
    when /^\/(.{2})\/(\d{4})\/?$/
      render_page $1, $2
    when /^\/(.{2})\/(\d{4})\/(.+?)\/?$/
      render_page $1, $2, $3
    else
      render_404
    end

  rescue
    render_500
  end

  def default_template
    'Missing Template: {{template}}'
  end

  def mustache(template_name, content)
    unless template_name.nil?
      template_path = project_root + '/public/templates/' + template_name + '.mustache'
      if File.exists?(template_path)
        template = File.read(template_path)
      else
        template = default_template
      end
    else
      template = default_template
    end

    Mustache.render(template, content)
  end

  def find_content(locale, year, page)
    locale = data.keys.first if locale.nil?

    if data.key?(locale)

      year = data[locale].keys.first if year.nil?
      year = year.to_i

      if data[locale].key?(year)

        page = data[locale][year].keys.first

        if data[locale][year].key?(page)

          return data[locale][year][page]
        end

      end

    end

    nil
  end

  def render_page(locale = nil, year = nil, page = nil)
    content = find_content(locale, year, page)

    unless content.nil?
      [200,
        {'Content-Type' => 'text/html'},
        [mustache(content['template'], content)]
      ]
    else
      render_404
    end
  end

  def render_404
    [404, {'Content-Type' => 'text/plain'}, [Mustache.render(File.read(project_root + '/public/templates/404.mustache'), {})]]
  end

  def render_500
    puts $!
    [500, {'Content-Type' => 'text/plain'}, [Mustache.render(File.read(project_root + '/public/templates/500.mustache'), {})]]
  end

end

use Rack::Static, :urls => ["/public"]

map "/assets" do
  run assets
end

run RedMoon.new