 class window.BullettinsPage extends window.Page

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
    (@$ '.item>article>a').bind('click', @clickItem)
    (@$ '.item .close').bind('click', @clickCloseItem)

  unbind: =>
    (@$ '.scroller').unbind('mousedown', @scrollerMouseDown)
    (@$ '.item>article>a').bind('click', @clickItem)
    (@$ '.item .close').bind('click', @clickCloseItem)

  startMoving: (ev) =>
    @setupValues()
    @closeAllItems()

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

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget).parents('.item')

  openItem: (item) =>
    unless item.hasClass('open')
      @closeAllItems => @centerItem(item, @openSubitem)

  centerItem: (item, callback) =>
    @setupValues()

    scroll = ($ '.oriz-scroll')
    @position = (scroll.scrollLeft() + item.position().left) / (@content_width - scroll.width()) * 100
    @render( -> callback?(item))

  openSubitem: (item) =>
    unless item.hasClass('open')
      item.addClass('open')
      item.find('.close').show()
      li = item.find('.detail li')
      item.stop().animate { width: 270 + (li.length * li.outerWidth()) + 12 }, {duration: 600, easing: 'easeInOutSine'}

  closeAllItems: (callback) =>
    items = (@$ '.item.open')
    if items.length
      items.removeClass('open')
      items.stop().animate { width: 270 }, {
        duration: 600,
        easing: 'easeInOutSine',
        complete: =>
          if @position > 100
            @position = 100
            @render(callback)
          else
            callback?()
      }
      items.find('.close').hide()
    else
      callback?()

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