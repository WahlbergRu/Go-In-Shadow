define [], ->
  ->
    mapLayers = undefined
    mapWidth = undefined
    mapHeight = undefined
    scaledMapWidth = undefined
    scaledMapHeight = undefined
    tileWidth = undefined
    tileHeight = undefined
    screenWidth = undefined
    screenHeight = undefined
    mapOffsetX = undefined
    mapOffsetY = undefined
    curZoom = undefined
    startX = 0
    startY = 0
    focusX = 0
    focusY = 0
    rangeX = 0
    rangeY = 0
    isometric = false
    xyNextPos = {}
    lockToScreen = false
    # if set to True, tile maps larger than screen will not scroll off screen boundary

    _setup = (layers, mapW, mapH, tileW, tileH, screenW, screenH, curZ, lts) ->
      mapLayers = layers
      mapWidth = mapW
      mapHeight = mapH
      tileWidth = tileW
      tileHeight = tileH
      curZoom = curZ or 1
      screenWidth = screenW
      screenHeight = screenH
      scaledMapWidth = mapWidth / tileW
      scaledMapWidth = scaledMapWidth * tileW * curZoom
      scaledMapHeight = mapHeight / tileW
      scaledMapHeight = scaledMapHeight * tileH * curZoom
      if lts
        lockToScreen = lts
      {
        startX: startX
        startY: startY
        pinFocusX: focusX
        pinFocusY: focusY
      }

    _getXYCoords = (x, y) ->
      positionY = undefined
      positionX = undefined
      if !isometric
        positionY = Math.round((y - (tileHeight * curZoom / 2)) / (tileHeight * curZoom))
        positionX = Math.round((x - (tileWidth * curZoom / 2)) / (tileWidth * curZoom))
      else
        positionY = (2 * (y - mapOffsetY) - x + mapOffsetX) / 2
        positionX = x + positionY - mapOffsetX - (tileHeight * curZoom)
        positionY = Math.round(positionY / (tileHeight * curZoom))
        positionX = Math.round(positionX / (tileHeight * curZoom))
      {
        x: positionX
        y: positionY
      }

    _setFocus = (posX, posY, cameraRangeX, cameraRangeY, setZoom) ->
      xyMapOffset = undefined
      i = undefined
      if setZoom != undefined
        curZoom = setZoom
        scaledMapWidth = mapWidth / tileWidth
        scaledMapWidth = scaledMapWidth * tileWidth * curZoom
        scaledMapHeight = mapHeight / tileHeight
        scaledMapHeight = scaledMapHeight * tileHeight * curZoom
        screenHeight = Math.round(window.innerHeight / (tileHeight * curZoom))
        screenWidth = Math.round(window.innerWidth / (tileWidth * curZoom))
      rangeX = cameraRangeX or rangeX
      rangeY = cameraRangeY or rangeY
      startX = Math.round(posX - (screenWidth / 2))
      startY = Math.round(posY - (screenHeight / 2))
      if !lockToScreen
        if startX < 0
          startX = 0
        if startY < 0
          startY = 0
      if screenHeight * tileHeight > scaledMapHeight
        i = 0
        while i < mapLayers.length
          mapLayers[i].setOffset null, Math.round(screenHeight * tileHeight * curZoom / 2 - (scaledMapHeight / 2))
          i++
      else
        i = 0
        while i < mapLayers.length
          if startY < 0
            mapLayers[i].setOffset null, Math.round(-(tileHeight * curZoom) * posY + posY * tileHeight * curZoom)
          else
            if lockToScreen and startY + screenHeight > scaledMapHeight / tileHeight
              mapLayers[i].setOffset null, -(Math.round(scaledMapHeight / tileHeight) - screenHeight) * tileHeight + tileHeight
            else
              mapLayers[i].setOffset null, Math.round(-(tileHeight * curZoom) * posY + screenHeight / 2 * tileHeight * curZoom)
          i++
      if screenWidth * tileWidth > scaledMapWidth
        i = 0
        while i < mapLayers.length
          mapLayers[i].setOffset Math.round(screenWidth * tileWidth * curZoom / 2 - (scaledMapWidth / 2)), null
          i++
      else
        i = 0
        while i < mapLayers.length
          if startX < 0
            mapLayers[i].setOffset Math.floor(screenWidth * tileWidth * curZoom / 2 - (scaledMapWidth / 2)), null
          else
            if lockToScreen and startX + screenWidth > scaledMapWidth / tileWidth
              mapLayers[i].setOffset -(Math.floor(scaledMapWidth / tileWidth) - screenWidth) * tileWidth, null
            else
              mapLayers[i].setOffset Math.round(-(tileWidth * curZoom) * posX + screenWidth / 2 * tileWidth * curZoom), null
          i++
      xyMapOffset = mapLayers[0].getOffset()
      focusX = posX * curZoom * tileWidth + xyMapOffset.x
      focusY = posY * curZoom * tileHeight + xyMapOffset.y
      xyNextPos = _getXYCoords(focusX - (xyMapOffset.x), focusY - (xyMapOffset.y))
      startXNew = Math.floor(xyNextPos.x - (rangeX / 2))
      startYNew = Math.floor(xyNextPos.y - (rangeY / 2))
      if !lockToScreen
        if startXNew < 0
          startXNew = 0
        if startYNew < 0
          startYNew = 0

      ###if (startXNew + screenWidth > scaledMapWidth / (tileWidth * curZoom)) {
        startXNew = scaledMapWidth / (tileWidth * curZoom) - screenWidth;
      }
      if (startYNew + screenHeight > scaledMapHeight / (tileHeight * curZoom)) {
        startYNew = scaledMapHeight / (tileHeight * curZoom) - screenHeight;
      }
      ###

      {
        startX: startXNew
        startY: startYNew
        pinFocusX: Math.floor(focusX)
        pinFocusY: Math.floor(focusY)
        tileX: Math.floor(posX)
        tileY: Math.floor(posY)
      }

    # direction: "up", "down", "left", "right" - distance: int

    _move = (direction, distance) ->
      xyMapOffset = mapLayers[0].getOffset()
      xyNextPos = _getXYCoords(focusX - (xyMapOffset.x), focusY - (xyMapOffset.y))
      console.log xyNextPos
      switch direction
        when 'up'
          if !lockToScreen or lockToScreen and xyNextPos.y - 1 <= startY + screenHeight / 2 and focusY < screenHeight / 2 * tileHeight and xyMapOffset.y <= 0
            i = 0
            while i < mapLayers.length
              mapLayers[i].move 'up', distance
              i++
          else
            focusY -= distance
        when 'down'
          if !lockToScreen or lockToScreen and xyNextPos.y >= screenHeight / 2 and focusY > screenHeight / 2 * tileHeight and xyMapOffset.y >= -mapHeight + tileHeight + focusY + screenHeight / 2 * tileHeight
            i = 0
            while i < mapLayers.length
              mapLayers[i].move 'down', distance
              i++
          else
            focusY += distance
        when 'left'
          if !lockToScreen or lockToScreen and xyNextPos.x - 1 <= startX + screenWidth / 2 and focusX < screenWidth / 2 * tileWidth and xyMapOffset.x <= 0
            i = 0
            while i < mapLayers.length
              mapLayers[i].move 'left', distance
              i++
          else
            focusX -= distance
        when 'right'
          if !lockToScreen or lockToScreen and xyNextPos.x >= screenWidth / 2 and xyMapOffset.x >= -mapWidth + focusX + screenWidth / 2 * tileWidth
            i = 0
            while i < mapLayers.length
              mapLayers[i].move 'right', distance
              i++
          else
            focusX += distance
      startX = xyNextPos.x - (rangeX / 2)
      startY = xyNextPos.y - (rangeY / 2)
      {
        startX: Math.floor(startX)
        startY: Math.floor(startY)
        pinFocusX: Math.floor(focusX)
        pinFocusY: Math.floor(focusY)
        tileX: Math.floor(xyNextPos.x)
        tileY: Math.floor(xyNextPos.y)
      }
      # Returns where to start drawing the tiles from.
      # pinFocus represents a precise location withn the map.

    {
      setup: (mapLayers, mapWidth, mapHeight, tileWidth, tileHeight, screenWidth, screenHeight, curZoom, lockToScreen) ->
        _setup mapLayers, mapWidth, mapHeight, tileWidth, tileHeight, screenWidth, screenHeight, curZoom, lockToScreen
      setFocus: (posX, posY, rangeX, rangeY, setZoom) ->
        _setFocus posX, posY, rangeX, rangeY, setZoom
      setPinFocusY: (y) ->
        focusY = y
        {
          startX: Math.floor(startX)
          startY: Math.floor(startY)
          pinFocusX: focusX
          pinFocusY: focusY
          tileX: Math.floor(xyNextPos.x)
          tileY: Math.floor(xyNextPos.y)
        }
      setPinFocusX: (x) ->
        focusX = x
        {
          startX: Math.floor(startX)
          startY: Math.floor(startY)
          pinFocusX: focusX
          pinFocusY: focusY
          tileX: Math.floor(xyNextPos.x)
          tileY: Math.floor(xyNextPos.y)
        }
      getFocus: ->
        {
          startX: Math.floor(startX)
          startY: Math.floor(startY)
          pinFocusX: focusX
          pinFocusY: focusY
          tileX: Math.floor(xyNextPos.x)
          tileY: Math.floor(xyNextPos.y)
        }
      move: (direction, distance, setZoom) ->
        _move direction, distance, setZoom

    }
