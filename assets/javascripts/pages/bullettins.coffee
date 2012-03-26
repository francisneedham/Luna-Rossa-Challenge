 class window.BullettinsPage extends window.Page

  init: ->
    @content_width = (@$ '.item').outerWidth() * (@$ '.item').length
    (@$ '.wrap-items').css width: @content_width

  entered: ->
    @bind()

  left: ->
    @unbind()
    @stopMoving()

  bind: =>
    (@$ '.scroller').bind('mousedown', @scrollerMouseDown)
    (@$ '.item>article>a').bind('click', @clickItem)
    (@$ '.item .close').bind('click', @clickCloseItem)

  unbind: =>
    (@$ '.scroller').unbind('mousedown', @scrollerMouseDown)

  startMoving: (ev) =>
    container = (@$ '.scroll')
    scroller = (@$ '.scroller')
    @scrollbar_left = container.offset().left
    @scrollbar_width = container.width() - scroller.width()

    scroll_position = scroller.offset().left
    @moving_offset = scroll_position - ev.clientX

    ($ 'body').bind('mousemove.bulletins', @mouseMove)
    ($ 'body').bind('mouseup.bulletins', @scrollerMouseUp)

  stopMoving: =>
    @moving_offset = 0
    ($ 'body').unbind('.bulletins')

  scrollerMouseUp: (ev) =>
    ev.preventDefault()
    @stopMoving()

  scrollerMouseDown: (ev) =>
    ev.preventDefault()
    @startMoving(ev)

  mouseMove: (ev) =>
    @moving(ev.pageX)

  moving: (pageX) =>
    @position = Math.max(0, Math.min(@getPositionFromMouse(pageX), 100))
    @render()

  getPositionFromMouse: (left) ->
    ((left - @scrollbar_left + @moving_offset) / @scrollbar_width) * 100

  render: =>
    scroll_position = @position * @scrollbar_width / 100
    content_position = @position * (@content_width - ($ '.oriz-scroll').width()) / 100

    (@$ '.scroller').stop().animate({left: scroll_position}, { duration: 30, easing: 'easeInOutSine' })
    (@$ '.oriz-scroll').stop().animate({scrollLeft: content_position}, { duration: 400, easing: 'easeInOutSine'})

  resize: (width, height) ->
    item_width = 295
    available_width = width - 90
    available_items = Math.floor(available_width / item_width)
    total_width = item_width * available_items
    (@$ '.oriz-scroll').css(width: total_width)

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget).parents('.item')

  openItem: (item) =>
    unless item.hasClass('open')
      @closeAllItem => @centerItem(item, @openSubitem)

  centerItem: (item, callback) =>
    ($ '.wrap-items').css(width: '+=600')
    content_position = item.position().left

    console.log('content_position', content_position)

    (@$ '.oriz-scroll').stop().animate({scrollLeft: "+=#{content_position}"}, {
      duration: 400,
      easing: 'easeInOutSine',
      complete: -> callback?(item)
    })

  openSubitem: (item) =>
    unless item.hasClass('open')
      item.addClass('open')
      item.find('.close').show()
      item.stop().animate { width: 870 }, {duration: 600, easing: 'easeInOutSine'}

  closeAllItem: (callback) =>
    items = (@$ '.item.open')
    if items.length
      items.removeClass('open')
      items.stop().animate { width: 270 }, {
        duration: 600,
        easing: 'easeInOutSine',
        complete: =>
          ($ '.wrap-items').css(width: '-=600')
          callback?()
      }
      items.find('.close').hide()
    else
      callback?()

  clickCloseItem: (ev) =>
    ev.preventDefault()
    @closeAllItem()