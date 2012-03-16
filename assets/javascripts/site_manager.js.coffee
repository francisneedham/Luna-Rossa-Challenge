window.SiteManager = class
  animationOptions:
    duration: 500
    easing: 'easeInOutSine'

  constructor: (@el) ->
    @getData()
    @detectCurrentPage()
    @buildSite()

  getData: ->
    @data = JSON.parse(extract('#site-data'))
    ($ '#site-data').remove()

    @yearsList = _.map @data, (content, year) -> year

    @templates = {}

  pagesList: (year = @currentYear) =>
    @pagesLists = [] unless @pagesLists
    @pagesLists[year] or (@pagesLists[year] = _.map(@data[year], (discard, page) -> page))

  detectCurrentPage: ->
    pathParts = window.location.pathname.replace(/^\/.{2}\//, '').split('/')

    @currentYear = pathParts[0]
    @currentYear = @yearsList[0] unless @currentYear

    @currentPage = pathParts[1]
    unless @currentPage
      @currentPage = @pagesList()[0]

  getTemplate: (template) ->
    if template in @templates
      @templates[template]
    else
      @templates[template] = extract("#tpl-#{template}")

  mustache: (template, content) ->
    Mustache.render(@getTemplate(template), content)

  buildSite: ->
    _.each @data, @buildYear

  buildYear: (content, year) =>
    if content?
      if year != @currentYear
        firstPage = content['home']

        container = ($ '<div class="container" />')
        el = ($ '<li class="single-year" />').attr(id: "y-#{year}").append(container)

        _.each content, (content, page) =>
          @buildPage(container, content, page)

        if _.indexOf(@yearsList, year) > _.indexOf(@yearsList, @currentYear)
          ($ '#years-list').append(el)
        else
          ($ "#y-#{@currentYear}").before(el)

      else
        el = ($ "#y-#{year}").find('.container')
        _.each content, (content, page) =>
          @buildPageCurrentYear(el, content, page)

  buildPage: (parent, content, page) =>
    if content?
      el = @mustache(content.template, content)
      parent.append el
      view = new window[capitalize(content.template) + 'Page'](el, content)
      content.view = view

  buildPageCurrentYear: (parent, content, page) =>
    if page != @currentPage
      if _.indexOf(@pagesList(), page) > _.indexOf(@pagesList(), @currentPage)
        parent.append @mustache(content['template'], content)
      else
        parent.find(".#{@currentContent()['css_class']}").before(@mustache(content['template'], content))

  resize: =>
    $w = ($ window)
    @width = $w.width()
    @height = $w.height() - ($ '#footer').height()

    ($ '#years-list, .step, .aux, .single-year').css
      width: @width
      height: @height

    ($ '.section-title').css
      top: (@height * 0.23)

    @position(true)

  position: (skipAnimation, callback) =>
    top = _.indexOf(@yearsList, @currentYear) * @height
    left = _.indexOf(@pagesList(), @currentPage) * @width

    ($ '#wrapper').removeClass().addClass(@currentContent()['page_mood'])

    if skipAnimation
      ($ '#years-list').scrollTop(top)
      ($ "#y-#{@currentYear}").scrollLeft(left)
    else
      animationOptions = _.clone(@animationOptions)
      animationOptions.complete = callback

      ($ '#years-list').animate(scrollTop: top, animationOptions)
      ($ "#y-#{@currentYear}").animate({scrollLeft: left}, animationOptions)

  gotoYear: (year) =>
    year = year.toString()
    if year != @currentYear
      @currentYear = year
      @currentPage = @pagesList()[0]

      @position(false)

  gotoPage: (page) =>
    if page != @currentPage
      begin = @currentEl().find('.section-title')
      target = @currentEl(page).find('.section-title')

      begin.toggleClass('fixed-header', true)
      target.css(opacity: 0).toggleClass('fixed-header', true)

      begin.animate(opacity: 0, @animationOptions)
      target.animate(opacity: 1, @animationOptions)

      @currentPage = page
      @position(false, @pageScrolled)

  goto: (year, page) =>
    year = year.toString()
    if year != @currentYear
      @gotoYear(year)
    else if page != @currentPage
      @gotoPage(page)

  currentEl: (page = @currentPage, year = @currentYear) =>
    ($ "#y-#{year} .#{@currentContent(page, year)['css_class']}")

  currentContent: (page = @currentPage, year = @currentYear) =>
    @data[year][page]

  pageScrolled: =>
    ($ '.fixed-header').toggleClass('fixed-header', false)

  prevPage: =>
    nextPath = @currentContent()['prev']

    if nextPath
      History.pushState({}, null, nextPath)

  nextPage: =>
    nextPath = @currentContent()['next']

    if nextPath
      History.pushState({}, null, nextPath)

  prevYear: =>
    nextPath = @currentContent(@pagesList()[0])['prev']

    if nextPath
      History.pushState({}, null, nextPath)

  nextYear: =>
    pagesList = @pagesList()
    nextPath = @currentContent(pagesList[pagesList.length - 1])['next']

    if nextPath
      History.pushState({}, null, nextPath)