// Generated by CoffeeScript 1.10.0
(function() {
  define(function() {

    /**
    * Loads an array of JSON response paths
    * @param  {Array} contains strings of the JSON response locations
    * @return {Promise.<Array>}          Returns JOSN data in an array for using once fulfilled
     */
    return function(paths) {

      /**
       * Loads a single path that contains a JSON response
       * @param  {String} path JSON response location
       * @return {Promise.<Object>}      contains the loaded JSON
       */
      var _jsonPromise, i, promises;
      _jsonPromise = function(path) {
        return new Promise(function(resolve, reject) {
          var xmlhttp;
          xmlhttp = new XMLHttpRequest;
          xmlhttp.open('GET', path, true);
          xmlhttp.send();
          xmlhttp.onload = function() {
            if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
              resolve(JSON.parse(xmlhttp.responseText));
            } else {
              reject();
            }
          };
        });
      };
      if (typeof paths !== 'string') {
        promises = [];
        i = 0;
        while (i < paths.length) {
          promises.push(_jsonPromise(paths[i]));
          i++;
        }
        return Promise.all(promises);
      } else {
        return _jsonPromise(paths);
      }
    };
  });

}).call(this);

//# sourceMappingURL=load.js.map
