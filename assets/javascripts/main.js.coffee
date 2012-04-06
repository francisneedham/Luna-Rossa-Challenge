$ ->
  NAVIGATION_SCOPE = 'navigation'
  w = window

  w.manager = manager = new SiteManager($ '#wrapper')

  ($ w).bind 'resize', manager.resize

  History.Adapter.bind w, 'statechange', ->
    State = History.getState()

    urlParts = State.url.replace(/^(https?:\/\/.+?)?\/(.{2}\/)?/, '').split('/')

    manager.goto urlParts[0], urlParts[1]

  ($ '#navbar a, .next-page, .prev-page, .logo').live 'click', (ev) ->
    ev.preventDefault()
    url = ($ this).attr('href')
    History.pushState({}, null, url)

  key('right', NAVIGATION_SCOPE, manager.nextPage)
  key('left', NAVIGATION_SCOPE, manager.prevPage)
  key('down', NAVIGATION_SCOPE, manager.nextYear)
  key('up', NAVIGATION_SCOPE, manager.prevYear)
  key.setScope(NAVIGATION_SCOPE)