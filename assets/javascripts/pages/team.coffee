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
    member_data = @data.members[(@$ '.item').index(item)]

    if member_data and member_data.popup_image
      (@$ '.aux').append(manager.mustache('team_popup', member_data))
      (@$ '.wrap-overlay').show()

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget).parents('.item')

  clickClose: (ev) =>
    ev.preventDefault()
    @closeAllItems()