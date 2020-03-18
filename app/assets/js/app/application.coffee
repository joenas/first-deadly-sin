$ ->

  $.cl = (obj) ->
    console.log(obj)

  ###
  Code from So-nice
  https://github.com/sunny/so-nice/blob/master/public/script.js
  ###

  $.fn.background = (bg) ->
    $(this).css "backgroundImage", (if bg then "url(" + bg + ")" else "none")

  # Get a new artist image from Last.fm via jsonp
  # When found calls the `callback` with the image url as the first argument
  artistImage = (artist, callback) ->
    if !artist
      return callback()

    cb = ->
      callback cache[artist]
      return

    cache = artistImage.cache
    artist = encodeURI(artist)
    # Deliver from cache
    if cache.hasOwnProperty(artist)
      # execute the callback asynchronously to minimize codepaths
      setTimeout cb, 10
      return
    # Load
    $.get '/artist.json', {artist: artist}, (data) ->
      if data.url
        cache[artist] = data.url
        cb()
      else
        callback()
      return

    return

  artistImage.cache = {}

  ###
  Faye!
  ###

  client = new Faye.Client 'http://' + location.hostname + ':9292/faye'

  subscription = client.subscribe '/first-sin/mpd', (msg) ->
    mpdInfo msg['info']

  subscription.callback ->
    fayeStatus(true)

  subscription.errback (error) ->
    fayeStatus(false)

  client.bind 'transport:down', ->
    fayeStatus(false)

  client.bind 'transport:up', ->
    fayeStatus(true)

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
    updateMpdInfo()

  # Volume button
  $(document).on "click", 'a.mpd_volume', (e) ->
    $.get '/mpd.json', {vol: $(this).data('volume')}

  # MPD functions!
  clearClass = (selector, klass) ->
    $(selector).each ->
      $(@).removeClass(klass)
    return true

  updateMpdInfo = () ->
    $.get('/mpd.json', (data) ->
      mpdInfo data
    )

  mpdInfo = (data) ->
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
        console.log(url)
        $("body").background url
    else
      $('.alert').show()
      $('.alert-message').html(data['error'])
      $('#mpd-info').html('')

  activeButton = (action) ->
    clearClass('a[data-clear=true]', 'active')
    $('a[data-action='+action+']').addClass('active')

  ###
  On load
  ###

  updateMpdInfo()
