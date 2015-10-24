
###*
* Loads an array of JSON response @paths
* @param  {Array} contains strings of the JSON response locations
* @return {Promise.<Array>}          Returns JOSN data in an array for using once fulfilled
###

class JsonLoader
  constructor: (@paths) ->
  
    ###*
    # Loads a single path that contains a JSON response
    # @param  {String} path JSON response location
    # @return {Promise.<Object>}      contains the loaded JSON
    ###
  
    _jsonPromise = (path) ->
      new Promise((resolve, reject) ->
        xmlhttp = new XMLHttpRequest
        xmlhttp.open 'GET', path, true
        xmlhttp.send()
  
        xmlhttp.onload = ->
          if xmlhttp.readyState == 4 and xmlhttp.status == 200
            resolve JSON.parse(xmlhttp.responseText)
          else
            reject()
          return
  
        return
      )
  
    if typeof @paths != 'string'
      promises = []
      i = 0
      while i < @paths.length
        promises.push _jsonPromise(@paths[i])
        i++
      return Promise.all promises
    else
      return _jsonPromise @paths
