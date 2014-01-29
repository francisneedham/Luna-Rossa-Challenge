class window.ScrollPage extends Page

  init: =>
    @content_width = 295 * (@$ '.item').length
    (@$ '.wrap-items').css width: (@content_width + 650)

  entered: =>
    @bind()

  leaving: =>
    @closeAllItems()
    @reset()

  left: =>
    @unbind()
    @stopMoving()

  bind: =>
    (@$ '.item .close').bind('click', @clickCloseItem)

    if manager.isTouch()
      (@$ '.scroller').bind('touchstart.scroll', @scrollerTouchStart)
    else
      (@$ '.scroller').bind('mousedown.scroll', @scrollerMouseDown)

  unbind: =>
    (@$ '.item .close').unbind('click', @clickCloseItem)
    (@$ '.scroller').unbind('.scroll', @scrollerMouseDown)

  startMoving: (clientX) =>
    @setupValues()

    (@$ '.wrap-scroll').addClass('focus')

    scroll_position = (@$ '.scroller').offset().left
    @moving_offset = scroll_position - clientX

    if manager.isTouch()
      ($ 'body')
        .bind('touchmove.bulletins', @touchMove)
        .bind('touchend.bulletins', @scrollerTouchEnd)
    else
      ($ 'body')
        .bind('mousemove.bulletins', @mouseMove)
        .bind('mouseup.bulletins', @scrollerMouseUp)
        .bind('mouseleave.bulletins', @scrollerMouseUp)

  stopMoving: =>
    (@$ '.wrap-scroll').removeClass('focus')
    @moving_offset = 0
    ($ 'body').unbind('.bulletins')

  moving: (pageX) =>
    @position = Math.max(0, Math.min(@getPositionFromMouse(pageX), 100))
    console.log @position
    @render()

  movingz: (pageX) =>
    @position = pageX
    @renderf()

  getPositionFromMouse: (left) ->
    ((left - @scrollbar_left + @moving_offset) / @scrollbar_width) * 100

  render: (callback) =>
    scroll_position = @position * @scrollbar_width / 100
    content_position = @position * (@content_width - ($ '.oriz-scroll').width()) / 100

    (@$ '.scroller').stop().animate({left: scroll_position}, { duration: 30, easing: 'easeOutSine' })
    (@$ '.oriz-scroll').stop().animate({scrollLeft: content_position}, {
      duration: 400,
      easing: 'easeOutSine',
      complete: callback
    })


  renderf: (callback) =>
    scroll_position = @position * @scrollbar_width / 100
    content_position = @position * (@content_width) / 100

    (@$ '.scroller').stop().animate({left: scroll_position}, { duration: 30, easing: 'easeOutSine' })
    (@$ '.oriz-scroll').stop().animate({scrollLeft: content_position}, {
      duration: 400,
      easing: 'easeOutSine',
      complete: callback
    })

  resize: (width, height) ->
    if (@$ '.scroll').length > 0
      @setupValues()

      scroller_width = (@$ '.oriz-scroll').width()
      if @content_width <= scroller_width
        (@$ '.scroll').hide()
      else
        (@$ '.scroll').show()

  setupValues: =>
    container = (@$ '.scroll')
    scroller = (@$ '.scroller')
    @scrollbar_left = container.offset().left
    @scrollbar_width = container.width() - scroller.width()

  reset: =>
    @position = 0
    @render()

  dispose: =>
    @unbind()

  # EVENTS

  scrollerMouseUp: (ev) =>
    ev.preventDefault()
    @stopMoving()

  scrollerMouseDown: (ev) =>
    ev.preventDefault()
    @startMoving(ev.clientX)

  mouseMove: (ev) =>
    @moving(ev.pageX)

  scrollerTouchEnd: (ev) =>
    ev.preventDefault()
    @stopMoving()

  scrollerTouchStart: (ev) =>
    ev.preventDefault()
    @startMoving(ev.originalEvent.touches[0].clientX)

  touchMove: (ev) =>
    ev.preventDefault()
    @moving(ev.originalEvent.touches[0].pageX)

  clickCloseItem: (ev) =>
    ev.preventDefault()
    @closeAllItems()