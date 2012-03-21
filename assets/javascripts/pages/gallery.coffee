 class window.GalleryPage

  constructor: (@el, @data) ->

    #____TEST
    @init()
    
  init: ->
    
    #console.log @el
    #console.log @data
    
    @is_ios = if navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i) || navigator.userAgent.match(/iPad/i) then true else false
    
    @w = $ window
    @h = $ '#header'
    @f = $ '#footer'
    @wrap = $ '.wrap-gallery-carousel'
    @gc = $ '.gallery-carousel'
    @items = @gc.find '.item'
    
    @fps = 30
    @w_width = 0
    @gc_width = 0
    @vel_min = 2
    @vel_max = 20
    @is_updating = false

    @addRightBorder()
    @setGalleryWidth()
    
    #____TEST
    @entered()
    
  entered: ->
      
    if @is_ios
      @wrap.css {overflow: 'scroll'}
    else
      @w.bind 'mousemove', @onMouseMove
      @is_updating = true
    @setUpdateTimeout()
    
  exiting: ->
    
    unless @is_ios
      @w.unbind 'mousemove'
      @is_updating = false

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
  
  onMouseMove: (e) =>
    
    @mouseX = e.pageX
    @mouseY = e.pageY
    
  setUpdateTimeout: ->
    
    @update_timeout = window.setTimeout @updatePosition, 1000 / @fps
    
  clearUpdateTimeout: ->
    
    window.clearTimeout @update_timeout
  
  updatePosition: =>
    
    @clearUpdateTimeout()
    
    if @is_ios
      if @w.width() isnt @w_width
        @w_width = @w.width()
        @wrap.css {width: "#{@w_width}px"}
    else
      posX = 2 * ((@mouseX / @w.width()) - .5)
      current_left = @gc.position().left
      current_amp = parseInt @gc_width - @w.width()
      current_vel = @vel_min + (1 - Math.abs(2 * ((Math.abs(current_left) / current_amp) - .5))) * @vel_max
      updated_left = Math.round(current_left - posX * current_vel)
      bounded_left = Math.max(- current_amp, Math.min(0, updated_left))
      @gc.css {left: bounded_left}
    
    if @is_updating then @setUpdateTimeout()