init = (TileField) ->
# -- FPS --------------------------------
#  input = new Input(document, CanvasControl)
#  TODO: сделать дравинг в зависимости от размера экрана
  launch = ->
    new JsonLoader([
      gameScheme.map
    ]).then (jsonResponse) ->

      images = [
        {
          graphics: [
            "../samples/img/game/ground/0-grass.png",
            "../samples/img/game/ground/1-path.png",
            "../samples/img/game/ground/blank-block.png"
          ]
        },
        {
          graphics: [
            "../samples/img/players/main.png"
          ]
        }
      ];

      new ImgLoader(images).then (imgResponse) ->
        #TODO: 20, 20 - эти цифры должны заменится размером раб. области (экран, тач)
        game = new main(0, 0, 40, 20)
#         heightMap:
#           map: jsonResponse[0].height
#           offset: 0
#           heightTile: imgResponse[0].files['ground.png']

        # X & Y drawing position, and tile span to draw - малая карта
        # поменять лаяут на меньшую размерность, и работать отсюда далее 22.11.15 14:34

        game.init [ {
          Title: 'Graphics'
          layout: jsonResponse[0]
          layoutHeight: jsonResponse[0].length
          graphics: imgResponse[0].files
          graphicsDictionary: imgResponse[0].dictionary
          heightMap: {
            offset: 0,
            heightTile: imgResponse[0].files["blank-block.png"]
          },
          heightTile: 64
          tileHeight: gameScheme.tileHeight
          tileWidth: gameScheme.tileWidth
          zeroIsBlank: true
          layoutLevel: 0
          applyInteractions: true
          shadow: {
            offset: 0
            verticalColor: '(5, 5, 30, 0.4)'
            horizontalColor: '(6, 5, 50, 0.5)'
          }
        }]

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
      clickTile = document.createElement('a')
      clickTile.innerHTML += '<img  height=\'50\' width=\'50\' src=\'../../assets/img/Grass/' + tile + '\' />'
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
    layoutLevelObj = document.getElementById('layoutLevel')
    control = new Control()
    CanvasControl = control.getCanvas()


    context = CanvasControl.create('canavas', 920, 600,
      background: '#000022'
      display: 'block'
      marginLeft: 'auto'
      marginRight: 'auto')

    CanvasControl.fullScreen()

    input =  new Input(document, CanvasControl())

    input.mouse_action (coords) ->
      mapLayers.map (layer) ->
        tile_coordinates = layer.applyMouseFocus(coords.x, coords.y)
        # layer.setHeightmapTile(tile_coordinates.x, tile_coordinates.y, layer.getHeightMapTile(tile_coordinates.x, tile_coordinates.y) + 1); // Increase heightmap tile
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
        when 77
          #m - на уровень вверх
          if pressed
            mapLayers.map (layer) ->
              layer.layoutLevelChange 'up'
              layoutLevelObj.innerHTML = layer.getLayoutLevel();
            return
        when 78
          #n - на уровень вниз
          if pressed
            mapLayers.map (layer) ->
              layer.layoutLevelChange 'down'
              layoutLevelObj.innerHTML = layer.getLayoutLevel();
            return
        when 72
          #j - отдалить
          mapLayers.map (layer) ->
            console.log();
            if rangeY + 1 < 25
              layer.setZoom 'out'
              layer.align 'h-center', CanvasControl().width, xrange, -0
              layer.align 'v-center', CanvasControl().height, yrange, 0
              rangeX += 1
              rangeY += 1
            return
        when 74
          #k - приблизить
          console.log();
          mapLayers.map (layer) ->
            if rangeY - 1 > defaultRangeY - 1
              layer.setZoom 'in'
              layer.align 'h-center', CanvasControl().width, xrange, -0
              layer.align 'v-center', CanvasControl().height, yrange, 0
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

    return {
      init: (layers) ->
        i = 0
        while i < 0 + layers.length
          mapLayers[i] = new Field(context, CanvasControl().height, CanvasControl().width)
          mapLayers[i].setup layers[i]
          mapLayers[i].align 'h-center', CanvasControl().width, xrange + startX, 0
          mapLayers[i].align 'v-center', CanvasControl().height, yrange + startY, yrange + startY
          mapLayers[i].setZoom 'in'
          i++
#        console.log(mapLayers);
        draw()
    }


  ##TODO переписать вот эту часть на колбеки, вместо фпса.

  window.requestAnimFrame = do ->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback, element) ->
      window.setTimeout callback, 1000 / 60
      return
  # ---------------------------------------
  # Editor Globals ------------------------
  tileSelection = {}
  # ---------------------------------------
  gameScheme =
    tileHeight: 64
    tileWidth: 128
    map: 'json/mapSmall.json'

  launch()
  return

init()