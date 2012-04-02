window.SiteManager = class
  animationOptions:
    duration: 500
    easing: 'easeOutSine'

  constructor: (@el) ->
    @resize()

    @getData()
    @detectCurrentPage()

    @buildSite()

  getData: ->
    @data = JSON.parse(extract('#site-data'))
    ($ '#site-data').remove()

    @yearsList = _.map(@data, (content, year) -> year)
    @yearsList = @yearsList.sort (a, b) -> parseInt(b, 10) - parseInt(a, 10)

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

    @activeYear(@currentYear)

  getTemplate: (template) ->
    if template in @templates
      @templates[template]
    else
      @templates[template] = extract("#tpl-#{template}")

  mustache: (template, content) ->
    Mustache.render(@getTemplate(template), content)

  buildSite: ->
    @showLoader()
    window.setTimeout(@buildSiteCallback, 50)

  buildSiteCallback: =>
    _.each @yearsList, @buildYear
    @createSharrre()
    @hideLoader()
    @resize()

  buildYear: (year) =>
    content = @data[year]
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
      el = ($ @mustache(content.template, content))
      parent.append el

      viewClass = window[capitalize(content.template) + 'Page']
      viewClass = Page unless viewClass

      view = new viewClass(el, content)
      content.view = view

  buildPageCurrentYear: (parent, content, page) =>
    if page != @currentPage
      el = ($ @mustache(content['template'], content))
      if _.indexOf(@pagesList(), page) > _.indexOf(@pagesList(), @currentPage)
        parent.append el
      else
        parent.find(".step.#{@currentContent()['css_class']}").before(el)
    else
      el = parent.find(".step.#{@currentContent()['css_class']}")

      viewClass = window[capitalize(content.template) + 'Page']
      viewClass = Page unless viewClass

      view = new viewClass(el, content)
    content.view = view

  createSharrre: ->
    ($ '.wrap-sharing').sharrre
      share: {
        twitter: true
        facebook: true
      }
      template: '<span class="title">share this</span><ul><li class="tw"><a class="twitter" href="#">twitter</a></li><li class="fb"><a class="facebook" href="#">facebook</a></li></ul>'
      enableHover: false
      enableTracking: true
      render: (api, options) ->
        ($ api.element).on 'click', '.twitter', ->
          api.openPopup('twitter')

        ($ api.element).on 'click', '.facebook', ->
          api.openPopup('facebook')

  resize: =>
    $w = ($ window)
    @width = $w.width()
    @height = $w.height() - ($ '#footer').height()

    ($ '#years-list, .step, .single-year').css
      width: @width
      height: @height

    ($ '.section-title').css
      top: (@height * 0.23)

    ($ '.section-arrow').css
      bottom: (@height * 0.11)

    @position(true)

  position: (skipAnimation, callback) =>
    if @yearsList
      top = _.indexOf(@yearsList, @currentYear) * @height
      left = _.indexOf(@pagesList(), @currentPage) * @width

      content = @currentContent()
      ($ '#wrapper').removeClass().addClass(content['page_mood'])

      if not @previousContent? or content != @previousContent
        @previousContent?.view?.leaving?()
        content.view?.entering?()

      if skipAnimation
        ($ '#years-list').scrollTop(top)
        ($ "#y-#{@currentYear}").scrollLeft(left)

        if not @previousContent? or content != @previousContent
          @previousContent?.view?.left?()
          content.view?.entered?()

        @previousContent = content
      else
        animationOptions = _.clone(@animationOptions)
        animationOptions.complete = =>
          if not @previousContent? or content != @previousContent
            @previousContent?.view?.left?()
            content.view?.entered?()

          @previousContent = content
          callback()

        if top != ($ '#years-list').scrollTop()
          ($ '#years-list').animate({scrollTop: top}, animationOptions)

        if left != ($ "#y-#{@currentYear}").scrollLeft()
          ($ "#y-#{@currentYear}").animate({scrollLeft: left}, animationOptions)

  activeYear: (year) =>
    ($ "#navbar .active").removeClass('active')
    ($ "#link-#{year}").addClass('active')

  gotoYear: (year) =>
    year = year.toString()
    if year != @currentYear
      @activeYear(year)

      if @currentPage != @pagesList()[0]
        left = (_.indexOf(@pagesList(), @currentPage) - 1) * @width

        if @currentPage != @pagesList()[1]
          home = @currentEl(@pagesList()[0])
          home.toggleClass('moved', true).css(left: left)

        ($ "#y-#{@currentYear}").animate({scrollLeft: left}, @animationOptions)

      @currentYear = year
      @currentPage = @pagesList()[0]

      @position(false, @yearScrolled)

  gotoPage: (page) =>
    if page != @currentPage
      # unless moving from home to first page or vice versa
      unless (page == @pagesList()[0] and @currentPage == @pagesList()[1]) or (page == @pagesList()[1] and @currentPage == @pagesList()[0])

        # animate title
        begin = @currentEl().find('.section-title')
        target = @currentEl(page).find('.section-title')

        begin.stop(true)
        target.stop(true)

        begin.toggleClass('fixed-header', true)
        target.css(opacity: 0).toggleClass('fixed-header', true)

        begin.animate(opacity: 0, @animationOptions)
        target.animate(opacity: 1, @animationOptions)

        #animate arrows
        begin = @currentEl().find('.section-arrow')
        target = @currentEl(page).find('.section-arrow')

        begin.stop(true)
        target.stop(true)

        begin.toggleClass('fixed-menu', true)
        target.css(opacity: 0).toggleClass('fixed-menu', true)

        begin.animate(opacity: 0, @animationOptions)
        target.animate(opacity: 1, @animationOptions)

      @previousContent = @currentContent()

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
    ($ '.fixed-header').toggleClass('fixed-header', false).css(opacity: 1)
    ($ '.fixed-menu').toggleClass('fixed-menu', false).css(opacity: 1)

  yearScrolled: =>
    ($ '.moved').toggleClass('moved', false).css(left: '')
    ($ '.single-year').stop(true).scrollLeft(0)

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

  showLoader: ->
    ($ '.loader').show()

  hideLoader: ->
    ($ '.loader').hide()

  isTouch: ->
    @touch ||= ($ 'html').hasClass('touch')