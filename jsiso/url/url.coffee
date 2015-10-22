url = ->

  @_path = (part) ->
    `var url`
    url = window.location.href
    url_parts = url.split('/')
    url_parts[part + 3]

  return
