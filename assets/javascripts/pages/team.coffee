 class window.TeamPage extends window.ScrollPage

  bind: =>
    super()
    (@$ 'li>article>a').bind('click', @clickItem)
    ($ @el).delegate('.close', 'click', @clickClose)

  unbind: =>
    super()
    (@$ 'li>article>a').unbind('click', @clickItem)
    ($ @el).undelegate('.close', 'click', @clickClose)

  closeAllItems: =>
    ($ '.wrap-overlay').hide()

  openItem: (item) =>
    ($ '.wrap-overlay').show()

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget)

  clickClose: (ev) =>
    ev.preventDefault()
    @closeAllItems()