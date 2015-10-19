/*
- Author : Iain M Hamilton - <iain@beakable.com> - http://www.beakable.com
  Twitter: @beakable
*/
/** jsiso/utils simple common functions used throughout JsIso **/

define(function() {

  return {

    roundTo: function (num, dec) {
      return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
    },

    rand: function (l, u) {
      return Math.floor((Math.random() * (u - l + 1)) + l);
    },

    remove: function (from, to) {
      var rest = this.slice((to || from) + 1 || this.length);
      this.length = from < 0 ? this.length + from : from;
      return this.push.apply(this, rest);
    },

    range: function(from, to) {
      return {from: from, to: to};
    },

    flipTwoDArray: function(arrayLayout, direction) {
      var tempArray = [],
          tempLine = [],
          i, j;
      if (direction === "horizontal") {
        for (i = arrayLayout.length - 1 ; i >= 0; i--) {
           for (j = 0; j < arrayLayout[i].length; j++) {
            tempLine.push(arrayLayout[i][j]);
          }
          tempArray.push(tempLine);
          tempLine = [];
        }
        return tempArray;
      }
      else if (direction === "vertical") {
        for (i = 0; i < arrayLayout.length; i++) {
           for (j = arrayLayout[i].length - 1; j >= 0; j--) {
            tempLine.push(arrayLayout[i][j]);
          }
          tempArray.push(tempLine);
          tempLine = [];
        }
        return tempArray;
      }
    },

    rotateTwoDArray: function(arrayLayout, direction) {
      var tempArray = [],
          tempLine = [],
          i, j;
      var w = arrayLayout.length;
      var h = (arrayLayout[0] ? arrayLayout[0].length : 0);
      if (direction === "left") {
        for (i = 0; i < h; i++) {
          for (j = 0; j < w; j++) {
            if (!tempArray[i]) {
              tempArray[i] = [];
            }
            tempArray[i][j] = arrayLayout[w - j - 1][i];
          }
        }
        return tempArray;
      }
      else if (direction === "right") {
        for (i = 0; i < h; i++) {
          for (j = 0; j < w; j++) {
            if (!tempArray[i]) {
              tempArray[i] = [];
            }
            tempArray[i][j] = arrayLayout[j][h - i - 1];
          }
        }
        return tempArray;
      }
    },

    lineSplit: function(ctx, text, width) {
      var textLines = [];
      var elements = "";
      var line = "";
      var tempLine = "";
      var lastword = null;
      if(ctx.measureText(text).width > width) {
        elements = text.split(" ");
        for (var i = 0; i < elements.length; i++) {
          tempLine += elements[i] + " ";
          if (ctx.measureText(tempLine).width < width) {
            line += elements[i] + " ";
            lastword = elements[i];
          }
          else {
            if (lastword && lastword !== elements[i]) { // Prevent getitng locked in a large word
              i --;
              textLines.push(line);
            }
            else {
              textLines.push(tempLine);
            }
            line = "";
            tempLine = "";
          }
        }
      }
      else{
        textLines[0] = text;
      }
      if (line !== "") {
        textLines.push(line);
      }
      return textLines;
    }

  };

});