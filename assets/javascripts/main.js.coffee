($ document).ready ->
  w = window

  w.manager = new SiteManager($ '#wrapper')

  w.manager.resize()
  w.manager.position(true)

  ($ w).bind 'resize', w.manager.resize