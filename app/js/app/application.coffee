$ ->

  $.cl = (obj) ->
    console.log(obj)

  ###
  Code from So-nice
  https://github.com/sunny/so-nice/blob/master/public/script.js
  ###
  Array::random = ->
    this[Math.floor(Math.random() * @length)]

  $.fn.background = (bg) ->
    $(this).css "backgroundImage", (if bg then "url(" + bg + ")" else "none")

  # Get a new artist image from Last.fm via jsonp
  # When found calls the `callback` with the image url as the first argument
  artistImage = (artist, callback) ->
    cb = ->
      callback cache[artist].random()

    cache = artistImage.cache
    artist = encodeURI(artist)

    # Deliver from cache
    if cache.hasOwnProperty(artist)

      # execute the callback asynchronously to minimize codepaths
      setTimeout cb, 10
      return

    # Load
    last_fm_uri = "http://ws.audioscrobbler.com/2.0/?format=json&method=artist.getimages&artist=%s&api_key=e37be5627a5ca3106743f138b2220f12"
    $.ajax
      url: last_fm_uri.replace("%s", artist)
      dataType: "jsonp"
      success: (obj) ->
        if obj.images.image
          cache[artist] = $.map(obj.images.image, (img) ->
            img.sizes.size[0]["#text"]
          )
          cb()
        else
          callback()

  artistImage.cache = {}

  ###
  Faye!
  ###

  client = new Faye.Client 'http://' + location.hostname + ':9292/faye'

  subscription = client.subscribe '/first-sin/mpd', (msg) ->
    #fayeStatusMsg(msg.text)
    fayeActionHandler(msg.action) if msg.action?

  subscription.callback ->
    fayeStatus(true)

  subscription.errback (error) ->
    fayeStatus(false)

  client.bind 'transport:down', ->
    fayeStatus(false)

  client.bind 'transport:up', ->
    fayeStatus(true)

  fayeActionHandler = (action) ->
    switch action
      when 'mpd'      then mpdInfo()

  fayeStatus = (connected) ->
    if connected
      icon = 'icon-ok'
    else
      icon = 'icon-remove'
    fayeStatusIcon icon

  fayeStatusIcon = (icon) ->
    $('i[data-id=faye-status-icon]').attr('class', icon)

  ###
  Templates
  ###
  _.templateSettings =
    evaluate:    /\{\{(.+?)\}\}/g
    interpolate: /\{\{=(.+?)\}\}/g

  tmpl = {}

  $.each $('script[id^=tmpl-]'), (t) ->
    name = $( @ ).attr( "id" ).replace( "tmpl-", "" )
    tmpl[name] = $( @ ).html()
    return true

  ###
  General button binders
  ###

  # Close button
  $(document).on "click", 'i.close', () ->
    $('div.alert').hide()

  # Menu: MPD
  $(document).on "click", 'a[data-menu=mpd]', () ->
    mpdInfo()

  ###
  MPD page
  ###

  # Control buttons
  $(document).on "click", 'a.mpd_control', (e) ->
    action = $(this).data('action')
    toggle = $(this).data('toggle')
    clear  = $(this).data('clear')
    clearClass('a[data-clear=true]', 'active') if (clear)
    $(@).toggleClass('active') if  ( toggle )
    mpdDo(action)

  # Update button
  $(document).on "click", 'a.mpd_update', (e) ->
    mpdInfo()

  # Volume button
  $(document).on "click", 'a.mpd_volume', (e) ->
    $.get '/mpd.json', {vol: $(this).data('volume')}

  # MPD functions!
  clearClass = (selector, klass) ->
    $(selector).each ->
      $(@).removeClass(klass)
    return true

  mpdInfo = () ->
    $.get '/mpd.json', (data) ->
      $('a[data-action=random]').addClass('active') if (data['random'])

      $('a[data-action=repeat]').addClass('active') if (data['repeat'])

      activeButton(data['state'])
      updatePlayer(data)
      return true


  mpdDo = (action) ->
    $.get '/mpd.json', {action: action}, (data) ->
      updatePlayer(data)


  updatePlayer = (data) ->
    unless data['error']?
      template = _.template(tmpl['mpd-info'], {data: data})
      $('#mpd-info').html(template)
      artistImage data['artist'], (url) ->
        $("body").background url
    else
      $('.alert').show()
      $('.alert-message').html(data['error'])
      $('#mpd-info').html('')

  activeButton = (action) ->
    clearClass('a[data-clear=true]', 'active')
    $('a[data-action='+action+']').addClass('active')

  toggleButton = (action, state) ->
    if (state)
      $('a.mpd_'+action).addClass('active')
    else
      $('a.mpd_'+action).removeClass('active')

  setInterval( () ->
    mpdInfo()
  ,30000)


  ###
  On load
  ###

  mpdInfo()

  # $.get '/playlist.json', (data) ->
  #     $.cl data
  #     template = _.template(tmpl['mpd-playlist'], {data: data})
  #     $('#mpd-playlist').html(template)
  #     return true


