require 'open3'
require 'yui/compressor'
require 'uglifier'

class RedMoon
  attr_reader :data

  def project_root
    @project_root ||= File.expand_path(File.dirname(__FILE__) + '/..')
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
            content[:next] = "/#{locale}/#{year}/#{pages.keys[page_index+1]}/"
          elsif year_index < years.keys.length - 1
            next_year = years.keys[year_index - 1]
            content[:next] = "/#{locale}/#{next_year}/#{years[next_year].keys.first}/"
          end

          if page_index > 0
            content[:prev] = "/#{locale}/#{year}/#{pages.keys[page_index-1]}/"
          elsif year_index > 0
            prev_year = years.keys[year_index - 1]
            content[:prev] = "/#{locale}/#{prev_year}/#{years[prev_year].keys.first}/"
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
    master_data['locale'] = locale || data.keys.first
    master_data['json'] = data[master_data['locale']].to_json
    master_data['years'] = data[master_data['locale']].keys
    master_data['year'] = year || master_data['years'].first
    master_data['templates'] = Dir.glob(project_root + '/public/templates/*.mustache').map do |name|
      name = name.gsub(/^.*\/(.+)\.mustache$/){$1}

      unless %{ 404 500 index }.include? name
        {
          'name' => name,
          'content' => minify_mustache(File.read(project_root + "/public/templates/#{name}.mustache"))
        }
      else
        nil
      end

    end

    master_data['templates'].compact!

    unless content.nil?
      [200,
        {'Content-Type' => 'text/html'},
        [minify_html(mustache('index', master_data))]
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

  def minify_html(html)
    if File.exists? File.join(project_root, 'htmlcompressor.jar')
      stdin, stdout, stderr = Open3.popen3('java -jar htmlcompressor.jar --remove-link-attr --remove-script-attr --remove-input-attr --simple-bool-attr --remove-style-attr --remove-quotes --remove-intertag-spaces')
      stdin.write(html)
      stdin.close
      stdout.readlines.join('')
    else
      html
    end
  end

  def minify_mustache(html)
    if File.exists? File.join(project_root, 'htmlcompressor.jar')
      stdin, stdout, stderr = Open3.popen3('java -jar htmlcompressor.jar --remove-link-attr --remove-script-attr --remove-input-attr --simple-bool-attr --remove-style-attr --remove-intertag-spaces')
      stdin.write(html)
      stdin.close
      stdout.readlines.join('')
    else
      html
    end
  end

  def compile
    build_data

    clear_static

    compile_pages
    compile_assets
    compile_images
  end

  def clear_static
    FileUtils.rm_rf(project_root + '/static')
  end

  def compile_pages

    first_locale = @data.keys.first
    first_year = @data[first_locale].keys.first
    first_page = @data[first_locale][first_year].keys.first

    FileUtils.mkdir_p(project_root + "/static/")
    File.open(project_root + "/static/index.html", 'w') do |f|
      f.write render_page(first_locale, first_year, first_page)[2].join('')
    end

    @data.each do |locale, content|

      first_year = @data[locale].keys.first
      first_page = @data[locale][first_year].keys.first

      FileUtils.mkdir_p(project_root + "/static/#{locale}/")
      File.open(project_root + "/static/#{locale}/index.html", 'w') do |f|
        f.write render_page(locale, first_year, first_page)[2].join('')
      end

      content.each do |year, content|

        first_page = @data[locale][first_year].keys.first

        FileUtils.mkdir_p(project_root + "/static/#{locale}/#{year}/")
        File.open(project_root + "/static/#{locale}/#{year}/index.html", 'w') do |f|
          f.write render_page(locale, year, first_page)[2].join('')
        end

        content.each do |page, content|
          FileUtils.mkdir_p(project_root + "/static/#{locale}/#{year}/#{page}/")
          File.open(project_root + "/static/#{locale}/#{year}/#{page}/index.html", 'w') do |f|
            f.write render_page(locale, year, page)[2].join('')
          end
        end
      end
    end
  end

  def sprockets
    unless @sprockets
      @sprockets = Sprockets::Environment.new(project_root) do |env|
        env.logger = Logger.new(STDOUT)
      end

      compass_gem_root = Gem.loaded_specs['compass'].full_gem_path

      @sprockets.append_path(File.join(project_root, 'assets'))
      @sprockets.append_path(File.join(project_root, 'assets', 'javascripts'))
      @sprockets.append_path(File.join(project_root, 'assets', 'stylesheets'))
      @sprockets.append_path(File.join(project_root, 'public','images'))

      @sprockets.css_compressor = YUI::CssCompressor.new
      @sprockets.js_compressor = ::Uglifier.new

      Compass.configuration do |config|
        config.images_dir = 'public/images'
        config.sprite_engine = :chunky_png
      end
    end

    @sprockets
  end

  def compile_assets
    compile_javascripts
    compile_stylesheets
  end

  def compile_javascripts
    asset     = sprockets['application.js']
    outpath   = File.join(project_root, 'static', 'assets','javascripts')
    outfile   = Pathname.new(outpath).join('application.js') # may want to use the digest in the future?

    FileUtils.mkdir_p outfile.dirname

    asset.write_to(outfile)
  end

  def compile_stylesheets
    asset     = sprockets['application.css']
    outpath   = File.join(project_root, 'static', 'assets','stylesheets')
    outfile   = Pathname.new(outpath).join('application.css') # may want to use the digest in the future?

    FileUtils.mkdir_p outfile.dirname

    asset.write_to(outfile)
  end

  def compile_images
    FileUtils.cp_r(File.join(project_root, 'public'), File.join(project_root, 'static'))
  end

end