class window.ScrollPage extends Page

  init: =>
    @content_width = (@$ '.item').outerWidth() * (@$ '.item').length
    (@$ '.wrap-items').css width: (@content_width + 600)

  entered: =>
    @bind()

  leaving: =>
    @closeAllItems()
    @reset()

  left: =>
    @unbind()
    @stopMoving()

  bind: =>
    (@$ '.scroller').bind('mousedown', @scrollerMouseDown)
    (@$ '.item .close').bind('click', @clickCloseItem)

  unbind: =>
    (@$ '.scroller').unbind('mousedown', @scrollerMouseDown)
    (@$ '.item .close').bind('click', @clickCloseItem)

  startMoving: (ev) =>
    @setupValues()

    scroll_position = (@$ '.scroller').offset().left
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

  render: (callback) =>
    scroll_position = @position * @scrollbar_width / 100
    content_position = @position * (@content_width - ($ '.oriz-scroll').width()) / 100

    (@$ '.scroller').stop().animate({left: scroll_position}, { duration: 30, easing: 'easeInOutSine' })
    (@$ '.oriz-scroll').stop().animate({scrollLeft: content_position}, {
      duration: 400,
      easing: 'easeInOutSine',
      complete: callback
    })


  resize: (width, height) ->
    item_width = 295
    available_width = width - 90
    available_items = Math.floor(available_width / item_width)
    total_width = item_width * available_items
    (@$ '.oriz-scroll').css(width: total_width)

    @setupValues()

  clickCloseItem: (ev) =>
    ev.preventDefault()
    @closeAllItems()

  setupValues: =>
    container = (@$ '.scroll')
    scroller = (@$ '.scroller')
    @scrollbar_left = container.offset().left
    @scrollbar_width = container.width() - scroller.width()

  reset: =>
    @position = 0
    @render()