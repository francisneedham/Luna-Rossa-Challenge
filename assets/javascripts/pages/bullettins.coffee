 class window.BullettinsPage extends window.ScrollPage

  bind: =>
    super()
    (@$ '.item>article>a').bind('click', @clickItem)

  unbind: =>
    super()
    (@$ '.item>article>a').bind('click', @clickItem)

  startMoving: (ev) =>
    @closeAllItems()
    super(ev)

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