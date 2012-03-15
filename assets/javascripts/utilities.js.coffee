
w = window

w.extract = (query) ->
  content = ($ query).text()
  content = $.trim(content)
  content = content.replace(/^\/\*/, '').replace(/\*\/$/, '')
  $.trim(content)

w.capitalize = (string) ->
  string.replace /^./, (firstChar) -> firstChar.toUpperCase()