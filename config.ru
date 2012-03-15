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

    @data.each do |locale, years|
      years.each do |year, pages|
        year_index = years.keys.index(year)

        pages.each do |page, content|
          page_index = pages.keys.index(page)

          if page_index < pages.keys.length - 1
            content[:next] = "/#{year}/#{pages.keys[page_index+1]}/"
          elsif year_index < years.keys.length - 1
            next_year = years.keys[year_index - 1]
            content[:next] = "/#{next_year}/#{years[next_year].keys.first}/"
          end

          if page_index > 0
            content[:prev] = "/#{year}/#{pages.keys[page_index-1]}/"
          elsif year_index > 0
            prev_year = years.keys[year_index - 1]
            content[:prev] = "/#{prev_year}/#{years[prev_year].keys.first}/"
          end

        end
      end
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

    Mustache.template_path = 'public/templates/'
    Mustache.render(template, content)
  end

  def find_content(locale, year, page)
    locale = data.keys.first if locale.nil?

    if data.key?(locale)

      year = data[locale].keys.first if year.nil?
      year = year.to_i

      if data[locale].key?(year)

        page = data[locale][year].keys.first if page.nil?

        if data[locale][year].key?(page)

          return data[locale][year][page]
        end

      end

    end

    nil
  end

  def render_page(locale = nil, year = nil, page = nil)
    content = find_content(locale, year, page)

    master_data = {}
    master_data['content'] = mustache(content['template'], content)
    master_data['json'] = data[locale || data.keys.first].to_json
    master_data['years'] = data[locale || data.keys.first].keys
    master_data['year'] = year || master_data['years'].first
    master_data['templates'] = Dir.glob(project_root + '/public/templates/*.mustache').map do |name|
      name = name.gsub(/^.*\/(.+)\.mustache$/){$1}

      unless %{ 404 500 index }.include? name
        {
          'name' => name,
          'content' => File.read(project_root + "/public/templates/#{name}.mustache")
        }
      else
        nil
      end

    end

    master_data['templates'].compact!

    unless content.nil?
      [200,
        {'Content-Type' => 'text/html'},
        [mustache('index', master_data)]
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

if %{ staging production }.include? ENV['RACK_ENV']
  use Rack::Auth::Basic do |username, password|
    username == 'lunarossa' && password == 'challange'
  end
end

use Rack::Static, :urls => ["/public"]

map "/assets" do
  run assets
end

run RedMoon.new