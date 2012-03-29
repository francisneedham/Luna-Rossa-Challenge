class window.GalleryPage extends window.Page

  ###
  TODO:
  - performance ipad al close
  ###
  
  ######################
  # INIT/ENTERED/LEAVING
  ######################
  
  init: ->

    #console.log @el
    #console.log @data

    @is_mobi = if navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i) || navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/Android/i) then true else false

    @w = $ window
    @h = $ '#header'
    @f = $ '#footer'
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
    @vel_min = 2
    @vel_max = 30
    @is_updating = false

    @setWrapperWidth()
    @addRightBorder()
    @setGalleryWidth()
    
    if @is_mobi
      @setWrapperWidth()
      #@gc.attr('data-scrollable', 'x')
      new EasyScroller @gc[0], {
        scrollingX: true,
        scrollingY: false,
        zooming: false
      }
      
    @loadFirstBigImage()

  entered: ->
    
    @startUpdating()
    @setInteractions()

  leaving: ->

    @showGallery()
    @stopUpdating()
    @resetInteractions()
      
  ########
  # LAYOUT
  ########
  
  setWrapperWidth: ->
    
    if @w.width() isnt @w_width
      @w_width = @w.width()
      @wrap.css {width: "#{@w_width}px"}

  addRightBorder: ->

    item = $ @items[@items.length - 1]
    bl = item.css 'border-left-width'
    bc = item.css 'border-left-color'
    item.css {'border-right': "#{bl} solid #{bc}"}

  setGalleryWidth: ->

    item = $ @items[0]
    iw = parseInt(item.css 'width')
    bw = parseInt(item.css 'border-left-width')
    @gc_width =  @items.length * iw + (@items.length + 1) * bw
    @gc.css {width: "#{@gc_width}px"}
    
  ##############
  # INTERACTIONS
  ##############
  
  setInteractions: ->
    
    if @is_mobi
      @items.bind 'touchstart', @onItemTouchStart
      @items.bind 'touchend', @onItemTouchEnd
      @close.bind 'touchstart', @onCloseTouchOrClick
    else
      @items.bind 'click', @onItemTouchOrClick
      @close.bind 'click', @onCloseTouchOrClick
      
  resetInteractions: ->
    
    if @is_mobi
      @items.unbind 'touchstart'
      @items.unbind 'touchend'
      @close.unbind 'touchstart'
    else
      @items.unbind 'click'
      @close.unbind 'click'

  onItemTouchStart: (e) =>
    
    @touch = e.originalEvent.touches[0] || e.originalEvent.changedTouches[0]
    @touch_start_x = @touch.pageX
    
  onItemTouchEnd: (e) =>

    delta = @touch.pageX - @touch_start_x
    if delta is 0 then @onItemTouchOrClick(e)
  
  onItemTouchOrClick: (e) =>
    
    #e.preventDefault()
    big_url = (@$(e.target).attr 'src').replace /.jpg/, "_big.jpg"
    @hideGallery big_url
    
  onCloseTouchOrClick: (e) =>

    #e.preventDefault()
    @showGallery()
    
  #####################
  # SWAP GALLERY/DETAIL
  #####################
  
  hideGallery: (big_url) ->
    
    #@stopUpdating()
    @gc.stop().animate {top: @gc.height()}, {duration: 600, easing: 'easeInOutCubic', complete: (=> @loadBigImage big_url)}
    @close.show()
    @title.hide()
    
  showGallery: ->

    unless @is_mobi 
      @startUpdating()
    @canvas.show()
    @gc.stop().animate {top: 0}, {duration: 600, easing: 'easeInOutCubic'}
    @img.stop().animate {opacity: 0}, {duration: 600, easing: 'easeInOutCubic'}
    @close.hide()
    @title.show()
    
  loadFirstBigImage: ->
    
    big_url = (@data.images[0].src).replace /.jpg/, "_big.jpg"
    
    @img.css {opacity: "0"}
    @canvas.css {opacity: "0"}
    
    @img.load @onFirstBigImageLoaded
    #@img.error @onBigImageLoadingError
    @img.attr 'src', big_url
    
  onFirstBigImageLoaded : =>
  
    @createBlurCanvas()
    @canvas.show()
    @canvas.stop().animate {opacity: 1}, {duration: 600, easing: 'easeInOutCubic'}
    @localResize()
  
  loadBigImage: (big_url) ->
    
    unless @is_mobi 
      @stopUpdating()
    if @img.attr('src') is big_url
      @onBigImageLoaded()
    else 
      @img.load @onBigImageLoaded
      #@img.error @onBigImageLoadingError
      @img.attr 'src', big_url
    
  onBigImageLoaded : =>
    
    @img.stop().animate {opacity: 1}, {duration: 600, easing: 'easeInOutCubic', complete: @createBlurCanvas}
    @localResize()
    
  createBlurCanvas : =>
    
    # stackBlurImage( sourceImageID, targetCanvasID, radius, blurAlphaChannel );
    stackBlurImage 'detail-img', 'detail-canvas', 10, 1
    @localResize()
    @canvas.hide()
    
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
      @setUpdateTimeout()
    
  stopUpdating: ->
    
    unless @is_mobi
      @w.unbind 'mousemove'
      @is_updating = false
  
  onMouseMove: (e) =>

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
   current_left = @gc.position().left
   current_amp = parseInt @gc_width - @w.width()
   current_vel = @vel_min + (1 - Math.abs(2 * ((Math.abs(current_left) / current_amp) - .5))) * @vel_max
   updated_left = current_left - posX * current_vel
   bounded_left = Math.max(- current_amp, Math.min(0, updated_left))
   @gc.css {left: bounded_left}

   if @is_updating then @setUpdateTimeout()
