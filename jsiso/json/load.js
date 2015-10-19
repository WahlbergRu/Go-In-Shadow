define(function() {

  /**
  * Loads an array of JSON response paths
  * @param  {Array} contains strings of the JSON response locations
  * @return {Promise.<Array>}          Returns JOSN data in an array for using once fulfilled
  */
  return function (paths) {


/**
 * Loads a single path that contains a JSON response
 * @param  {String} path JSON response location
 * @return {Promise.<Object>}      contains the loaded JSON
 */
    function _jsonPromise(path) {
       return new Promise(function(resolve, reject) {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open("GET", path, true);
        xmlhttp.send();
        xmlhttp.onload = function() {
          if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
            resolve(JSON.parse(xmlhttp.responseText));
          }
          else {
            reject();
          }
        };
      });
    }

    if (typeof paths !== "string") {
      var promises = [];
      for (var i = 0; i < paths.length; i++) {
        promises.push(_jsonPromise(paths[i]));
      }
      return Promise.all(promises);
    }
    else {
      return _jsonPromise(paths);
    }
  };
});