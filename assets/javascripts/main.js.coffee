($ document).ready ->
  $w = ($ window)
  width = $w.width()
  height = $w.height() - ($ '#footer').height()

  ($ '#years-list, .step, .aux, .single-year').css
    width: width
    height: height