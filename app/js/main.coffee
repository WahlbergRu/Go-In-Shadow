control = new Control()
CanvasControl = control.getCanvas()



init = (CanvasControl, CanvasInput, imgLoader, jsonLoader, TileField, pathfind, EffectLoader, utils) ->
  # -- FPS --------------------------------
  #TODO: сделать дравинг в зависимости от размера экрана

  launch = ->
    jsonLoader([
      gameScheme.map
      gameScheme.imageFiles
    ]).then (jsonResponse) ->
      imgLoader([ { graphics: jsonResponse[1].images } ]).then (imgResponse) ->
        game = new main(0, 0, 20, 20)
        # X & Y drawing position, and tile span to draw - малая карта
        # var game = new main(45, 45, 45, 45);// X & Y drawing position, and tile span to draw - большая карта
        game.init [ {
          Title: 'Graphics'
          layout: jsonResponse[0].ground
          graphics: imgResponse[0].files
          graphicsDictionary: imgResponse[0].dictionary
          heightMap:
            map: jsonResponse[0].height
            offset: -80
            heightTile: imgResponse[0].files['ground.png']
          tileHeight: gameScheme.tileHeight
          tileWidth: gameScheme.tileWidth
          zeroIsBlank: true
        } ]
        addTilesToHUD 'Graphics', imgResponse[0].dictionary, 1
        return
      return
    return

  tileChoice = (layer, tile) ->
    tileSelection.title = layer
    tileSelection.value = tile
    return

  #Функция добавления на лаяут других объктов

  addTilesToHUD = (layer, dictionary, offset) ->
    clickTile = undefined
    dictionary.forEach (tile, i) ->
      `var clickTile`
      clickTile = document.createElement('a')
      clickTile.innerHTML += '<img  height=\'50\' width=\'50\' src=\'../img/Grass/' + tile + '\' />'
      document.getElementById('gameInfo').appendChild clickTile
      clickTile.addEventListener 'click', (e) ->
        tileChoice layer, i + offset
        return
      return
    return

  main = (x, y, xrange, yrange) ->
    mapLayers = []
    startY = y
    startX = x
    rangeX = xrange
    rangeY = yrange
    defaultRangeY = rangeY
    context = CanvasControl.create('canavas', 920, 600,
      background: '#000022'
      display: 'block'
      marginLeft: 'auto'
      marginRight: 'auto')

    draw = ->
      context.clearRect 0, 0, CanvasControl().width, CanvasControl().height
      i = startY
      while i < startY + rangeY
        j = startX
        while j < startX + rangeX
          mapLayers.map (layer) ->
            layer.draw i, j
            return
          j++
        i++
      requestAnimFrame draw
      return

    CanvasControl.fullScreen()
    input = new CanvasInput(document, CanvasControl())
    input.mouse_action (coords) ->
      mapLayers.map (layer) ->
        #                                console.log(layer.getHeightMapTile());
        tile_coordinates = layer.applyMouseFocus(coords.x, coords.y)
        # Get the current mouse location from X & Y Coords
        console.log coords
        #layer.setHeightmapTile(tile_coordinates.x, tile_coordinates.y, layer.getHeightMapTile(tile_coordinates.x, tile_coordinates.y) + 1); // Increase heightmap tile
        layer.setTile tile_coordinates.x, tile_coordinates.y, tileSelection.value
        # Force the chaning of tile graphic
        return
      return
    input.mouse_move (coords) ->
      mapLayers.map (layer) ->
        tile_coordinates = layer.applyMouseFocus(coords.x, coords.y)
        # Apply mouse rollover via mouse location X & Y
        return
      return
    input.keyboard (keyCode, pressed, e) ->
      #Светить в консоли кейкод
      console.log keyCode
      switch keyCode
        when 65
          #a - отдалить
          mapLayers.map (layer) ->
            if startY + rangeY + 1 < mapLayers[0].getLayout().length
              layer.setZoom 'out'
              layer.align 'h-center', CanvasControl().width, xrange, -60
              layer.align 'v-center', CanvasControl().height, yrange, 240
              rangeX += 1
              rangeY += 1
            return
        when 83
          #s - приблизить
          mapLayers.map (layer) ->
            if rangeY - 1 > defaultRangeY - 1
              layer.setZoom 'in'
              layer.align 'h-center', CanvasControl().width, xrange, -60
              layer.align 'v-center', CanvasControl().height, yrange, 240
              rangeX -= 1
              rangeY -= 1
            return
        when 49
          # 1 - жми АДЫН
          mapLayers.map (layer) ->
            layer.toggleGraphicsHide true
            layer.toggleHeightShadow true
            return
        when 50
          # 2 - жми два
          mapLayers.map (layer) ->
            layer.toggleGraphicsHide false
            layer.toggleHeightShadow false
            return
        when 66
          if pressed and document.getElementById('gameInfo').style.display != 'none'
            document.getElementById('gameInfo').style.display = 'none'
          else if pressed
            document.getElementById('gameInfo').style.display = 'block'
        when 89
          #Поворот Y, U
          if pressed
            mapLayers.map (layer) ->
              layer.rotate 'left'
              return
        when 85
          #Поворот Y, U
          if pressed
            mapLayers.map (layer) ->
              layer.rotate 'right'
              return
        when 75
          #save на кнопку, пока что-почему-то не работает, но метод лучше оставить. Вдруг пригодится)))
          #в нём чувствуется какая-то будущее нужда на ровне с вебсокетом
          XML = new XMLPopulate
          XML.saveMap 44, mapLayers[0].getLayout(), mapLayers[0].getHeightLayout(), null
        when 39
          #down  - X--
          #left  - Y++
          #up    - Y--
          #right - X++
          if pressed
            mapLayers.map (layer) ->
              console.log layer
              layer.move 'down', gameScheme.tileHeight
              layer.move 'left', gameScheme.tileHeight
              return
            startX--
            startY++
        when 38
          if pressed
            mapLayers.map (layer) ->
              layer.move 'down', gameScheme.tileHeight
              layer.move 'up', gameScheme.tileHeight
              return
            startX--
            startY--
        when 40
          if pressed
            mapLayers.map (layer) ->
              layer.move 'right', gameScheme.tileHeight
              layer.move 'left', gameScheme.tileHeight
              return
            startX++
            startY++
        when 37
          if pressed
            mapLayers.map (layer) ->
              layer.move 'up', gameScheme.tileHeight
              layer.move 'right', gameScheme.tileHeight
              return
            startX++
            startY--
      return

      init: (layers) ->
      i = 0
      while i < 0 + layers.length
        mapLayers[i] = new TileField(context, CanvasControl().height, CanvasControl().width)
        mapLayers[i].setup layers[i]
        mapLayers[i].align 'h-center', CanvasControl().width, xrange + startX, 0
        mapLayers[i].align 'v-center', CanvasControl().height, yrange + startY, yrange + startY
        mapLayers[i].setZoom 'in'
        i++
      draw()
      return


  window.requestAnimFrame = do ->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
      window.setTimeout callback, 1000 / 60
      return
  # ---------------------------------------
  # Editor Globals ------------------------
  tileSelection = {}
  # ---------------------------------------
  gameScheme = 
    tileHeight: 43
    tileWidth: 100
    map: 'mapSmall.json'
    imageFiles: 'imageFiles.json'
  launch()
  return

init(CanvasControl)