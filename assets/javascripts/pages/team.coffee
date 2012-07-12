POPUP_SCOPE = 'popup'

class window.TeamPage extends window.ScrollPage

  init: =>
    super()
    key('esc', POPUP_SCOPE, @closeAllItems)

  bind: =>
    super()
    (@$ 'li>article>a').bind('click', @clickItem)
    ($ @el).delegate('.close', 'click', @clickClose)

  unbind: =>
    super()
    (@$ 'li>article>a').unbind('click', @clickItem)
    ($ @el).undelegate('.close', 'click', @clickClose)

  closeAllItems: =>
    key.setScope('navigation')
    ($ '.wrap-overlay').hide().remove()

  openItem: (item) =>
    member_data = @data.members[(@$ '.item').index(item)]

    if member_data and member_data.popup_image
      key.setScope(POPUP_SCOPE)
      (@$ '.aux').append(manager.mustache('team_popup', member_data))

      if manager.isPad()
        (@$ '.wrap-overlay').show()
      else
        (@$ '.wrap-overlay').fadeIn()

  clickItem: (ev) =>
    ev.preventDefault()
    @openItem ($ ev.currentTarget).parents('.item')

  clickClose: (ev) =>
    ev.preventDefault()
    @closeAllItems()