($ document).ready ->
  w = window

  w.manager = new SiteManager($ '#wrapper')

  w.manager.resize()
  w.manager.position(true)

  ($ w).bind 'resize', w.manager.resize

  History.Adapter.bind w, 'statechange', ->
    State = History.getState()

    urlParts = State.url.replace(/^(https?:\/\/.+?)?\//, '').split('/')

    w.manager.goto urlParts[0], urlParts[1]

  ($ '#navbar a, .next-page, .prev-page').click (ev) ->
    ev.preventDefault()
    url = ($ this).attr('href')
    History.pushState({}, null, url)