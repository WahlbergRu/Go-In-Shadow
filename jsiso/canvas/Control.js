//18.10.15 развёртка экрана


define(function() {

  // Private properties for Control

  var canvasElement = null;

  var width = null;
  var height = null;

  /**
   * Checks if browser supports the canvas context 2d
   * @return {Boolean}
   */
  function _supported () {
    var elem = document.createElement('canvas');
    return !!(elem.getContext && elem.getContext('2d'));
  }


  function _getRatio() {
    var ctx = document.createElement("canvas").getContext("2d"),
    dpr = window.devicePixelRatio || 1,
    bsr = ctx.webkitBackingStorePixelRatio ||
      ctx.mozBackingStorePixelRatio ||
      ctx.msBackingStorePixelRatio ||
      ctx.oBackingStorePixelRatio ||
      ctx.backingStorePixelRatio || 1;
    return dpr / bsr;
  }

   function _create(name, w, h, style, element, usePixelRatio) {
    var pxRatio = 1;
    var canvasType = null;
    if (_supported()) {
      if (usePixelRatio) {
        pxRatio = _getRatio();
      }
      width = w;
      height = h;
      canvasElement = document.createElement('canvas');
      canvasElement.id = name;
      canvasElement.tabindex = "1";
      for (var s in style) {
        canvasElement.style[s] = style[s];
      }
      canvasType = '2d';
      canvasElement.style.width = w + "px";
      canvasElement.style.height = h + "px";
      canvasElement.width = w * pxRatio || window.innerWidth;
      canvasElement.height = h * pxRatio || window.innerHeight;
      canvasElement.getContext(canvasType).setTransform(pxRatio, 0, 0, pxRatio, 0, 0);
      if (!element) {
        // Append Canvas into document body
        return document.body.appendChild(canvasElement).getContext(canvasType);
      }
      else {
        // Place canvas into passed through body element
        return document.getElementById(element).appendChild(canvasElement).getContext(canvasType);
      }
    }
    else {
      // Create an HTML element displaying that Canvas is not supported :(
      var noCanvas = document.createElement("div");
      noCanvas.style.color = "#FFF";
      noCanvas.style.textAlign = "center";
      noCanvas.innerHTML = "Sorry, you need to use a more modern browser. We like: <a href='https://www.google.com/intl/en/chrome/browser/'>Chrome</a> &amp; <a href='http://www.mozilla.org/en-US/firefox/new/'>Firefox</a>";
      return document.body.appendChild(noCanvas);
    }
  }

  function _style(setting, value) {
    canvasElement.style[setting] = value;
  }

  /**
  * Fullscreens the Canvas object
  */
  function _fullScreen() {
    document.body.style.margin = "0";
    document.body.style.padding = "0";
    document.body.style.overflow = "hidden";
    canvasElement.style.width = window.innerWidth + "px";
    canvasElement.style.height = window.innerHeight + "px";
    canvasElement.height = window.innerHeight;
    canvasElement.width = window.innerWidth;
    canvasElement.style.position = "absolute";
    canvasElement.style.zIndex = 100;
    
    window.onresize = function(e){
      _update(0, 0);
      //I think we need a repaint here.
    };
    window.top.scrollTo(0, 1);
  }


  /**
  * Update the Canvas object dimensions
  * @param {Number} width
  * @param {Number} height
  */
  function _update(w, h) {
    var pxRatio = 1;
    canvasElement.width = (w + "px") || window.innerWidth;
    canvasElement.height = (h + "px") || window.innerHeight;
    canvasElement.style.width = window.innerWidth + "px";
    canvasElement.style.height = window.innerHeight + "px";
    canvasElement.width = w * pxRatio || window.innerWidth;
    canvasElement.height = h * pxRatio || window.innerHeight;
  }


  /**
  * Return the created HTML Canvas element when it is called directly
  * @return {HTML} Canvas element
  */
  function canvas() {
    return canvasElement;
  }


  // ----
  // -- Public properties for Control
  // ----
  canvas.create = _create;
  canvas.fullScreen = _fullScreen;
  canvas.update = _update;
  canvas.style = _style;


  // Return Canvas Object
  return canvas;
});