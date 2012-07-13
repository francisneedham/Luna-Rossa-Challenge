scopes = 1

class window.GalleryPage extends window.Page

  ###
  TODO:
  - performance ipad al close
  - non funziona quando cambio anno?
  ###

  ########
  # STATES
  ########

  init: ->

    #console.log @el
    #console.log @data

    @is_ie = $.browser.msie
    @is_mobi = if navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i) || navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/Android/i) then true else false

    @w = $ window
    @h = $ '#header'
    @f = $ '#footer'
    @loader = $ '.loader'
    @navbar = $ '#navbar'
    @section_arrows = @$ '.section-arrow'
    @detail_arrows = @$ '.detail-arrow'
    @img = @$ '#detail-img'
    @canvas = @$ '#detail-canvas'
    @title = @$ '.section-title'
    @wrap = @$ '.wrap-gallery-carousel'
    @gc = @$ '.gallery-carousel'
    @items = @gc.find '.item'
    @close = @$ '.gallery-close'

    @fps = 30
    @w_width = 0
    @gc_width = 0
    @vel_min = 3
    @vel_max = 30
    @is_updating = false
    @current_detail_index = 0

    @img.attr 'id', "#{@img.attr 'id'}_#{scopes}"
    @img_id = @img.attr 'id'
    @canvas.attr 'id', "#{@canvas.attr 'id'}_#{scopes}"
    @canvas_id = @canvas.attr 'id'

    @keymasterScope = "gallery_#{scopes++}"
    @addKeyControl()

  entering: ->
    @setWrapperWidth()
    @adjustLastItem()
    @setGalleryWidth()

    if @is_mobi

      @gc.show()
      #@gc.attr('data-scrollable', 'x')
      new EasyScroller @gc[0], {
        scrollingX: true,
        scrollingY: false,
        zooming: false
      }

    @startUpdating()
    @setInteractions()
    @gc.css {top: @gc.height() + 10}
    @loadFirstBigImage()

  entered: ->

  leaving: ->

    #@showGallery false
    @stopUpdating()
    @resetInteractions()

  left: ->

    @showGallery false

  ########
  # LAYOUT
  ########

  setWrapperWidth: ->

    if @w.width() isnt @w_width
      @w_width = @w.width()
      @wrap.css {width: "#{@w_width}px"}

  adjustLastItem: ->

    item = $ @items[@items.length - 1]
    bl = item.css 'border-left-width'
    bc = item.css 'border-left-color'
    item.css {'border-right': "#{bl} solid #{bc}"}
    item.css {'margin-right': "0"}

  setGalleryWidth: ->

    item = $ @items[0]
    iw = parseInt(item.css 'width')
    bw = parseInt(item.css 'border-left-width')
    mw = parseInt(item.css 'margin-right')

    @gc_width =  @items.length * iw + (@items.length + 1) * bw + (@items.length - 1) * (bw + mw)
    @gc.css {width: "#{@gc_width}px"}

  ##############
  # INTERACTIONS
  ##############

  setInteractions: ->

    if @is_mobi
      @items.bind 'touchstart', @onItemTouchStart
      @items.bind 'touchend', @onItemTouchEnd
    else
      @items.bind 'click', @onItemTouchOrClick
    @close.bind 'click', @onCloseTouchOrClick
    @detail_arrows.bind 'click', @onDetailArrowTouchOrClick

  resetInteractions: ->

    if @is_mobi
      @items.unbind 'touchstart'
      @items.unbind 'touchend'
    else
      @items.unbind 'click'
    @close.unbind 'click'
    @detail_arrows.unbind 'click'

  onItemTouchStart: (e) =>

    @touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
    @touch_start_x = @touch.pageX

  onItemTouchEnd: (e) =>

    delta = @touch.pageX - @touch_start_x
    if delta is 0 then @onItemTouchOrClick(e)

  onItemTouchOrClick: (e) =>

    e.preventDefault()
    big_url = (@$(e.target).attr 'src').replace /.jpg/, "_big.jpg"
    @hideGallery big_url

  onCloseTouchOrClick: (e) =>

    e.preventDefault()
    @showGallery true

  onDetailArrowTouchOrClick: (e) =>

    e.preventDefault()
    dir = parseInt(@$(e.target).attr 'data-dir')
    @changeDetail dir

  addKeyControl: ->

    unless @is_mobi
      key('right', @keymasterScope, (=> @changeDetail 1))
      key('left', @keymasterScope, (=> @changeDetail -1))
      key('esc', @keymasterScope, (=> @showGallery true))

  setKeyControl: ->

    unless @is_mobi
      key.setScope(@keymasterScope)

  resetKeyControl: ->

    unless @is_mobi
      key.setScope('navigation')

  #####################
  # SWAP GALLERY/DETAIL
  #####################

  hideGallery: (big_url) ->

    #@stopUpdating()
    @gc.stop().animate {top: @gc.height() + 10}, {duration: 600, easing: 'easeInOutCubic', complete: (=> @loadBigImage big_url)}
    @close.show()
    @title.hide()
    @navbar.hide()
    @section_arrows.hide()
    @detail_arrows.show().animate {opacity: 1}, {duration: 600, easing: 'easeInCubic'}
    @setKeyControl()

  showGallery: (is_animated)->

    unless @is_mobi
      @startUpdating()
    unless @is_ie or @is_mobi
      @canvas.show()
    @gc.show()
    if(is_animated)
      @gc.stop().animate {top: 0}, {duration: 600, easing: 'easeInOutCubic'}
      unless @is_ie or @is_mobi
        @img.stop().animate {opacity: 0}, {duration: 600, easing: 'easeInOutCubic'}
    else
      @gc.css {top: @gc.height() + 10}
      @gc.css {left: 0}
      unless @is_ie or @is_mobi
        @img.css {opacity: 0}
    @close.hide()
    @title.show()
    @navbar.show()
    @section_arrows.show()
    @detail_arrows.hide().css {opacity: 0}
    @resetKeyControl()

  changeDetail: (dir) ->

    new_index =  @current_detail_index + dir
    if new_index < 0 then new_index = @data.images.length - 1
    else if new_index is @data.images.length then new_index = 0
    @img.stop().css {opacity: "0"}
    unless @is_ie or @is_mobi
      @canvas.show()
    big_url = (@data.images[new_index].src).replace /.jpg/, "_big.jpg"
    @loadBigImage (big_url)

  loadFirstBigImage: ->

    @loader.show()
    @img.css {opacity: "0"}

    big_url = (@data.images[0].src).replace /.jpg/, "_big.jpg"
    @current_detail_index = 0

    current_url = @img.attr 'src'
    if current_url? and current_url is big_url
      @onFirstBigImageLoaded()
    else
      @img.unbind('load.big').bind('load.big', @onFirstBigImageLoaded)
      #@img.error @onBigImageLoadingError
      @img.attr 'src', big_url

  onFirstBigImageLoaded : =>
    if @is_mobi
      @img.stop().css(opacity: 1)
      window.setTimeout @onFirstBigImageEntered, 600
    else
    @img.stop().animate {opacity: 1}, {duration: 600, easing: 'easeInOutCubic', complete: @onFirstBigImageEntered}

    @localResize()
    @loader.hide()

  onFirstBigImageEntered: =>

    @createBlurCanvas()
    @showGallery true

  loadBigImage: (big_url) ->
    @loader.show()
    if @is_ie or @is_mobi
      @img.css {opacity: "0"}
    @current_detail_index = (@getCurrentDetailIndex big_url)[0]

    unless @is_mobi
      @stopUpdating()
    if @img.attr('src') is big_url
      @onBigImageLoaded()
    else
      @img.unbind('load.big').bind('load.big', @onBigImageLoaded)
      #@img.error @onBigImageLoadingError
      @img.attr 'src', big_url

  onBigImageLoaded: =>
    if @is_mobi
      @img.stop().css(opacity: 1)
    else
      @img.stop().animate {opacity: 1}, {duration: 600, easing: 'easeInOutCubic', complete: @createBlurCanvas}
    @localResize()
    @loader.hide()

  createBlurCanvas: =>

    unless @is_ie or @is_mobi
      # stackBlurImage( sourceImageID, targetCanvasID, radius, blurAlphaChannel );
      stackBlurImage @img_id, @canvas_id, 10
      @localResize()
      @canvas.hide()

  getCurrentDetailIndex: (big_url) ->

    thumb_url = big_url.replace /_big.jpg/, ".jpg"
    index = i for i in [0...@data.images.length] when @data.images[i].src is thumb_url

  ########
  # RESIZE
  ########

  localResize: ->

   if @img?
     area_width = @w.width()
     area_height = @w.height() - @f.height()
     ratio = @img.width() / @img.height()

     new_height = area_width / ratio

     if new_height > area_height
       new_width = area_width
       top = .5 * (area_height - new_height)
       left = 0
     else
       new_width = area_height * ratio
       new_height = area_height
       top = .5 * (area_width - new_width)
       left = 0

     (@$ '.full-detail').css
       width: new_width
       height: new_height
       paddingTop: -top
       paddingLeft: -left
       paddingBottom: -top
       paddingRight: -left
       marginTop: top
       marginLeft: left

  ####################
  # SCROLLING / UPDATE
  ####################

  startUpdating: ->

    unless @is_mobi
      @w.bind 'mousemove', @onMouseMove
      @is_updating = true
      @current_left = @gc.position().left
      @setUpdateTimeout()

  stopUpdating: ->

    unless @is_mobi
      @w.unbind 'mousemove'
      @is_updating = false

  onMouseMove: (e) =>

    if @is_ie
      @mouseX = e.clientX
      @mouseY = e.clientY
    else
      @mouseX = e.pageX
      @mouseY = e.pageY

  setUpdateTimeout: ->

    @update_timeout = window.setTimeout @updatePosition, 1000 / @fps

  clearUpdateTimeout: ->

    window.clearTimeout @update_timeout

  updatePosition: =>
    @clearUpdateTimeout()

    @setWrapperWidth()
    posX = 2 * ((@mouseX / @w.width()) - .5)
    current_amp = Math.max(0, parseInt @gc_width - @w.width())
    current_vel = @vel_min + (1 - Math.abs(2 * ((Math.abs(@current_left) / current_amp) - .5))) * @vel_max
    updated_left = @current_left - posX * current_vel
    bounded_left = Math.max(- current_amp, Math.min(0, updated_left))

    if @current_left != bounded_left
      @gc.css {left: bounded_left}
      @current_left = bounded_left

    if @is_updating then @setUpdateTimeout()
