($ document).ready ->

  window.manager = new SiteManager($ '#wrapper')

  window.manager.resize()
  window.manager.position(true)