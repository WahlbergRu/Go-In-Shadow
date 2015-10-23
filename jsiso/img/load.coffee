define ->

  ###*
  * Loads an array of images or an array of spritesheets for using within JsIso
  * @param  {Array} graphics an array of objects specifying the image locations and optional spritesheet settings
  * @return {Promise.<Array>}          Returns images in an array for using once fulfilled
  ###

  ### Example:
  [{
    graphics: ["img/sground.png"],
    spritesheet: { // OPTIONAL spritesheet is optional for images to be auto split up
      width: 24, 
      height: 24, 
      offsetX: 0, // OPTIONAL
      offsetY: 0, // OPTIONAL
      spacing: 0, // OPTIONAL
      firstgid: 0 // OPTIONAL
    }
  }]
  ###

  (graphics) ->

    ###*
    # Breaks up a solid image into smaller images via canvas and returns the individual sprite graphics and individual ones
    # @param  {Object} spritesheet contains the spritesheet image and required paramaters for measuring the individual image locations for cropping
    # @return {Promise.<Array>}             Returns seperated spritesheet images in array for using once fulfilled
    ###

    _splitSpriteSheet = (spritesheet) ->
      new Promise((resolve, reject) ->
        loaded = 0
        # Images total the preloader has loaded
        loading = 0
        # Images total the preloader needs to load
        images = []
        ctx = document.createElement('canvas')
        tileManip = undefined
        imageFilePathArray = []
        spriteID = spritesheet.firstgid or 0
        tileRow = undefined
        tileCol = undefined
        spritesheetCols = Math.floor(spritesheet.files[spritesheet.dictionary[0]].width / spritesheet.width)
        spritesheetRows = Math.floor(spritesheet.files[spritesheet.dictionary[0]].height / spritesheet.height)
        loading += spritesheetCols * spritesheetRows
        ctx.width = spritesheet.width
        ctx.height = spritesheet.height
        tileManip = ctx.getContext('2d')
        i = 0
        while i < spritesheetRows
          j = 0
          while j < spritesheetCols
            tileManip.drawImage spritesheet.files[spritesheet.dictionary[0]], j * (spritesheet.width + spritesheet.offsetX + spritesheet.spacing) + spritesheet.spacing, i * (spritesheet.height + spritesheet.offsetY + spritesheet.spacing) + spritesheet.spacing, spritesheet.width + spritesheet.offsetX - (spritesheet.spacing), spritesheet.height + spritesheet.offsetY - (spritesheet.spacing), 0, 0, spritesheet.width, spritesheet.height
            imageFilePathArray[spriteID] = spriteID
            images[spriteID] = new Image
            images[spriteID].src = ctx.toDataURL()
            tileManip.clearRect 0, 0, spritesheet.width, spritesheet.height

            images[spriteID].onload = ->
              loaded++
              if loaded == loading
                resolve
                  files: images
                  dictionary: imageFilePathArray

            spriteID++
            j++
          i++
        return
      )
    ###*
    # Takes an individual set of graphics whether a singular image, an array of images, or spritesheet and loads it for using within JsIso
    # @param  {Object} graphic a single graphic set with the optional spritesheet paramaters for preloading
    # @return {Promite.<Array>}         Contains the loaded images for use
    ###

    _imgPromise = (graphic) ->
      new Promise((resolve, reject) ->
        loaded = 0
        # Images total the preloader has loaded
        loading = 0
        # Images total the preloader needs to load
        images = []
        loading += graphic.graphics.length
        graphic.graphics.map (img) ->
          imgName = img
          if graphic.removePath == undefined or graphic.removePath == true
            imgName = img.split('/').pop()
          images[imgName] = new Image
          images[imgName].src = img

          images[imgName].onload = ->
            loaded++
            if loaded == loading and !graphic.spritesheet
              resolve
                files: images
                dictionary: graphic.graphics
            else
              if graphic.spritesheet
                _splitSpriteSheet(
                  files: images
                  dictionary: graphic.graphics
                  width: graphic.spritesheet.width
                  height: graphic.spritesheet.height
                  offsetX: graphic.spritesheet.offsetX or 0
                  offsetY: graphic.spritesheet.offsetY or 0
                  spacing: graphic.spritesheet.spacing or 0
                  firstgid: graphic.spritesheet.firstgid or 0
                ).then (response) ->
                  resolve response
        if graphic.removePath == undefined or graphic.removePath == true
          i = 0
          while i < graphic.graphics.length
            graphic.graphics[i] = graphic.graphics[i].split('/').pop()
            i++
      )

    if Object::toString.call(graphics) == '[object Array]'
      promises = []
      i = 0
      while i < graphics.length
        promises.push _imgPromise(graphics[i])
        i++
      Promise.all promises
    else
      _imgPromise(graphics)