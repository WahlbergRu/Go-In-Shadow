#(EffectLoader, Emitter, utils) ->


class Field
  constructor:(ctx, mapWidth, mapHeight, mapLayout) ->
    #class
    utils = new Utils()
    emitter = new Emitter()
    effectLoader = new EffectLoader()
    globalI = 0
    globalJ = 0
    globalK = 0
    title = ''
    zeroIsBlank = false
    stackTiles = false
    stackTileGraphic = null
    drawX = 0
    drawY = 0
    tileHeight = 0
    tileWidth = 0
    heightMap = null
    layoutHeight = null
    layoutLevel = null
    lightMap = null
    lightX = null
    lightY = null
    heightOffset = 0
    heightShadows = null
    shadowSettings = null
    shadowDistance = null
    heightMapOnTop = false
    particleEffects = null
    curZoom = 1
    mouseUsed = false
    applyInteractions = false
    focusTilePosX = 0
    focusTilePosY = 0
    alphaWhenFocusBehind = {}
    # Used for applying alpha to objects infront of focus 
    tilesHide = null
    hideSettings = null
    particleTiles = null
    particleMap = []
    particleMapHolder = []
    isometric = true
    tileImages = []
    tileImagesDictionary = []

    _setup = (settings) ->
      tileWidth = settings.tileWidth
      tileHeight = settings.tileHeight
      lightMap = settings.lightMap
      shadowDistance = settings.shadowDistance
      title = settings.title
      layoutLevel = settings.layoutLevel
      zeroIsBlank = settings.zeroIsBlank
      applyInteractions = settings.applyInteractions
      if settings.particleMap
        _particleTiles settings.particleMap
      if settings.layout
        mapLayout = settings.layout
      if settings.layoutHeight
        layoutHeight = settings.layoutHeight
      if settings.graphics
        tileImages = settings.graphics
      if settings.graphicsDictionary
        tileImagesDictionary = settings.graphicsDictionary
      if settings.isometric != undefined
        isometric = settings.isometric
      if settings.shadow
        _applyHeightShadow true, settings.shadow
      if settings.heightTile
        _stackTiles settings.heightTile
      if settings.particleEffects
        particleEffects = settings.particleEffects


      if settings.width
        row = []
        col = 0
        mapLayout = []
        i = 0
        while i < settings.layout.length
          col++
          if col != settings.width
            row.push settings.layout[i]
          else
            row.push settings.layout[i]
            mapLayout.push row
            row = []
            col = 0
          i++
      alphaWhenFocusBehind = settings.alphaWhenFocusBehind
      return

    #Used for drawing horizontal shadows on top of tiles or RGBA tiles when color value is passed
    #Отрисовка на взаимодействие с мышкой

    #TODO: дописать отрисовку при приближение и отдаление, либо убрать отдаление и приближение вообще

    _drawHorizontalColorOverlay = (xpos, ypos, graphicValue, stack, resizedTileHeight) ->
      if !isometric
        ctx.fillStyle = 'rgba' + graphicValue
        ctx.beginPath()
        ctx.moveTo xpos, ypos
        ctx.lineTo xpos + tileWidth * curZoom, ypos
        ctx.lineTo xpos + tileWidth * curZoom, ypos + tileHeight * curZoom
        ctx.lineTo xpos, ypos + tileHeight * curZoom
        ctx.fill()
      else
        tileOffset = undefined

        if tileHeight < resizedTileHeight
          tileOffset = (tileHeight - resizedTileHeight) * curZoom
        else
          tileOffset = (resizedTileHeight - tileHeight) * curZoom

        ctx.fillStyle = 'rgba' + graphicValue
        ctx.beginPath()
        ctx.moveTo xpos,                              ypos + (stack - 1) * tileOffset + tileHeight * curZoom / 2
        ctx.lineTo xpos + tileHeight * curZoom,       ypos + (stack - 1) * tileOffset
        ctx.lineTo xpos + tileHeight * curZoom * 2,   ypos + (stack - 1) * tileOffset + tileHeight * curZoom / 2
        ctx.lineTo xpos + tileHeight * curZoom,       ypos + (stack - 1) * tileOffset + tileHeight * curZoom
        ctx.fill()

      return

    # Used for drawing vertical shadows on top of tiles in isometric view if switched on
    # Используется для рисования вертикальных теней на элементе сетки в изометрическом вьюме, если вклчючена

    _drawVeritcalColorOverlay = (shadowXpos, shadowYpos, graphicValue, currStack, resizedTileHeight, direction) ->
      ctx.fillStyle = 'rgba' + graphicValue
      #      ctx.moveTo xpos, ypos
      #      ctx.lineTo xpos + tileWidth * curZoom, ypos
      #      ctx.lineTo xpos + tileWidth * curZoom, ypos + tileHeight * curZoom
      #      ctx.lineTo xpos, ypos + tileHeight * curZoom
      tileOffset = undefined

      if tileHeight < resizedTileHeight
        tileOffset = (tileHeight - resizedTileHeight) * curZoom
      else
        tileOffset = (resizedTileHeight - tileHeight) * curZoom

      #Work tut

      if direction == 'FromLeftToBottom'
        ctx.beginPath()
        ctx.moveTo shadowXpos,                                shadowYpos + (currStack - 1) * tileOffset + tileHeight * curZoom / 2
        ctx.lineTo shadowXpos + tileHeight * curZoom,         shadowYpos + (currStack - 2) * tileOffset
        ctx.lineTo shadowXpos + tileHeight * curZoom,         shadowYpos + (currStack - 2) * tileOffset + tileHeight * curZoom
        ctx.lineTo shadowXpos,                                shadowYpos + (currStack - 2) * tileOffset + tileHeight * curZoom / 2
        ctx.fill()
        return
      else if direction == 'FromBottomToRight'
        ctx.beginPath()
        ctx.moveTo shadowXpos + tileHeight * curZoom * 2,     shadowYpos + (currStack - 1) * tileOffset + tileHeight * curZoom / 2
        ctx.lineTo shadowXpos + tileHeight * curZoom ,        shadowYpos + (currStack - 2) * tileOffset
        ctx.lineTo shadowXpos + tileHeight * curZoom ,        shadowYpos + (currStack - 2) * tileOffset + tileHeight * curZoom
        ctx.lineTo shadowXpos + tileHeight * curZoom * 2,     shadowYpos + (currStack - 2) * tileOffset + tileHeight * curZoom / 2
        ctx.fill()
        return

    # Used for drawing particle effects applied to tiles

    _drawParticles = (xpos, ypos, i, j, stack, distanceLighting, distanceLightingSettings, resizedTileHeight) ->
      if particleMap[i] and particleMap[i][j] != undefined and Number(particleMap[i][j]) != 0
        if !distanceLightingSettings or distanceLightingSettings and distanceLighting < distanceLightingSettings.darkness
          if !particleMapHolder[i]
            particleMapHolder[i] = []
          if !particleMapHolder[i][j]
            if particleEffects and particleEffects[particleMap[i][j]]
              particleMapHolder[i][j] = new emitter(ctx, 0, 0, particleEffects[particleMap[i][j]].pcount, particleEffects[particleMap[i][j]].loop, utils.range(0, mapHeight), utils.range(0, mapWidth))
              for partK of particleEffects[particleMap[i][j]]
                particleMapHolder[i][j][partK] = particleEffects[particleMap[i][j]][partK]
              particleMapHolder[i][j].Load()
            else
              particleMapHolder[i][j] = (new effectLoader).getEffect(particleMap[i][j], ctx, utils.range(0, mapHeight), utils.range(0, mapWidth))
          particleMapHolder[i][j].Draw xpos, ypos + (stack - 1) * (tileHeight - heightOffset - tileHeight) * curZoom - ((resizedTileHeight - tileHeight) * curZoom), curZoom
      return


    #Отрисовка основного грида
    _draw = (i, j) ->

      xpos = undefined
      ypos = undefined
      i = Math.round(i)
      j = Math.round(j)

      #При невыполнимых условиях заканчивается сразу
      if i < 0
        return
      if j < 0
        return
      if i > mapLayout[layoutLevel].length - 1
        return
      if mapLayout[layoutLevel][i] and j > mapLayout[layoutLevel][i].length - 1
        return

      #какие-то условия
      resizedTileHeight = undefined
      stackGraphic = null

      #с высотой работать тут
      stack = 0
      while (layoutLevel+stack<layoutHeight)
        if mapLayout[layoutLevel+stack][i] and mapLayout[layoutLevel+stack][i][j] == 0
          stack++
        else
          break

      if mapLayout[layoutLevel+stack][i]
        graphicValue = mapLayout[layoutLevel+stack][i][j]

      distanceLighting = null
      distanceLightingSettings = undefined
      k = 0


      if shadowDistance
        distanceLightingSettings =
          distance: shadowDistance.distance
          darkness: shadowDistance.darkness
          color: shadowDistance.color
        distanceLighting = Math.sqrt(Math.round(i - lightX) * Math.round(i - lightX) + Math.round(j - lightY) * Math.round(j - lightY))

        if lightMap
          lightDist = 0
          lightI = undefined
          lightJ = undefined
          # Calculate which light source is closest
          light = 0

          while light < lightMap.length
            lightI = Math.round(i - (lightMap[light][0]))
            lightJ = Math.round(j - (lightMap[light][1]))
            lightDist = Math.sqrt(lightI * lightI + lightJ * lightJ)

            if distanceLighting / (distanceLightingSettings.darkness * distanceLightingSettings.distance) > lightDist / (lightMap[light][2] * lightMap[light][3])
              distanceLighting = lightDist
              distanceLightingSettings.distance = lightMap[light][2]
              distanceLightingSettings.darkness = lightMap[light][3]
            light++

        if distanceLighting > distanceLightingSettings.distance
          distanceLighting = distanceLightingSettings.distance

        distanceLighting = distanceLighting / (distanceLightingSettings.darkness * distanceLightingSettings.distance)

      if graphicValue
        if zeroIsBlank
          if Number(graphicValue) >= 0
            graphicValue--

        if tilesHide and graphicValue >= hideSettings.hideStart and graphicValue <= hideSettings.hideEnd
          stackGraphic = tileImages[hideSettings.planeGraphic]
        else
          if stackTileGraphic
            stackGraphic = stackTileGraphic
          else
            if Number(graphicValue) >= 0
              stackGraphic = tileImages[tileImagesDictionary[graphicValue]]
            else
              stackGraphic = undefined

        resizedTileHeight = 0


        if stackGraphic
          resizedTileHeight = stackGraphic.height / (stackGraphic.width / tileWidth)

        if !isometric
          xpos = i * tileHeight * curZoom + drawX
          ypos = j * tileWidth * curZoom + drawY
        else
          xpos = (i - j) * tileHeight * curZoom + drawX
          ypos = (i + j) * tileWidth / 4 * curZoom + drawY

        # If no heightmap for this tile
        if !distanceLightingSettings or distanceLightingSettings and distanceLighting < distanceLightingSettings.darkness
          # Draw the tile image
          ctx.save()
          # TODO: разобраться с alphaWhenFocusBehind
          #            if alphaWhenFocusBehind and alphaWhenFocusBehind.apply == true
          #              if i == focusTilePosX + 1 and j == focusTilePosY + 1 or i == focusTilePosX and j == focusTilePosY + 1 or i == focusTilePosX + 1 and j == focusTilePosY
          #                if alphaWhenFocusBehind.objectApplied and (alphaWhenFocusBehind.objectApplied == null or alphaWhenFocusBehind.objectApplied and resizedTileHeight * curZoom > alphaWhenFocusBehind.objectApplied.height * curZoom)
          #                  ctx.globalAlpha = 0.6
          #          stack = layoutHeight
          # TODO: сделать отрисовку разных уровней
          # tileImages - тайлы из imageFiles
          # layoutLevel - подставить для смены уровня
          # console.log(layoutLevel)

          if Number(graphicValue) >= 0
            # tile has a graphic ID
            # img_elem,dx_or_sx,dy_or_sy,dw_or_sw,dh_or_sh,dx,dy,dw,dh
            if stackGraphic != undefined
              img_elem = stackGraphic
              sx = 0
              sy = 0
              sw = stackGraphic.width
              sh = stackGraphic.height
              dx = xpos
              dw = tileWidth * curZoom
              dh = resizedTileHeight * curZoom
              dy = ypos + ((stack+1) * heightOffset - (resizedTileHeight - tileHeight)) * curZoom

              n=layoutHeight-stack
              while (n>=0)
                dy = ypos + ((layoutHeight+layoutLevel+1) * heightOffset - (resizedTileHeight - tileHeight)) * curZoom
                ctx.drawImage img_elem, sx, sy, sw, sh, dx, dy, dw, dh
                n--

              # Apply mouse over tile coloring
              if mouseUsed and applyInteractions
                if i == focusTilePosX and j == focusTilePosY
                  _drawHorizontalColorOverlay xpos, ypos, '(255, 255, 120, 0.4)', -stack+1, resizedTileHeight


          else if graphicValue != -1

            # tile is an RGBA value
            img_elem = stackGraphic
            dx = xpos
            dy = ypos + ((stack+1) * heightOffset - (resizedTileHeight - tileHeight)) * curZoom

            n=layoutHeight-stack

            #TODO: построить отрисовку стенок с помощью теней
            _drawHorizontalColorOverlay dx, dy, graphicValue, layoutHeight+layoutLevel, resizedTileHeight

            if mouseUsed and applyInteractions
              if i == focusTilePosX and j == focusTilePosY
                _drawHorizontalColorOverlay dx, dy, '(255, 255, 120, 0.4)', layoutHeight+layoutLevel, resizedTileHeight

            while (n>=0)
              _drawVeritcalColorOverlay dx, dy, '(50, 50, 150, 1)', n+stack+layoutLevel, resizedTileHeight, 'FromLeftToBottom'
              _drawVeritcalColorOverlay dx, dy, '(50, 50, 100, 1)', n+stack+layoutLevel, resizedTileHeight, 'FromBottomToRight'
              n--

#        else
#          if heightMapOnTop
#            # If tile is to be placed on top of heightmap
#            if !distanceLightingSettings or distanceLightingSettings and distanceLighting < distanceLightingSettings.darkness
#              if tileImageOverwite
#                # Draw overwriting image on top of height map
#                ctx.drawImage tileImageOverwite, 0, 0, tileImageOverwite.width, tileImageOverwite.height, xpos, ypos + (stack - 1) * (tileHeight - heightOffset - tileHeight) * curZoom - ((resizedTileHeight - tileHeight) * curZoom), tileWidth * curZoom, resizedTileHeight * curZoom
#              else
#                # Draw the tile image on top of height map
#                if Number(graphicValue) >= 0
#                  ctx.save()
#                  if alphaWhenFocusBehind and alphaWhenFocusBehind.apply == true
#                    if i == focusTilePosX + 1 and j == focusTilePosY + 1 or i == focusTilePosX and j == focusTilePosY + 1 or i == focusTilePosX + 1 and j == focusTilePosY
#                      if alphaWhenFocusBehind.objectApplied and (alphaWhenFocusBehind.objectApplied == null or alphaWhenFocusBehind.objectApplied and resizedTileHeight * curZoom > alphaWhenFocusBehind.objectApplied.height * curZoom)
#                        ctx.globalAlpha = 0.6
#                  ctx.drawImage stackGraphic, 0, 0, stackGraphic.width, stackGraphic.height, xpos, ypos + (stack - 1) * (tileHeight - heightOffset - tileHeight) * curZoom - ((resizedTileHeight - tileHeight) * curZoom), tileWidth * curZoom, resizedTileHeight * curZoom
#                  ctx.restore()
#                else if graphicValue != -1
#                  _drawHorizontalColorOverlay xpos, ypos, graphicValue, stack, resizedTileHeight
#          else
#           If tile is to be repeated for heightmap
#          k = 0
#          while k <= stack
#            if !distanceLightingSettings or distanceLightingSettings and distanceLighting < distanceLightingSettings.darkness
#              if tileImageOverwite
#                # If there is an overwrite image
#                ctx.drawImage tileImageOverwite, 0, 0, tileImageOverwite.width, tileImageOverwite.height, xpos, ypos + k * (tileHeight - heightOffset - resizedTileHeight) * curZoom, tileWidth * curZoom, resizedTileHeight * curZoom
#              else
#                if stackTileGraphic
#                  if k != stack
#                    # Repeat tile graphic till it's reach heightmap max
#                    if stackGraphic
#                      ctx.drawImage stackGraphic, 0, 0, stackGraphic.width, stackGraphic.height, xpos, ypos + k * (tileHeight - heightOffset - resizedTileHeight) * curZoom, tileWidth * curZoom, resizedTileHeight * curZoom
#                  else
#                    if Number(graphicValue) >= 0
#                      # reset stackGraphic
#                      stackGraphic = tileImages[tileImagesDictionary[graphicValue]]
#                      ctx.drawImage stackGraphic, 0, 0, stackGraphic.width, stackGraphic.height, xpos, ypos + (k - 1) * (tileHeight - heightOffset - resizedTileHeight) * curZoom, tileWidth * curZoom, stackGraphic.height / (stackGraphic.width / tileWidth) * curZoom
#                    else if graphicValue != -1
#                      _drawHorizontalColorOverlay xpos, ypos, graphicValue, k, resizedTileHeight
#                else
#                  # No stack graphic specified so draw tile at top
#                  if k == stack
#                    if Number(graphicValue) >= 0
#                      ctx.drawImage stackGraphic, 0, 0, stackGraphic.width, stackGraphic.height, xpos, ypos + k * (tileHeight - heightOffset - resizedTileHeight) * curZoom, tileWidth * curZoom, resizedTileHeight * curZoom
#                    else if graphicValue != -1
#                      _drawHorizontalColorOverlay xpos, ypos, graphicValue, stack, resizedTileHeight
#                  else
#                    ctx.drawImage stackGraphic, 0, 0, stackGraphic.width, stackGraphic.height, xpos, ypos + k * (tileHeight - heightOffset - resizedTileHeight) * curZoom, tileWidth * curZoom, resizedTileHeight * curZoom
#            k++

      if heightShadows
        nextStack = 0
        currStack = 0
        shadowXpos = 0
        shadowYpos = 0
        if mapLayout
          nextStack = Math.round(Number(mapLayout[layoutHeight+layoutLevel][i][j - 1]))
          currStack = Math.round(Number(mapLayout[layoutHeight+layoutLevel][i][j - 1]))
          if currStack < nextStack
            shadowXpos = (i - j) * tileHeight * curZoom + drawX
            shadowYpos = (i + j) * tileWidth / 4 * curZoom + drawY
            # Apply Horizontal shadow created from stacked tiles
            if shadowSettings.horizontalColor
              if !distanceLightingSettings or distanceLighting < distanceLightingSettings.darkness
                _drawHorizontalColorOverlay shadowXpos, shadowYpos, (if typeof shadowSettings.verticalColor == 'string' then shadowSettings.verticalColor else shadowSettings.verticalColor[i][j]), currStack, resizedTileHeight
            # Apply Vertical shadow created from stacked tiles
            if shadowSettings.verticalColor
              if !distanceLightingSettings or distanceLighting < distanceLightingSettings.darkness
                _drawVeritcalColorOverlay shadowXpos, shadowYpos, (if typeof shadowSettings.horizontalColor == 'string' then shadowSettings.horizontalColor else shadowSettings.horizontalColor[i][j]), currStack, nextStack, resizedTileHeight, shadowSettings
        else
          # Shadows without height map e.g. Object Shadows
          currStack = Math.round(Number(mapLayout[i][j - 1]))
          if currStack > 0
            shadowXpos = (i - j) * tileHeight * curZoom + drawX
            shadowYpos = (i + j) * tileWidth / 4 * curZoom + drawY
            _drawHorizontalColorOverlay shadowXpos, shadowYpos, (if typeof shadowSettings.verticalColor == 'string' then shadowSettings.verticalColor else shadowSettings.verticalColor[i][j]), k, resizedTileHeight
      if distanceLightingSettings
        if distanceLightingSettings.color != false
          --k
          if distanceLighting < distanceLightingSettings.darkness
            # Apply distance shadows from light source
            if stackGraphic != undefined or zeroIsBlank and stackGraphic != 0
              _drawHorizontalColorOverlay xpos, ypos, '(' + distanceLightingSettings.color + ',' + distanceLighting + ')', k, resizedTileHeight
      ctx.restore()

      if particleTiles
        # Draw Particles
        _drawParticles xpos, ypos, i, j, k, distanceLighting, distanceLightingSettings, resizedTileHeight
      return

    _stackTiles = (heightTile) ->
      heightOffset = heightTile
      return

    _particleTiles = (map) ->
      particleTiles = true
      particleMap = map
      return

    _setLight = (posX, posY) ->
      lightX = posX
      lightY = posY
      return

    _getLayout = ->
      mapLayout

    _setLayout = (data, width) ->
      if width
        row = []
        col = 0
        mapLayout = []
        i = 0
        while i < data.length
          col++
          if col != width
            row.push data[i]
          else
            row.push data[i]
            mapLayout.push row
            row = []
            col = 0
          i++
      else
        mapLayout = data
      return

    _getHeightLayout = ->
      heightMap

    _getTile = (posX, posY) ->
      if mapLayout[posX] and mapLayout[posX][posY]
        return mapLayout[posX][posY]
      null

    _getHeightMapTile = (posX, posY) ->

#      console.log(_getTile[posX][posY])

    _setZoom = (dir) ->
      if Number(dir)
        curZoom = dir
      else if dir == 'in'
        if curZoom + 0.1 <= 1
          curZoom += 0.1
        else
          curZoom = 1
      else if dir == 'out'
        if curZoom - 0.1 > 0.1
          curZoom -= 0.1
        else
          curZoom = 0.1
      return

    _layoutLevelChange = (direction) ->
      if direction == 'up'
        layoutLevel++
      else if direction == 'down'
        layoutLevel--

    _setLayoutLevel = (level) ->
      layoutLevel = level

    _adjustLight = (setting, increase) ->
      if increase
        shadowDistance.distance += setting
      else
        shadowDistance.distance -= setting
      return

    _getTilePos = (x, y) ->
      xpos = undefined
      ypos = undefined
      if !isometric
        xpos = x * tileHeight * curZoom + drawX
        ypos = y * tileWidth * curZoom + drawY
      else
        xpos = (x - y) * tileHeight * curZoom + drawX
        ypos = (x + y) * tileWidth / 4 * curZoom + drawY
      {
        x: xpos
        y: ypos
      }

    _getXYCoords = (x, y) ->
      positionY = undefined
      positionX = undefined
      if !isometric
        positionY = Math.round((y - (tileWidth * curZoom / 2)) / (tileWidth * curZoom))
        positionX = Math.round((x - (tileHeight * curZoom / 2)) / (tileHeight * curZoom))
      else
        positionY = (2 * (y - drawY) - x + drawX) / 2
        positionX = x + positionY - drawX - (tileHeight * curZoom)
        positionY = Math.round(positionY / (tileHeight * curZoom))
        positionX = Math.round(positionX / (tileHeight * curZoom))
      {
        x: positionX
        y: positionY
      }



    #принимает значения мышки
    _applyMouseFocus = (x, y) ->
      mouseUsed = true
      if !isometric
        focusTilePosY = Math.round((y - (tileWidth * curZoom / 2)) / (tileWidth * curZoom))
        focusTilePosX = Math.round((x - (tileHeight * curZoom / 2)) / (tileHeight * curZoom))
      else
        focusTilePosY = (2 * (y - drawY) - x + drawX) / 2
        focusTilePosX = x + focusTilePosY - drawX - (tileHeight * curZoom)
        focusTilePosY = Math.round(focusTilePosY / (tileHeight * curZoom))
        focusTilePosX = Math.round(focusTilePosX / (tileHeight * curZoom))
      {
        x: focusTilePosX
        y: focusTilePosY
      }

    #Повесить элемент
    _setTile = (x, y, val) ->
      if !mapLayout[layoutLevel][x]
        mapLayout[layoutLevel][x] = []
      mapLayout[layoutLevel][x][y] = val
      return

    _setHeightmapTile = (x, y, val) ->
      heightMap[x][y] = val
      return

    _tileInView = (tileX, tileY) ->
      distanceLighting = Math.sqrt(Math.round(tileX - lightX) * Math.round(tileX - lightX) + Math.round(tileY - lightY) * Math.round(tileY - lightY))
      if lightMap
        lightDist = 0
        # Calculate which light source is closest
        light = 0
        while light < lightMap.length
          lightI = Math.round(tileX - (lightMap[light][0]))
          lightJ = Math.round(tileY - (lightMap[light][1]))
          lightDist = Math.sqrt(lightI * lightI + lightJ * lightJ)
          if distanceLighting / (shadowDistance.darkness * shadowDistance.distance) > lightDist / (light[2] * light[3])
            distanceLighting = lightDist
          light++
      if distanceLighting / (shadowDistance.darkness * shadowDistance.distance) > shadowDistance.darkness
        return false
      true

    _setParticlemapTile = (x, y, val) ->
      if !particleMap[x]
        particleMap[x] = []
      particleMap[x][y] = val
      return

    _setLightmap = (lightmapArray) ->
      lightMap = lightmapArray
      return

    _applyFocus = (xPos, yPos) ->
      focusTilePosX = xPos
      focusTilePosY = yPos
      return

    _align = (position, screenDimension, size, offset) ->
      switch position
        when 'h-center'
          if isometric
            drawX = screenDimension / 2 - (tileWidth / 4 * size * curZoom / (size / 2))
          else
            drawX = screenDimension / 2 - (tileWidth / 2 * size * curZoom)
        when 'v-center'
          drawY = screenDimension / 2 - (tileHeight / 2 * size * curZoom) - (offset * tileHeight * curZoom / 4)
      return

    _hideGraphics = (toggle, settings) ->
      tilesHide = toggle
      if settings
        hideSettings = settings
      return

    _applyHeightShadow = (toggle, settings) ->
      if toggle
        if settings or shadowSettings
          heightShadows = true
      else
        if settings or shadowSettings
          heightShadows = false
      if settings
        shadowSettings = settings
      return

    _flip = (setting) ->
      if stackTiles
        heightMap = utils.flipTwoDArray(heightMap, setting)
      if particleTiles
        # -- particleMap = utils.flipTwoDArray(particleMap, setting);
      else
      mapLayout = utils.flipTwoDArray(mapLayout, setting)
      return

    _rotate = (setting) ->
      if stackTiles
        heightMap = utils.rotateTwoDArray(heightMap, setting)
      if particleTiles
        # -- particleMap = utils.rotateTwoDArray(particleMap, setting);
      else
      mapLayout = utils.rotateTwoDArray(mapLayout, setting)
      return

    return {
      setup: (settings) ->
        _setup settings

      draw: (tileX, tileY) ->
        _draw tileX, tileY

      stackTiles: (heightTile) ->
        _stackTiles heightTile

      particleTiles: (map) ->
        _particleTiles map

      getLayout: ->
        _getLayout()

      setLayout: (data, width) ->
        _setLayout data, width

      getHeightLayout: ->
        _getHeightLayout()

      getTitle: ->
        title

      getTile: (tileX, tileY) ->
        Number _getTile(tileX, tileY)

      getHeightMapTile: (tileX, tileY) ->
        Number _getHeightMapTile(tileX, tileY)

      setTile: (tileX, tileY, val) ->
        _setTile tileX, tileY, val

      setHeightmapTile: (tileX, tileY, val) ->
        _setHeightmapTile tileX, tileY, val

      setZoom: (direction) ->
        # in || out
        _setZoom direction

      setLayoutLevel: (level) ->
        _setLayoutLevel level

      layoutLevelChange: (direction) ->
        # up || down
        if (layoutLevel < layoutHeight && direction == 'up')
          _layoutLevelChange direction
        else if (layoutLevel > 0 && direction == 'down')
          _layoutLevelChange direction

      getLayoutLevel: ->
        layoutLevel

      setLight: (tileX, tileY) ->
        _setLight tileX, tileY

      setLightmap: (lightmap) ->
        _setLightmap lightmap

      setParticlemapTile: (tileX, tileY, val) ->
        _setParticlemapTile tileX, tileY, val

      clearParticlemap: ->
        particleMap = []

      getXYCoords: (XPosition, YPosition) ->
        _getXYCoords XPosition, YPosition

      applyMouseFocus: (mouseXPosition, mouseYPosition) ->
        _applyMouseFocus mouseXPosition, mouseYPosition

      applyFocus: (tileX, tileY) ->
        _applyFocus tileX, tileY

      align: (position, screenDimension, size, offset) ->
        _align position, screenDimension, size, offset

      hideGraphics: (toggle, settings) ->
        _hideGraphics toggle, settings

      tileInView: (tileX, tileY) ->
        _tileInView tileX, tileY

      applyHeightShadow: (toggle, settings) ->
        _applyHeightShadow toggle, settings

      rotate: (direction) ->
        # left || right
        _rotate direction

      flip: (direction) ->
        # horizontal || vertical
        _flip direction

      toggleGraphicsHide: (toggle) ->
        if tilesHide != null
          _hideGraphics toggle

      toggleHeightShadow: (toggle) ->
        if heightShadows != null
          _applyHeightShadow toggle

      setLightness: (setting) ->
        shadowDistance.distance = setting

      adjustLightness: (setting, increase) ->
        _adjustLight setting, increase

      setOffset: (x, y) ->
        if x != null
          drawX = x
        if y != null
          drawY = y

      getTilePos: (x, y) ->
        _getTilePos x, y
      getOffset: ->
        {
          x: drawX
          y: drawY
        }
      getLightness: ->
        shadowDistance.distance

      move: (direction, distance) ->
        # left || right || up || down
        particle = undefined
        subPart = undefined
        distance = distance or tileHeight
#        console.log(curZoom)
        #smotret' tut
        if isometric
          if direction == 'up'
            drawY += distance / 2 * curZoom
            drawX += distance * curZoom
          else if direction == 'down'
            drawY += distance / 2 * curZoom
            drawX -= distance * curZoom
          else if direction == 'left'
            drawY -= distance / 2 * curZoom
            drawX -= distance * curZoom
          else if direction == 'right'
            drawY -= distance / 2 * curZoom
            drawX += distance * curZoom
        else
          #Это нас не интересует
          #TODO: убрать всё что не измотрика
          if direction == 'up'
            drawY += distance * curZoom
            # Offset moving for particle effect particles
            for particle of particleMapHolder
              `particle = particle`
              for subPart of particleMapHolder[particle]
                `subPart = subPart`
                particleMapHolder[particle][subPart].ShiftBy 0, distance * curZoom
          else if direction == 'down'
            drawY -= distance * curZoom
            # Offset moving for particle effect particles
            for particle of particleMapHolder
              `particle = particle`
              for subPart of particleMapHolder[particle]
                `subPart = subPart`
                particleMapHolder[particle][subPart].ShiftBy 0, -distance * curZoom
          else if direction == 'left'
            drawX += distance * curZoom
            # Offset moving for particle effect particles
            for particle of particleMapHolder
              `particle = particle`
              for subPart of particleMapHolder[particle]
                `subPart = subPart`
                particleMapHolder[particle][subPart].ShiftBy distance * curZoom, 0
          else if direction == 'right'
            drawX -= distance * curZoom
            # Offset moving for particle effect particles
            for particle of particleMapHolder
              `particle = particle`
              for subPart of particleMapHolder[particle]
                `subPart = subPart`
                particleMapHolder[particle][subPart].ShiftBy -distance * curZoom, 0

    }
