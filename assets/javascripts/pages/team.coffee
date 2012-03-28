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
    ($ '.wrap-overlay').hide().remove()

  openItem: (item) =>
    member_index = (@$ '.item').index(item)
    (@$ '.aux').append(manager.mustache('team_popup', @data.members[member_index]))
    (@$ '.wrap-overlay').show()

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget).parents('.item')

  clickClose: (ev) =>
    ev.preventDefault()
    @closeAllItems()