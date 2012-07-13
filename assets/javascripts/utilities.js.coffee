
w = window

w.extract = (query) ->
  domObj = ($ query)
  content = domObj.html()

  domObj.remove()
  delete domObj

  content = $.trim(content)
  content = content.replace(/^\/\*/, '').replace(/\*\/$/, '')
  $.trim(content)

w.capitalize = (string) ->
  string.replace /^./, (firstChar) -> firstChar.toUpperCase()