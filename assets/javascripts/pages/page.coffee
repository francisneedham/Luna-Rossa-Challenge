class window.Page
  constructor: (@el, @data) ->
    @$ = (query) => ($ query, @el)

    @resize()
    ($ window).bind('resize', @resize)

    @preloadBackground()

    @init() if @init?

  preloadBackground: =>
    if @data.image? and not ($ 'html').hasClass('backgroundsize')
      img = new Image()
      ($ img).bind('load', => @backgroundPreloaded(img))
      img.src = @data.image

  backgroundPreloaded: (image) =>
    @height = image.height
    @width = image.width

    @resize()

  resize: =>
    $w = ($ window)
    width = $w.width()
    height = $w.height() - ($ '#footer').height()

    ($ @el).css
      width: width
      height: height

    if not @data.image? or ($ 'html').hasClass('backgroundsize')
      (@$ '.aux').css
        width: width
        height: height
    else
      if @height?
        rap = @width / @height

        new_height = width / rap

        if new_height > height
          new_width = width
          left = 0
          top = (height - new_height) / 2
        else
          new_width = height * rap
          new_height = height
          left = 0
          top = (width - new_width) / 2

        (@$ '.aux').css
          width: width
          height: height
          paddingTop: -top
          paddingLeft: -left
          paddingBottom: -top
          paddingRight: -left
          marginTop: top
          marginLeft: left