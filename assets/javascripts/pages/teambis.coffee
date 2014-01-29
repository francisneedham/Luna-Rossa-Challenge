class window.TeambisPage extends window.TeamPage
  init: => 
    super()

  bind: =>
    super()
    (@$ '#man').bind('click', @clickAnchors)
    (@$ '#steam').bind('click', @clickAnchor)
    (@$ '#dteam').bind('click', @clickAnchor)
    (@$ '#shteam').bind('click', @clickAnchor)
    (@$ '#cpr').bind('click', @clickAnchor)

  unbind: =>
    super()
    (@$ '#steam').unbind('click', @clickAnchor)

  clickAnchor: (ev) =>
    ev.preventDefault()
    anchor = $(ev.target) 
    values = { 'steam' : 2957, 'mgm' : 0, 'dteam' : 8860, 'shteam' : 12990, 'cpr' : 26266 }
    position = ( values[anchor.attr('id')] / @content_width ) * 100
    @startMoving(0)
    @movingz(position)
    @stopMoving()

  clickAnchors: (ev) =>
    ev.preventDefault()
    position = 0
    @startMoving(0)
    @movingz(position)
    @stopMoving()