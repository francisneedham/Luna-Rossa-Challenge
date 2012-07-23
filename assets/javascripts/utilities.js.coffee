
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

w.imagesLoaded = (dom, callback) ->
  images = dom.find('img')
  imagesToLoad = images.length

  for image in images
    imagesToLoad-- if image.complete

  loadedFn = ->
    imagesToLoad--
    if imagesToLoad == 0
      callback()

  if imagesToLoad
    images.load loadedFn
    images.bind('error', loadedFn)
  else
    callback()