#18.10.15 ��������� ������
define ->
  # Private properties for Control
  canvasElement = null
  width = null
  height = null
  # ----
  # -- Public properties for Control
  # ----

  ###*
  # Checks if browser supports the canvas context 2d
  # @return {Boolean}
  ###

  _supported = ->
    elem = document.createElement('canvas')
    ! !(elem.getContext and elem.getContext('2d'))

  _getRatio = ->
    ctx = document.createElement('canvas').getContext('2d')
    dpr = window.devicePixelRatio or 1
    bsr = ctx.webkitBackingStorePixelRatio or ctx.mozBackingStorePixelRatio or ctx.msBackingStorePixelRatio or ctx.oBackingStorePixelRatio or ctx.backingStorePixelRatio or 1
    dpr / bsr

  _create = (name, w, h, style, element, usePixelRatio) ->
    pxRatio = 1
    canvasType = null
    if _supported()
      if usePixelRatio
        pxRatio = _getRatio()
      width = w
      height = h
      canvasElement = document.createElement('canvas')
      canvasElement.id = name
      canvasElement.tabindex = '1'
      for s of style
        canvasElement.style[s] = style[s]
      canvasType = '2d'
      canvasElement.style.width = w + 'px'
      canvasElement.style.height = h + 'px'
      canvasElement.width = w * pxRatio or window.innerWidth
      canvasElement.height = h * pxRatio or window.innerHeight
      canvasElement.getContext(canvasType).setTransform pxRatio, 0, 0, pxRatio, 0, 0
      if !element
        # Append Canvas into document body
        document.body.appendChild(canvasElement).getContext canvasType
      else
        # Place canvas into passed through body element
        document.getElementById(element).appendChild(canvasElement).getContext canvasType
    else
      # Create an HTML element displaying that Canvas is not supported :(
      noCanvas = document.createElement('div')
      noCanvas.style.color = '#FFF'
      noCanvas.style.textAlign = 'center'
      noCanvas.innerHTML = 'Sorry, you need to use a more modern browser. We like: <a href=\'https://www.google.com/intl/en/chrome/browser/\'>Chrome</a> &amp; <a href=\'http://www.mozilla.org/en-US/firefox/new/\'>Firefox</a>'
      document.body.appendChild noCanvas

  _style = (setting, value) ->
    canvasElement.style[setting] = value
    return

  ###*
  * Fullscreens the Canvas object
  ###

  _fullScreen = ->
    document.body.style.margin = '0'
    document.body.style.padding = '0'
    document.body.style.overflow = 'hidden'
    canvasElement.style.width = window.innerWidth + 'px'
    canvasElement.style.height = window.innerHeight + 'px'
    canvasElement.height = window.innerHeight
    canvasElement.width = window.innerWidth
    canvasElement.style.position = 'absolute'
    canvasElement.style.zIndex = 100

    window.onresize = (e) ->
      _update 0, 0
      #I think we need a repaint here.
      return

    window.top.scrollTo 0, 1
    return

  ###*
  * Update the Canvas object dimensions
  * @param {Number} width
  * @param {Number} height
  ###

  _update = (w, h) ->
    pxRatio = 1
    canvasElement.width = w + 'px' or window.innerWidth
    canvasElement.height = h + 'px' or window.innerHeight
    canvasElement.style.width = window.innerWidth + 'px'
    canvasElement.style.height = window.innerHeight + 'px'
    canvasElement.width = w * pxRatio or window.innerWidth
    canvasElement.height = h * pxRatio or window.innerHeight
    return

  ###*
  * Return the created HTML Canvas element when it is called directly
  * @return {HTML} Canvas element
  ###

  canvas = ->
    canvasElement

  canvas.create = _create
  canvas.fullScreen = _fullScreen
  canvas.update = _update
  canvas.style = _style
  # Return Canvas Object
  canvas
