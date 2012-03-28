$ ->
  w = window

  w.manager = manager = new SiteManager($ '#wrapper')

  manager.resize()
  manager.position(true)

  ($ w).bind 'resize', manager.resize

  History.Adapter.bind w, 'statechange', ->
    State = History.getState()

    urlParts = State.url.replace(/^(https?:\/\/.+?)?\/.{2}\//, '').split('/')

    manager.goto urlParts[0], urlParts[1]

  ($ '#navbar a, .next-page, .prev-page').click (ev) ->
    ev.preventDefault()
    url = ($ this).attr('href')
    History.pushState({}, null, url)

  key('right', manager.nextPage)
  key('left', manager.prevPage)
  key('down', manager.nextYear)
  key('up', manager.prevYear)