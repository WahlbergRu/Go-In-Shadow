
define(function() {

  /**
  * Loads an array of images or an array of spritesheets for using within JsIso
  * @param  {Array} graphics an array of objects specifying the image locations and optional spritesheet settings
  * @return {Promise.<Array>}          Returns images in an array for using once fulfilled
  */
  /* Example:
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
  */

  return function(graphics) {

/**
 * Breaks up a solid image into smaller images via canvas and returns the individual sprite graphics and individual ones
 * @param  {Object} spritesheet contains the spritesheet image and required paramaters for measuring the individual image locations for cropping
 * @return {Promise.<Array>}             Returns seperated spritesheet images in array for using once fulfilled
 */

    function _splitSpriteSheet(spritesheet) {
      return new Promise(function(resolve, reject) {
        var loaded = 0; // Images total the preloader has loaded
        var loading = 0; // Images total the preloader needs to load
        
        var images = [];
        var ctx = document.createElement('canvas');
        var tileManip;
        var imageFilePathArray = [];
        var spriteID = (spritesheet.firstgid || 0);
        var tileRow;
        var tileCol;
        var spritesheetCols = Math.floor(spritesheet.files[spritesheet.dictionary[0]].width / (spritesheet.width));
        var spritesheetRows = Math.floor(spritesheet.files[spritesheet.dictionary[0]].height / (spritesheet.height));
        loading +=  spritesheetCols * spritesheetRows;
        ctx.width = spritesheet.width;
        ctx.height = spritesheet.height;
        tileManip = ctx.getContext('2d');
        for (var i = 0; i < spritesheetRows; i++) {
          for (var j = 0; j < spritesheetCols; j++) {
            tileManip.drawImage(spritesheet.files[spritesheet.dictionary[0]], j * (spritesheet.width + spritesheet.offsetX  + spritesheet.spacing) + spritesheet.spacing, i * (spritesheet.height + spritesheet.offsetY + spritesheet.spacing) + spritesheet.spacing,  spritesheet.width + spritesheet.offsetX - spritesheet.spacing, spritesheet.height  + spritesheet.offsetY - spritesheet.spacing, 0, 0, spritesheet.width, spritesheet.height);
            imageFilePathArray[spriteID] = spriteID;
            images[spriteID] = new Image();
            images[spriteID].src = ctx.toDataURL();
            tileManip.clearRect (0, 0, spritesheet.width, spritesheet.height);
            images[spriteID].onload = function () {
              loaded ++;
              if (loaded === loading) {
                resolve({files: images, dictionary: imageFilePathArray});
              }
            };
            spriteID ++;
          }
        }
      });
    }

    /**
     * Takes an individual set of graphics whether a singular image, an array of images, or spritesheet and loads it for using within JsIso
     * @param  {Object} graphic a single graphic set with the optional spritesheet paramaters for preloading
     * @return {Promite.<Array>}         Contains the loaded images for use
     */
    function _imgPromise(graphic) {
      return new Promise(function(resolve, reject) {

        var loaded = 0; // Images total the preloader has loaded
        var loading = 0; // Images total the preloader needs to load

        var images = [];
        loading += graphic.graphics.length;
       
        graphic.graphics.map(function(img) {
          imgName = img;
          if (graphic.removePath === undefined || graphic.removePath === true) {
            imgName = img.split("/").pop();
          }
          images[imgName] = new Image();
          images[imgName].src = img;
          images[imgName].onload = function() {
            loaded ++;
            if (loaded === loading && !graphic.spritesheet) {
              resolve({files: images, dictionary: graphic.graphics});
            }
            else {
              if (graphic.spritesheet) {
                _splitSpriteSheet({
                  files: images,
                  dictionary: graphic.graphics,
                  width: graphic.spritesheet.width,
                  height: graphic.spritesheet.height,
                  offsetX: (graphic.spritesheet.offsetX || 0),
                  offsetY: (graphic.spritesheet.offsetY || 0),
                  spacing: (graphic.spritesheet.spacing || 0),
                  firstgid: (graphic.spritesheet.firstgid || 0)
                }).then(function(response) {
                  resolve(response);
                });
              }
            }
          };
        });
        if (graphic.removePath === undefined || graphic.removePath === true) {
          for (var i = 0; i < graphic.graphics.length; i++) {
            graphic.graphics[i] = graphic.graphics[i].split("/").pop();
          }
        }
      });
    }

    if (Object.prototype.toString.call(graphics) === '[object Array]') {
      var promises = [];
      for (var i = 0; i < graphics.length; i++) {
        promises.push(_imgPromise(graphics[i]));
      }
      return Promise.all(promises);
    }
    else {
      return _imgPromise(graphics);
    }

  };
});