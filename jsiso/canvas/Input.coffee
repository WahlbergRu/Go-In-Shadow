#18.10.15 ��-����� ��� ����������. ���� ��� ����� ������ �����

###**

jsiso/canvas/Input

Simplifies adding multiple input methods
for canvas interaction

**
###

define ->
  # Return Input Class
  (doc, canvas) ->
    # ----
    # -- Public properties for Input
    # ----
    # Private properties for Input

    ###*
    * Used for getting keyboard interaction keycodes
    * @param {Event} Event
    * @param {Function} Callback function
    * @param {Boolean} If the key is down or up
    * @return {Function} callback({Number} keycode, {Boolean} pressed)
    ###

    _keyboardInput = (e, callback, pressed) ->
      console.log e
      keyCode = undefined
      if e == null
        keyCode = window.e.keyCode
      else
        keyCode = e.keyCode
      callback keyCode, pressed, e
      return

    ###*
    * Used for getting touch screen coordinates
    * @param {Event} Event
    * @param {Function} Callback function
    * @param {Boolean} If the screen is being touched
    * @return {Function} callback({Object} X & Y touch coordinates, {Boolean} pressed)
    ###

    _mobileInput = (e, callback, pressed) ->
      coords = {}
      if pressed
        coords.x = e.touches[0].pageX - (canvas.offsetLeft)
        coords.y = e.touches[0].pageY - (canvas.offsetTop)
      callback coords, pressed
      return

    ###*
    * Used for getting mouse click coordinates
    * @param {Event} Event
    * @param {Function} Callback function
    * @return {Function} callback({Object} X & Y mouse coordinates)
    ###

    _mouseInput = (e, callback) ->
      coords = {}
      coords.x = e.pageX - (canvas.offsetLeft)
      coords.y = e.pageY - (canvas.offsetTop)
      callback coords
      return

    ###*
    * Performs the callback function when screen orientation change is detected
    * @param {Function} Callback function
    * @return {Function} callback()
    ###

    _orientationChange = (callback) ->
      window.addEventListener 'orientationchange', (->
        callback()
        return
      ), false
      return

    {
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
