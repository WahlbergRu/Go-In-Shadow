###**

jsiso/canvas/Input

Simplifies adding multiple input methods
for canvas interaction

**
###
class Input
  constructor: (doc, canvas) ->
    _keyboardInput = (e, callback, pressed) ->
      console.log e
      keyCode = undefined
      if e == null
        keyCode = window.e.keyCode
      else
        keyCode = e.keyCode
      callback keyCode, pressed, e
      return

    _mobileInput = (e, callback, pressed) ->
      coords = {}
      if pressed
        coords.x = e.touches[0].pageX - (canvas.offsetLeft)
        coords.y = e.touches[0].pageY - (canvas.offsetTop)
      callback coords, pressed
      return

    _mouseInput = (e, callback) ->
      coords = {}
      coords.x = e.pageX - (canvas.offsetLeft)
      coords.y = e.pageY - (canvas.offsetTop)
      callback coords
      return

    _orientationChange = (callback) ->
      window.addEventListener 'orientationchange', (->
        callback()
        return
      ), false
      return

    return {
      keyboard: (callback) ->
        # Callback returns 2 paramaters:
        # -- Pressed keycode
        # -- True if button is down / False if button is up

        doc.onkeydown = (event) ->
          _keyboardInput event, callback, true
          return

        doc.onkeyup = (event) ->
          _keyboardInput event, callback, false
          return

        return

      orientationChange: (callback) ->
        # Callback returns if orientation of screen is changed
        _orientationChange callback
        return

      mobile: (callback) ->
        touchendCoords = {}
        # Callback returns when screen is touched and when screen touch ends
        canvas.addEventListener 'touchstart', ((event) ->
          event.preventDefault()
          _mobileInput event, ((coords, pressed) ->
            touchendCoords = coords
            callback coords, pressed
            return
          ), true
          return
        ), false
        canvas.addEventListener 'touchend', (event) ->
          event.preventDefault()
          callback touchendCoords, false
          return
        return

      mouse_action: (callback) ->
        # Callback returns on mouse down
        canvas.addEventListener 'mousedown', ((event) ->
          event.preventDefault()
          _mouseInput event, callback
          return
        ), false
        return

      mouse_move: (callback) ->
        # Callback returns when mouse is moved
        canvas.addEventListener 'mousemove', ((event) ->
          event.preventDefault()
          _mouseInput event, callback
          return
        ), false
        return
    }