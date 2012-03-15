
window.extract = (query) ->
  content = ($ query).text()
  content = $.trim(content)
  content = content.replace(/^\/\*/, '').replace(/\*\/$/, '')
  $.trim(content)
